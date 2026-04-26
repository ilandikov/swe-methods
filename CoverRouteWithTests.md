# Cover a Route with Integration Tests

## Overview

This method produces a test suite that fully covers a single route file. Tests are integration tests — they run against a real database and exercise the full stack: HTTP handler → SQL → response. SQL is an implementation detail; tests assert on HTTP responses only.

## Prerequisites

Before starting, verify the test infrastructure is in place:

- A test database exists and is reachable
- `npm test` runs and exits cleanly (even with zero tests)
- A test setup file truncates all tables between tests
- A `buildApp()` (or equivalent) function is exported separately from the server entrypoint so tests can import the app without starting the HTTP server

If any of these are missing, set them up first.

## Step 1: Read the Route File

Read the entire route file top to bottom. For each handler, note:

- The HTTP method and path
- What it returns on success (status code + shape)
- What it returns on each error path (status code + shape)
- What external dependencies it needs (e.g. a valid foreign key ID to satisfy a constraint)

This gives you the list of cases to cover.

## Step 2: Write the First Test

Pick the simplest happy path — usually a POST followed by a GET. Write one test that:

1. Seeds any required reference data (e.g. a parent record needed for a foreign key)
2. Calls the write endpoint
3. Asserts the response status and shape
4. Calls the read endpoint
5. Asserts the created record appears in the response

Run `npm test` and confirm it passes before continuing.

## Step 3: Check Coverage

Run tests with coverage enabled. Read the coverage report for the route file. Note every line or branch that is not yet covered.

## Step 4: Cover Each Uncovered Line

Work through uncovered lines one at a time. For each:

1. Identify what condition triggers that line (error path, edge case, conflict check)
2. Write a test that exercises exactly that condition
3. Run `npm test` and confirm the new test passes and the line is now covered

Repeat until the route file is fully covered.

## Steps 5 & 6: Optional Cleanup (ask first)

Before doing either of these, ask the user: *"Do you want to extract test data and helpers now, or move on?"* Only proceed if they say yes.

## Step 5 (Optional): Extract Test Data

Once you have tests for more than one route file, move shared geometric or domain constants into a `test/testData.ts` file and import them where needed. This keeps individual test files focused on behaviour rather than data definitions.

What belongs in `testData.ts`:
- Geometric fixtures reused across files (polygons, points, coordinates)
- Any constant that would otherwise be copy-pasted between test files

What stays in the test file:
- String values (`name`, `label`, etc.) — these are part of the test's narrative and should stay inline where they're read

## Step 6 (Optional): Extract Helpers

Once you have two or three tests, look for repeated patterns — building request options, awaiting and parsing responses, asserting a specific status code. If the same shape appears across tests, extract a helper.

Guidelines:
- Helpers for happy paths (e.g. `sendPOST`, `sendPATCH`) can assert the expected status internally and return the parsed body directly. This keeps test bodies focused on what matters.
- Error-path calls (expecting 4xx) should stay as raw `app.request()` calls or use a separate helper — do not mix success and error assertions in the same helper.
- Helper signatures will differ across projects. Do not assume names or parameters from a previous session — check what exists in the test folder first.
- The right time to extract is after two or three tests, not after one (too early) and not after all tests are written (refactoring becomes larger).

When reusing helpers across multiple route test files, check whether the existing helpers already cover the shape you need. Extend them only if necessary.

## Naming Test Data

Test data constants and string values should reflect their role in the scenario, not their abstract properties.

**Constants** must say what they are relative to — not just what they are geometrically or generically. `POINT_INSIDE_POLYGON` is clear; `POINT_INSIDE` raises the question: inside of what?

**String values** (names, labels, etc.) should tell the story of the test:

- Data that plays a narrative role in an error scenario gets a first-person English sentence:
  ```typescript
  name: 'I will be overlapping with the new location'
  label: 'I am outside the polygon'
  ```
- Before/after values in update tests get descriptive words in the project language:
  ```typescript
  label: 'Старый ярлык'  // before
  label: 'Новый ярлык'   // after
  ```
- Neutral fixture data gets a real-sounding value, not a placeholder:
  ```typescript
  name: 'Северный квартал'  // not 'Test Location' or 'name1'
  ```

The rule: a reader who has never seen the test should understand each piece of data's purpose without reading the assertion.

## Test Order

Order tests by HTTP method: POST first, PATCH after. GET is not tested in isolation — it is used inside POST (and PATCH) tests to verify that writes persisted correctly.

This order mirrors the natural dependency: PATCH tests require a record to exist, so POST must come first. A reader scanning the file top-to-bottom sees creation before mutation.

## What Makes a Good Test

A good test is short, reads in one pass, and fails for exactly one reason.

**Aim for one `expect` per test.** If a test asserts five things, a failure tells you something broke — not what. One assertion per test makes failures self-explanatory.

**Use `toEqual` instead of `toMatchObject`.** `toMatchObject` only checks the fields you list — it silently ignores any extra fields the response returns. `toEqual` compares the full object, so an unexpected field in the response will fail the test. For dynamic fields like `id` or `createdAt`, use `expect.any(String)` to acknowledge them explicitly:

```typescript
expect(list).toEqual([
  {
    id: expect.any(String),
    createdAt: expect.any(String),
    name: 'Северный квартал',
    districtId,
    polygon: POLYGON,
  },
])
```

This is stricter and catches shape regressions that `toMatchObject` would miss.

Good:
```typescript
test('PATCH updates the name', async () => {
  const created = await sendPOST(app, '/locations', { name: 'Old', polygon: POLYGON, districtId })
  const updated = await sendPATCH(app, `/locations/${created.id}`, { name: 'New' })
  expect(updated).toEqual({ ...created, name: 'New' })
})
```

Too many concerns in one test:
```typescript
test('PATCH works', async () => {
  const created = await sendPOST(app, '/locations', { name: 'Old', polygon: POLYGON, districtId })
  const updated = await sendPATCH(app, `/locations/${created.id}`, { name: 'New' })
  expect(updated.name).toBe('New')
  expect(updated.polygon).toEqual(created.polygon)
  expect(updated.districtId).toBe(created.districtId)
  expect(updated.id).toBe(created.id)
  expect(updated.createdAt).toBe(created.createdAt)
})
```

The second version is not wrong, but if `districtId` fails you don't immediately know whether PATCH broke district handling or just returns the wrong shape. Split it if each assertion represents a distinct concern.

**Helpers reduce noise but can hide intent.** A helper like `sendPOST` that asserts 201 internally is fine when the status code is not the thing under test — it's setup. But when the status code *is* the thing under test, use a raw call:

```typescript
// The 409 is the point of this test — keep it visible
const res = await app.request('/locations', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ name: 'Overlap', polygon: OVERLAPPING_POLYGON, districtId }),
})
expect(res.status).toBe(409)
```

A helper that swallows the response and returns only the body would make this test impossible to write clearly.

The rule: use a helper when it removes repetition that is not relevant to the test's intent. Keep raw calls when the mechanics *are* the intent.

## Output

A test file that:
- Has one test per meaningful behaviour (happy path + each error branch)
- Passes `npm test` with the route file at or near 100% coverage
- Uses shared helpers for repeated request patterns where they exist
