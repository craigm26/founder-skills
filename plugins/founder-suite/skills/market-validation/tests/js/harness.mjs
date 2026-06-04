// Test harness for assets/research-workflow.js
//
// The workflow is NOT a standalone Node module: it is a Workflow script that the
// harness runs by wrapping its body in an async function and injecting the globals
// `agent`, `parallel`, `phase`, `log`, `args`. The file legitimately uses top-level
// `await` AND a top-level `return` -- both illegal in a plain ES module, both legal
// inside the harness wrapper. So we can't `import()` it; we replicate the harness:
// strip the `export` sugar, wrap the body in `new Function`, and inject stubs.
//
// This loads the REAL, unmodified source on disk, so tests exercise the shipped code.

import fs from 'node:fs';
import path from 'node:path';
import url from 'node:url';

const HERE = path.dirname(url.fileURLToPath(import.meta.url));
const WORKFLOW = path.resolve(HERE, '../../assets/research-workflow.js');

// Run the workflow body with the supplied harness stubs.
// stubs: { agent, parallel?, phase?, log?, args }
//  - agent(prompt, opts) -> async; opts.label identifies the call
//      ("investigate:<key>", "investigate-loose:<key>", "curate", "verify:<i>", "synthesize")
//  - parallel defaults to Promise.all over the thunks
//  - log/phase default to recording no-ops
// Returns { result, logs, agentCalls } where agentCalls is the ordered list of labels.
export async function runWorkflow(stubs) {
  const src = fs.readFileSync(WORKFLOW, 'utf8');
  const body = src.replace(/^export\s+const\s+meta/m, 'const meta');

  const logs = [];
  const agentCalls = [];

  const agent = async (prompt, opts) => {
    const label = (opts && opts.label) || '';
    agentCalls.push(label);
    return stubs.agent(prompt, opts);
  };
  const parallel = stubs.parallel || ((thunks) => Promise.all(thunks.map((t) => t())));
  const phase = stubs.phase || (() => {});
  const log = stubs.log || ((m) => logs.push(m));
  const args = stubs.args || {};

  const runner = new Function(
    'agent',
    'parallel',
    'phase',
    'log',
    'args',
    `return (async () => {\n${body}\n})();`
  );
  const result = await runner(agent, parallel, phase, log, args);
  return { result, logs, agentCalls };
}
