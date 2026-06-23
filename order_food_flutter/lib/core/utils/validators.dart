class Validators {
  Validators._();

  static bool isEmail(String value) =>
      RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value.trim());

  static bool isNotEmpty(String value) => value.trim().isNotEmpty;

  static bool isPositiveNumber(String value) {
    final number = num.tryParse(value.trim());
    return number != null && number > 0;
  }
}
