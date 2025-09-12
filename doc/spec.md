# 簡単なタイマーアプリ 基本設計書

## 1. 目的

最小限のUIで操作できるカウントダウンタイマーを実装する。3分・5分のプリセット、開始/停止、完了時アラートを提供する。

## 2. 対象/前提

* 対象：単一画面のシンプルなアプリ（Web/モバイル/デスクトップいずれでも実装可能な汎用設計）
* 表示形式：`mm.ss`（例：03.00, 05.00, 00.00）
* 初期表示：`00.00`
* 仕様の時間単位：秒（内部状態は秒で保持）

## 3. 画面/UI仕様

### 3.1 コンポーネント

* **時間表示欄**：中央大きめフォント、等幅フォント推奨。読み取り専用。
* **3ボタン**：ラベル「3」。
* **5ボタン**：ラベル「5」。
* **スタート/ストップボタン**：ラベルは状態に応じて「スタート」/「ストップ」にトグル表示。

### 3.2 レイアウト（例）

```
[    00.00    ]
[  3  ] [  5  ]
[   スタート/ストップ   ]
```

## 4. 用語/変数

* `remainingSec`：残り秒（整数）
* `state`：`IDLE | RUNNING | PAUSED | FINISHED`
* `timerId`：タイマー制御ハンドル（interval/chrono等）

## 5. 機能仕様（要求の反映）

1. **3ボタンクリック**：`remainingSec = 180` に設定し、表示を `03.00` に更新。タイマーは**リセット**（RUNNING/PAUSED 関係なく停止→IDLE）。
2. **5ボタンクリック**：`remainingSec = 300` に設定し、表示を `05.00` に更新。タイマーは**リセット**。
3. **スタート/ストップボタンクリック（共通）**

   * `state = RUNNING` のとき：**停止**して `PAUSED` に遷移（残り時間は保持）。
   * `state = PAUSED` のとき：**再開**して `RUNNING` に遷移。
   * `state = IDLE` のとき：

     * `remainingSec > 0` なら **開始**（`RUNNING` へ）。
     * `remainingSec == 0` なら **何も起きない**（表示・状態変化なし）。
   * `state = FINISHED` のとき：**何も起きない**（再スタート不可、プリセットでのリセットは可）。
4. **カウントダウン**：`RUNNING` 中は 1 秒ごとに `remainingSec--`。更新毎に表示を再描画。
5. **完了判定**：`remainingSec` が 0 になったら

   * `state = FINISHED` に遷移
   * **アラート表示**（メッセージボックス）：「時間になりました」等
   * タイマーは自動停止
6. **リセット条件**：`RUNNING` または `PAUSED` 中に 3/5 ボタンが押下された場合は該当時間に即時リセットし、`IDLE` へ（カウントダウンは止まる）。

## 6. 表示仕様（フォーマット）

* `remainingSec` を `mm.ss` に変換

  * `mm = floor(remainingSec / 60)` を2桁ゼロ詰め
  * `ss = remainingSec % 60` を2桁ゼロ詰め
  * 例：180 → `03.00`、5 → `00.05`、0 → `00.00`

## 7. 状態遷移

| 現在状態     | イベント   | 条件     | 次状態      | 動作                         |
| -------- | ------ | ------ | -------- | -------------------------- |
| IDLE     | 3ボタン   | –      | IDLE     | rem=180、表示更新、タイマー停止        |
| IDLE     | 5ボタン   | –      | IDLE     | rem=300、表示更新、タイマー停止        |
| IDLE     | スタート   | rem>0  | RUNNING  | interval開始                 |
| IDLE     | スタート   | rem=0  | IDLE     | 何もしない                      |
| RUNNING  | 3/5ボタン | –      | IDLE     | 該当時間に設定、interval停止、表示更新    |
| RUNNING  | ストップ   | –      | PAUSED   | interval停止                 |
| RUNNING  | tick   | rem>1  | RUNNING  | rem--、表示更新                 |
| RUNNING  | tick   | rem==1 | FINISHED | rem→0、表示更新、interval停止、アラート |
| PAUSED   | 3/5ボタン | –      | IDLE     | 該当時間に設定、表示更新               |
| PAUSED   | スタート   | –      | RUNNING  | interval再開                 |
| FINISHED | スタート   | –      | FINISHED | 何もしない                      |
| FINISHED | 3/5ボタン | –      | IDLE     | 該当時間に設定、表示更新               |

