# Documentation

architecture: <on|off>
plain-english: <on|off>

Technical pages live in `docs/architecture/`. Jargon-free pages live in
`docs/plain-english/`. Each surface is independent: keep one, the other,
or both. When both are on, the same number in each directory is a twin
pair.

| Architecture | Plain English |
| --- | --- |
| [`NN-<slug>.md`](architecture/NN-<slug>.md) | [`NN-<pe-slug>.md`](plain-english/NN-<pe-slug>.md) |

Drop the column of any surface that is off.

## Freshness

docs-baseline: <sha>

Last sweep: <YYYY-MM-DD>

## Mapping

Path globs to page numbers. A path may list several numbers.

| Changed path | Pages |
| --- | --- |
| `<glob or directory>` | `<NN>` |
