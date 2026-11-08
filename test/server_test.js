const http = require('http');
const assert = require('assert');
const server = require('../server');

const TEST_PORT = 8999;

function request(path) {
  return new Promise((resolve, reject) => {
    http.get(`http://127.0.0.1:${TEST_PORT}${path}`, (res) => {
      let data = '';
      res.on('data', (chunk) => (data += chunk));
      res.on('end', () => resolve({ status: res.statusCode, headers: res.headers, body: data }));
    }).on('error', reject);
  });
}

async function runTests() {
  server.listen(TEST_PORT, '127.0.0.1');

  try {
    console.log('Testing root path / ...');
    const resRoot = await request('/');
    assert.strictEqual(resRoot.status, 200);
    assert(resRoot.headers['content-type'].includes('text/html'));
    assert(resRoot.body.includes('<base href="/thomas/">'));

    console.log('Testing /thomas redirect ...');
    const resRedirect = await request('/thomas');
    assert.strictEqual(resRedirect.status, 301);
    assert.strictEqual(resRedirect.headers['location'], '/thomas/');

    console.log('Testing subpath /thomas/ ...');
    const resThomas = await request('/thomas/');
    assert.strictEqual(resThomas.status, 200);
    assert(resThomas.headers['content-type'].includes('text/html'));
    assert(resThomas.body.includes('<base href="/thomas/">'));

    console.log('Testing asset /thomas/flutter_bootstrap.js ...');
    const resAssetSubpath = await request('/thomas/flutter_bootstrap.js');
    assert.strictEqual(resAssetSubpath.status, 200);
    assert(resAssetSubpath.headers['content-type'].includes('application/javascript'));

    console.log('Testing asset /flutter_bootstrap.js ...');
    const resAssetRoot = await request('/flutter_bootstrap.js');
    assert.strictEqual(resAssetRoot.status, 200);
    assert(resAssetRoot.headers['content-type'].includes('application/javascript'));

    console.log('Testing SPA fallback /thomas/unknown-route ...');
    const resSpa = await request('/thomas/unknown-route');
    assert.strictEqual(resSpa.status, 200);
    assert(resSpa.headers['content-type'].includes('text/html'));

    console.log('All server.js tests passed successfully!');
  } finally {
    server.close();
  }
}

runTests().catch((err) => {
  console.error('Test failed:', err);
  server.close();
  process.exit(1);
});
