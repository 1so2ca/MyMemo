#!/usr/bin/env bash
# PostToolUse(Write|Edit): md 以外＝コードを書いた直後、そのファイルに言及している md があるときだけ整合性チェックを注入する
# 探索は hook 内で完結させる(find + grep 各1回)。ヒット 0 なら何も出さず、Claude 側の探索コストを 0 にする
set -u

raw=$(grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1)
path=$(printf '%s' "${raw#*:}" | tr -d '"' | sed 's/^[[:space:]]*//')
case "$path" in
  ""|*.md|*.MD) exit 0 ;;
esac

base=$(printf '%s' "$path" | sed 's#.*[/\]##')
[ -z "$base" ] && exit 0

root=${CLAUDE_PROJECT_DIR:-.}
hits=$(find "$root" \( -name .git -o -name node_modules -o -name .venv \) -prune -o \
  -type f \( -name '*.md' -o -name '*.MD' \) -print0 2>/dev/null \
  | xargs -0 -r grep -l -F -e "$base" 2>/dev/null | head -3 | tr '\n' ' ')
[ -z "$hits" ] && exit 0

printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"%s を変更した。これに言及している md: %s。この変更で記述がズレたか確認し、ズレていれば同じ変更の中で直す。ズレていなければ何もしない。報告は直した場合のみ1行。"}}\n' "$base" "$hits"
