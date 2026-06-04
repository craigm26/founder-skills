import { test } from 'node:test';
import assert from 'node:assert/strict';
import { runWorkflow } from './harness.mjs';

// Four angles. The investigator stub simulates a flaky host:
//   pain      -> strict attempt returns null first time, succeeds on retry
//   competitor-> strict attempt THROWS first time (schema-validation), recovered via loose retry
//   wtp       -> BOTH attempts fail permanently (host fully choked on this angle)
//   counter   -> succeeds first try
const ANGLES = [
  { key: 'pain', title: 'Customer pain & demand', focus: 'f-pain' },
  { key: 'competitor', title: 'Competitors & funding', focus: 'f-comp' },
  { key: 'wtp', title: 'Willingness to pay', focus: 'f-wtp' },
  { key: 'counter', title: 'Counter-evidence & risks', focus: 'f-counter' },
];

function claim(dim, tag) {
  return { text: 't-' + tag, quote: 'q-' + tag, dimension: dim, sourceUrl: 'http://x/' + tag, sourceTitle: 'src-' + tag };
}

// Build an agent stub whose investigator behavior is per-angle and stateful.
// `loose` calls are distinguished by the label prefix the implementation uses
// ("investigate-loose:" or "investigate:" with a `loose`/relaxed flag) OR by a
// second call to the same angle key. We treat ANY second call to a given angle
// key as the retry attempt, which is implementation-agnostic.
function makeFlakyAgent() {
  const seen = Object.create(null); // angleKey -> count of investigator calls
  return async function agent(_prompt, opts) {
    const label = (opts && opts.label) || '';

    // Investigator calls carry the angle key after a ':' (strict OR loose label).
    const m = label.match(/^investigate(?:-loose)?:(.+)$/);
    if (m) {
      const key = m[1];
      seen[key] = (seen[key] || 0) + 1;
      const attempt = seen[key]; // 1 = first/strict, 2 = retry/loose

      if (key === 'pain') {
        // null on strict, recover on retry
        if (attempt === 1) return null;
        return { angle: 'pain', claims: [claim('pain', 'pain-recovered')] };
      }
      if (key === 'competitor') {
        // throw (schema-validation style) on strict, recover on retry
        if (attempt === 1) throw new Error('schema validation failed: missing required field');
        return { angle: 'competitor', claims: [claim('competitor', 'comp-recovered')] };
      }
      if (key === 'wtp') {
        // permanently fails on BOTH attempts
        if (attempt === 1) return null;
        throw new Error('schema validation failed again on retry');
      }
      if (key === 'counter') {
        return { angle: 'counter', claims: [claim('counter', 'counter-ok')] };
      }
      return null;
    }

    // Downstream phases: keep them trivially valid so the run completes.
    if (label === 'curate') {
      return { claims: [], competitors: [] };
    }
    if (label.startsWith('verify:')) {
      return { urlResolves: true, quoteConfirmed: 'confirmed', verdict: 'confirm', reason: 'ok' };
    }
    return 'REPORT-MD';
  };
}

test('flaky strict investigator call is recovered on retry (returns null first, succeeds second)', async () => {
  const { logs } = await runWorkflow({
    agent: makeFlakyAgent(),
    args: { config: { product: 'Widget' }, angles: ANGLES },
  });

  const collected = logs.find((l) => /Collected \d+ raw claims across \d+/.test(l));
  assert.ok(collected, 'should log a "Collected ... across N ..." line');
  // pain (recovered), competitor (recovered), counter (ok) = 3 angles contribute.
  // wtp is the only permanent failure. WITHOUT retry, pain throws/null + competitor throws ->
  // either a crash or only 1 angle survives. WITH retry, exactly 3 of 4 survive.
  const m = collected.match(/across (\d+)\b/);
  assert.ok(m, 'collected line should report a surviving-angle count: ' + collected);
  assert.equal(Number(m[1]), 3, 'pain + competitor + counter must all survive via retry');
});

