---
name: poc-complete
description: PoC の完了処理。完了基準の判定、docs/poc-findings.md の整形、PoC コードとブランチの破棄、知見コミット、本実装フェーズのルール起こしまでを行う。
---

# poc-complete

## 完了基準

`docs/poc-findings.md` の検証項目すべてについて、採否の判断材料が揃っていること。
不足がある項目を残したまま完了処理に進まない。

## 手順

1. 判定
   - 項目ごとに「判断材料あり / 不足」を提示し、続行承認を得る
2. 整形
   - `docs/poc-findings.md` の欠落を埋める（「本実装に持ち込むもの」「残課題」まで）
   - 内容を提示して承認を得る
3. 破棄
   - `/poc/` ディレクトリを削除
   - `poc/*` ブランチを一覧表示し、削除対象を確認してから削除
   - 削除は不可逆。それぞれ個別に承認を得る
4. コミット
   - main に残すのは「PoC 知見コミット」（`docs/poc-findings.md` の更新）のみ
   - 実行前に承認を得る
5. フェーズ移行
   - PoC 用スキル（`poc-try` / `poc-log` / 本スキル）を削除
   - PoC 抑制 hook を削除（`.claude/hooks/poc-phase.sh` と `.claude/settings.json` の SessionStart エントリ）。これで pr-flow が有効になる
   - 本実装フェーズのルールを起こす。置き場（子 `CLAUDE.md` / スキル）はユーザと決める。root `CLAUDE.md` には置かない
     - 軽量 DDD（ドメイン層を分離。集約・値オブジェクト・ドメインサービスを最小構成で）
     - TDD（Red-Green-Refactor）
     - アーキテクチャは PoC 知見をもとに確定