## 8. タイマー精度/実装ポリシー

* **刻み**：1秒毎に表示更新。
* **精度**：可能なら実時刻参照（開始/再開時に「目標時刻」を記録し、tick毎に `remainingSec = max(0, ceil((targetTime - now)/1000))` のように補正）。
* **重複起動防止**：`RUNNING` へ遷移時に既存intervalがあれば必ずクリア。

## 9. アラート仕様

* 形式：メッセージボックス（OS/プラットフォーム標準ダイアログで可）
* 文言（例）：「時間になりました」
* アラート表示後も表示欄は `00.00` のまま、状態は `FINISHED`。

## 10. 例外/エッジケース

* 連打対策：ボタン多重押下で二重intervalが走らないようガード。
* 背景遷移/スリープ（モバイル/デスクトップ）：復帰時は実時刻補正で残りを再計算（任意実装、初版は必須ではない）。
* ローカライズ：数値フォントは等幅、記号は必ずドット（小数点）で固定表示。

## 11. 疑似コード（参照用）

```pseudo
state = IDLE
remainingSec = 0
timerId = null

function format(remainingSec):
  mm = floor(remainingSec / 60)
  ss = remainingSec % 60
  return pad2(mm) + "." + pad2(ss)

function render():
  display.text = format(remainingSec)
  startStopButton.label = (state == RUNNING) ? "ストップ" : "スタート"

function resetTo(sec):
  clearInterval(timerId)
  timerId = null
  remainingSec = sec
  state = IDLE
  render()

onClickButton3():
  resetTo(180)

onClickButton5():
  resetTo(300)

onClickStartStop():
  if state == RUNNING:
    clearInterval(timerId)
    timerId = null
    state = PAUSED
    render()
  else if state == PAUSED and remainingSec > 0:
    startTimer()
  else if state == IDLE and remainingSec > 0:
    startTimer()
  else:
    // FINISHED or remainingSec == 0 -> do nothing

function startTimer():
  if timerId != null: clearInterval(timerId)
  state = RUNNING
  targetEpochMs = now() + remainingSec * 1000
  timerId = setInterval(1000, () => {
    delta = targetEpochMs - now()
    remainingSec = max(0, ceil(delta / 1000))
    render()
    if remainingSec == 0:
      clearInterval(timerId)
      timerId = null
      state = FINISHED
      alert("時間になりました")
      render()
  })
  render()
```

## 12. テスト観点（抜粋）

1. **初期表示**：起動直後 `00.00`、ボタン表示が正しい。
2. **プリセット**：3押下→`03.00`、5押下→`05.00`、いずれも状態`IDLE`。
3. **開始/停止/再開**：

   * `03.00`→スタート→1秒ごとに減少。
   * カウント中ストップ→時刻保持。再スタートで続きから減少。
4. **完了**：`00.00` 到達時に一度だけアラート、状態`FINISHED`。
5. **完了後の操作**：`FINISHED` でスタート押下→無反応。3/5押下→リセット可。
6. **リセット中断**：RUNNING/PAUSED 中に 3/5 押下で即 `IDLE`、残り時間は該当値に。
7. **多重interval防止**：連打しても1本のみ稼働。
8. **表示フォーマット**：`mm.ss` でゼロ詰め、境界（60→59.59ではなく 01.00→00.59 のように正しく推移）。
9. **秒精度補正**：長時間動作/スリープ復帰後も大きなズレがない（補正方式採用時）。
10. **アラート文言**：文言・一度のみ表示を確認。

## 13. 非機能（初版の目安）

* レイテンシ：表示更新は1秒間隔以内の遅延。
* 安定性：連続1時間稼働しても異常停止がない。
* アクセシビリティ：ボタンにフォーカス可能、Enter/Space操作（Webの場合）。

## 14. 今後の拡張（任意）

* 任意分数入力（カスタム値）
* バックグラウンド動作保証/通知（モバイル）
* アラーム音・バイブレーション
* 複数プリセットの追加、履歴機能

――以上。
