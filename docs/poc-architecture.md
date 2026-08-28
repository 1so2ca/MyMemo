# PoC アーキテクチャ

## 構成

```mermaid
flowchart LR
  subgraph client["クライアント（Svelte / Vite）"]
    buf["編集中バッファ<br/>コンテキスト切り出し"]
    memo["メモ一覧・保存"]
  end

  subgraph access["Cloudflare Access（Worker 単位）"]
    subgraph worker["Worker（Hono）"]
      comp["POST /complete"]
      api["/api/memos"]
      st["GET /*"]
    end
  end

  ai["Workers AI<br/>@cf/google/gemma-4-26b-a4b-it"]
  db[("D1")]

  buf -- "head, prefix, suffix" --> comp
  comp --> ai
  ai -- "候補文字列" --> comp
  comp -- "候補文字列" --> buf

  memo -- "メモ本文（3s debounce）" --> api
  api <--> db

  client -. "初回ロード" .-> st
  st -. "ビルド成果物" .-> client
```

## 補完

### エディタ

```mermaid
flowchart LR
  subgraph normal["通常"]
    n1["前面 textarea<br/>文字は透明・キャレット可視"]
    n2["背面 div<br/>本文 + 候補（灰）"]
  end

  subgraph composing["IME 変換中"]
    c1["前面 textarea<br/>文字可視・下線と文節ハイライト"]
    c2["背面 div<br/>非表示"]
  end

  n1 -. "value / scrollTop" .-> n2
  normal -- "compositionstart" --> composing
  composing -- "compositionend" --> normal
```

### 発火

```mermaid
flowchart LR
  k["input イベント"] --> ime{"isComposing"}
  ime -- "true" --> stop["タイマー停止"]
  ime -- "false" --> wait["打鍵停止 500ms"]
  wait --> same{"破棄直後の<br/>同一位置"}
  same -- "はい" --> skip["発火しない"]
  same -- "いいえ" --> abort["前リクエストを abort"]
  abort --> post["POST /complete"]
  post --> show["候補を表示"]
  show -- "右スワイプ" --> accept["全文を受理"]
  show -- "打鍵" --> k
```

### コンテキスト

| 要素 | 量 |
|---|---|
| head（メモ冒頭） | 100 字 |
| prefix（カーソル前） | 600 字 |
| suffix（カーソル後） | 200 字 |
| few-shot 例 | 3 例・長さをばらつかせる |
| 出力上限 | 64 tokens |

## 永続化

```sql
CREATE TABLE memos (
  id         TEXT    PRIMARY KEY,
  title      TEXT,                       -- NULL なら body の先頭行を表示名に使う
  body       TEXT    NOT NULL DEFAULT '',
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

CREATE INDEX idx_memos_updated_at ON memos(updated_at DESC);
```
