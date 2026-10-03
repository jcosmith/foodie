// Generates the app's launcher icons from one picture (issue #22).
//
// Usage: dart run tool/generate_app_icon.dart
//
// Reads apps/freezer_app/app_icon/app_icon_source.jpg and writes:
// - Android: mipmap-*/ic_launcher.png (legacy square icons, 48 to 192 px)
//   and, for Android 8 and later, an adaptive icon whose foreground is the
//   picture, its subject inside the circle every launcher mask leaves
//   visible, on a background of the picture's own edge colour
//   (mipmap-anydpi-v26, values/ic_launcher_background);
// - iOS: every size listed in AppIcon.appiconset/Contents.json, without
//   transparency as the App Store requires.
//
// The picture is cropped to its subject by trimming a plain border, placed
// in the middle of a square of the border's colour, and scaled with an
// averaging filter, so any reasonably large picture works.
// Run it again after replacing the source picture; the outputs are committed.
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as image_codec;
import 'package:path/path.dart' as path;

const String _applicationDirectory = 'apps/freezer_app';
const String _sourcePath = '$_applicationDirectory/app_icon/app_icon_source.jpg';
const String _androidResourceDirectory = '$_applicationDirectory/android/app/src/main/res';
const String _iosIconSetDirectory =
    '$_applicationDirectory/ios/Runner/Assets.xcassets/AppIcon.appiconset';

/// Pixels per density-independent pixel for each Android density bucket.
const Map<String, double> _androidDensityScales = {
  'mdpi': 1,
  'hdpi': 1.5,
  'xhdpi': 2,
  'xxhdpi': 3,
  'xxxhdpi': 4,
};

/// A legacy launcher icon is 48 dp; an adaptive icon layer is 108 dp, of
/// which launchers show at most the central 72 dp, and always at least a
/// circle of 66 dp in the middle.
const int _legacyIconSizeInDp = 48;
const int _adaptiveLayerSizeInDp = 108;
const int _adaptiveVisibleSizeInDp = 72;
const int _adaptiveSafeCircleDiameterInDp = 66;

/// Colour channels may differ this much and still count as the same plain
/// border colour.
const int _borderColourTolerance = 24;

/// Space kept free around the subject on each side, as a share of its
/// longer side.
const double _marginShare = 0.06;

void main() {
  final sourceFile = File(_sourcePath);
  if (!sourceFile.existsSync()) {
    stderr.writeln('Put the icon picture at $_sourcePath first.');
    exitCode = 66;
    return;
  }
  final decodedSource = image_codec.decodeImage(sourceFile.readAsBytesSync());
  if (decodedSource == null) {
    stderr.writeln('$_sourcePath is no picture this tool can read.');
    exitCode = 65;
    return;
  }

  final upright = image_codec.bakeOrientation(decodedSource).convert(numChannels: 4);
  final edgeColour = _averageEdgeColour(upright);
  final subject = _trimPlainBorder(upright, edgeColour);
  final square = _padToSquare(subject, edgeColour);
  // How far the subject's corners reach from the middle of the square, as a
  // share of the square's edge, so that round launcher masks can spare them.
  final subjectDiagonalShare =
      sqrt(subject.width * subject.width + subject.height * subject.height) / square.width;
  stdout.writeln(
    'Source ${decodedSource.width}×${decodedSource.height}, '
    'icon square ${square.width}×${square.height}, '
    'edge colour #${_hexOf(edgeColour)}',
  );

  _writeAndroidIcons(square, edgeColour, subjectDiagonalShare: subjectDiagonalShare);
  _writeIosIcons(square, edgeColour);
  stdout.writeln('App icons written.');
}

void _writeAndroidIcons(
  image_codec.Image square,
  image_codec.Color backgroundColour, {
  required double subjectDiagonalShare,
}) {
  // The picture is as large as it can be while the whole subject stays inside
  // the safe circle that every launcher mask shape leaves visible.
  final adaptivePictureSizeInDp = min(
    _adaptiveVisibleSizeInDp.toDouble(),
    _adaptiveSafeCircleDiameterInDp / subjectDiagonalShare,
  );
  for (final MapEntry(key: density, value: scale) in _androidDensityScales.entries) {
    final directory = Directory(path.join(_androidResourceDirectory, 'mipmap-$density'))
      ..createSync(recursive: true);

    final legacySize = (_legacyIconSizeInDp * scale).round();
    _writePng(
      path.join(directory.path, 'ic_launcher.png'),
      _flatten(_resize(square, legacySize), backgroundColour),
    );

    final layerSize = (_adaptiveLayerSizeInDp * scale).round();
    final pictureSize = (adaptivePictureSizeInDp * scale).round();
    final foreground = image_codec.Image(width: layerSize, height: layerSize, numChannels: 4);
    image_codec.compositeImage(
      foreground,
      _resize(square, pictureSize),
      dstX: (layerSize - pictureSize) ~/ 2,
      dstY: (layerSize - pictureSize) ~/ 2,
      blend: image_codec.BlendMode.direct,
    );
    _writePng(path.join(directory.path, 'ic_launcher_foreground.png'), foreground);
  }

  final adaptiveDirectory = Directory(path.join(_androidResourceDirectory, 'mipmap-anydpi-v26'))
    ..createSync(recursive: true);
  File(path.join(adaptiveDirectory.path, 'ic_launcher.xml')).writeAsStringSync('''
<?xml version="1.0" encoding="utf-8"?>
<!-- Generated by tool/generate_app_icon.dart. -->
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background" />
    <foreground android:drawable="@mipmap/ic_launcher_foreground" />
</adaptive-icon>
''');
  File(
    path.join(_androidResourceDirectory, 'values', 'ic_launcher_background.xml'),
  ).writeAsStringSync('''
<?xml version="1.0" encoding="utf-8"?>
<!-- Generated by tool/generate_app_icon.dart: the edge colour of the icon picture. -->
<resources>
    <color name="ic_launcher_background">#${_hexOf(backgroundColour)}</color>
</resources>
''');
}

