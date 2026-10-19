# Retro (meta loop)

## Trace, during the run

Append one JSON line per agent run to `.factory/<id>/trace.jsonl`:

```json
{"step":"slice","issue":12,"slice":2,"round":1,"agent":"factory-review-gpt","model":"openai-codex/gpt-6.1-sol","verdict":"CHANGES","findings":{"Bug":1,"Gap":0},"standin":false}
```

Also log human corrections at gates (`{"step":"gate3","human":"revise","what":"<one line>"}`), queued questions, budget hits, and checks that fired.

## After the last issue

Write `.factory/<id>/retro.md` and show the human:

- **Repeated findings** (same class and pattern in 2+ slices or issues) → propose a check (ast-grep or lint rule, architecture test) that would have caught it, naming the decision it enforces.
- **Reviewer quality**: per reviewer agent, findings raised vs findings that led to a code change. A reviewer far below its pair is a candidate to swap (name the alias in `omp/config.yml` and a replacement model).
- **Escalations**: decision types that kept reaching the question queue → propose a Gate 3 question that would settle them up front.
- **Manual asks that repeated** across this or earlier runs → propose a new step or reference file in the factory skill.
- **Cost**: review rounds per slice, stand-ins used, budget hits.

Everything is a proposal. Never edit the factory skill, agents, or config yourself; the human decides and applies.

`stage: "done"`.

## Evals for the factory itself

Fixed eval tasks live in the plugin's `evals/` directory. When the skill, an agent, a model alias, or routing changes, the human can run them; the retro reminds them if a change happened since the last eval run.
