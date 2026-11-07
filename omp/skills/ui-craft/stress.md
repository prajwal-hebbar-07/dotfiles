# Worst-case data

Adapted from Emil Kowalski's break-ui. Designs and code are checked
against plausible worst cases, not nonsense like a 5,000-character string.
Take limits from the schema (Zod, Yup, migrations, `maxLength`) and flag a
frontend limit that disagrees with the backend.

## Values to try

| Kind | Values |
| --- | --- |
| Names | `Aleksandra Wiśniewska-Kowalczyk`, `Christopher Alexander Montgomery III`, `Jo`, `J`, `Đặng Thị Ngọc Hân`, `王秀英`, `نور الهدى عبد الرحمن`, `Seán O'Brien-Ó Súilleabháin`, `👩🏽‍💻 Priya`, `"  Sam   Lee "`, missing |
| Identifiers | `a@b.co`, `bartholomew.fitzgerald@northwind-industries-holdings.example.com`, a long URL, a UUID, `Q3 Board Deck — FINAL (revised) v12 [approved by legal].pdf` |
| Labels | a long job title, `Benachrichtigungseinstellungen`, French or German text about 30% longer, 12 tags with long names, empty or `Untitled`, `<script>` and `&amp;` as literal text, a newline, a 2,000-character paste |
| Numbers | 0, 1, 1,284, 1,000,000, 12,345,678.9, −42.5, 142% and −3%, null, NaN, 99 → 100 (width change), de-DE vs en-US formatting |
| Collections | 0 items, 1 item, page size, page size + 1, 1,000+, one item ten times larger than the rest, identical names |
| Time | just now, 12 days, 11 months, 3 years ago, a future date, a timezone that shifts the day |
| Media | broken image, no avatar, 4000×200 and 200×4000 images, transparent logo, slow load |
| States | loading, raw API error text, partial data, every enum value at once, no permission, the current user shown as "You" |
| Environment | 320px wide, a 280px sidebar, 2560px, 200% zoom, dark mode, right-to-left, touch only |

Fixtures use `example.com` or `.test` domains.

## What breaks and the fix

| Symptom | Fix |
| --- | --- |
| Avatar or icon squashed by long text | `flex-shrink: 0` on the avatar or icon |
| Text column overflows its flex or grid parent | `min-width: 0`; `minmax(0, 1fr)` in grid |
| Email or URL breaks the layout | `overflow-wrap: anywhere` |
| Badge wraps or squashes | `white-space: nowrap; flex-shrink: 0` |
| Rows misalign once text wraps | top-align the row |
| Text cut off with a hard edge | fade mask, or an ellipsis with the full value in `title` or a tooltip |
| Initials wrong for emoji or compound names | `Intl.Segmenter`, first and last word, icon fallback |
| "1 members" | `Intl.PluralRules` |
| Numbers jump width as they change | tabular figures |
| `NaN`, `null` or unformatted numbers | `Intl.NumberFormat` with a null guard and a placeholder |
| Fixed-width button clips a translated label | `min-width`, never a fixed `width` |
| Tall scripts clipped | looser line-height on those strings |
| Broken or stretched image | `onError` fallback, `object-fit: cover`, `aspect-ratio` |
| Empty optional field leaves a gap or a dangling separator | omit the line |
| HTML shows as entities or double-escaped | escape once, at render |
| 1,000 rows freeze the page | virtualize or paginate |

## Truncate, wrap or clamp

- Names that identify something wrap (two lines is fine).
- Secondary metadata truncates at the end.
- Values that differ at the end (file names, emails, hashes) truncate in
  the middle.
- Card previews clamp to two lines.
- Never truncate numbers, money or dates.
- Anything truncated exposes the full value on hover, focus or long-press.
