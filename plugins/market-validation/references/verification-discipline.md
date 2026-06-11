# Verification discipline (non-negotiable)

These are the rules that make a market-validation run *defensible* rather than plausible-sounding.
They were the load-bearing fixes in the run that this skill generalizes.

## 1. Live-URL verification (anti-hallucination)
Every curated claim is checked by **one tool-enabled verifier that re-fetches the cited URL** and confirms:
(a) it resolves (not 404/dead), (b) the quote/number actually appears on the page, (c) for a competitor,
the company is real and does what's claimed. **Default-drop** anything that won't confirm; **default-drop
any competitor you cannot independently confirm exists.** Internal-consistency checking is NOT enough — the
real risk in a "prove the market" pack is *fabrication* (a company that doesn't exist, a dead URL, a quote
never on the page). One tool-enabled verifier beats N toolless voters for this, and is cheaper.

## 2. Mandatory counter-evidence angle
The research angle set ALWAYS includes a counter-evidence angle: failed startups, customers who avoid the
problem, evidence it is *not* a top pain, free/commoditized substitutes, and current market/political/funding
risk. The synthesis ALWAYS has a "Counter-evidence, risks & gaps" section. No cherry-picking.

## 3. Honest competitor tiers
The competitor table carries a **Category/Tier** column so failures and free counter-models are not laundered
as demand. Only the `direct` tier is straight "the market is real" validation.

## 4. Flag weak sources
Snippet-only or vendor-marketing claims are explicitly flagged as weaker (not promoted to facts). Confidence
is stated as HIGH/MODERATE/LOW per major claim.

## 5. Single source of truth
One canonical `deck-data.json` drives every artifact (deck.html, .pdf, .pptx, market-map JSON, brief). Never let
the deck, the PPTX, and the report drift — generate them all from the same object.

## 6. Apply your own discipline to your own claims
When you assert how an artifact integrates ("this loads into X today"), verify it the same way you verify
research claims. If you only *read* that a path works but never *ran* it, say "described, untested" — see
`sinks.md` for the standing example (an emitted map is shape-valid; each sink's load path is untested until run).

## Tufte checklist for the deck
- Maximize data-ink; zero chartjunk. Default grayscale; colour only to encode meaning (durable/frozen/tier).
- Range-frames + direct labels, not full axes + legends. Bar length/height ∝ value (lie factor ≈ 1).
- Collision test: no text overlaps another text or a data mark (e.g., spread same-period funding events).
- Charts adapt to available data; omit a chart whose data block is absent rather than faking it.
