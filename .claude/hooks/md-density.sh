#!/usr/bin/env bash
# PostToolUse(Write|Edit): .md を書いた直後に密度チェックを注入する
set -u

path=$(grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1)
case "$path" in
  *.md\"|*.MD\") ;;
  *) exit 0 ;;
esac

cat <<'EOF'
{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"md を書き込んだ。次の作業に移る前に必ず実行する。(1) 削除テスト: 今回追加した各行について「この行が無いと何が壊れるか」を1文で言えるか確認し、言えない行は削る。(2) 差し引き: この追加で不要・重複になった既存の行を、同じ変更の中で削る。(3) 報告: 変更後の総行数と増減(+N/-M)を1行で示す。増えた場合は理由を1行添える。"}}
EOF
