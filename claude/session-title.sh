#!/bin/sh
set -eu

jq -c '
  if (.session_title // "") != "" then
    empty
  else
    [
      "a", "an", "and", "are", "as", "at", "be", "can", "could", "do",
      "for", "from", "how", "i", "in", "is", "it", "me", "my", "of", "on",
      "or", "please", "that", "the", "this", "to", "we", "will", "with", "you"
    ] as $stopwords
    | (
        (.prompt // "")
        | ascii_downcase
        | [scan("[a-z0-9]+")]
        | map(. as $word | select(($stopwords | index($word)) == null))
        | . + ["chat", "work", "task", "session"]
        | .[:4]
      ) as $words
    | ((.session_id // "session") | gsub("-"; "") | .[:8]) as $id
    | ($words[3] + "_" + $id) as $last
    | {
        hookSpecificOutput: {
          hookEventName: "UserPromptSubmit",
          sessionTitle: (($words[:3] + [$last]) | join("-"))
        }
      }
  end
'
