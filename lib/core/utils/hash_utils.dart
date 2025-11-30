import 'dart:convert';
import 'package:crypto/crypto.dart';

class HashUtils {
  /// Creates a SHA-256 hash of the given input string
  /// Returns a 64 character hex string
  static String hashSha256(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Validates if a given hash matches the expected hash of the input
  static bool validateHash(String input, String expectedHash) {
    final inputHash = hashSha256(input);
    return inputHash == expectedHash;
  }
}

