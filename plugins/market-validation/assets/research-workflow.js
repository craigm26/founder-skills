export const meta = {
  name: 'market-validation-research',
  description: 'Validate demand for a product: multi-angle investigate -> curate -> live-URL verify -> synthesize a cited evidence pack',
  phases: [
    { title: 'Investigate', detail: 'one investigator per angle: search + fetch + extract falsifiable claims' },
    { title: 'Curate', detail: 'dedup, rank, balance claims; build competitor roster' },
    { title: 'Verify', detail: 'one tool-enabled verifier per claim re-fetches the cited URL' },
    { title: 'Synthesize', detail: 'cited evidence pack organized by proof dimension' },
  ],
}

// ---- parameters (Claude supplies these via args; the script does NOT invent angles) ----
const A = (typeof args === 'string') ? (function () { try { return JSON.parse(args); } catch (e) { return {}; } })() : (args || {});
const CFG = A.config || {};
const PRODUCT = CFG.product || 'the product';
const TODAY = CFG.date || 'today';
const SCOPE = CFG.scope ||
  ('Market = software/services for ' + PRODUCT + '. Customer = ' + (CFG.customer || 'the target buyer') +
   '. Geography = ' + (CFG.geography || 'US') + '. Strongly prefer recent, credible sources and CURRENT status as of ' + TODAY + '.');

// Each angle: { key, title, focus }. Claude assembles the set in Phase 0/1 (4 fixed dimensions +
// product-specific angles) and passes it via args.angles. This fallback is the minimum viable set.
const DEFAULT_ANGLES = [
  { key: 'pain', title: 'Customer pain & demand', focus: 'Surveys, trade press, forums, and direct customer quotes showing the target customer feels this pain acutely and wants help. Capture specific numbers and direct quotes.' },
  { key: 'competitor', title: 'Competitors & funding', focus: 'Companies/startups building this or adjacent products. Capture company name, what it does, funding raised, traction, and a resolving source URL. Find as many real ones as possible.' },
  { key: 'wtp', title: 'Willingness to pay', focus: 'Evidence the customer already PAYS for this or a substitute (fees, % cuts, dedicated headcount, third-party services). Any pricing data or revealed-preference spend.' },
  { key: 'counter', title: 'Counter-evidence & risks', focus: 'HONEST counter-evidence: failed startups, customers who avoid the problem, evidence it is NOT a top pain, free/commoditized substitutes, and current market/political/funding risks. The strongest case AGAINST this market.' },
];
const ANGLES = (A.angles && A.angles.length) ? A.angles : DEFAULT_ANGLES;

const CLAIM_ITEM = {
  type: 'object',
  properties: {
    text: { type: 'string', description: 'A specific, falsifiable claim' },
    quote: { type: 'string', description: 'Exact supporting quote/number from the source; prefix "[search snippet]" if not from a fetched page' },
    dimension: { type: 'string', enum: ['pain', 'competitor', 'wtp', 'context', 'counter'] },
    sourceUrl: { type: 'string' },
    sourceTitle: { type: 'string' },
    sourceDate: { type: 'string', description: 'Publication date if known, else empty string' },
    company: { type: 'string', description: 'Company name if a competitor claim, else empty string' },
    funding: { type: 'string', description: 'Funding/traction detail if stated, else empty string' },
  },
  required: ['text', 'quote', 'dimension', 'sourceUrl', 'sourceTitle'],
};
const INVESTIGATOR_SCHEMA = {
  type: 'object',
  properties: { angle: { type: 'string' }, claims: { type: 'array', items: CLAIM_ITEM } },
  required: ['angle', 'claims'],
};
// Looser fallback: same shape, but only `text` is hard-required per claim, and the
// claims array itself is optional. A flaky host that choked on the strict structured
// output can still contribute a best-effort batch; weak/partial claims are still
// adversarially re-checked in the Verify phase, so resilience here never lowers the bar.
const LOOSE_CLAIM_ITEM = {
  type: 'object',
  properties: CLAIM_ITEM.properties,
  required: ['text'],
};
const LOOSE_INVESTIGATOR_SCHEMA = {
  type: 'object',
  properties: { angle: { type: 'string' }, claims: { type: 'array', items: LOOSE_CLAIM_ITEM } },
  required: [],
};

