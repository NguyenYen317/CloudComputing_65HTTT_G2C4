class CurrencyFormatter {
  CurrencyFormatter._();

  static String vnd(int value) {
    final negative = value < 0;
    final raw = value.abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final position = raw.length - i;
      buffer.write(raw[i]);
      if (position > 1 && position % 3 == 1) buffer.write('.');
    }
    return '${negative ? '-' : ''}$bufferđ';
  }
}
