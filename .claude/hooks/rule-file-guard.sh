#!/usr/bin/env bash
# PreToolUse(Write|Edit|Bash): 恒久ルールファイル(.claude/skills/** と CLAUDE.md)を書き換える直前だけ、
# 記述の寿命を確認させる。該当しなければ無出力で終わり、コンテキストコストは 0
set -u

payload=$(cat)

hits_rule_file() {
  case "$1" in
    *.claude/skills/*|*.claude\skills\*|*CLAUDE.md*|*CLAUDE.MD*) return 0 ;;
  esac
  return 1
}

tool=$(printf '%s' "$payload" | grep -oE '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:[[:space:]]*"//; s/"$//')

case "$tool" in
  Write|Edit)
    subject=$(printf '%s' "$payload" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1)
    ;;
  Bash)
    subject=$(printf '%s' "$payload" | grep -oE '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1)
    # Bash は書き込み系の語を伴うときだけ対象にする(cat / grep など読み取りを拾わない)
    printf '%s' "$subject" | grep -qE '>|sed -i|tee |cp |mv |rm ' || exit 0
    ;;
  *) exit 0 ;;
esac

hits_rule_file "$subject" || exit 0

cat <<'EOF'
{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"恒久ルールファイル(.claude/skills/** または CLAUDE.md)を書き換えようとしている。書く前に確認する。(1) この記述はいつ消えるか。(2) 一時フェーズ(PoC 等)の都合なら恒久ファイルへ書かない。恒久ファイルは触らず外側(hook 等)から抑制し、撤去手順を寿命の管理者スキルへ置く。(3) 置き場の選択肢を実装前にユーザへ提示する。恒久ルール自体の変更なら続行してよい。"}}
EOF
