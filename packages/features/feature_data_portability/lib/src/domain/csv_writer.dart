/// Writes comma-separated values as RFC 4180 describes: fields with commas,
/// quotes or line breaks are quoted, quotes are doubled, lines end in CRLF.
/// A byte order mark lets spreadsheet apps detect UTF-8.
abstract final class CsvWriter {
  static const String _byteOrderMark = '﻿';

  static String write(List<String> header, Iterable<List<String>> rows) {
    final buffer = StringBuffer(_byteOrderMark)..write(_line(header));
    for (final row in rows) {
      buffer.write(_line(row));
    }
    return buffer.toString();
  }

  static String _line(List<String> fields) => '${fields.map(_field).join(',')}\r\n';

  static String _field(String value) {
    final needsQuotes =
        value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r') ||
        value.startsWith(' ') ||
        value.endsWith(' ');
    return needsQuotes ? '"${value.replaceAll('"', '""')}"' : value;
  }
}
