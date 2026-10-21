# <Feature>

Explains commit <sha> · <date> · written by <model>

## What it does

<Two to four sentences, from the user's side.>

## The path through the code

```mermaid
flowchart TD
  <one node per file, in the order the code runs>
```

## Step by step

### <n>. <What this step does> — `<path>:<start>-<end>`

```<language>
<the lines start–end, verbatim>
```

**What it does.**

- **Line <n>:** <in detail; line by line where a line is not obvious>

**Why it is written this way.**

- <reason> [<source: ADR NNNN, ARCHITECTURE.md, R<n>, PR #<n>, or commit <sha>>]
- <reason no written source gives> *(inferred)*

## Tests

### <Test name> — `<path>:<start>-<end>`

```<language>
<the test, verbatim>
```

<One line on what it proves.>
