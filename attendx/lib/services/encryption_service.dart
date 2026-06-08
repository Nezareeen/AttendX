import 'package:encrypt/encrypt.dart';
import 'package:attendx/env/env.dart';

class EncryptionService {
  static final String _keyString = Env.chatEncryptionKey.isNotEmpty ? Env.chatEncryptionKey : 'w9z\$C&F)J@NcRfUjXn2r5u8x/A?D*G-K'; // Fallback for dev just in case
  static final Key _key = Key.fromUtf8(_keyString);
  // We use a fixed IV or random IV. For AES-CBC, random IV is recommended.
  // But wait, if we use a random IV, we need to prepend it to the ciphertext.
  // Let's prepend the IV to the encrypted text so we can decrypt it later.

  static String encryptMessage(String plainText) {
    if (plainText.isEmpty) return plainText;
    try {
      final iv = IV.fromSecureRandom(16);
      final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      return '${iv.base64}:${encrypted.base64}';
    } catch (e) {
      // Return original if encryption fails for some reason
      return plainText;
    }
  }

  static String decryptMessage(String encryptedText) {
    if (encryptedText.isEmpty) return encryptedText;
    try {
      final parts = encryptedText.split(':');
      if (parts.length == 2) {
        final iv = IV.fromBase64(parts[0]);
        final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
        return encrypter.decrypt64(parts[1], iv: iv);
      }
      // If it doesn't match the pattern, it might be an unencrypted legacy message
      return encryptedText;
    } catch (e) {
      // Fallback for unencrypted legacy messages
      return encryptedText;
    }
  }
}
