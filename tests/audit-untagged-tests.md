---
name: audit-untagged-tests
description: For every test that isn't tagged with a spec ID, decide whether to tag it (matching or extending an existing scenario), propose a new spec item, or discard it. Add the judgement as a comment after the it(...) line and draft new spec items into the docs markdown. Do not refactor test code.
---

## Inputs

Ask the user for:

1. **Documentation repo path** — contains `CLAUDE.md` and the spec markdown (e.g. `docs/index.md`).
2. **Test repo path(s)** — usually listed in the documentation repo's `CLAUDE.md`. Run the audit per repo.

If the user gives a single repo path and it looks like the docs repo (has `CLAUDE.md` + `docs/`), read `CLAUDE.md` to find linked test repos automatically.

The `find-untagged-tests.sh` script lives next to this skill file.

## Setup

1. Read the docs repo's `CLAUDE.md`. Note:
   - Spec file location (e.g. `docs/index.md`).
   - Test repo location(s).
   - Notation conventions (`[x]`, `[~]`, `[ ]`, `#вопрос`).
   - Tag pattern (e.g. `[SECTION-NAME-NN]`).
   - Typography rules (`→`, `«»` etc.).
   - Spec language (the spec sentences will be written in this language).

2. Read the spec markdown file end-to-end. Note:
   - Existing scenarios and their IDs (so you can propose next-available IDs).
   - Section structure (so new items land in the right place).
   - Vocabulary the spec already uses for analogous concepts: «режим активируется», «открывается окно», «появляется на карте», «значения по умолчанию», «кнопка становится доступной», etc. Reuse this vocabulary when drafting new items — do not invent new phrasing for old ideas.

3. Run `find-untagged-tests.sh <test-repo>` and capture the list of untagged `it()` calls per file.

## Mindset

- **«Тест — это и есть спец»** — every test should map to a spec scenario.
- Three buckets for unmapped tests:
  - **Hidden spec item** → propose adding to the spec, then tag.
  - **Redundant** → recommend discard or merge.
  - **Implementation detail** → recommend discard unless it has independent value.
- Bias toward "less is more": prefer one test per spec rule. If multiple tests verify the same rule, suggest a merger.
- **Don't refactor test code.** Judgements live in comments. Refactor proposals go inside the comment as commented-out pseudo-code.

## Process

Work file by file, top to bottom. For each untagged `it()`:

### Step 1 — Read what the test actually proves

Read the full test: setup, render, action, assertion. Trace into helpers if behavior is unclear. Identify what the test proves, not what its name claims.

### Step 2 — Categorize

Pick exactly one of the categories below. If unsure between two, escalate via a question (Step 4) rather than guessing.

#### A. Tag with existing spec ID

When the test proves the same user-facing rule as an existing scenario. This is the most common outcome.

Common patterns:

- **"Render markers/polygons/data from props"** tests (e.g. AccessNodeMarkers, ClosureMarkers, PoleMarkers, HomesView render-marker tests, EditPolygon "render polygon" test).
  - These map to the **-ADD-01 (mode activation)** scenario, NOT -ADD-02 (which is usually about creation on click).
  - The activated mode is what makes existing markers visible — the spec's «режим активируется» sentence often needs a richer description. Flag this in the comment.
  - ⚠️ Lesson learned: don't reflexively tag these as -ADD-02. Read the spec sentence carefully — if -ADD-02 describes a creation action ("кликнуть на карту → появляется"), the render test does NOT fit there. The render test is about display of existing data, which is a precondition/consequence of being in the mode.

- **Reducer-level tests** asserting state transitions that mirror UI scenarios (e.g. `POLYGON_CONFIRMED` → idle).
  - Tag with the corresponding UI-level spec ID (e.g. `LOCATION-CREATE-06`).
  - Same rule, different layer.

- **Negative-path tests of an existing rule** — see B.

#### B. Negative-path tests

Two flavors, decide which:

1. **Same-rule negative** (boundary check). The test proves a side of the same rule the positive test proves. Example: "button disabled when name empty" is the boundary of "button enabled when both filled."
   - Same spec ID as the positive.
   - Suggest merging multiple negative-path tests into one parameterized `it.each` (inside the comment, as a snippet).
   - Heuristic for "is this negative test needed?": the positive test alone passes against a "too permissive" implementation (e.g. button always enabled). If yes, the negative is needed.

