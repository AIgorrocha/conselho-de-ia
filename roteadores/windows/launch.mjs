import { spawn } from 'node:child_process';
import { accessSync, constants } from 'node:fs';
import { delimiter, isAbsolute, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { startSession, buildProfile } from './proxy.mjs';

export function parseArgs(args) {
  const options = { model: 'jev-router' };
  const seen = new Set();
  for (let i = 0; i < args.length; i++) {
    const flag = args[i];
    if (flag.includes('budget') || flag === '--jev-auto') throw Error('JEV_BUDGET_NOT_AUTHORIZED');
    if (!['--cli', '--role', '--catalog', '--model', '--effort'].includes(flag)) throw Error('OPTION_NOT_SUPPORTED');
    if (seen.has(flag)) throw Error('DUPLICATE_OPTION');
    seen.add(flag);
    const value = args[++i];
    if (!value || value.startsWith('--')) throw Error('OPTION_VALUE_REQUIRED');
    options[flag.slice(2)] = flag === '--catalog' ? value.split(',') : value;
  }
  if (!['codex', 'claude'].includes(options.cli)) throw Error('CLI_NOT_SUPPORTED');
  if (!['high', 'medium', 'simple'].includes(options.role)) throw Error('ROLE_NOT_SUPPORTED');
  if (!Array.isArray(options.catalog) || options.catalog.some(value => !value)) throw Error('CATALOG_REQUIRED');
  if (!(options.cli === 'codex' ? ['low', 'medium', 'high', 'xhigh'] : ['low', 'medium', 'high']).includes(options.effort)) throw Error('EFFORT_NOT_SUPPORTED');
  return options;
}

function nativeExecutable(cli, env) {
  const name = process.platform === 'win32' ? `${cli}.exe` : cli;
  for (const raw of (env.PATH ?? '').split(delimiter)) {
    const directory = raw.replace(/^"|"$/g, '');
    if (!isAbsolute(directory)) continue;
    const file = join(directory, name);
    try { accessSync(file, process.platform === 'win32' ? constants.F_OK : constants.X_OK); return file; }
    catch { /* Only absolute native executable paths are candidates. */ }
  }
  throw Error('NATIVE_EXECUTABLE_REQUIRED');
}

export async function launch(args) {
  const { cli, role, catalog, effort, model } = parseArgs(args);
  const session = await startSession({ cli, role, catalog, onDecision(event) {
    process.stderr.write(`${JSON.stringify(event)}\n`);
  } });
  let child;
  const stop = () => { if (child && child.exitCode === null) child.kill(); };
  try {
    const profile = buildProfile(session, { effort, model }, process.env);
    const executable = nativeExecutable(cli, profile.env);
    process.once('SIGINT', stop);
    process.once('SIGTERM', stop);
    return await new Promise((resolve, reject) => {
      child = spawn(executable, profile.args, { stdio: 'inherit', shell: false, windowsHide: true, env: profile.env });
      child.once('error', () => reject(Error('NATIVE_LAUNCH_FAILED')));
      child.once('exit', (code, signal) => resolve(signal ? 1 : (code ?? 1)));
    });
  } finally {
    process.removeListener('SIGINT', stop);
    process.removeListener('SIGTERM', stop);
    await session.close();
  }
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  if (process.argv.length === 3 && process.argv[2] === '--help') {
    process.stdout.write('Explicit role proxy, no JEV classification or API budget. Use jev-continuous.ps1 codex|claude --role high|medium|simple --catalog COMMA_SEPARATED_IDS --effort high [--model EXACT_ID]. Interactive native CLI only.\n');
  } else {
    try { process.exitCode = await launch(process.argv.slice(2)); }
    catch (error) {
      const code = /^[A-Z_]+$/.test(error.message) ? error.message : 'CONTINUOUS_LAUNCH_FAILED';
      process.stderr.write(`${code}\n`);
      process.exitCode = 1;
    }
  }
}
