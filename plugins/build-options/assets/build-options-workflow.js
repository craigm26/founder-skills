export const meta = {
  name: 'build-options-judge-panel',
  description: 'Generate divergent build options, score them with an independent judge panel, adversarially stress-test the top, return scored options',
  phases: [
    { title: 'Generate', detail: 'one generator per strategic lens -> a structured build option' },
    { title: 'Score', detail: '3 independent judges each score every option on every criterion' },
    { title: 'Stress-test', detail: 'skeptics try to refute the top options' },
  ],
}

// ---- parameters (Claude supplies via args; the script executes what it is handed) ----
const A = (typeof args === 'string') ? (function () { try { return JSON.parse(args); } catch (e) { return {}; } })() : (args || {});
const CTX = A.context || {};
const CONTEXT_STR = CTX.summary ||
  ('Product/market: ' + (CTX.product || 'the product') + '. Incumbent(s): ' + ((CTX.incumbents || []).join('; ') || 'n/a') +
   '. WTP/notes: ' + (CTX.wtp_notes || 'n/a') + '. Constraints: ' + (CTX.constraints || 'n/a') +
   '. Must-reuse assets: ' + ((CTX.mustReuseAssets || []).join('; ') || 'none') + '.');

const DEFAULT_CRITERIA = [
  { key: 'wtp_fit', label: 'Willingness-to-pay fit', weight: 0.20, higherIsBetter: true },
  { key: 'incumbent_displacement', label: 'Beats the incumbent', weight: 0.20, higherIsBetter: true },
  { key: 'time_to_mvp', label: 'Speed to MVP', weight: 0.15, higherIsBetter: true },
  { key: 'moat', label: 'Moat / defensibility', weight: 0.12, higherIsBetter: true },
  { key: 'unit_econ', label: 'Unit economics', weight: 0.12, higherIsBetter: true },
  { key: 'gtm', label: 'Distribution / GTM', weight: 0.11, higherIsBetter: true },
  { key: 'reg_risk', label: 'Regulatory risk (lower is better)', weight: 0.05, higherIsBetter: false },
  { key: 'asset_fit', label: 'Fit with existing assets', weight: 0.05, higherIsBetter: true },
];
const CRITERIA = (A.criteria && A.criteria.length) ? A.criteria : DEFAULT_CRITERIA;

const DEFAULT_LENSES = [
  { key: 'undercut-automation', title: 'Undercut via automation', focus: 'Beat the incumbent on price by collapsing cost-to-serve with automation.' },
  { key: 'premium-differentiate', title: 'Premium / differentiate', focus: 'Win on depth/quality at a higher price where the incumbent is commoditized.' },
  { key: 'platform-api', title: 'Platform / API', focus: 'Sell the capability as an API/white-label others embed (B2B2C).' },
  { key: 'niche-wedge', title: 'Niche wedge', focus: 'Own a sharp underserved segment or a free top-of-funnel hook the incumbent ignores.' },
  { key: 'bundle-aggregate', title: 'Bundle / aggregate', focus: 'Bundle into an adjacent workflow/product the customer already uses.' },
  { key: 'build-vs-buy-partner', title: 'Build-vs-buy / partner', focus: 'Partner, white-label, or acquire instead of building everything; ride existing distribution.' },
];
const LENSES = (A.lenses && A.lenses.length) ? A.lenses : DEFAULT_LENSES;

const OPTION_SCHEMA = {
  type: 'object',
  properties: {
    id: { type: 'string' }, name: { type: 'string' }, lens: { type: 'string' },
    thesis: { type: 'string' }, mvpScope: { type: 'string' }, businessModel: { type: 'string' },
    incumbentBeat: { type: 'string' },
    requiredAssets: { type: 'array', items: { type: 'string' } },
    keyRisks: { type: 'array', items: { type: 'string' } },
    timeToRevenue: { type: 'string' },
  },
  required: ['id', 'name', 'lens', 'thesis', 'mvpScope', 'businessModel', 'incumbentBeat', 'keyRisks', 'timeToRevenue'],
};

phase('Generate');
const options = (await parallel(LENSES.map(L => () =>
  agent(
    `You are a product strategist generating ONE concrete build option through a specific strategic lens.\nCONTEXT: ${CONTEXT_STR}\n\nLENS: "${L.title}" — ${L.focus}\n\nProduce a single, concrete, buildable option that genuinely follows this lens (do not drift to a generic idea). id = a kebab-case slug. Be specific about what you build first (mvpScope), the pricing/revenue model, and the exact mechanism by which it beats the incumbent. List required assets/capabilities and the key risks, and a rough time-to-revenue (weeks/months/quarters).`,
    { label: `gen:${L.key}`, phase: 'Generate', schema: OPTION_SCHEMA }
  )
))).filter(Boolean);

