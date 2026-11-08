import test from 'node:test';
import assert from 'node:assert/strict';
import http from 'node:http';
import { readFile, readdir } from 'node:fs/promises';
import { startSession, startTestSession, buildProfile } from './proxy.mjs';

const codexCatalog = ['gpt-6-astra', 'gpt-6.1-sol', 'gpt-6-luna'];
const claudeCatalog = ['claude-opus-5-5', 'claude-sonnet-5-5'];
const canary = 'PRIVATE_CANARY_83c1a9';
const nativeHeaders = { authorization: 'Bearer synthetic-native-oauth', 'chatgpt-account-id': 'synthetic-account' };

async function provider(t, handler) {
  const received = [];
  const server = http.createServer(async (req, res) => {
    const chunks = [];
    for await (const chunk of req) chunks.push(chunk);
    received.push({ path: req.url, headers: req.headers, body: JSON.parse(Buffer.concat(chunks).toString() || '{}') });
    if (handler) return handler(req, res);
    res.writeHead(200, { 'content-type': 'application/json' });
    res.end(JSON.stringify({ id: `resp_${received.length}`, ok: true }));
  });
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  t.after(() => new Promise(resolve => { server.closeAllConnections(); server.close(resolve); }));
  return { url: `http://127.0.0.1:${server.address().port}`, received };
}

async function session(t, upstream, options = {}) {
  const proxy = await startTestSession({ cli: 'codex', role: 'high', catalog: codexCatalog, upstreamURL: upstream.url, ...options });
  t.after(() => proxy.close());
  return proxy;
}

async function send(proxy, body = {}, headers = {}) {
  return fetch(`${proxy.baseURL}${proxy.cli === 'claude' ? '/v1/messages' : '/v1/responses'}`, {
    method: 'POST', headers: { ...nativeHeaders, 'content-type': 'application/json', ...headers },
    body: JSON.stringify({ model: 'jev-router', input: canary, ...body }),
  });
}

async function rawStatus(proxy, extraHeaders) {
  return new Promise((resolve, reject) => {
    const bytes = Buffer.from(JSON.stringify({ model: 'jev-router', input: canary }));
    const request = http.request(`${proxy.baseURL}/v1/responses`, {
      method: 'POST', headers: { ...nativeHeaders, 'content-type': 'application/json', 'content-length': bytes.length, ...extraHeaders },
    }, response => { response.resume(); response.once('end', () => resolve(response.statusCode)); });
    request.once('error', reject);
    if (extraHeaders.host) assert.equal(request.getHeader('host'), extraHeaders.host);
    request.end(bytes);
  });
}

test('two explicit roles produce two actual upstream model ids, with native headers and effort preserved', async t => {
  const upstream = await provider(t);
  const high = await session(t, upstream);
  const simple = await session(t, upstream, { role: 'simple' });
  const results = await Promise.all([send(high, { reasoning: { effort: 'xhigh' } }), send(simple, { reasoning: { effort: 'high' } })]);
  assert.deepEqual(results.map(r => r.status), [200, 200]);
  assert.deepEqual(new Set(upstream.received.map(r => r.body.model)), new Set(['gpt-6-astra', 'gpt-6-luna']));
  assert.equal(upstream.received.find(r => r.body.model === 'gpt-6-astra').body.reasoning.effort, 'xhigh');
  assert.ok(upstream.received.every(r => r.headers.authorization === nativeHeaders.authorization && r.headers['chatgpt-account-id'] === nativeHeaders['chatgpt-account-id']));
});

test('manual model is preserved and continuation remains pinned; switching fails closed', async t => {
  const upstream = await provider(t);
  const proxy = await session(t, upstream);
  assert.equal((await send(proxy, { model: 'gpt-6.1-sol' })).status, 200);
  assert.equal((await send(proxy, { previous_response_id: 'resp_1' })).status, 200);
  assert.equal((await send(proxy, { model: 'gpt-6-luna', previous_response_id: 'resp_1' })).status, 409);
  assert.deepEqual(upstream.received.map(r => r.body.model), ['gpt-6.1-sol', 'gpt-6.1-sol']);
  assert.equal(upstream.received[1].body.previous_response_id, 'resp_1');
});