// Run one investigator angle with a retry / looser-schema fallback so flaky-host
// failures (a null "skipped" return OR a thrown schema-validation error) don't silently
// thin research breadth. STRICT attempt first; on any failure, ONE retry with the loose
// schema. If BOTH fail, log the dropped angle by NAME (quality rule: no silent caps) and
// return null so the existing `.filter(Boolean)` backstop drops it visibly, not silently.
async function investigateAngle(a) {
  const prompt = `You are a market-research investigator.\nSCOPE: ${SCOPE}\n\nYOUR ANGLE: "${a.title}"\nFOCUS: ${a.focus}\n\nSTEPS:\n1. Run 3-5 WebSearch queries for this angle. Prefer recent and credible sources (trade press, surveys, company sites, funding announcements, government/program pages). Avoid generic SEO listicles.\n2. WebFetch your 3-5 best sources.\n3. Extract 4-8 FALSIFIABLE claims. Each needs: an exact supporting quote/number, the source URL, source title/publisher, and a date if available. Tag each claim's dimension (pain | competitor | wtp | context | counter).\n4. For competitor claims: capture company name, what it does, funding/traction if stated.\n5. Prefer specific numbers, named companies, dated facts, and direct customer quotes over vague generalities. If a fetch fails you may use the search snippet, prefixed "[search snippet]".\nReturn your best claims.`;
  // Attempt 1: strict structured output.
  try {
    const r = await agent(prompt, { label: `investigate:${a.key}`, phase: 'Investigate', agentType: 'general-purpose', schema: INVESTIGATOR_SCHEMA });
    if (r) return r;
  } catch (e) {
    log(`Investigator "${a.key}" (${a.title}) strict attempt failed (${e && e.message ? e.message : e}); retrying with looser schema`);
  }
  // Attempt 2: looser schema (best-effort). Still real claims, just fewer required fields.
  try {
    const r2 = await agent(
      prompt + `\n\nNOTE: a stricter pass did not return usable structured output. Return whatever real, sourced claims you have — at minimum each claim's text; include sourceUrl/quote wherever you can. Do NOT invent sources or numbers.`,
      { label: `investigate-loose:${a.key}`, phase: 'Investigate', agentType: 'general-purpose', schema: LOOSE_INVESTIGATOR_SCHEMA }
    );
    if (r2) return r2;
  } catch (e) {
    log(`Investigator "${a.key}" (${a.title}) loose retry also threw (${e && e.message ? e.message : e})`);
  }
  // Both attempts failed: make the coverage loss VISIBLE before .filter(Boolean) eats it.
  log(`DROPPED ANGLE "${a.key}" (${a.title}): investigator returned no usable claims after strict + loose attempts — research breadth reduced by this angle.`);
  return null;
}

phase('Investigate');
const raw = await parallel(ANGLES.map(a => () => investigateAngle(a)));
const survivedAngles = raw.filter(Boolean);
const droppedAngles = ANGLES.length - survivedAngles.length;
const allClaims = survivedAngles.flatMap(r => (r.claims || []));
log(`Collected ${allClaims.length} raw claims across ${survivedAngles.length} of ${ANGLES.length} dispatched angles` + (droppedAngles ? ` (${droppedAngles} angle(s) DROPPED after retry — see logs above; coverage reduced)` : ''));

phase('Curate');
const CURATE_SCHEMA = {
  type: 'object',
  properties: {
    claims: { type: 'array', items: CLAIM_ITEM },
    competitors: { type: 'array', items: { type: 'object', properties: { name: { type: 'string' }, what: { type: 'string' }, funding: { type: 'string' }, sourceUrl: { type: 'string' } }, required: ['name', 'what', 'sourceUrl'] } },
  },
  required: ['claims', 'competitors'],
};
const curated = await agent(
  `You are curating market-research claims for an evidence pack on demand for: ${PRODUCT}.\nHere are ${allClaims.length} raw claims (JSON):\n${JSON.stringify(allClaims)}\n\nDo:\n- Drop vague, redundant, or non-falsifiable claims.\n- Merge near-duplicates (keep the strongest-sourced version).\n- Keep the 18-24 STRONGEST, most decision-relevant claims, balanced across dimensions (ensure pain, competitor, wtp, and counter are all represented).\n- Build a deduped competitor roster (name, what it does, funding/traction, source URL).\nPreserve each claim's original quote, sourceUrl, sourceTitle, sourceDate, company, funding fields exactly.`,
  { label: 'curate', phase: 'Curate', schema: CURATE_SCHEMA }
);
const toVerify = (curated && curated.claims) ? curated.claims : [];
log(`Curated ${toVerify.length} claims; ${curated && curated.competitors ? curated.competitors.length : 0} competitors`);

