bool isLowerThan(String a, String b) {
  final aParts = _parse(a);
  final bParts = _parse(b);
  final length = aParts.length > bParts.length ? aParts.length : bParts.length;

  for (var i = 0; i < length; i++) {
    final av = i < aParts.length ? aParts[i] : 0;
    final bv = i < bParts.length ? bParts[i] : 0;
    if (av < bv) return true;
    if (av > bv) return false;
  }
  return false;
}

List<int> _parse(String version) {
  final clean = version.split('+').first.split('-').first;
  return clean.split('.').map((p) => int.tryParse(p) ?? 0).toList();
}