log(`Generated ${options.length} options`);
const optsForJudges = options.map(o => ({ id: o.id, name: o.name, lens: o.lens, thesis: o.thesis, mvpScope: o.mvpScope, businessModel: o.businessModel, incumbentBeat: o.incumbentBeat }));

phase('Score');
const SCORE_SCHEMA = {
  type: 'object',
  properties: {
    judge: { type: 'string' },
    scores: {
      type: 'object',
      description: 'optionId -> { criterionKey -> { score (0-5 integer), note } }',
      additionalProperties: {
        type: 'object',
        additionalProperties: {
          type: 'object',
          properties: { score: { type: 'number' }, note: { type: 'string' } },
          required: ['score'],
        },
      },
    },
  },
  required: ['judge', 'scores'],
};
const critList = CRITERIA.map(c => `${c.key} (${c.label}${c.higherIsBetter === false ? '; LOWER is better' : ''})`).join('; ');
const judges = await parallel([1, 2, 3].map(n => () =>
  agent(
    `You are independent judge #${n} scoring build options for a decision matrix. Be calibrated and use the FULL 0-5 range — do not cluster every option at 3-4; reserve 5 for clearly excellent and 0-1 for clearly poor.\nCONTEXT: ${CONTEXT_STR}\n\nCRITERIA (score each option 0-5 on each; for any criterion marked LOWER is better, a higher raw score still means "more of the named thing"): ${critList}\n\nOPTIONS (JSON):\n${JSON.stringify(optsForJudges)}\n\nReturn { judge: "${n}", scores: { <optionId>: { <criterionKey>: { score, note } , ... }, ... } } covering EVERY option and EVERY criterion with a one-line note grounding each score.`,
    { label: `judge:${n}`, phase: 'Score', schema: SCORE_SCHEMA }
  )
)).then(rs => rs.filter(Boolean));

// aggregate judges -> per-option scores {mean, spread, notes}; raw unweighted mean to pick top-N for stress-test
options.forEach(o => {
  o.scores = {};
  CRITERIA.forEach(c => {
    const vals = [], notes = [];
    judges.forEach(j => {
      const cell = j.scores && j.scores[o.id] && j.scores[o.id][c.key];
      if (cell && typeof cell.score === 'number') { vals.push(cell.score); if (cell.note) notes.push(cell.note); }
    });
    if (vals.length) o.scores[c.key] = { mean: Math.round((vals.reduce((a, b) => a + b, 0) / vals.length) * 100) / 100, spread: Math.max(...vals) - Math.min(...vals), notes: notes[0] || '' };
  });
  const ms = Object.values(o.scores).map(s => s.mean);
  o._rawMean = ms.length ? ms.reduce((a, b) => a + b, 0) / ms.length : 0;
});
const top = [...options].sort((a, b) => b._rawMean - a._rawMean).slice(0, 3);
log(`Scored by ${judges.length} judges; stress-testing top ${top.length}`);

phase('Stress-test');
const ADV_SCHEMA = {
  type: 'object',
  properties: {
    optionId: { type: 'string' },
    verdict: { type: 'string', enum: ['survive', 'wounded', 'killed'] },
    killerRisks: { type: 'array', items: { type: 'string' } },
  },
  required: ['optionId', 'verdict', 'killerRisks'],
};
const adversarial = (await parallel(top.map(o => () =>
  agent(
    `You are a skeptical investor trying to REFUTE this build option. It is the present day.\nCONTEXT: ${CONTEXT_STR}\nOPTION: ${o.name} (${o.lens}) — ${o.thesis}\nMVP: ${o.mvpScope}\nHow it claims to beat the incumbent: ${o.incumbentBeat}\n\nAttack it: the incumbent's most likely counter-move, hidden costs, regulatory/liability landmines, distribution reality, and why it could fail. Then verdict: "killed" (a fatal flaw), "wounded" (serious but survivable risks), or "survive" (holds up). List the concrete killer risks. Return optionId exactly "${o.id}".`,
    { label: `refute:${o.id}`, phase: 'Stress-test', schema: ADV_SCHEMA }
  // Bind the verdict to the option by construction (closure), never by the model's
  // echoed optionId — a paraphrased echo previously joined to nothing and silently
  // defaulted every option to {survive, []} (proving run 2026-07-02).
  ).then(v => (v ? { ...v, optionId: o.id } : v))
))).filter(Boolean);
const advById = {}; adversarial.forEach(a => { advById[a.optionId] = { verdict: a.verdict, killerRisks: a.killerRisks }; });
options.forEach(o => { o.adversarial = advById[o.id] || { verdict: 'survive', killerRisks: [] }; delete o._rawMean; });

return { options, criteria: CRITERIA, judgeCount: judges.length, stressTested: top.map(o => o.id) };
