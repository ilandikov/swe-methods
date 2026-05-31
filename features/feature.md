---
name: feature
description: Structured feature interview — asks the user questions one at a time to understand a new feature, then writes the result to the project's documentation following the conventions in CLAUDE.md.
---

Start by reading the project's `CLAUDE.md` to understand:
- Which files to write scenarios and data model changes to
- What notation to use (`[x]`, `[ ]`, open question markers, etc.)
- What writing style and language is expected
- What the step format looks like
- Any domain-specific rules

Then conduct the interview below.

## Interview rules

- Ask questions **one at a time**. Never ask two questions in one message.
- Do not write to any files until the interview is complete, unless the user explicitly asks you to write something now.
- If an answer reveals an open issue that needs a decision, note it using the project's open-question notation — continue the interview, don't block on it.
- Challenge the user when their answer has a meaningful tradeoff they may not have considered. Keep the challenge concise and offer a concrete recommendation.
- Stop when you have enough to write a complete scenario and update the data model.

## Questions to cover (adapt order and relevance to the conversation)

1. How does the user enter this mode or trigger this feature?
2. What are the exact steps the user takes, in order?
3. What happens at each decision point — confirm, cancel, error?
4. What data does the feature create or modify? What fields?
5. Are there forbidden or restricted cases?
6. What is displayed or how does it look on screen / on the map?
7. What is explicitly out of scope for now (future iteration)?
8. Does this feature introduce any new domain entities or relationships?

Always ask these specifically:

- **Save button:** is it disabled until required fields are filled? Which fields are required?
- **Cancel:** is there a cancel option? At what point can it be triggered? What state is restored?
- **Precondition:** does this feature require something to be selected or active first (e.g., a location, a mode)?
- **Directionality:** if the feature involves connecting two things, does it work in both directions?
- **Named UI elements:** what is the exact label on the button or control the user clicks?

## Writing rules

Follow whatever conventions are defined in the project's `CLAUDE.md` exactly — notation, language, file targets, step format, data model style. If `CLAUDE.md` is silent on something, default to: user-language steps in `действие → результат` format, open questions marked inline, data model as a domain glossary with no implementation details.

## Scenario writing patterns

**Feature title = user action (verb).** Not a noun, not a component name.
- ✗ «Список локаций»
- ✓ «Выбор локации из списка»

**Preconditions in the title, not as a scenario.** If a feature requires something to be pre-selected, say so in the feature line.
- ✗ `HOME-ADD-01` Select location from list → map moves to polygon
- ✓ Feature title: «Добавление дома в выбранной локации»

**Sequential actions within one scenario use a comma, not `→`.**
- ✗ `Ввести метку → нажать Enter → дом сохраняется`
- ✓ `Ввести метку, нажать Enter → дом сохраняется`

**Cancel scenario comes before save scenario** — ordered by minimal precondition. If cancel can happen after step N, place it immediately after step N.

**Save button disabled pattern** — when a form has required fields:
1. Opening the form → button disabled
2. Cancel (can happen here)
3. Fill required fields → button enabled
4. Save → result

**One result per scenario when results can vary independently. Multiple results are fine when always coupled.** "Modal closes, data saved" is one scenario — these never happen independently.

**No visual or implementation details** unless the visual IS the only observable result (e.g., a color-coded marker). Don't include: CSS properties, component names, animation descriptions, UI mechanism (dropdown vs toggle vs button group).

**Use exact button labels** in «» when the button name is fixed and specific. Use generic wording ("переключиться") when the UI mechanism is a design decision not yet made.

**Use concrete examples for readability** when the behavior depends on input format or case sensitivity — e.g., `«БАЙТИ» → «Байтик»`.

**Test granularity:** one scenario per distinct behavior. For forms with multiple optional fields, one test that edits any field and verifies it saved is sufficient. Don't test every field combination. Transport concerns (PATCH vs PUT, request payload shape) belong in the test code, not in the doc.

**Directionality:** if a feature connects two entities, test each direction as a separate scenario.

## Scenario IDs

When writing feature sub-bullets (individual test scenarios), assign each one a stable, greppable ID in backticks at the start of the line:

```markdown
- [x] Нарисовать полигон и сохранить локацию
  - `LOCATION-CREATE-02` Нажать «Отмена» в режиме рисования → полигон удаляется
  - `LOCATION-CREATE-03` Нарисовать полигон → открывается модальное окно, кнопка «Сохранить» недоступна
  - `LOCATION-CREATE-04` Нажать «Отмена» → окно закрывается
  - `LOCATION-CREATE-05` Ввести название, выбрать район и область → кнопка «Сохранить» становится доступной
  - `LOCATION-CREATE-06` Нажать «Сохранить» → локация создаётся и отображается на карте
```

**Format:** `ENTITY-ACTION-NN`

- **ENTITY** — the domain object the scenario touches (`LOCATION`, `HOUSE`, `POLE`, `SUBSCRIBER`, etc.)
- **ACTION** — what happens (`CREATE`, `EDIT-DATA`, `EDIT-POSITION`, `ADD`, `DRAW`, `EXPORT`, etc.)
- **NN** — two-digit sequence number within that group, starting at `01`

**Rules:**
- Use full words, not abbreviations. `LOCATION` not `LOC`, `POLYGON` not `POLY`, `SUBSCRIBER` not `SUB`, `POSITION` not `POS`.
- IDs are assigned once and never reused, even if the scenario is deleted.
- Don't assign IDs to open questions or prose notes — only to concrete action → result steps.
- Tests reference the ID in a comment: `// LOCATION-CREATE-03`
- `grep -r "LOCATION-CREATE-03"` finds both the doc and the test.

## Start

Ask the user: **"Describe the feature — what should the user be able to do?"**
