#!/usr/bin/env python3
"""Aggregate token usage from a Claude Code session transcript (JSONL).

This is the seed tool for the MEASURED-NOT-CLAIMED research front in
fs-research-frontier. It turns a raw session transcript into a measurement
artifact: total tokens by type, message count, and per-model breakdown.

Usage:
    python3 aggregate_transcript_usage.py <transcript.jsonl> [--json]

Transcripts live at ~/.claude/projects/<escaped-cwd>/<session-id>.jsonl
(environment-specific: that is Claude Code's own storage location, verified
2026-07-02). Each assistant message line carries a "usage" object with
input_tokens, cache_creation_input_tokens, cache_read_input_tokens,
output_tokens.

Stdlib only. No dependencies. Read-only: never writes anywhere.
"""
import json
import sys
from collections import defaultdict

USAGE_KEYS = (
    "input_tokens",
    "cache_creation_input_tokens",
    "cache_read_input_tokens",
    "output_tokens",
)


def find_usage(obj):
    """Recursively find every dict that looks like a usage block."""
    if isinstance(obj, dict):
        if "usage" in obj and isinstance(obj["usage"], dict):
            u = obj["usage"]
            if any(k in u for k in USAGE_KEYS):
                model = obj.get("model") or "unknown"
                yield model, u
        for v in obj.values():
            yield from find_usage(v)
    elif isinstance(obj, list):
        for item in obj:
            yield from find_usage(item)


def main():
    args = [a for a in sys.argv[1:] if a != "--json"]
    as_json = "--json" in sys.argv
    if len(args) != 1:
        print(__doc__)
        sys.exit(2)
    path = args[0]

    totals = defaultdict(int)
    per_model = defaultdict(lambda: defaultdict(int))
    usage_blocks = 0
    lines = 0
    parse_errors = 0

    with open(path, "r", encoding="utf-8") as fh:
        for line in fh:
            line = line.strip()
            if not line:
                continue
            lines += 1
            try:
                record = json.loads(line)
            except json.JSONDecodeError:
                parse_errors += 1
                continue
            for model, u in find_usage(record):
                usage_blocks += 1
                for k in USAGE_KEYS:
                    v = u.get(k, 0) or 0
                    totals[k] += v
                    per_model[model][k] += v

    result = {
        "transcript": path,
        "lines": lines,
        "parse_errors": parse_errors,
        "usage_blocks": usage_blocks,
        "totals": dict(totals),
        "total_all_token_types": sum(totals.values()),
        "per_model": {m: dict(u) for m, u in per_model.items()},
    }

    if as_json:
        print(json.dumps(result, indent=2))
    else:
        print(f"transcript      : {path}")
        print(f"lines / errors  : {lines} / {parse_errors}")
        print(f"usage blocks    : {usage_blocks}")
        for k in USAGE_KEYS:
            print(f"{k:34s}: {totals[k]:>12,}")
        print(f"{'TOTAL (all types)':34s}: {sum(totals.values()):>12,}")
        for m, u in sorted(per_model.items()):
            print(f"  model {m}: " + ", ".join(f"{k}={u.get(k,0):,}" for k in USAGE_KEYS))


if __name__ == "__main__":
    main()
