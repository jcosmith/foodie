import 'package:meta/meta.dart';

/// Turns a preference value into stored text and back.
abstract interface class PreferenceValueCodec<TValue> {
  /// Returns `null` to remove the stored entry, so the default applies again.
  String? encode(TValue value);

  /// Throws [FormatException] for text it cannot read.
  TValue decode(String encodedValue);
}

/// A typed, namespaced setting such as `configuration.theme_choice`.
///
/// Each module declares its keys as constants and namespaces them with its
/// module identifier, so modules never overwrite each other's settings.
@immutable
final class PreferenceKey<TValue> {
  const PreferenceKey({
    required this.moduleNamespace,
    required this.name,
    required this.defaultValue,
    required this.codec,
  });

  static PreferenceKey<bool> boolean({
    required String moduleNamespace,
    required String name,
    required bool defaultValue,
  }) => PreferenceKey(
    moduleNamespace: moduleNamespace,
    name: name,
    defaultValue: defaultValue,
    codec: const BooleanPreferenceCodec(),
  );

  static PreferenceKey<int> integer({
    required String moduleNamespace,
    required String name,
    required int defaultValue,
  }) => PreferenceKey(
    moduleNamespace: moduleNamespace,
    name: name,
    defaultValue: defaultValue,
    codec: const IntegerPreferenceCodec(),
  );

  static PreferenceKey<String> text({
    required String moduleNamespace,
    required String name,
    required String defaultValue,
  }) => PreferenceKey(
    moduleNamespace: moduleNamespace,
    name: name,
    defaultValue: defaultValue,
    codec: const TextPreferenceCodec(),
  );

  static PreferenceKey<TEnum> enumeration<TEnum extends Enum>({
    required String moduleNamespace,
    required String name,
    required TEnum defaultValue,
    required List<TEnum> values,
  }) => PreferenceKey(
    moduleNamespace: moduleNamespace,
    name: name,
    defaultValue: defaultValue,
    codec: EnumerationPreferenceCodec(values),
  );

  /// A point in time that may be absent, such as "last backup".
  static PreferenceKey<DateTime?> optionalInstant({
    required String moduleNamespace,
    required String name,
  }) => PreferenceKey(
    moduleNamespace: moduleNamespace,
    name: name,
    defaultValue: null,
    codec: const OptionalInstantPreferenceCodec(),
  );

  final String moduleNamespace;
  final String name;
  final TValue defaultValue;
  final PreferenceValueCodec<TValue> codec;

  /// The key under which the value is stored.
  String get storageKey => '$moduleNamespace.$name';

  @override
  bool operator ==(Object other) =>
      other is PreferenceKey<TValue> && other.storageKey == storageKey;

  @override
  int get hashCode => storageKey.hashCode;

  @override
  String toString() => 'PreferenceKey($storageKey)';
}

final class BooleanPreferenceCodec implements PreferenceValueCodec<bool> {
  const BooleanPreferenceCodec();

  @override
  String encode(bool value) => value ? 'true' : 'false';

  @override
  bool decode(String encodedValue) => switch (encodedValue) {
    'true' => true,
    'false' => false,
    _ => throw FormatException('Not a boolean', encodedValue),
  };
}

final class IntegerPreferenceCodec implements PreferenceValueCodec<int> {
  const IntegerPreferenceCodec();

  @override
  String encode(int value) => value.toString();

  @override
  int decode(String encodedValue) => int.parse(encodedValue);
}

final class TextPreferenceCodec implements PreferenceValueCodec<String> {
  const TextPreferenceCodec();

  @override
  String encode(String value) => value;

  @override
  String decode(String encodedValue) => encodedValue;
}

/// Stores the enum value's name, so reordering the enum never changes stored data.
final class EnumerationPreferenceCodec<TEnum extends Enum> implements PreferenceValueCodec<TEnum> {
  const EnumerationPreferenceCodec(this.values);

  final List<TEnum> values;

  @override
  String encode(TEnum value) => value.name;

  @override
  TEnum decode(String encodedValue) => values.firstWhere(
    (value) => value.name == encodedValue,
    orElse: () => throw FormatException('Unknown value', encodedValue),
  );
}

final class OptionalInstantPreferenceCodec implements PreferenceValueCodec<DateTime?> {
  const OptionalInstantPreferenceCodec();

  @override
  String? encode(DateTime? value) => value?.toUtc().toIso8601String();

  @override
  DateTime? decode(String encodedValue) => DateTime.parse(encodedValue).toUtc();
}
