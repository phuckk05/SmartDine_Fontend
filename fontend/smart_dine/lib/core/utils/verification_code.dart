import 'dart:math';

/// Generates a numeric verification code with the given [length].
/// Defaults to 6 digits and uses a cryptographically secure random source
/// when available.
String generateVerificationCode({int length = 6}) {
  if (length <= 0) {
    throw ArgumentError.value(length, 'length', 'must be greater than zero');
  }
  const digits = '0123456789';
  final random = _buildRandom();
  return List.generate(
    length,
    (_) => digits[random.nextInt(digits.length)],
  ).join();
}

Random _buildRandom() {
  try {
    return Random.secure();
  } catch (_) {
    return Random();
  }
}
