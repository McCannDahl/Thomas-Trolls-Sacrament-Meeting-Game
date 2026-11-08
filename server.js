const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = parseInt(process.env.PORT || '8088', 10);
const HOST = process.env.HOST || '0.0.0.0';
const WEB_DIR = path.resolve(__dirname, 'build', 'web');

const MIME_TYPES = {
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

const server = http.createServer((req, res) => {
  if (req.method !== 'GET' && req.method !== 'HEAD') {
    res.writeHead(405, { 'Content-Type': 'text/plain' });
    return res.end('Method Not Allowed');
  }

  const url = new URL(req.url, `http://${req.headers.host || 'localhost'}`);
  let pathname = decodeURIComponent(url.pathname);

  // Redirect /thomas -> /thomas/
  if (pathname === '/thomas') {
    res.writeHead(301, { Location: '/thomas/' });
    return res.end();
  }

  // Strip leading /thomas or /thomas/ if present
  if (pathname === '/thomas/') {
    pathname = '/';
  } else if (pathname.startsWith('/thomas/')) {
    pathname = pathname.slice('/thomas'.length);
  }

  // Check if build/web exists
  if (!fs.existsSync(WEB_DIR)) {
    res.writeHead(503, { 'Content-Type': 'text/html; charset=utf-8' });
    return res.end(
      '<h1>503 Service Unavailable</h1><p>Flutter web build not found. Please run <code>flutter build web --base-href /thomas/</code> or <code>npm run build</code> first.</p>'
    );
  }

  // Normalize requested path inside WEB_DIR
  let relativePath = pathname.replace(/^\/+/, '');
  let filePath = path.resolve(WEB_DIR, relativePath);

  // Prevent directory traversal attacks
  if (!filePath.startsWith(WEB_DIR)) {
    res.writeHead(403, { 'Content-Type': 'text/plain' });
    return res.end('Forbidden');
  }

  // If path is a directory, check for index.html inside
  if (fs.existsSync(filePath) && fs.statSync(filePath).isDirectory()) {
    filePath = path.join(filePath, 'index.html');
  }

  // Fallback to index.html for SPA routing
  if (!fs.existsSync(filePath) || !fs.statSync(filePath).isFile()) {
    filePath = path.join(WEB_DIR, 'index.html');
  }

  if (!fs.existsSync(filePath)) {
    res.writeHead(404, { 'Content-Type': 'text/plain' });
    return res.end('Not Found');
  }

  const ext = path.extname(filePath).toLowerCase();
  const contentType = MIME_TYPES[ext] || 'application/octet-stream';
  const stat = fs.statSync(filePath);

  res.writeHead(200, {
    'Content-Type': contentType,
    'Content-Length': stat.size,
    'Access-Control-Allow-Origin': '*',
    'Cache-Control': ext === '.html' ? 'no-cache' : 'public, max-age=3600',
  });

  if (req.method === 'HEAD') {
    return res.end();
  }

  const stream = fs.createReadStream(filePath);
  stream.pipe(res);
  stream.on('error', (err) => {
    console.error('Stream error:', err);
    if (!res.headersSent) {
      res.writeHead(500, { 'Content-Type': 'text/plain' });
    }
    res.end('Internal Server Error');
  });
});

if (require.main === module) {
  server.listen(PORT, HOST, () => {
    console.log(`Thomas Trolls Game server running on http://${HOST}:${PORT}/`);
    console.log(`Subpath access: http://${HOST}:${PORT}/thomas/`);
    console.log(`Serving static files from: ${WEB_DIR}`);
  });
}

module.exports = server;
