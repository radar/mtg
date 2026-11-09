#!/usr/bin/env bash
# PreToolUse hook (matcher: Bash). Blocks commands that CLAUDE.md bans.
# Exit 2 + stderr message = call blocked, message goes back to the model.

# Match only against the command skeleton: drop heredoc bodies and quoted
# strings first, so words inside commit messages or rg patterns do not trip it.
cmd=$(jq -r '
  (.tool_input.command // "")
  | gsub("<<-?[ \\t]*[\u0027\"]?(?<d>[A-Za-z_]+)[\u0027\"]?[\\s\\S]*?\\n[ \\t]*\\k<d>"; "")
  | gsub("\u0027[^\u0027]*\u0027|\"[^\"]*\""; "\"\"")
')

# Redirects that are fine: fd duplication (2>&1), /dev/null, and writes under tmp/. Whatever redirect is left
# writes somewhere else, and is blocked below.
redirects=$(jq -Rrs '
  gsub("[0-9]?>&[0-9-]+"; "")
  | gsub("&?[0-9]?>>?[ \\t]*/dev/null"; "")
  | gsub("[0-9]?>[>|]?[ \\t]*tmp/[^ \\t;&|)]*"; "")
' <<<"$cmd")

# A command word: at start of line, or after ; & | ( or a newline.
pos='(^|[;&|(]|\n)[[:space:]]*'

block() {
  echo "BLOCKED by .claude/hooks/block-banned-bash.sh: $1" >&2
  exit 2
}

if [[ $cmd =~ (^|[^[:alnum:]_-])xargs([^[:alnum:]_-]|$) ]]; then
  block "Never use xargs. Use rg/fd multi-file handling or a loop."
fi

if [[ $cmd =~ ${pos}(sed|perl|python[0-9.]*|tee)([[:space:]]|$) ]] || [[ $cmd =~ ${pos}ruby[[:space:]]+-e ]]; then
  block "Do not edit or script files from the shell (sed/perl/python/ruby -e/tee). Use the Edit and Write tools only. For read-only data questions use jq, rg or fd."
fi

if [[ $cmd =~ ${pos}cat[[:space:]]*\>  ]]; then
  block "No heredoc or redirect file writes (cat > f). Use the Write tool."
fi

if [[ $redirects == *">"* ]]; then
  block "No redirect file writes outside tmp/ (echo x > f, cat in > out, ...). Use the Write tool, or redirect into tmp/ with >|."
fi

if [[ $cmd =~ ${pos}find([[:space:]]|$) ]]; then
  block "Use fd, not find."
fi

if [[ $cmd =~ ${pos}(grep|egrep|fgrep)([[:space:]]|$) ]]; then
  block "Use rg, not grep."
fi

if [[ $cmd =~ ${pos}cd([[:space:]]|$) ]]; then
  block "Do not cd. Run from the repo root with relative paths."
fi

if [[ $cmd == */Users/* ]]; then
  block "No absolute paths (/Users/...). Use paths relative to the repo root."
fi

exit 0
