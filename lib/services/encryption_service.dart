import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  static const String _keyStorageKey = 'encryption_key';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  Key? _encryptionKey;
  IV? _iv;

  Future<void> initialize() async {
    try {
      final keyString = await _secureStorage.read(key: _keyStorageKey);
      
      if (keyString != null) {
        _encryptionKey = Key.fromBase64(keyString);
      } else {
        final key = Key.fromSecureRandom(32); 
        await _secureStorage.write(
          key: _keyStorageKey,
          value: key.base64,
        );
        _encryptionKey = key;
      }

      final ivBytes = sha256.convert(utf8.encode('asr_app_iv')).bytes.take(16).toList();
      _iv = IV(Uint8List.fromList(ivBytes));
    } catch (e) {
      throw Exception('Failed to initialize encryption: $e');
    }
  }

  Future<String> encrypt(String plaintext) async {
    if (_encryptionKey == null || _iv == null) {
      await initialize();
    }

    try {
      final encrypter = Encrypter(AES(_encryptionKey!));
      final encrypted = encrypter.encrypt(plaintext, iv: _iv!);
      return encrypted.base64;
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  Future<String> decrypt(String ciphertext) async {
    if (_encryptionKey == null || _iv == null) {
      await initialize();
    }

    try {
      final encrypter = Encrypter(AES(_encryptionKey!));
      final encrypted = Encrypted.fromBase64(ciphertext);
      return encrypter.decrypt(encrypted, iv: _iv!);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  Future<String> encryptJson(Map<String, dynamic> data) async {
    final jsonString = json.encode(data);
    return await encrypt(jsonString);
  }

  Future<Map<String, dynamic>> decryptJson(String encryptedData) async {
    final jsonString = await decrypt(encryptedData);
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  Future<void> clearKey() async {
    await _secureStorage.delete(key: _keyStorageKey);
    _encryptionKey = null;
    _iv = null;
  }
}