phase('Verify');
const VERDICT_SCHEMA = {
  type: 'object',
  properties: {
    urlResolves: { type: 'boolean' },
    quoteConfirmed: { type: 'string', enum: ['confirmed', 'partial', 'not_found', 'unreachable'] },
    companyReal: { type: 'string', enum: ['yes', 'no', 'n/a', 'unsure'] },
    verdict: { type: 'string', enum: ['confirm', 'weaken', 'drop'] },
    reason: { type: 'string' },
  },
  required: ['urlResolves', 'quoteConfirmed', 'verdict', 'reason'],
};
const verified = await parallel(toVerify.map((c, i) => () =>
  agent(
    `Adversarially VERIFY this market-research claim against its LIVE source. It is ${TODAY}.\nCLAIM: "${c.text}"\nSUPPORTING QUOTE: "${c.quote}"\nSOURCE URL: ${c.sourceUrl}\nSOURCE: ${c.sourceTitle || ''}\n${c.company ? 'COMPANY: ' + c.company + '\n' : ''}STEPS:\n1. WebFetch the SOURCE URL. Does it resolve (not 404/dead)?\n2. Does the quote/number actually appear on (or clearly paraphrase content on) that page? Rate confirmed / partial / not_found / unreachable.\n3. If this is a competitor/company claim: is the company REAL and does it do what's claimed? (a quick WebSearch is allowed). Set companyReal yes/no/unsure (n/a if not a company claim).\nVERDICT: "confirm" only if the URL resolves AND the quote is confirmed AND (company real or n/a). "weaken" if it resolves but the quote is only partial / snippet-only / a minor mismatch. "drop" if the URL is unreachable/404, the quote is not found, or a named company cannot be verified. DEFAULT TO "drop" for any competitor you cannot independently confirm exists.`,
    { label: `verify:${i}`, phase: 'Verify', agentType: 'general-purpose', schema: VERDICT_SCHEMA }
  ).then(v => ({ ...c, verify: v }))
));
const checked = verified.filter(Boolean);
const survivors = checked.filter(c => c.verify && c.verify.verdict !== 'drop');
const dropped = checked.filter(c => c.verify && c.verify.verdict === 'drop');
log(`Verified: ${survivors.length} survived, ${dropped.length} dropped`);

phase('Synthesize');
const report = await agent(
  `Write a rigorous, CITED market-evidence pack (GitHub-flavored markdown) titled "${PRODUCT} — Market Evidence". Date it ${TODAY}.\nSCOPE: ${SCOPE}\n\nVERIFIED, SURVIVING CLAIMS (your facts; verify.verdict "confirm" = solid, "weaken" = present but flag as weaker/snippet-only):\n${JSON.stringify(survivors)}\n\nCOMPETITOR ROSTER (include only companies with a resolving sourceUrl):\n${JSON.stringify(curated && curated.competitors ? curated.competitors : [])}\n\nDROPPED CLAIMS (failed live verification — do NOT present as fact; may mention as a limitation):\n${JSON.stringify(dropped.map(d => ({ text: d.text, reason: d.verify && d.verify.reason })))}\n\nSECTIONS: 1) Verdict (is there a market + HIGH/MOD/LOW confidence + one sentence of sizing). 2) Pain-point demand (quotes + [n] citations). 3) Competitor validation (a markdown TABLE Company|Category/Tier|What|Funding|Source + what their existence proves; a Category column so failures/free counter-models are NOT laundered as demand). 4) Willingness to pay. 5) Global/regional signals. 6) Counter-evidence, risks & gaps (honest; current market/political risk; flag weak/snippet-only claims). 7) Sources (numbered, every URL).\nRules: cite inline [n] mapping to Sources; flag any "weaken"-verdict claim as weaker; do not invent sources/numbers; be candid about confidence.`,
  { label: 'synthesize', phase: 'Synthesize' }
);

return {
  report,
  survivors,
  competitors: (curated && curated.competitors) ? curated.competitors : [],
  droppedCount: dropped.length,
};
