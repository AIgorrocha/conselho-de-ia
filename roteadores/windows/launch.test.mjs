import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { parseArgs } from './launch.mjs';

test('production launcher accepts only enum profile, explicit catalog and effort', () => {
  assert.deepEqual(parseArgs(['--cli', 'codex', '--role', 'medium', '--catalog', 'gpt-6.1-sol,gpt-6-astra', '--effort', 'high']), {
    cli: 'codex', role: 'medium', catalog: ['gpt-6.1-sol', 'gpt-6-astra'], effort: 'high', model: 'jev-router',
  });
  assert.throws(() => parseArgs(['--upstream', 'http://127.0.0.1']), /OPTION/);
  assert.throws(() => parseArgs(['--jev-budget-usd', '1']), /BUDGET/);
  assert.throws(() => parseArgs(['--cli', 'codex', '--cli', 'claude']), /DUPLICATE/);
  assert.throws(() => parseArgs(['--cli', 'codex', '--role', 'auto']), /ROLE/);
});

test('production launch does not import test factory or accept inherited provider settings', async () => {
  const source = await readFile(new URL('./launch.mjs', import.meta.url), 'utf8');
  assert.equal(source.includes('startTestSession'), false);
  assert.equal(source.includes('shell: false'), true);
  assert.equal(source.includes('stdio: \'inherit\''), true);
  assert.equal(source.includes('...process.env'), false);
});
