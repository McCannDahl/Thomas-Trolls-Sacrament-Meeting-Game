const assert = require('assert');
const {
  normalizeBaseHref,
  parseArgs,
  getFlutterCommand,
  buildWeb,
} = require('../scripts/build-web');

function runTests() {
  console.log('Testing normalizeBaseHref ...');
  assert.strictEqual(normalizeBaseHref('/thomas/'), '/thomas/');
  assert.strictEqual(normalizeBaseHref('thomas'), '/thomas/');
  assert.strictEqual(normalizeBaseHref('/thomas'), '/thomas/');
  assert.strictEqual(normalizeBaseHref('thomas/'), '/thomas/');
  assert.strictEqual(normalizeBaseHref('/'), '/');
  assert.strictEqual(normalizeBaseHref(''), '/thomas/');
  assert.strictEqual(normalizeBaseHref(null), '/thomas/');

  console.log('Testing parseArgs ...');
  const defaultParsed = parseArgs([]);
  assert.strictEqual(defaultParsed.baseHref, '/thomas/');
  assert.strictEqual(defaultParsed.dryRun, false);
  assert.deepStrictEqual(defaultParsed.extraArgs, []);

  const flagParsed = parseArgs(['--base-href', '/custom-path/']);
  assert.strictEqual(flagParsed.baseHref, '/custom-path/');

  const eqParsed = parseArgs(['--base-href=/game/']);
  assert.strictEqual(eqParsed.baseHref, '/game/');

  const extraParsed = parseArgs(['--dry-run', '--release', '--no-tree-shake-icons']);
  assert.strictEqual(extraParsed.dryRun, true);
  assert.deepStrictEqual(extraParsed.extraArgs, ['--release', '--no-tree-shake-icons']);

  console.log('Testing getFlutterCommand ...');
  assert.strictEqual(getFlutterCommand('win32'), 'flutter.bat');
  assert.strictEqual(getFlutterCommand('darwin'), 'flutter');
  assert.strictEqual(getFlutterCommand('linux'), 'flutter');

  console.log('Testing buildWeb dry-run on win32 ...');
  const winResult = buildWeb({
    platform: 'win32',
    dryRun: true,
    baseHref: '/thomas/',
  });
  assert.strictEqual(winResult.flutterCmd, 'flutter.bat');
  assert.strictEqual(winResult.baseHref, '/thomas/');
  assert.deepStrictEqual(winResult.args, ['build', 'web', '--base-href', '/thomas/']);

  console.log('Testing buildWeb dry-run on darwin ...');
  const macResult = buildWeb({
    platform: 'darwin',
    dryRun: true,
    baseHref: '/thomas/',
    extraArgs: ['--wasm'],
  });
  assert.strictEqual(macResult.flutterCmd, 'flutter');
  assert.strictEqual(macResult.baseHref, '/thomas/');
  assert.deepStrictEqual(macResult.args, ['build', 'web', '--base-href', '/thomas/', '--wasm']);

  console.log('Testing MSYS environment variables ...');
  assert.strictEqual(process.env.MSYS_NO_PATHCONV, '1');
  assert.strictEqual(process.env.MSYS2_ARG_CONV_EXCL, '*');

  console.log('All build-web script tests passed successfully!');
}

runTests();
