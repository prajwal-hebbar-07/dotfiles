# Launch campaign: <product in a few words>

<One short paragraph, first person: what I built, who it is for, and what a
reader should do after the last post. Trade-off in the same breath if the
files support it. No architecture. No file names.>

**Job:** launch / OSS adoption / waitlist / explain — <one line>
**Speaks as:** personal / product — <handle if known, else "unknown">
**Subreddits:** r/<name>, r/<name>
**Inferences:** <what you assumed, or "none">

## Freshness

twitter-campaign-baseline: <full sha>

Last sweep: <YYYY-MM-DD>

## Arc

- **Start:** <the world before this, or the itch that started the repo — only
  what the files support>
- **End:** <the reader knows what it is, believes it, and takes the last-post
  action>

## How to post this campaign

This document is the contract. Post in order. Do not skip a beat to "start
with the demo".

1. Produce every asset marked **required** before that post goes out. A
   screenshot note is not a screenshot. A generate prompt is not an image.
2. Paste Twitter **Copy** unchanged unless a fact in the product has changed —
   then fix the fact, not the vibe. Count characters per TWITTER SPEC in the
   skill (URLs = 23; spaces and newlines count; no hashtags unless this
   document wrote one).
3. Post one Twitter beat per weekday unless a **Cadence** line says otherwise.
   A thread is one beat: post the hook, then the replies in order, same day.
4. Do not add hashtags, emoji, or a "what do you think?" that this document
   did not write.
5. Pin the Twitter post this document names under **Pin**.
6. Post each Reddit **Copy** to the named subreddit only after every asset in
   its **Assets** line exists. Do not add a screenshot Reddit does not already
   inherit from Twitter.
7. If the product has moved on and a post would be false, stop. Update this
   file. Do not post a lie.

## Cadence

One Twitter beat per weekday. Reddit posts in the same week as the last
Twitter beat whose asset they reuse. Dates only if a start day was given:
<none / dates>.

**Pin:** Twitter post <N> — <why>.

## Out of scope

What this campaign will not claim, even if it came up. Features that are not
in the tree. Numbers you do not have. Warts the files do not show.

## Twitter

| # | Role | Hook | Media |
| --- | --- | --- | --- |
| 1 | <role on the arc> | <first line of copy> | screenshot (required) |
| 2 | <role on the arc> | <first line of copy> | recording (required) |

---

### T1. <short name>

**Role:** <where this sits on the arc>

**Copy**

```
<ready to paste, first person, ≤ 280 characters>
```

**Chars:** <N> / 280

**Media:** Screenshot (required)

- Capture: <exact screen, route, command, or dialog>
- State: <logged in / empty / realistic data; no production secrets>
- Frame: <desktop or mobile; app chrome only>
- Highlight: <what the eye should hit>
- Alt: <one sentence>

**Do not post until:** that screenshot exists.

### T2. <short name>

**Role:** <where this sits on the arc>

**Copy**

```
<ready to paste, first person, ≤ 280 characters>
```

**Chars:** <N> / 280

**Media:** Recording (required)

- Capture: <the flow, start to end>
- Length: <seconds>
- State: <as screenshot>
- Frame: <as screenshot>
- Highlight: <what the eye should hit>
- Alt: <one sentence>

**Do not post until:** that recording exists.

**Added because:** <commit subject or changed path — only on posts appended
after the first sweep>

Repeat the `### TN.` block for every beat. Threads stay one row in the index
and add `### TNa`, `### TNb` under the beat — each with Copy, Chars, Media,
and Do not post until. Other Media values: `none`, `existing — path`,
`Generate (required)`. Appended posts keep **Added because**.

## Reddit

| # | Subreddit | Title | Assets |
| --- | --- | --- | --- |
| 1 | r/<name> | <post title> | T1 screenshot, T2 recording |

---

### R1. <short name>

**Subreddit:** r/<name>

**Title:** <ready to paste>

**Assets:** T1 screenshot, T2 recording

**Copy**

```markdown
## <section: how I built it / the API wart / the diagram>

<long-form, first person, code or API detail from the tree>

## <section>

<next section — still the same post>
```

**Do not post until:** every asset in **Assets** exists.

**Added because:** <commit subject or changed path — only on posts appended
after the first sweep>

Repeat the `### RN.` block for every Reddit post. 2–4 posts. Each uses at
least one Twitter screenshot or recording. No visual that Twitter does not
specify.

## Asset map

Every Twitter screenshot or recording (and every generate used as a diagram
or UI) has one row. Each row is used by exactly one Reddit post.

| Asset | Twitter | Reddit | Section |
| --- | --- | --- | --- |
| T1 screenshot | T1 | R1 | <heading in R1 Copy> |
| T2 recording | T2 | R1 | <heading in R1 Copy> |

## Required assets

Every **required** item from the Twitter posts, in one checklist. Produce
these before the matching Twitter beat and before any Reddit post that maps
to them.

| Twitter | Kind | What to produce | Reddit |
| --- | --- | --- | --- |
| T1 | screenshot | <one line, same as Capture> | R1 |
| T2 | recording | <one line, same as Capture> | R1 |

If nothing is required: `None. Copy only.`
