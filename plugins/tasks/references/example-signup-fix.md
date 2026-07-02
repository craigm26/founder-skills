# Worked example — exploding "fix the signup page" into prd.json

The worked example the `tasks` skill was generalized from: a debugging PRD whose single high-level
task becomes a 10-task, dependency-ordered `prd.json`. Browser criteria use the generic
`browser:` capability patterns (open / snapshot / click / fill / screenshot / console-check) —
the executing agent supplies its own browser executor.

## The split rule, illustrated

Too big (one task, four vague criteria):

```json
{
  "title": "Test signup flow and fix issues",
  "acceptanceCriteria": [
    "Test the signup flow",
    "Identify any issues",
    "Fix the issues",
    "Verify the fix works"
  ]
}
```

Properly split — investigation first (findings go to `notes`), one concern per task, verification
last:

## The input PRD task

```markdown
### T-001: Fix signup page with 0% conversion
- Test the signup flow
- Identify the bug
- Fix it
- Verify on mobile and desktop
```

## The exploded prd.json (10 tasks)

```json
{
  "project": "MyProject",
  "branchName": "compound/fix-signup",
  "description": "Fix broken signup page",
  "tasks": [
    {
      "id": "T-001",
      "title": "Load signup page and check for errors",
      "acceptanceCriteria": [
        "browser: open /signup - page loads (status 200)",
        "browser: screenshot saved to tmp/signup-desktop.png",
        "Console errors saved to notes field (or 'none' if clean)"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    },
    {
      "id": "T-002",
      "title": "Test signup page on mobile viewport",
      "acceptanceCriteria": [
        "Set viewport to 375x812 (iPhone)",
        "browser: open /signup - page loads",
        "browser: screenshot saved to tmp/signup-mobile.png",
        "CTA button visible in screenshot (not below fold)"
      ],
      "priority": 2,
      "passes": false,
      "notes": ""
    },
    {
      "id": "T-003",
      "title": "Test email input field",
      "acceptanceCriteria": [
        "Email input field exists and is interactable",
        "browser: fill email field 'test@example.com' - value appears in field",
        "browser: console shows no errors after typing"
      ],
      "priority": 3,
      "passes": false,
      "notes": ""
    },
    {
      "id": "T-004",
      "title": "Test password input field",
      "acceptanceCriteria": [
        "Password input field exists and is interactable",
        "browser: fill password field 'TestPassword123!' - value appears (masked)",
        "browser: console shows no errors after typing"
      ],
      "priority": 4,
      "passes": false,
      "notes": ""
    },
    {
      "id": "T-005",
      "title": "Test form submission",
      "acceptanceCriteria": [
        "browser: click submit button - button responds to click",
        "Loading state appears OR form submits",
        "Log result to notes: success redirect URL or error message"
      ],
      "priority": 5,
      "passes": false,
      "notes": ""
    },
    {
      "id": "T-006",
      "title": "Inspect SignUp component configuration",
      "acceptanceCriteria": [
        "Read file containing SignUp component",
        "Log routing prop value to notes",
        "Log forceRedirectUrl prop value to notes",
        "Log any other relevant props to notes"
      ],
      "priority": 6,
      "passes": false,
      "notes": ""
    },
    {
      "id": "T-007",
      "title": "Check middleware route protection",
      "acceptanceCriteria": [
        "Read middleware.ts file",
        "Log public routes array to notes",
        "Confirm /signup is accessible without auth"
      ],
      "priority": 7,
      "passes": false,
      "notes": ""
    },
    {
      "id": "T-008",
      "title": "Implement fix based on findings",
      "acceptanceCriteria": [
        "Review notes from T-001 through T-007",
        "Make targeted code change to fix identified issue",
        "Run `npm run typecheck` - exits with code 0",
        "Run `npm test` - exits with code 0"
      ],
      "priority": 8,
      "passes": false,
      "notes": ""
    },
    {
      "id": "T-009",
      "title": "Verify fix on desktop",
      "acceptanceCriteria": [
        "browser: open /signup",
        "Complete full signup with test credentials",
        "Redirect occurs to expected URL",
        "browser: console shows no errors during flow"
      ],
      "priority": 9,
      "passes": false,
      "notes": ""
    },
    {
      "id": "T-010",
      "title": "Verify fix on mobile",
      "acceptanceCriteria": [
        "Set viewport to 375x812",
        "browser: open /signup",
        "Complete full signup with test credentials",
        "Redirect occurs to expected URL"
      ],
      "priority": 10,
      "passes": false,
      "notes": ""
    }
  ]
}
```

## Why this split

- T-001–T-007 are pure investigation: each checks ONE surface (desktop load, mobile viewport, each
  input, submission, component config, middleware) and logs findings to `notes` — no fixing.
- T-008 is the only implementation task; it reads the accumulated `notes` and gates on typecheck +
  tests exiting 0.
- T-009–T-010 verify the fix end-to-end on both viewports, mirroring the investigation criteria so
  pass/fail is directly comparable.
