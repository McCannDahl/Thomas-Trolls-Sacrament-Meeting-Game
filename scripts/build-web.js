#!/usr/bin/env node

const { spawnSync } = require('child_process');

// Disable MSYS / Git Bash POSIX-to-Win32 path conversion (e.g. converting /thomas/ to C:/Git/thomas/)
process.env.MSYS_NO_PATHCONV = '1';
process.env.MSYS2_ARG_CONV_EXCL = '*';

function normalizeBaseHref(href) {
  if (!href) return '/thomas/';
  let normalized = href.trim();
  if (!normalized.startsWith('/')) {
    normalized = '/' + normalized;
  }
  if (!normalized.endsWith('/')) {
    normalized = normalized + '/';
  }
  return normalized;
}

function parseArgs(argv) {
  let baseHref = process.env.BASE_HREF ? normalizeBaseHref(process.env.BASE_HREF) : null;
  const extraArgs = [];
  let dryRun = false;

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === '--dry-run') {
      dryRun = true;
    } else if (arg === '--base-href' && argv[i + 1]) {
      baseHref = normalizeBaseHref(argv[++i]);
    } else if (arg.startsWith('--base-href=')) {
      baseHref = normalizeBaseHref(arg.slice('--base-href='.length));
    } else {
      extraArgs.push(arg);
    }
  }

  if (!baseHref) {
    baseHref = '/thomas/';
  }

  return { baseHref, extraArgs, dryRun };
}

function getFlutterCommand(platform = process.platform) {
  if (process.env.FLUTTER_CMD) return process.env.FLUTTER_CMD;
  return platform === 'win32' ? 'flutter.bat' : 'flutter';
}

function buildWeb(options = {}) {
  const platform = options.platform || process.platform;
  const isWindows = platform === 'win32';
  const flutterCmd = options.flutterCmd || getFlutterCommand(platform);
  const baseHref = normalizeBaseHref(options.baseHref || '/thomas/');
  const extraArgs = options.extraArgs || [];
  const dryRun = options.dryRun || false;

  const args = ['build', 'web', '--base-href', baseHref, ...extraArgs];

  console.log(`[build-web] Building Flutter web with base-href: "${baseHref}"`);
  console.log(`[build-web] Command: ${flutterCmd} ${args.join(' ')}`);

  if (dryRun) {
    return { status: 0, args, flutterCmd, baseHref };
  }

  // Ensure MSYS path conversion is disabled in spawned process environment
  const env = {
    ...process.env,
    MSYS_NO_PATHCONV: '1',
    MSYS2_ARG_CONV_EXCL: '*',
  };

  let result = spawnSync(flutterCmd, args, {
    stdio: 'inherit',
    shell: isWindows,
    env,
  });

  // On Windows, if flutter.bat was not found directly in PATH, retry with 'flutter'
  if (result.error && result.error.code === 'ENOENT' && isWindows && flutterCmd === 'flutter.bat') {
    console.log(`[build-web] Retrying with command: flutter ${args.join(' ')}`);
    result = spawnSync('flutter', args, {
      stdio: 'inherit',
      shell: true,
      env,
    });
  }

  if (result.error) {
    console.error('[build-web] Error executing flutter build:', result.error);
    process.exit(1);
  }

  if (result.status !== 0) {
    process.exit(result.status ?? 1);
  }

  return result;
}

if (require.main === module) {
  const { baseHref, extraArgs, dryRun } = parseArgs(process.argv.slice(2));
  buildWeb({ baseHref, extraArgs, dryRun });
}

module.exports = {
  normalizeBaseHref,
  parseArgs,
  getFlutterCommand,
  buildWeb,
};
