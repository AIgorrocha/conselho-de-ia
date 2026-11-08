// Adapted from gargpratyush/jev-router, commit 38da6b84ea01241bfc41fbddc0928d0f40a703f0.
// MIT copyright (c) 2026 Jev Router contributors. See LICENSE.
import http from 'node:http';
import https from 'node:https';
import { createHash } from 'node:crypto';

const MODELS = Object.freeze({
  codex: Object.freeze({ high: 'gpt-6-astra', medium: 'gpt-6.1-sol', simple: 'gpt-6-luna' }),
  claude: Object.freeze({ high: 'claude-opus-5-5', medium: 'claude-sonnet-5-5', simple: 'claude-sonnet-5-5' }),
});
const ENDPOINTS = Object.freeze({
  codex: 'https://chatgpt.com/backend-api/codex/responses',
  claude: 'https://api.anthropic.com/v1/messages',
});
const ENV_KEYS = ['PATH', 'SystemRoot', 'WINDIR', 'USERPROFILE', 'HOME', 'HOMEDRIVE', 'HOMEPATH', 'APPDATA', 'LOCALAPPDATA', 'TEMP', 'TMP', 'TERM', 'COLORTERM', 'LANG', 'LC_ALL'];
const sessions = new WeakMap();
const MAX_BODY = 2 * 1024 * 1024;
const RESPONSE_TTL = 30 * 60 * 1000;

function responseObserver(contentType, remember) {
  if (contentType === undefined) {
    let probe = Buffer.alloc(0);
    let observer;
    return {
      consume(chunk) {
        if (observer) return observer.consume(chunk);
        if (probe === null) return;
        const prefix = chunk.subarray(0, 16 * 1024 - probe.length);
        probe = Buffer.concat([probe, prefix]);
        const start = probe.toString('utf8').replace(/^\uFEFF/, '').trimStart();
        const detected = /^(?:event:|data:|id:|retry:|:)/.test(start)
          ? 'text/event-stream'
          : start.startsWith('{') || start.startsWith('[') ? 'application/json' : undefined;
        if (detected) {
          observer = responseObserver(detected, remember);
          observer.consume(probe);
          probe = null;
          if (chunk.length > prefix.length) observer.consume(chunk.subarray(prefix.length));
        } else if (probe.length === 16 * 1024) probe = null;
      },
      end() { observer?.end(); probe = null; },
    };
  }
  if (contentType?.startsWith('text/event-stream')) {
    const decoder = new TextDecoder();
    let pending = '';
    let bytes = 0;
    let discarded = false;
    let blankLine = true;
    return {
      consume(chunk) {
        for (let i = 0; i < chunk.length; i += 1024) {
          const text = decoder.decode(chunk.subarray(i, i + 1024), { stream: true });
          for (const character of text) {
            if (!discarded) {
              bytes += Buffer.byteLength(character);
              if (bytes > 16 * 1024) { pending = ''; discarded = true; }
              else pending += character;
            }
            if (character === '\n') {
              if (blankLine) {
                const event = pending;
                pending = '';
                bytes = 0;
                if (!discarded) {
                  const lines = event.split(/\r?\n/);
                  const type = lines.find(line => line.startsWith('event:'))?.slice(6).trim();
                  if (type === undefined || type === 'response.created' || type === 'response.completed') {
                    const data = lines.filter(line => line.startsWith('data:')).map(line => line.slice(5).trimStart()).join('\n');
                    try {
                      const metadata = JSON.parse(data);
                      const knownType = type ?? metadata?.type;
                      if ((knownType === 'response.created' || knownType === 'response.completed') && (metadata.type === undefined || metadata.type === knownType)) remember(metadata?.response?.id);
                    } catch { /* Metadata is optional; bytes still pass untouched. */ }
                  }
                }
                discarded = false;
              }
              blankLine = true;
            } else if (character !== '\r') blankLine = false;
          }
        }
      },
      end() { pending = ''; bytes = 0; },
    };
  }
  let chunks = [];
  let size = 0;
  let discarded = !contentType?.startsWith('application/json');
  return {
    consume(chunk) {
      if (discarded) return;
      size += chunk.length;
      if (size > MAX_BODY) { chunks = []; discarded = true; }
      else chunks.push(chunk);
    },
    end() {
      if (!discarded) {
        try { remember(JSON.parse(Buffer.concat(chunks).toString('utf8'))?.id); } catch { /* Invalid metadata fails closed for continuation. */ }
      }
      chunks = [];
    },
  };
}

