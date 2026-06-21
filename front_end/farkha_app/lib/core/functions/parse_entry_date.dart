/// Parses an entry date that may arrive in ISO format (`yyyy-MM-dd`) from local
/// storage, or in slash format (`yyyy/MM/dd`) produced by `parseDateToString`
/// when loaded from the server.
///
/// `DateTime.tryParse` only accepts ISO 8601 (dashes), so the slash variant
/// previously failed and fell back to `DateTime.now()`, making all
/// server-loaded entries appear with today's date. This handles both.
DateTime parseEntryDate(Object? value) {
  final s = (value ?? '').toString();
  return DateTime.tryParse(s) ??
      DateTime.tryParse(s.replaceAll('/', '-')) ??
      DateTime.now();
}