2. **Separate-behavior negative** (system DOES something visible). Example: invalid input → "shows error message".
   - Own spec item. Propose a new ID and a sentence.

If the negative path is "nothing happens" AND another tagged test already pins the gating rule (e.g. via disabled-button state), the negative test may be **redundant** — see D.

#### C. Add a new spec item

When the test exposes a real user-facing rule not yet documented. Common patterns:

- **Tree expand/collapse mechanics** (list/accordion): "click to expand", "click again to collapse", "independence of branches". One new subsection covering all related rules.
- **UX niceties**: auto-fill linked select when its parent is chosen, clear dependent select when parent changes, etc. One new subsection («Выбор области и района») covering the cluster.
- **Form-default rule**: "every modal open returns to default values" — one general rule, multiple tests verify (first open, reopen after cancel, reopen after success). It's one spec sentence, not three.
  - ⚠️ Lesson learned: do not phrase as "empty input" — phrase as "default values" (some fields have non-empty defaults, e.g. closure type = `distribution`).
- **Error-state display**: explicit «ошибка → отображается сообщение» step.
- **Optional-fields persistence**: when an entity has fields beyond the spec-documented mandatory ones — propose a step that says optional fields persist on save.

When proposing a new ID, count existing IDs in the section and use the next number (e.g. if `LOCATION-CREATE` goes up to `-06`, propose `-07`).

#### D. Likely redundant

The test exercises the same code path as another tagged test from a different angle. Common patterns:

- Multi-click variants of a single-click test (same handler, repeated).
- Enter-key submission negative tests when the click-save positive test exists AND the disabled-button gate is shared (same controlled-form code path).
- Parameterizations over enum values that don't change behavior — the enumeration belongs in «Модель данных», not in behavior tests.
- "Cleared-field" edge cases when the default-empty case is already covered (filled-then-cleared has no semantic difference from never-filled).
- "Match snapshot" tests when behavioral tests already cover the visible state.

Recommend discard, OR fold into an existing tagged test as a parameterized case. State which.

#### E. Discard outright

- Pure shape assertions that re-state source literals (e.g. "initial state equals { mode: 'idle', ... }"). A typo updates both — no spec value.
- DOM snapshots that don't encode a domain rule and are covered by behavior tests.
- Tests for behaviors decided NOT to be features (e.g. click-to-select on an entity that has no edit-data flow — confirm with a question first).
- Snapshot tests under strict «тест = спец»: snapshots don't encode a behavior rule, so they don't fit. Even if they catch CSS regressions, the right move is to assert the rule explicitly (e.g. data-attribute, class) and discard the snapshot.

### Step 3 — Write the comment

Format — single block comment **inside the test body**, immediately after the `it(...)` opening line:

```js
it('description', () => {
  // → [Decision]. [Reasoning, 1-2 lines].
  //   [Optional: refactor proposal — commented-out pseudo-code]
  ...
})
```

Decision phrases (use exactly these openings):

- `Tag as [SPEC-ID].` — and if the spec sentence needs broadening, say so: `Spec description for [SPEC-ID] needs a richer description of <what>.`
- `Add spec item under «<section>»: «<scenario sentence in spec language>». Tag e.g. <NEW-SPEC-ID>.`
- `Same rule as the previous test; same tag.`
- `Likely redundant with [SPEC-ID].` — explain why.
- `Discard.` — say why.
- `Cannot decide — needs business input.` — and follow up with a question in Step 4.

For refactor proposals, include the proposed snippet **inside the comment** as commented-out pseudo-code (no actual edit to the test body). Example:

```js
// → Merge this and the next test into one parameterized test tagged
//   LOCATION-CREATE-05 (negative path).
//
//   it.each([
//     { missing: 'name',     fill: () => setSelectOption(districtSelect, '...') },
//     { missing: 'district', fill: () => typeInInput(nameInput, '...') },
//   ])('should disable save when $missing is missing [LOCATION-CREATE-05]', ({ fill }) => {
//     renderComponent({})
//     fill()
//     testButtonDisabled(saveButton)
//   })
```

Style:
- Comments in **English** (matches the test code).
- New spec sentences in the **spec's language** (e.g. Russian for linkup-docs).
- Use the spec's typography (`→`, `«»`) when writing in the spec's language.
- Keep terse — 2-4 lines per comment. Don't restate what the test code already shows.