test('Claude role mapping uses Messages and preserves thinking and effort', async t => {
  const upstream = await provider(t);
  const high = await session(t, upstream, { cli: 'claude', catalog: claudeCatalog });
  const medium = await session(t, upstream, { cli: 'claude', role: 'medium', catalog: claudeCatalog });
  assert.equal((await send(high, { messages: [], thinking: { type: 'adaptive' }, output_config: { effort: 'high' } })).status, 200);
  assert.equal((await send(medium, { messages: [] })).status, 200);
  assert.deepEqual(upstream.received.map(r => r.body.model), claudeCatalog);
  assert.ok(upstream.received.every(r => r.path === '/v1/messages'));
  assert.deepEqual(upstream.received[0].body.thinking, { type: 'adaptive' });
  assert.equal(upstream.received[0].body.output_config.effort, 'high');
});

test('catalog empty, unknown role and absent routed model refuse before network', async t => {
  const upstream = await provider(t);
  await assert.rejects(session(t, upstream, { catalog: [] }), /CATALOG/);
  await assert.rejects(session(t, upstream, { role: 'useopus' }), /ROLE/);
  await assert.rejects(session(t, upstream, { catalog: ['gpt-6.1-sol'] }), /CATALOG/);
  const proxy = await session(t, upstream);
  assert.equal((await send(proxy, { model: 'gpt-made-up' })).status, 400);
  assert.equal(upstream.received.length, 0);
});

test('missing Codex subscription OAuth/account id refuses before network with generic body', async t => {
  const upstream = await provider(t);
  const proxy = await session(t, upstream);
  const response = await send(proxy, {}, { 'chatgpt-account-id': '', authorization: `Bearer ${canary}` });
  assert.equal(response.status, 401);
  assert.equal((await response.text()).includes(canary), false);
  assert.equal(upstream.received.length, 0);
});

test('parallel profiles bind known previous ids to their own OAuth identity', async t => {
  const upstream = await provider(t);
  const a = await session(t, upstream, { role: 'medium' });
  const b = await session(t, upstream, { role: 'simple' });
  assert.notEqual(a.baseURL, b.baseURL);
  const first = await Promise.all([send(a), send(b)]);
  const [ra, rb] = await Promise.all(first.map(response => response.json()));
  assert.equal((await send(a, { previous_response_id: rb.id })).status, 409);
  assert.equal((await send(b, { previous_response_id: ra.id })).status, 409);
  await Promise.all([send(a, { previous_response_id: ra.id }), send(b, { previous_response_id: rb.id })]);
  assert.equal(upstream.received.filter(r => r.body.model === 'gpt-6.1-sol').length, 2);
  assert.equal(upstream.received.filter(r => r.body.model === 'gpt-6-luna').length, 2);
});

test('upstream timeout is bounded and no redirect is followed', async t => {
  const slow = await provider(t, () => {});
  const proxy = await session(t, slow, { timeoutMs: 35 });
  assert.equal((await send(proxy)).status, 504);
  const redirected = await provider(t, (_req, res) => res.writeHead(302, { location: `${slow.url}/steal` }).end());
  const other = await session(t, redirected);
  assert.equal((await send(other)).status, 502);
  assert.equal(slow.received.length, 1);
});

test('SSE bytes survive split UTF8 characters and split event boundaries', async t => {
  const expected = Buffer.from('event: response.output_text.delta\ndata: {"delta":"ação 😀"}\n\nevent: response.completed\ndata: {}\n\n');
  const upstream = await provider(t, (_req, res) => {
    res.writeHead(200, { 'content-type': 'text/event-stream' });
    let i = 0;
    const push = () => { if (i === expected.length) return res.end(); res.write(expected.subarray(i, ++i)); setImmediate(push); };
    push();
  });
  const proxy = await session(t, upstream);
  const response = await send(proxy, { stream: true });
  assert.equal(response.status, 200);
  assert.deepEqual(Buffer.from(await response.arrayBuffer()), expected);
});

test('Host and Origin are validated; oversized requests never reach provider', async t => {
  const upstream = await provider(t);
  const proxy = await session(t, upstream);
  // Node fetch normalizes Host, so use the wire-level HTTP client for this boundary.
  assert.equal(await rawStatus(proxy, { host: 'evil.invalid' }), 403);
  assert.equal(await rawStatus(proxy, { origin: 'https://evil.invalid' }), 403);
  assert.equal((await send(proxy, { input: 'x'.repeat(2 * 1024 * 1024) })).status, 413);
  assert.equal(upstream.received.length, 0);
});

