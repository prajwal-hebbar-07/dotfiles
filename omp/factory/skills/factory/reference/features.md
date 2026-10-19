# /factory features

Lists every complete module or feature in the application, computed from the code each time. Works in any repo; commits nothing; needs no run grant (it runs only read-only commands).

## Do

1. Append `.factory/` to `.git/info/exclude` if absent. Spawn `factory-features`:

```
Repo: <root>. Base branch: <base>.
List every complete module or feature of this application (for example an auth module, a to-do list feature), from the code.
If .factory/ exists, also read every .factory/*/state.json for issue numbers, PRs and branches; and list docs/walkthroughs/.
Write the list to .factory/features.md in the format of skill://factory/reference/features.md, section "Output".
```

2. Print `.factory/features.md` to the human as it is.

## Output

```markdown
# Features — <repo> @ <short sha>

| Feature | Purpose | Entry points | Main files | Tests | Built by |
| Auth | Sign-up, sign-in, sessions | `POST /api/signup`, `POST /api/login`, `<LoginPage>` | `src/auth/` | `tests/auth/*.test.ts` (14) | #12 · PR #13 · docs/walkthroughs/auth.md |
| To-do list | Create, complete, delete tasks | `/todos`, `TodoService` | `src/todos/` | `tests/todos/` (9) | — |

Not a feature: <shared infrastructure found, e.g. `src/lib/db.ts` (database client), with one line each>
```

A feature is something a user or caller can do end to end, or a self-contained module other code depends on through one interface. Shared plumbing goes under "Not a feature". Test counts come from counting test cases in the files, not from running them.
