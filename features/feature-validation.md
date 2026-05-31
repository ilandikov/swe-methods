---
name: feature-validation
description: Links spec test case IDs from the project's documentation to existing test descriptions in code. Run after feature.md, once scenario IDs exist in the spec and test skeletons or tests exist in the codebase.
---

Read the project's `CLAUDE.md` to find:
- Which markdown file holds the spec (scenario IDs live there)
- Where the tests are (relative paths to test directories)

## What this skill does

1. Extracts all `ENTITY-ACTION-NN` IDs from the spec
2. Reads every test file in the project
3. For each spec ID, finds the best-matching existing test and appends the ID to the `it()` description
4. For every test that has no spec ID, appends `[UNKNOWN-TEST-CASE-N]` with a globally incrementing counter

The result: `grep -r "MAP-GOTO-01"` finds both the spec line and the test. Every test is either owned by a spec case or explicitly flagged as undocumented.

## Mapping rules

**Match spec → test by behavior, not name.** The test description rarely mirrors the spec step word-for-word. Read what each test actually asserts, then ask: which spec step does this verify?

**One spec ID per test is the default.** If two tests cover different aspects of the same spec step (e.g., one checks modal opens, another checks button state), tag both with the same ID — that's fine.

**One test can cover at most one spec ID.** If a test clearly covers two distinct spec steps (e.g., "button enabled" and "save navigates"), pick the primary one — the outcome the user cares about most.

**Skip spec IDs that have no test.** Don't create empty tests. The spec → test gap is visible in the spec itself (open `[ ]` checkbox with no matching grep result).

**Append the ID in brackets at the end of the `it()` string:**
```ts
it('should open modal with empty input [MAP-GOTO-01]', () => { ... })
```

**UNKNOWN counter is global across all test files.** Number sequentially in the order you encounter tests without a spec match, file by file. Never reuse a number, even across sessions — check the highest existing `UNKNOWN-TEST-CASE-N` in the codebase before starting.

## What counts as UNKNOWN

Tag a test as UNKNOWN when:
- It tests internal state (reducers, context values) not described as a user-visible step in the spec
- It tests snapshot rendering with no behavioral assertion
- It tests a UI tree invariant (e.g., "region without locations is hidden") that exists as defensive coverage but was never written as a spec scenario
- It tests an edge case the spec doesn't mention (reset on second click, field clearing, etc.)

Don't tag as UNKNOWN:
- Tests that cover a spec step even partially — tag with the spec ID instead
- Tests that verify the negative of a spec step (e.g., spec says "button enabled when filled" → test "button disabled when empty" is still that same spec ID)

## Common ambiguities

**Same modal, two flows (create vs edit).** If a modal component is shared between a create flow and an edit flow, the same test may cover spec IDs from both. Tag with the creation flow ID when the test uses empty initial state; tag with the edit flow ID when the test uses pre-filled initial state.

**Multiple tests for one spec step.** Acceptable. Tag all of them with the same ID. Example: "fly to on button click [MAP-GOTO-03]" and "fly to on enter [MAP-GOTO-03]" — both verify the same user-observable outcome via different inputs.

**Mechanism test vs behavior test.** A test that calls `setSelectedClosure(...)` and checks the context value is a mechanism test (UNKNOWN). A test that opens a modal and verifies fields is a behavior test (tag with the spec ID for "clicking the marker opens the modal").

## After tagging

Update snapshot files if test description changes broke snapshot keys:
```
npx vitest run --update
```

Run the full test suite to verify nothing broke.