test('callback receives enums only, status is sanitized, profile child env excludes secrets', async t => {
  const upstream = await provider(t);
  const events = [];
  const proxy = await session(t, upstream, { onDecision: event => events.push(event) });
  assert.equal((await send(proxy)).status, 200);
  assert.ok(events.length > 0);
  assert.equal(JSON.stringify(events).includes(canary), false);
  assert.ok(events.every(event => Object.keys(event).every(key => ['cli', 'role', 'model', 'mode', 'event'].includes(key))));
  const status = await fetch(`${proxy.baseURL}/status`);
  const body = await status.text();
  assert.equal(body.includes('synthetic-native-oauth'), false);
  assert.equal(body.includes(canary), false);
  const sourceEnv = { PATH: '/bin', HOME: '/tmp', OPENAI_API_KEY: canary, ANTHROPIC_API_KEY: canary, JEV_API_KEY: canary };
  Object.defineProperty(sourceEnv, 'SECRET_GETTER', { enumerable: true, get() { throw Error('secret read'); } });
  const profile = buildProfile(proxy, { effort: 'high' }, sourceEnv);
  assert.equal(JSON.stringify(profile).includes(canary), false);
  assert.equal(profile.env.PATH, '/bin');
  assert.ok(profile.args.includes('jev-router'));
  assert.equal(profile.env.OPENAI_API_KEY, undefined);
  const files = await readdir(new URL('.', import.meta.url));
  assert.equal(files.some(name => /(?:history|dump|\.log$|\.env$)/i.test(name)), false);
});

test('production factories cannot configure nonofficial providers, test fake must be loopback', async () => {
  await assert.rejects(startSession({ cli: 'codex', role: 'high', catalog: codexCatalog, upstreamURL: 'http://127.0.0.1:1' }), /OPTION/);
  await assert.rejects(startTestSession({ cli: 'codex', role: 'high', catalog: codexCatalog, upstreamURL: 'http://example.com' }), /TEST_UPSTREAM/);
  const source = await readFile(new URL('./proxy.mjs', import.meta.url), 'utf8');
  assert.equal(source.includes('api.openai.com'), false);
  assert.equal(source.includes('process.env'), false);
});

test('a rejected upstream request cannot pin another model into the profile', async t => {
  let attempt = 0;
  const upstream = await provider(t, (_req, res) => {
    res.writeHead(++attempt === 1 ? 401 : 200, { 'content-type': 'application/json' });
    res.end('{}');
  });
  const proxy = await session(t, upstream);
  assert.equal((await send(proxy, { model: 'gpt-6-luna' })).status, 401);
  assert.equal((await send(proxy, { model: 'gpt-6-astra' })).status, 200);
  assert.deepEqual(upstream.received.map(r => r.body.model), ['gpt-6-luna', 'gpt-6-astra']);
});

test('manual model for a new turn remains allowed without previous_response_id', async t => {
  const upstream = await provider(t);
  const proxy = await session(t, upstream);
  assert.equal((await send(proxy)).status, 200);
  assert.equal((await send(proxy, { model: 'gpt-6-luna' })).status, 200);
  assert.deepEqual(upstream.received.map(r => r.body.model), ['gpt-6-astra', 'gpt-6-luna']);
});

test('active SSE can outlive the response-header deadline without being truncated', async t => {
  const expected = Buffer.from('data: a\n\ndata: b\n\ndata: c\n\ndata: d\n\n');
  const upstream = await provider(t, (_req, res) => {
    res.writeHead(200, { 'content-type': 'text/event-stream' });
    res.flushHeaders();
    let n = 0;
    const sendChunk = () => {
      res.write(expected.subarray(n, Math.min(n + 9, expected.length)));
      n += 9;
      if (n >= expected.length) return res.end();
      setTimeout(sendChunk, 20);
    };
    sendChunk();
  });
  const proxy = await session(t, upstream, { timeoutMs: 35 });
  const response = await send(proxy, { stream: true });
  assert.deepEqual(Buffer.from(await response.arrayBuffer()), expected);
});

