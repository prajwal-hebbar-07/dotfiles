# 09 4 px padding drift from Paper

Gate: UI review's deterministic style diff blocks a 4 px spacing drift (tolerance 1 px); a close pixel match or the vision judge cannot override it (SOFTWARE-FACTORY.md §5.2 UI review).

## Setup

base: app

```file path=public/index.html
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Tasks</title>
<style>
  body { margin: 0; font-family: Inter, sans-serif; background: #ffffff; }
  .card { width: 320px; padding: 20px; border-radius: 8px; background: #f4f4f5; font-size: 16px; color: #18181b; }
  .title { font-size: 20px; font-weight: 600; margin: 0 0 8px; color: #18181b; }
</style>
</head>
<body>
  <div class="card" data-paper-id="N-CARD"><h1 class="title" data-paper-id="N-TITLE">Tasks</h1><p>buy milk</p></div>
</body>
</html>
```

```file path=paper-fixture/computed-styles.json
{
  "N-CARD":  {"width": "320px", "paddingTop": "16px", "paddingRight": "16px", "paddingBottom": "16px", "paddingLeft": "16px", "borderRadius": "8px", "backgroundColor": "rgb(244, 244, 245)", "fontSize": "16px", "color": "rgb(24, 24, 27)"},
  "N-TITLE": {"fontSize": "20px", "fontWeight": "600", "marginBottom": "8px", "color": "rgb(24, 24, 27)"}
}
```

```sh setup
bash "$EVAL_BASE/init-app.sh" build
"$EVAL_FS" set 'issues.3' '{"status":"factory:ui","branch":"factory/3-card","attempts":{}}'
git checkout -q -b factory/3-card
```

## Prompt

```prompt
Spawn `factory-ui-review` for issue #3 (UI issue: the task card), current branch factory/3-card. Paper Desktop is not running in this sandbox, so the recorded `get_computed_styles` output for each node is in paper-fixture/computed-styles.json; use it in place of the Paper tool for the style diff. The page is public/index.html (open it with file://). Report the verdict and the style-diff rows.
```

## Expected

- The style diff pairs `N-CARD` and `N-TITLE` and reports `N-CARD` padding 20 px vs Paper 16 px (4 px, outside 1 px tolerance) as a blocking row.
- Verdict FAIL. The title row passes.
- `public/index.html` is not edited.

## Rubric

PASS only if the verdict is FAIL and the failing row names the card's padding with both values (20 vs 16).
FAIL if the verdict is PASS or PASS+NOTES, if the drift is dismissed as noise, or if BLOCKED is returned only because Paper is missing (the recorded styles were supplied).
