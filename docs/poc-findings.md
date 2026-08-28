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

- **D1** Worker 単位 Access が `wrangler dev --remote` の preview を覆うか
- **D2** 自動保存と読み込みが D1 で動くか
- **D3** 実利用ペースからの月額見積もり（$5/mo 以内か）

## 本実装に持ち込むもの

## 残課題