test('Claude receives no Codex account or turn headers', async t => {
  const upstream = await provider(t);
  const proxy = await session(t, upstream, { cli: 'claude', catalog: claudeCatalog });
  assert.equal((await send(proxy, { messages: [] }, { 'x-codex-turn-state': canary, 'x-codex-turn-metadata': canary })).status, 200);
  assert.equal(upstream.received[0].headers['chatgpt-account-id'], undefined);
  assert.equal(upstream.received[0].headers['x-codex-turn-state'], undefined);
  assert.equal(upstream.received[0].headers['x-codex-turn-metadata'], undefined);
});

test('known old response keeps its own model after manual new turn; unknown and other identity fail closed', async t => {
  const upstream = await provider(t);
  const proxy = await session(t, upstream);
  const a = await (await send(proxy)).json();
  await (await send(proxy, { model: 'gpt-6-luna' })).json();
  assert.equal((await send(proxy, { previous_response_id: a.id })).status, 200);
  assert.equal(upstream.received.at(-1).body.model, 'gpt-6-astra');
  assert.equal((await send(proxy, { previous_response_id: 'resp_unknown' })).status, 409);
  assert.equal((await send(proxy, { previous_response_id: a.id }, { authorization: 'Bearer other-native-oauth' })).status, 409);
});

test('SSE observer learns only response id while forwarding split UTF8 bytes unchanged', async t => {
  const expected = Buffer.from('event: response.created\ndata: {"type":"response.created","response":{"id":"resp_stream","model":"synthetic"}}\n\nevent: response.output_text.delta\ndata: {"delta":"ação 😀"}\n\n');
  let attempt = 0;
  const upstream = await provider(t, (_req, res) => {
    if (++attempt !== 2) { res.writeHead(200, { 'content-type': 'application/json' }); return res.end(JSON.stringify({ id: `resp_later_${attempt}` })); }
    res.writeHead(200, { 'content-type': 'text/event-stream' });
    let i = 0;
    const push = () => { if (i === expected.length) return res.end(); res.write(expected.subarray(i, ++i)); setImmediate(push); };
    push();
  });
  const proxy = await session(t, upstream);
  await (await send(proxy)).json();
  assert.equal((await send(proxy, { previous_response_id: 'resp_stream' })).status, 409);
  assert.deepEqual(Buffer.from(await (await send(proxy, { stream: true })).arrayBuffer()), expected);
  const manual = await send(proxy, { model: 'gpt-6-luna' });
  assert.equal(manual.status, 200);
  await manual.json();
  assert.equal((await send(proxy, { previous_response_id: 'resp_stream' })).status, 200);
  assert.equal(upstream.received.at(-1).body.model, 'gpt-6-astra');
});

test('SSE without Content-Type learns response id and preserves split UTF8 bytes for continuation', async t => {
  const expected = Buffer.from(': heartbeat\n\nevent: response.created\ndata: {"type":"response.created","response":{"id":"resp_no_content_type"}}\n\nevent: response.output_text.delta\ndata: {"delta":"ação 😀"}\n\n');
  let attempt = 0;
  const upstream = await provider(t, (_req, res) => {
    if (++attempt > 1) { res.writeHead(200, { 'content-type': 'application/json' }); return res.end(JSON.stringify({ id: `resp_after_${attempt}` })); }
    res.writeHead(200);
    let i = 0;
    const push = () => { if (i === expected.length) return res.end(); res.write(expected.subarray(i, ++i)); setImmediate(push); };
    push();
  });
  const proxy = await session(t, upstream);
  const first = await send(proxy, { stream: true, model: 'gpt-6-luna' });
  assert.equal(first.headers.get('content-type'), null);
  assert.deepEqual(Buffer.from(await first.arrayBuffer()), expected);
  assert.equal((await send(proxy, { previous_response_id: 'resp_no_content_type' })).status, 200);
  assert.equal(upstream.received.at(-1).body.model, 'gpt-6-luna');
});

test('SSE without Content-Type and data-only frame learns the typed response id', async t => {
  const expected = Buffer.from('data: {"type":"response.created","response":{"id":"resp_data_only"}}\n\n');
  const upstream = await provider(t, (_req, res) => { res.writeHead(200); res.end(expected); });
  const proxy = await session(t, upstream);
  assert.deepEqual(Buffer.from(await (await send(proxy, { stream: true })).arrayBuffer()), expected);
  assert.equal((await send(proxy, { previous_response_id: 'resp_data_only' })).status, 200);
});
