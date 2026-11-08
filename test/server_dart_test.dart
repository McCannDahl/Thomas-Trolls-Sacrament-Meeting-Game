import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bin/server.dart serves flutter web build and handles /thomas/ subpath', () async {
    final serverProcess = await Process.start(
      'dart',
      ['run', 'bin/server.dart', '8998'],
      workingDirectory: Directory.current.path,
    );
    serverProcess.stdout.transform(utf8.decoder).listen(stdout.write);
    serverProcess.stderr.transform(utf8.decoder).listen(stderr.write);

    // Give server a moment to start
    await Future.delayed(const Duration(milliseconds: 1500));

    final client = HttpClient();

    try {
      // Test 1: GET /
      final req1 = await client.getUrl(Uri.parse('http://127.0.0.1:8998/'));
      final res1 = await req1.close();
      expect(res1.statusCode, equals(HttpStatus.ok));
      expect(res1.headers.contentType?.mimeType, equals('text/html'));
      final body1 = await utf8.decoder.bind(res1).join();
      expect(body1, contains('<base href="/thomas/">'));

      // Test 2: GET /thomas redirect
      final req2 = await client.getUrl(Uri.parse('http://127.0.0.1:8998/thomas'));
      req2.followRedirects = false;
      final res2 = await req2.close();
      expect(res2.statusCode, equals(HttpStatus.movedPermanently));
      expect(res2.headers.value(HttpHeaders.locationHeader), equals('/thomas/'));

      // Test 3: GET /thomas/
      final req3 = await client.getUrl(Uri.parse('http://127.0.0.1:8998/thomas/'));
      final res3 = await req3.close();
      expect(res3.statusCode, equals(HttpStatus.ok));
      final body3 = await utf8.decoder.bind(res3).join();
      expect(body3, contains('<base href="/thomas/">'));

      // Test 4: GET /thomas/flutter_bootstrap.js
      final req4 = await client.getUrl(Uri.parse('http://127.0.0.1:8998/thomas/flutter_bootstrap.js'));
      final res4 = await req4.close();
      expect(res4.statusCode, equals(HttpStatus.ok));
      expect(res4.headers.contentType?.mimeType, equals('application/javascript'));

      // Test 5: GET /flutter_bootstrap.js
      final req5 = await client.getUrl(Uri.parse('http://127.0.0.1:8998/flutter_bootstrap.js'));
      final res5 = await req5.close();
      expect(res5.statusCode, equals(HttpStatus.ok));
      expect(res5.headers.contentType?.mimeType, equals('application/javascript'));
    } finally {
      client.close();
      serverProcess.kill();
      await serverProcess.exitCode;
    }
  });
}