void _writeIosIcons(image_codec.Image square, image_codec.Color backgroundColour) {
  final contents =
      jsonDecode(File(path.join(_iosIconSetDirectory, 'Contents.json')).readAsStringSync())
          as Map<String, Object?>;
  for (final entry in (contents['images']! as List).cast<Map<String, Object?>>()) {
    final pointSize = double.parse((entry['size']! as String).split('x').first);
    final scale = double.parse((entry['scale']! as String).replaceAll('x', ''));
    final pixelSize = (pointSize * scale).round();
    _writePng(
      path.join(_iosIconSetDirectory, entry['filename']! as String),
      // iOS icons must not be transparent.
      _flatten(_resize(square, pixelSize), backgroundColour, keepAlpha: false),
    );
  }
}

/// The mean colour of the outermost pixel ring.
image_codec.Color _averageEdgeColour(image_codec.Image picture) {
  var red = 0.0, green = 0.0, blue = 0.0, count = 0;
  void add(int x, int y) {
    final pixel = picture.getPixel(x, y);
    // Transparent edges count as white, the usual icon background.
    final opacity = pixel.a / 255;
    red += pixel.r * opacity + 255 * (1 - opacity);
    green += pixel.g * opacity + 255 * (1 - opacity);
    blue += pixel.b * opacity + 255 * (1 - opacity);
    count++;
  }

  for (var x = 0; x < picture.width; x++) {
    add(x, 0);
    add(x, picture.height - 1);
  }
  for (var y = 1; y < picture.height - 1; y++) {
    add(0, y);
    add(picture.width - 1, y);
  }
  return image_codec.ColorRgb8(
    (red / count).round(),
    (green / count).round(),
    (blue / count).round(),
  );
}

/// Cuts away rows and columns at the edges that are all [borderColour] (or
/// transparent), such as the margin of a screenshot.
image_codec.Image _trimPlainBorder(image_codec.Image picture, image_codec.Color borderColour) {
  bool isBorder(int x, int y) {
    final pixel = picture.getPixel(x, y);
    if (pixel.a < 16) return true;
    return (pixel.r - borderColour.r).abs() <= _borderColourTolerance &&
        (pixel.g - borderColour.g).abs() <= _borderColourTolerance &&
        (pixel.b - borderColour.b).abs() <= _borderColourTolerance;
  }

  bool isBorderRow(int y) =>
      [for (var x = 0; x < picture.width; x++) x].every((x) => isBorder(x, y));
  bool isBorderColumn(int x, int top, int bottom) =>
      [for (var y = top; y <= bottom; y++) y].every((y) => isBorder(x, y));

  var top = 0, bottom = picture.height - 1;
  while (top < bottom && isBorderRow(top)) {
    top++;
  }
  while (bottom > top && isBorderRow(bottom)) {
    bottom--;
  }
  var left = 0, right = picture.width - 1;
  while (left < right && isBorderColumn(left, top, bottom)) {
    left++;
  }
  while (right > left && isBorderColumn(right, top, bottom)) {
    right--;
  }
  // A picture that is all border, or nearly, is used as it is.
  if (right - left < picture.width / 4 || bottom - top < picture.height / 4) return picture;
  return image_codec.copyCrop(
    picture,
    x: left,
    y: top,
    width: right - left + 1,
    height: bottom - top + 1,
  );
}

/// The picture centred on a square of [backgroundColour] with a margin of
/// [_marginShare] on every side, so nothing of the subject is cut off.
image_codec.Image _padToSquare(image_codec.Image picture, image_codec.Color backgroundColour) {
  final edge = (max(picture.width, picture.height) * (1 + 2 * _marginShare)).round();
  final square = image_codec.Image(width: edge, height: edge, numChannels: 4);
  image_codec.fill(square, color: backgroundColour);
  image_codec.compositeImage(
    square,
    picture,
    dstX: (edge - picture.width) ~/ 2,
    dstY: (edge - picture.height) ~/ 2,
  );
  return square;
}

image_codec.Image _resize(image_codec.Image square, int size) => image_codec.copyResize(
  square,
  width: size,
  height: size,
  interpolation: size < square.width
      ? image_codec.Interpolation.average
      : image_codec.Interpolation.cubic,
);

/// The picture over [backgroundColour], so transparent parts are filled.
image_codec.Image _flatten(
  image_codec.Image picture,
  image_codec.Color backgroundColour, {
  bool keepAlpha = true,
}) {
  final flattened = image_codec.Image(
    width: picture.width,
    height: picture.height,
    numChannels: keepAlpha ? 4 : 3,
  );
  image_codec.fill(flattened, color: backgroundColour);
  image_codec.compositeImage(flattened, picture);
  return flattened;
}

void _writePng(String filePath, image_codec.Image picture) =>
    File(filePath).writeAsBytesSync(image_codec.encodePng(picture));

String _hexOf(image_codec.Color colour) => [
  colour.r,
  colour.g,
  colour.b,
].map((channel) => channel.toInt().toRadixString(16).padLeft(2, '0')).join().toUpperCase();
