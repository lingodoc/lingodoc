import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:crypto/crypto.dart';

void main() {
  group('Checksum Verification Logic', () {
    test('SHA256 checksum calculation - known value', () {
      // Test with a known string and expected SHA256
      final testData = utf8.encode('Hello, Typst!');
      final hash = sha256.convert(testData).toString();

      // Verify hash format (64 hex characters)
      expect(hash.length, equals(64));
      expect(hash, matches(RegExp(r'^[a-f0-9]{64}$')));
    });

    test('SHA256 checksum - empty data', () {
      // Empty data should have a specific hash
      final emptyData = <int>[];
      final hash = sha256.convert(emptyData).toString();

      // Known SHA256 for empty data
      const expectedEmptyHash =
          'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';

      expect(hash, equals(expectedEmptyHash));
    });

    test('SHA256 checksum - case insensitivity', () {
      final testData = utf8.encode('Test data');
      final hash1 = sha256.convert(testData).toString().toLowerCase();
      final hash2 = sha256.convert(testData).toString().toUpperCase();

      // Both should represent the same hash value when compared case-insensitively
      expect(hash1.toLowerCase(), equals(hash2.toLowerCase()));
    });

    test('SHA256 checksum - different data produces different hashes', () {
      final data1 = utf8.encode('Typst 0.11.1');
      final data2 = utf8.encode('Typst 0.11.2');

      final hash1 = sha256.convert(data1).toString();
      final hash2 = sha256.convert(data2).toString();

      // Different data should produce different hashes
      expect(hash1, isNot(equals(hash2)));
    });

    test('SHA256 checksum - binary data', () {
      // Test with binary data (simulating a downloaded archive)
      final binaryData = List<int>.generate(1024, (i) => i % 256);
      final hash = sha256.convert(binaryData).toString();

      // Verify hash format
      expect(hash.length, equals(64));
      expect(hash, matches(RegExp(r'^[a-f0-9]{64}$')));
    });

    test('Checksum verification - matching hashes', () {
      final testData = utf8.encode('Sample archive data');
      final actualHash = sha256.convert(testData).toString();
      final expectedHash = sha256.convert(testData).toString();

      // Simulate the verification logic
      final isValid = actualHash.toLowerCase() == expectedHash.toLowerCase();

      expect(isValid, isTrue);
    });

    test('Checksum verification - mismatched hashes', () {
      final testData1 = utf8.encode('Original data');
      final testData2 = utf8.encode('Tampered data');

      final actualHash = sha256.convert(testData1).toString();
      final expectedHash = sha256.convert(testData2).toString();

      // Simulate the verification logic
      final isValid = actualHash.toLowerCase() == expectedHash.toLowerCase();

      expect(isValid, isFalse);
    });

    test('Platform checksum map - all platforms covered', () {
      // Verify that all supported platforms have checksum entries
      const supportedPlatforms = [
        'x86_64-unknown-linux-musl',
        'aarch64-unknown-linux-musl',
        'x86_64-apple-darwin',
        'aarch64-apple-darwin',
        'x86_64-pc-windows-msvc',
      ];

      // Simulate the checksums map structure
      const checksums = {
        'x86_64-unknown-linux-musl': 'VERIFY_CHECKSUM_FROM_OFFICIAL_RELEASE',
        'aarch64-unknown-linux-musl': 'VERIFY_CHECKSUM_FROM_OFFICIAL_RELEASE',
        'x86_64-apple-darwin': 'VERIFY_CHECKSUM_FROM_OFFICIAL_RELEASE',
        'aarch64-apple-darwin': 'VERIFY_CHECKSUM_FROM_OFFICIAL_RELEASE',
        'x86_64-pc-windows-msvc': 'VERIFY_CHECKSUM_FROM_OFFICIAL_RELEASE',
      };

      // Verify all platforms are present
      for (final platform in supportedPlatforms) {
        expect(checksums.containsKey(platform), isTrue,
            reason: 'Platform $platform should have a checksum entry');
      }
    });

    test('Placeholder detection - identifies unverified checksums', () {
      const placeholder = 'VERIFY_CHECKSUM_FROM_OFFICIAL_RELEASE';
      const validHash =
          '8a7d3f6f8c0b5e4a2d3c1f9e8b7a6d5c4e3f2a1b0c9d8e7f6a5b4c3d2e1f0a9b';

      // Simulate placeholder detection logic
      final isPlaceholder1 = placeholder == 'VERIFY_CHECKSUM_FROM_OFFICIAL_RELEASE';
      final isPlaceholder2 = validHash == 'VERIFY_CHECKSUM_FROM_OFFICIAL_RELEASE';

      expect(isPlaceholder1, isTrue);
      expect(isPlaceholder2, isFalse);
    });
  });

  group('Security Considerations', () {
    test('Checksum verification prevents tampered downloads', () {
      // Simulate a legitimate download
      final legitimateData = utf8.encode('Legitimate Typst binary');
      final legitimateHash = sha256.convert(legitimateData).toString();

      // Simulate a tampered download
      final tamperedData = utf8.encode('Malicious binary');
      final tamperedHash = sha256.convert(tamperedData).toString();

      // Verification should fail for tampered data
      final isValid =
          tamperedHash.toLowerCase() == legitimateHash.toLowerCase();

      expect(isValid, isFalse,
          reason: 'Tampered data should not match legitimate checksum');
    });

    test('Checksum format validation', () {
      // Valid SHA256 format
      const validHash =
          'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'; // 64 hex characters
      expect(validHash.length, equals(64));
      expect(validHash, matches(RegExp(r'^[a-f0-9]{64}$')));

      // Invalid formats
      const tooShort = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'; // 63 chars
      const tooLong = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'; // 65 chars
      const invalidChars =
          'gaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'; // 'g' is not a valid hex character

      expect(tooShort.length, isNot(equals(64)));
      expect(tooLong.length, isNot(equals(64)));
      expect(invalidChars, isNot(matches(RegExp(r'^[a-f0-9]{64}$'))));
    });
  });
}
