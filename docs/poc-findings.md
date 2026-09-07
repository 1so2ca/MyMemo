# PoC 知見

問い: Android Chrome の日本語入力で ghost text 補完が使い物になるか。判定は主観、出力は go / no-go。

## 検証項目と結果

### エディタ

- **A1** 透明 textarea と IME の共存 — `isComposing` での透明トグルのちらつき、変換中の下線・文節ハイライトの残存。失敗時は ghost のみ描画へ退避
- **A2** ミラー div と textarea のズレ — 日本語の折り返し・禁則・行高
- **A3** Gboard の候補ウィンドウが ghost text を覆うか

### 受理

- **B1** 右スワイプと Android 戻るジェスチャの競合 — `touch-action: pan-y` によるジェスチャ除外が効くか（exclusion rect は 200dp 制限）

### 補完

- **C1** 発火タイミングの体感 — debounce + 推論レイテンシ。応答タイムアウトと最小 prefix 長をここで決める
- **C2** 補完品質 — 日本語としての妥当性、中国語文字の混入、few-shot で出力量が動的に変わるか、出力上限に当たる頻度
- **C3** コンテキスト量の過不足
- **C4** モデル比較 — llama-3.1-8b-instruct-fast / qwen3-30b-a3b-fp8 / glm-4.7-flash

### インフラ

- **D1** Worker 単位 Access をかけた preview URL にスマホから到達できるか（`wrangler dev --remote` は localhost 提供のため実機に使えない）
- **D2** 自動保存と読み込みが D1 で動くか
- **D3** 実利用ペースからの月額見積もり（$5/mo 以内か）

### D1 — 2026-09-07

- 試したこと: Worker 単位 Access で保護した preview alias URL を Android Chrome から OTP 認証後に開いた
- 事実: `shell OK` と `Mozilla/5.0 (Linux; Android 10; K) ... Chrome/148.0.0.0 Mobile Safari/537.36` が表示された
- 解釈: Access で保護した Worker の preview URL へ Android Chrome から到達し、静的アセットを取得できる
- 判定: 採用
- 再現: `npx --yes wrangler@4.129.0 versions upload --preview-alias shell --config wrangler.jsonc`

## 本実装に持ち込むもの

- 実機検証には、Worker 単位 Access で保護した preview alias URL を使用する

## 残課題
