#!/usr/bin/env bash
# PreToolUse hook (matcher: Bash). Blocks commands that CLAUDE.md bans.
# Exit 2 + stderr message = call blocked, message goes back to the model.

cmd=$(jq -r '.tool_input.command // ""')

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