function optionsOf(options, testOnly) {
  if (!options || typeof options !== 'object') throw Error('OPTIONS_REQUIRED');
  const allowed = ['cli', 'role', 'catalog', 'onDecision', ...(testOnly ? ['upstreamURL', 'timeoutMs'] : [])];
  if (Object.keys(options).some(key => !allowed.includes(key))) throw Error('OPTION_NOT_SUPPORTED');
  const { cli, role, catalog, onDecision } = options;
  if (!Object.hasOwn(MODELS, cli)) throw Error('CLI_NOT_SUPPORTED');
  if (!Object.hasOwn(MODELS[cli], role)) throw Error('ROLE_NOT_SUPPORTED');
  const known = new Set(Object.values(MODELS[cli]));
  if (!Array.isArray(catalog) || !catalog.length || catalog.some(id => !known.has(id)) || !catalog.includes(MODELS[cli][role])) throw Error('CATALOG_NOT_AVAILABLE');
  if (onDecision !== undefined && typeof onDecision !== 'function') throw Error('CALLBACK_NOT_SUPPORTED');
  let target = new URL(ENDPOINTS[cli]);
  let timeoutMs = 10_000;
  if (testOnly) {
    target = new URL(options.upstreamURL);
    if (target.protocol !== 'http:' || target.hostname !== '127.0.0.1' || target.username || target.password || target.search || target.hash || target.pathname !== '/') throw Error('TEST_UPSTREAM_NOT_LOOPBACK');
    target.pathname = cli === 'codex' ? '/v1/responses' : '/v1/messages';
    timeoutMs = options.timeoutMs ?? timeoutMs;
    if (!Number.isInteger(timeoutMs) || timeoutMs < 1 || timeoutMs > 10_000) throw Error('TEST_TIMEOUT_NOT_SUPPORTED');
  }
  return { cli, role, catalog: new Set(catalog), onDecision, target, timeoutMs };
}

export async function startSession(options) {
  return start(optionsOf(options, false));
}

// Only tests import this factory. The production launcher never selects it.
export async function startTestSession(options) {
  return start(optionsOf(options, true));
}

