---
name: factory-grill
description: >
  The factory's grilling primitive. Works a design tree in rounds of numbered
  questions, each with a recommended answer, until the frontier is empty.
  Also runs two named special rounds: pre-mortem (requirements) and
  simplicity (stack, architecture, feature sketch). Use when a factory stage
  skill or factory-gate says to grill, or when invoked as /skill:factory-grill.
argument-hint: "[round: pre-mortem | simplicity]"
disable-model-invocation: true
---

# factory-grill

Read by the stage skills (`skill://factory-grill`). The caller says the topic,
the document being built, and which special round (if any) to run. Design:
`SOFTWARE-FACTORY.md` §4.2. Based on mattpocock `grilling` and addyosmani
`interview-me`; each borrowed rule is credited inline.

## Never

- Use `ask` to grill. Grill in chat (§4.2; mattpocock `.out-of-scope/native-question-tool.md`:
  pickers push toward multiple choice with pre-baked answers). `ask` is only for
  the approval gate.
- Ask the user for a fact you can look up. Send a `scout`.
- Accept "whatever you think", "sounds good", "sure" as an answer.
- Ask a question whose answer depends on another open question in the same round.
- Edit the document before the round's answers are in, or act on the result
  before the user confirms shared understanding (mattpocock `grilling`).

## Rounds (mattpocock `grilling`)

Map the topic as a **design tree**: every decision branches into the decisions
that hang off it. Work it in **rounds**.

1. **Frontier.** List every decision whose prerequisites are settled: the
   questions you can ask now without guessing answers you have not heard. A
   question that depends on another open one in this round waits for a later
   round.
2. **Facts.** When a frontier question needs a fact (the repo, the tools, a
   doc), spawn a `scout` for it. Do not block: only questions downstream of the
   running scout wait; ask the rest now. Decisions always go to the user.
3. **Ask the whole frontier at once**, in chat, numbered across the session,
   in exactly this format:

   ```
   ❓ **Q1** - **<question title>**: <question; may be several paragraphs, may list choices>

   ➡️ <recommended answer>

   ---

   ❓ **Q2** - **<question title>**: <question>

   ➡️ <recommended answer>
   ```

   Word each question so "yes" accepts the recommendation. Then stop and wait.
4. **Read the answers.** "yes" (or "yes to all", "Q1 yes, Q2 no: <text>")
   accepts the recommendation. Fold each settled answer into the caller's
   document. Recompute the frontier; settled decisions unblock later ones.
   Next round.
5. **Interview-me guard** (addyosmani `interview-me`). "Whatever you think",
   "sounds good", "sure, let's go" are not answers: they are delegation or a
   polite exit. Re-ask that question alone with two concrete options framed as
   a choice. When an answer is a buzzword or convention ("scalable", "the
   standard way"), ask: "If you didn't have to justify this to anyone, what
   would you actually want?"
6. **Exit.** The frontier is empty (every branch visited, nothing silently
   assumed), the special round the caller named has been answered, every
   answer is folded into the document, and the user has confirmed shared
   understanding. If after several rounds you cannot predict the user's
   reactions, say so and ask whether to step back (`interview-me`).

## Round: pre-mortem (requirements stage only)

Run when the frontier is empty. Architecture does not get one: it already has
the two-model review (§4.5).

1. Spawn one `task` agent on `@slow` (a different model from the author),
   giving it `docs/factory/REQUIREMENTS.md` (R1..Rn, non-functional
   requirements, Out of Scope). Ask: "It is three months after launch and this
   has failed, or corrupted someone's data. What went wrong?" It returns likely
   causes: a failure path with no acceptance criterion, an abuse case, a
   permission gap, a partial failure in an integration. Each names the `R`
   numbers it touches or says none covers it.
2. Open the round with that same sentence, then ask one numbered question per
   cause in the format above. Recommended answer = one of: new requirement
   (draft it with Given / When / Then), non-goal (goes to Out of Scope), or
   accepted risk (named, with who bears it).
3. Fold each answer into REQUIREMENTS.md as a new `R`, an Out of Scope line, or
   a recorded accepted risk (addyosmani `idea-refine` `frameworks.md`
   "Pre-mortem"; BMAD `methods.csv` "Pre-mortem Analysis").

## Round: simplicity (stack, architecture, feature sketch)

Run before the stack and architecture gates, and on the feature factory's
solution sketch. One round walks every piece the draft adds: each dependency,
service, module, layer, abstraction, config option, piece of infrastructure.

1. Each question is the ponytail ladder (DietrichGebert/ponytail
   `skills/ponytail/SKILL.md`): does it need to exist, and does something
   already there do it (the codebase, the chosen stack, the standard library, a
   platform feature, an installed dependency)? Use `scout` for what exists.
2. The recommended answer is always the simpler option, plus what would
   justify the bigger one, so "yes" picks simple:

   ```
   ❓ **Q4** - **Job queue**: Do we need Redis + BullMQ for background jobs?

   ➡️ No. A `jobs` table the app polls covers R5–R7 at the expected load. Add a queue when jobs pass ~100 a minute.
   ```

3. Keeping the bigger option needs an `R` number or a constraint that requires
   it. "We might need it later" is not a reason; re-ask.
4. **Kept** pieces: write each into STACK.md / ARCHITECTURE.md (or the brief's
   solution sketch) with its reason, so later stages do not ask again.
5. **Dropped** pieces: write `docs/factory/out-of-scope/<concept>.md` with what
   was dropped and what would bring it back (the same notes `factory-gate`
   writes for struck scope). In feature mode there is no `docs/factory/`; add
   them to the brief's Out of scope section instead, with the same
   "would bring it back" line.
