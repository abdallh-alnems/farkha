String? validateChickInput(String input) {
  final int? chickens = int.tryParse(input);
  if (chickens == null || chickens <= 0) {
    return 'يرجى إدخال قيم صحيحة';
  }
  return null;
}