async function start({ cli, role, catalog, onDecision, target, timeoutMs }) {
  let lastSuccessfulModel;
  let closed = false;
  let baseURL;
  const outgoing = new Set();
  const sockets = new Set();
  const responses = new Map();
  const pruneResponses = () => {
    for (const [id, record] of responses) if (record.expires <= Date.now()) responses.delete(id);
  };
  const failure = (res, status, code) => {
    if (res.destroyed || res.writableEnded) return;
    if (res.headersSent) return res.destroy();
    res.writeHead(status, { 'content-type': 'application/json', 'cache-control': 'no-store' });
    res.end(JSON.stringify({ error: { type: 'proxy_error', code } }));
  };
  const server = http.createServer(async (req, res) => {
    const remote = req.socket.remoteAddress;
    if (remote !== '127.0.0.1' || req.headers.host !== new URL(baseURL).host || (req.headers.origin !== undefined && req.headers.origin !== baseURL)) return failure(res, 403, 'LOCAL_ONLY');
    if (req.method === 'GET' && req.url === '/status') {
      res.writeHead(200, { 'content-type': 'application/json', 'cache-control': 'no-store' });
      return res.end(JSON.stringify({ cli, role, model: lastSuccessfulModel ?? null, mode: 'explicit_role', status: 'ready' }));
    }
    const path = cli === 'codex' ? '/v1/responses' : '/v1/messages';
    if (req.method !== 'POST' || req.url !== path) return failure(res, 404, 'ENDPOINT_NOT_SUPPORTED');
    if (typeof req.headers.authorization !== 'string' || !/^Bearer [^\s]+$/.test(req.headers.authorization) || (cli === 'codex' && !req.headers['chatgpt-account-id']?.trim())) return failure(res, 401, 'NATIVE_SUBSCRIPTION_AUTH_REQUIRED');
    if (req.headers['content-encoding'] !== undefined && req.headers['content-encoding'] !== 'identity') return failure(res, 415, 'ENCODING_NOT_SUPPORTED');
    if (!req.headers['content-type']?.toLowerCase().startsWith('application/json')) return failure(res, 415, 'JSON_REQUIRED');
    let size = 0;
    let chunks = [];
    const bodyTimer = setTimeout(() => { failure(res, 408, 'BODY_TIMEOUT'); req.destroy(); }, timeoutMs);
    try {
      for await (const chunk of req) {
        size += chunk.length;
        if (size > MAX_BODY) { failure(res, 413, 'BODY_TOO_LARGE'); req.resume(); return; }
        chunks.push(chunk);
      }
    } catch { return failure(res, 400, 'BODY_INVALID'); }
    finally { clearTimeout(bodyTimer); }
    let body;
    try { body = JSON.parse(Buffer.concat(chunks).toString('utf8')); }
    catch { return failure(res, 400, 'JSON_INVALID'); }
    finally { chunks = null; }
    if (!body || typeof body !== 'object' || Array.isArray(body)) return failure(res, 400, 'BODY_INVALID');
    const identity = createHash('sha256').update(cli).update('\0').update(req.headers.authorization).update('\0').update(cli === 'codex' ? req.headers['chatgpt-account-id'] : '').digest('hex');
    pruneResponses();
    const previous = body.previous_response_id;
    const parent = typeof previous === 'string' ? responses.get(previous) : undefined;
    if (previous !== undefined && (!parent || parent.identity !== identity)) return failure(res, 409, 'CONTINUATION_NOT_KNOWN');
    const manual = body.model !== 'jev-router';
    const model = manual ? body.model : parent?.model ?? MODELS[cli][role];
    if (!catalog.has(model)) return failure(res, 400, 'MODEL_NOT_IN_CATALOG');
    if (parent && parent.model !== model) return failure(res, 409, 'CONTINUATION_MODEL_CONFLICT');
    body.model = model;
    if (onDecision) {
      try { onDecision(Object.freeze({ cli, role, model, mode: manual ? 'manual' : 'explicit_role', event: 'routed' })); }
      catch { /* Observers cannot change routing or expose request contents. */ }
    }
    const bytes = Buffer.from(JSON.stringify(body));
    body = null;
    const headers = { 'content-type': 'application/json', 'content-length': bytes.length, 'accept-encoding': 'identity' };
    const providerHeaders = cli === 'codex'
      ? ['chatgpt-account-id', 'session_id', 'conversation_id', 'openai-beta', 'x-codex-turn-metadata', 'x-codex-turn-state']
      : ['anthropic-version', 'anthropic-beta'];
    for (const key of Object.keys(req.headers)) {
      if (['authorization', 'accept', 'user-agent', ...providerHeaders].includes(key) || (cli === 'claude' && key.startsWith('x-stainless-'))) headers[key] = req.headers[key];
    }
    const transport = target.protocol === 'https:' ? https : http;
    let headerTimer;
    let idleTimer;
    let wallTimer;
    const clearTimers = () => { clearTimeout(headerTimer); clearTimeout(idleTimer); clearTimeout(wallTimer); };
    const expire = () => { failure(res, 504, 'UPSTREAM_TIMEOUT'); upstream.destroy(); };
    const resetIdle = () => { clearTimeout(idleTimer); idleTimer = setTimeout(expire, 180_000); };
    const upstream = transport.request(target, { method: 'POST', headers, agent: false }, incoming => {
      clearTimeout(headerTimer);
      if (incoming.statusCode >= 300 && incoming.statusCode < 400) {
        incoming.destroy();
        upstream.destroy();
        return failure(res, 502, 'UPSTREAM_REDIRECT_BLOCKED');
      }
      const successful = incoming.statusCode >= 200 && incoming.statusCode < 300;
      const remember = id => {
        if (!successful || typeof id !== 'string' || !/^[A-Za-z0-9_-]{1,256}$/.test(id)) return;
        pruneResponses();
        const old = responses.get(id);
        if (old && (old.identity !== identity || old.model !== model)) { responses.delete(id); return; }
        if (responses.size >= 256 && !responses.has(id)) responses.delete(responses.keys().next().value);
        responses.set(id, { identity, model, expires: Date.now() + RESPONSE_TTL });
        lastSuccessfulModel = model;
      };
      const observer = responseObserver(incoming.headers['content-encoding'] && incoming.headers['content-encoding'] !== 'identity' ? '' : incoming.headers['content-type'], remember);
      resetIdle();
      incoming.on('data', chunk => { resetIdle(); if (successful) observer.consume(chunk); });
      incoming.once('end', () => { if (successful) observer.end(); clearTimers(); });
      incoming.once('close', () => { observer.end(); clearTimers(); });
      const responseHeaders = { 'cache-control': 'no-store' };
      for (const key of ['content-type', 'content-encoding', 'content-length', 'retry-after', 'request-id', 'x-request-id']) {
        if (incoming.headers[key] !== undefined) responseHeaders[key] = incoming.headers[key];
      }
      res.writeHead(incoming.statusCode ?? 502, responseHeaders);
      incoming.on('error', () => res.destroy());
      incoming.pipe(res);
    });
    outgoing.add(upstream);
    headerTimer = setTimeout(expire, timeoutMs);
    wallTimer = setTimeout(expire, RESPONSE_TTL);
    upstream.on('error', () => failure(res, 502, 'UPSTREAM_UNAVAILABLE'));
    upstream.on('close', () => outgoing.delete(upstream));
    res.on('close', () => { clearTimers(); if (!res.writableFinished) upstream.destroy(); });
    upstream.end(bytes);
  });
  server.maxHeadersCount = 100;
  server.headersTimeout = 10_000;
  server.requestTimeout = 10_000;
  server.on('connection', socket => { sockets.add(socket); socket.on('close', () => sockets.delete(socket)); });
  await new Promise((resolve, reject) => { server.once('error', reject); server.listen(0, '127.0.0.1', resolve); });
  baseURL = `http://127.0.0.1:${server.address().port}`;
  const session = Object.freeze({
    cli, role, baseURL,
    close() {
      if (closed) return Promise.resolve();
      closed = true;
      sessions.delete(session);
      responses.clear();
      for (const request of outgoing) request.destroy();
      for (const socket of sockets) socket.destroy();
      return new Promise(resolve => server.close(resolve));
    },
  });
  sessions.set(session, { cli, role, catalog });
  return session;
}

