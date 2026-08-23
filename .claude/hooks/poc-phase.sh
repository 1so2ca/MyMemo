#!/usr/bin/env bash
# SessionStart: PoC フェーズ中だけ pr-flow を抑制する。pr-flow 自体は書き換えない
# 判定は poc-try スキルの有無。/poc-complete がそれを消した時点で自動失効する
set -u

root=${CLAUDE_PROJECT_DIR:-.}
[ -d "$root/.claude/skills/poc-try" ] || exit 0

printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"PoC フェーズ中。pr-flow スキルは読まない・適用しない。PR は作らない。実験コードは poc/<topic> ブランチに置き main へマージしない。知見・ルール・ドキュメントの更新は main 直 commit 可。"}}\n'