### Step 4 — Ask questions for unclear cases

When the decision depends on a business choice you can't infer from the spec or code, **stop and ask via `AskUserQuestion`** — one question at a time, never batched. Wait for the answer before continuing.

Required questions (skip if already answered for this audit):

1. **Edit-data scenarios for entities with click-to-select tests**:
   "Is there a planned «Редактирование данных <entity>» scenario? <entity> has click-to-select but no edit-data step in the spec."
   Options: yes (add it) / no (discard test) / not decided (mark `#вопрос`).

2. **Optional fields in create modals**:
   "<entity> has fields beyond the documented required one. How should they be represented?"
   Options: separate scenario step / bundled into save / not documented (impl detail).

3. **Form reset on second modal open**:
   "Is the fresh-defaults-on-each-open behavior intentional?"
   Beware of a trap: the test name may say "when map is clicked again" but the actual real-app behavior is that the modal blocks a second map click — the test passes because the fake adapter doesn't simulate that block. Note this discrepancy explicitly in your follow-up.

4. **Any other intentional-vs-accidental** behavior surfacing in a test but missing from the spec — confirm before proposing a new spec item.

Phrase questions so the options are concrete actions (tag X, add scenario Y, discard) — not abstract preferences.

### Step 5 — Draft new spec items into the docs markdown

After the test-file pass, append proposed new spec items into the docs markdown:

- Insert each new item into the **appropriate existing section** (under «Создание локации», under «Редактирование локации», etc.) at the position matching the user's mental model — usually after the related existing items.
- Use the next-available ID number in that section.
- For new clusters (e.g. «Раскрытие и сворачивание дерева», «Выбор области и района»), create a new subsection at the right depth.
- Mark each new line with a clear draft marker — recommended convention:
  ```
  - [ ] `LOCATION-CREATE-07` Ошибка при сохранении → отображается сообщение `#draft`
  ```
  The `#draft` suffix tells the developer "this was proposed by the audit, review before promoting."
- **Do not** rewrite existing spec items. If an existing -ADD-01 sentence needs broadening, note it in the test-file comment, but leave the spec line alone — the developer decides whether to rewrite.
- **Match the spec's typography**: `→`, `«»`. Russian (or whatever language the spec uses) for the sentence, English for the ID.

## Common pitfalls (lessons learned)

- **-ADD-01 vs -ADD-02 confusion**: render-from-data tests are -ADD-01 (mode activation includes "existing markers visible"), not -ADD-02 (creation on click). Read the existing spec sentence for -ADD-02 before tagging — if it describes a creation action, the render test does not belong there.
- **"Empty" vs "default values"**: don't write "modal opens with empty input" if some fields have non-empty defaults (e.g. closure type = `distribution`). Use "со значениями по умолчанию".
- **Test name vs test reality**: a test named "X when map is clicked again" may actually verify "fresh state on next modal session" because the fake adapter doesn't simulate the real app's modal-blocks-map behavior. Read the actual sequence before commenting; call out the discrepancy.
- **Snapshot mislabeled cases**: occasionally a snapshot test's title contradicts the actual prop values (e.g. title says "faulty" but `faulty={false}`). Snapshots don't catch the swap. Call this out.
- **Don't refactor test code under "judge" mode**. Proposed refactors live in comments. The developer reviews, then applies.
- **One question at a time**. Never batch business questions into a multi-question call — the user wants to discuss one before the next is even asked.
- **Don't reuse training-data spec IDs**. Always count from the actual spec file. The next ID after `-06` is `-07`, regardless of what some other project does.

## Final output

After all test files are commented and the docs draft section is updated, print a summary to the user. Group by decision category:

- **Tag with existing spec items**: `<test file>:<line>` → `[SPEC-ID]`. Note where spec description needs broadening.
- **New spec items drafted**: list with proposed IDs and sentences (so the user can review without opening the file).
- **Likely redundant**: list with explanation.
- **Discard outright**: list with reason.
- **Open questions / `#вопрос`**: list with the unresolved business decision (only if any remain unanswered).

The user then reviews the comments and the doc drafts, decides which to promote, and applies the merges/discards manually. The skill stops here.