export function buildProfile(session, { model = 'jev-router', effort } = {}, sourceEnv = {}) {
  const state = sessions.get(session);
  if (!state) throw Error('SESSION_REQUIRED');
  const { cli, catalog } = state;
  if (model !== 'jev-router' && !catalog.has(model)) throw Error('MODEL_NOT_IN_CATALOG');
  if (!(cli === 'codex' ? ['low', 'medium', 'high', 'xhigh'] : ['low', 'medium', 'high']).includes(effort)) throw Error('EFFORT_NOT_SUPPORTED');
  const env = {};
  for (const key of Object.keys(sourceEnv)) {
    const allowed = ENV_KEYS.find(name => name.toLowerCase() === key.toLowerCase());
    if (allowed && typeof sourceEnv[key] === 'string') env[allowed] = sourceEnv[key];
  }
  const args = ['--model', model];
  if (cli === 'codex') {
    for (const value of [
      'model_provider="jev-continuous"',
      'model_providers.jev-continuous.name="Explicit role proxy"',
      `model_providers.jev-continuous.base_url="${session.baseURL}/v1"`,
      'model_providers.jev-continuous.wire_api="responses"',
      'model_providers.jev-continuous.requires_openai_auth=true',
      'model_providers.jev-continuous.supports_websockets=false',
      `model_reasoning_effort="${effort}"`,
    ]) args.push('--config', value);
  } else {
    env.ANTHROPIC_BASE_URL = session.baseURL;
    if (model === 'jev-router') {
      env.ANTHROPIC_CUSTOM_MODEL_OPTION = 'jev-router';
      env.ANTHROPIC_CUSTOM_MODEL_OPTION_NAME = 'Explicit role proxy';
      env.ANTHROPIC_CUSTOM_MODEL_OPTION_DESCRIPTION = 'Fixed explicit role, no JEV classification';
      env.ANTHROPIC_CUSTOM_MODEL_OPTION_SUPPORTED_CAPABILITIES = 'thinking,adaptive_thinking,interleaved_thinking,effort,max_effort';
      env.CLAUDE_CODE_DISABLE_UNKNOWN_MODEL_WINDOW_ENFORCEMENT = '1';
    }
    args.push('--effort', effort);
  }
  return { cli, args, env };
}
