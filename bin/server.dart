import 'dart:io';

Future<void> main(List<String> args) async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ??
      (args.isNotEmpty ? int.tryParse(args[0]) : null) ??
      8088;
  final host = InternetAddress.anyIPv4;
  final scriptDir = File(Platform.script.toFilePath()).parent.parent;
  final webDir = Directory('${scriptDir.path}/build/web');

  final mimeTypes = <String, String>{
    '.html': 'text/html; charset=utf-8',
    '.js': 'application/javascript; charset=utf-8',
    '.mjs': 'application/javascript; charset=utf-8',
    '.css': 'text/css; charset=utf-8',
    '.json': 'application/json; charset=utf-8',
    '.wasm': 'application/wasm',
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.gif': 'image/gif',
    '.svg': 'image/svg+xml',
    '.ico': 'image/x-icon',
    '.ttf': 'font/ttf',
    '.otf': 'font/otf',
    '.woff': 'font/woff',
    '.woff2': 'font/woff2',
    '.mp3': 'audio/mpeg',
    '.wav': 'audio/wav',
    '.ogg': 'audio/ogg',
    '.mp4': 'video/mp4',
    '.webm': 'video/webm',
  };

  final server = await HttpServer.bind(host, port);
  stdout.writeln('Thomas Trolls Game server running on http://${server.address.address}:$port/');
  stdout.writeln('Subpath access: http://${server.address.address}:$port/thomas/');
  stdout.writeln('Serving static files from: ${webDir.path}');

  await for (final request in server) {
    if (request.method != 'GET' && request.method != 'HEAD') {
      request.response
        ..statusCode = HttpStatus.methodNotAllowed
        ..headers.contentType = ContentType.text
        ..write('Method Not Allowed');
      await request.response.close();
      continue;
    }

    var pathname = Uri.decodeComponent(request.uri.path);

    // Redirect /thomas -> /thomas/
    if (pathname == '/thomas') {
      request.response
        ..statusCode = HttpStatus.movedPermanently
        ..headers.set(HttpHeaders.locationHeader, '/thomas/');
      await request.response.close();
      continue;
    }

    // Strip leading /thomas or /thomas/
    if (pathname == '/thomas/') {
      pathname = '/';
    } else if (pathname.startsWith('/thomas/')) {
      pathname = pathname.substring('/thomas'.length);
    }

    if (!webDir.existsSync()) {
      request.response
        ..statusCode = HttpStatus.serviceUnavailable
        ..headers.contentType = ContentType.html
        ..write(
            '<h1>503 Service Unavailable</h1><p>Flutter web build not found. Please run <code>flutter build web --base-href /thomas/</code> or <code>npm run build</code> first.</p>');
      await request.response.close();
      continue;
    }

    var relativePath = pathname.replaceFirst(RegExp(r'^/+'), '');
    var targetPath = '${webDir.path}/$relativePath';

    File? fileToServe;
    final targetFile = File(targetPath);
    final targetDirectory = Directory(targetPath);

    if (targetDirectory.existsSync()) {
      final indexFile = File('${targetDirectory.path}/index.html');
      if (indexFile.existsSync()) {
        fileToServe = indexFile;
      }
    } else if (targetFile.existsSync()) {
      fileToServe = targetFile;
    }

    // Fallback to index.html for SPA routing
    fileToServe ??= File('${webDir.path}/index.html');

    if (!fileToServe.existsSync()) {
      request.response
        ..statusCode = HttpStatus.notFound
        ..headers.contentType = ContentType.text
        ..write('Not Found');
      await request.response.close();
      continue;
    }

    final ext = fileToServe.path.contains('.')
        ? '.${fileToServe.path.split('.').last.toLowerCase()}'
        : '';
    final mime = mimeTypes[ext] ?? 'application/octet-stream';

    request.response.statusCode = HttpStatus.ok;
    request.response.headers.set('Access-Control-Allow-Origin', '*');
    request.response.headers.set(
      HttpHeaders.cacheControlHeader,
      ext == '.html' ? 'no-cache' : 'public, max-age=3600',
    );
    final parts = mime.split(';');
    final contentType = ContentType.parse(parts[0]);
    request.response.headers.contentType = contentType;

    if (request.method == 'HEAD') {
      await request.response.close();
      continue;
    }

    await fileToServe.openRead().pipe(request.response);
  }
}