test('a permanently-failing angle is logged as dropped, by name (no silent cap)', async () => {
  const { logs } = await runWorkflow({
    agent: makeFlakyAgent(),
    args: { config: { product: 'Widget' }, angles: ANGLES },
  });

  // The dropped angle (wtp) must be named in a log line so coverage loss is visible.
  const droppedLine = logs.find((l) => /drop|dropped|fail|lost|unrecover/i.test(l) && /wtp/.test(l));
  assert.ok(
    droppedLine,
    'expected a log line naming the permanently-dropped angle "wtp"; got logs:\n' + logs.join('\n')
  );
});

test('recovered claims actually flow into the curate input (breadth preserved)', async () => {
  // Capture the prompt the curate agent receives; it embeds the raw claims JSON.
  let curatePrompt = null;
  const flaky = makeFlakyAgent();
  const { result } = await runWorkflow({
    agent: async (prompt, opts) => {
      const out = await flaky(prompt, opts);
      if (opts && opts.label === 'curate') curatePrompt = prompt;
      return out;
    },
    args: { config: { product: 'Widget' }, angles: ANGLES },
  });

  assert.ok(curatePrompt, 'curate stage should have run');
  assert.ok(curatePrompt.includes('pain-recovered'), 'recovered pain claim must reach curate');
  assert.ok(curatePrompt.includes('comp-recovered'), 'recovered competitor claim must reach curate');
  assert.ok(curatePrompt.includes('counter-ok'), 'first-try counter claim must reach curate');
  assert.ok(result, 'workflow should return a result object');
});

test('happy path: no retry-on-success and no spurious drop logs when all angles succeed', async () => {
  let looseCalls = 0;
  const { result, logs } = await runWorkflow({
    agent: async (_p, opts) => {
      const label = (opts && opts.label) || '';
      if (label.startsWith('investigate-loose:')) { looseCalls++; throw new Error('loose retry must not fire on success'); }
      if (label.startsWith('investigate:')) return { angle: label, claims: [claim('pain', 'ok')] };
      if (label === 'curate') return { claims: [], competitors: [] };
      if (label.startsWith('verify:')) return { urlResolves: true, quoteConfirmed: 'confirmed', verdict: 'confirm', reason: 'ok' };
      return 'REPORT-MD';
    },
    args: { config: { product: 'Widget' }, angles: ANGLES },
  });
  assert.equal(looseCalls, 0, 'looser-schema retry must not run when the strict attempt succeeds');
  assert.equal(logs.filter((l) => /DROPPED ANGLE/.test(l)).length, 0, 'no angle should be reported dropped');
  assert.ok(result && typeof result.droppedCount === 'number', 'return shape preserved');
  const collected = logs.find((l) => /Collected/.test(l));
  assert.ok(/across 4\b/.test(collected), 'all 4 angles should survive: ' + collected);
});

test('recovery holds regardless of parallel() semantics (allSettled-style runner)', async () => {
  // The real Workflow runtime's parallel() semantics are unverified; harness defaults to
  // Promise.all (one throw rejects the batch). Prove the per-angle try/catch in
  // investigateAngle makes recovery robust EITHER way by injecting an allSettled-style
  // parallel that tolerates a thunk that itself rejects.
  const allSettledParallel = async (thunks) => {
    const settled = await Promise.allSettled(thunks.map((t) => t()));
    return settled.map((s) => (s.status === 'fulfilled' ? s.value : null));
  };
  const { logs } = await runWorkflow({
    agent: makeFlakyAgent(),
    parallel: allSettledParallel,
    args: { config: { product: 'Widget' }, angles: ANGLES },
  });
  const collected = logs.find((l) => /Collected/.test(l));
  const m = collected.match(/across (\d+)\b/);
  assert.equal(Number(m[1]), 3, '3 of 4 angles survive under allSettled-style parallel too');
  assert.ok(logs.some((l) => /DROPPED ANGLE/.test(l) && /wtp/.test(l)), 'wtp still named as dropped');
});
