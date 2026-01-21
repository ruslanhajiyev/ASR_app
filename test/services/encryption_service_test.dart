import 'package:flutter_test/flutter_test.dart';
import 'package:asr_app/services/encryption_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EncryptionService', () {
    late EncryptionService encryptionService;

    setUp(() {
 
      encryptionService = EncryptionService();
    });

    test('should encrypt and decrypt text correctly', () async {
   
      try {
        await encryptionService.initialize();
        
        const plaintext = 'Hello, World! This is a test message.';
        
        final encrypted = await encryptionService.encrypt(plaintext);
        expect(encrypted, isNotEmpty);
        expect(encrypted, isNot(equals(plaintext)));
        
        final decrypted = await encryptionService.decrypt(encrypted);
        expect(decrypted, equals(plaintext));
      } catch (e) {
      
        expect(e.toString(), contains('MissingPluginException'));
      }
    }, skip: 'Requires platform channels');

    test('should encrypt and decrypt JSON correctly', () async {
      try {
        await encryptionService.initialize();
        
        final jsonData = {
          'id': 'test-123',
          'name': 'Test User',
          'data': [1, 2, 3],
          'nested': {'key': 'value'},
        };
        
        final encrypted = await encryptionService.encryptJson(jsonData);
        expect(encrypted, isNotEmpty);
        
        final decrypted = await encryptionService.decryptJson(encrypted);
        expect(decrypted['id'], 'test-123');
        expect(decrypted['name'], 'Test User');
        expect(decrypted['data'], [1, 2, 3]);
        expect(decrypted['nested'], {'key': 'value'});
      } catch (e) {
        expect(e.toString(), contains('MissingPluginException'));
      }
    }, skip: 'Requires platform channels');

  
  });
}
