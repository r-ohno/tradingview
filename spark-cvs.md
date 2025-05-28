# Spark 2.4.7 CSVファイル 入力時・出力時オプション一覧

## 入力時（読み込み時）オプション

| オプション名                | デフォルト値                   | 説明                                                      |
| --------------------------- | ------------------------------ | --------------------------------------------------------- |
| `sep` / `delimiter`         | `,`                            | 区切り文字                                                |
| `encoding` / `charset`      | `UTF-8`                        | ファイルのエンコーディング                                |
| `quote`                     | `"`                            | クォート文字                                              |
| `escape`                    | `\`                            | エスケープ文字                                            |
| `header`                    | `false`                        | 1行目をヘッダーとして扱うか                               |
| `nullValue`                 | 無し                           | nullとして扱う文字列                                      |
| `dateFormat`                | `yyyy-MM-dd`                   | 日付型のパースフォーマット                                |
| `timestampFormat`           | `yyyy-MM-dd'T'HH:mm:ss.SSSXXX` | タイムスタンプ型のパースフォーマット                      |
| `ignoreLeadingWhiteSpace`   | `false`                        | フィールドの先頭空白を無視するか                          |
| `ignoreTrailingWhiteSpace`  | `false`                        | フィールドの末尾空白を無視するか                          |
| `mode`                      | `PERMISSIVE`                   | パースモード（`PERMISSIVE`, `DROPMALFORMED`, `FAILFAST`） |
| `multiLine`                 | `false`                        | 複数行にまたがるフィールドを許可するか                    |
| `lineSep`                   | 無し                           | 行区切り文字                                              |
| `maxColumns`                | `20480`                        | 最大カラム数                                              |
| `maxCharsPerColumn`         | `-1`                           | カラムごとの最大文字数（-1は制限なし）                    |
| `escapeQuotes`              | `true`                         | クォート内のエスケープを有効にするか                      |
| `emptyValue`                | 無し                           | 空文字列として扱う値                                      |
| `nanValue`                  | `NaN`                          | NaNとして扱う値                                           |
| `positiveInf`               | `Inf`                          | 正の無限大として扱う値                                    |
| `negativeInf`               | `-Inf`                         | 負の無限大として扱う値                                    |
| `locale`                    | `en-US`                        | ロケール                                                  |
| `columnNameOfCorruptRecord` | `_corrupt_record`              | パース失敗時に格納するカラム名                            |
| `inferSchema`               | `false`                        | スキーマを自動推定するか                                  |
| `comment`                   | 無し                           | コメント行の開始文字                                      |

---

## 出力時（書き出し時）オプション

| オプション名           | デフォルト値                   | 説明                                   |
| ---------------------- | ------------------------------ | -------------------------------------- |
| `sep` / `delimiter`    | `,`                            | 区切り文字                             |
| `encoding` / `charset` | `UTF-8`                        | ファイルのエンコーディング             |
| `quote`                | `"`                            | クォート文字                           |
| `escape`               | `\`                            | エスケープ文字                         |
| `header`               | `false`                        | ヘッダー行を出力するか                 |
| `nullValue`            | 無し                           | null値をどの文字列で出力するか         |
| `dateFormat`           | `yyyy-MM-dd`                   | 日付型の出力フォーマット               |
| `timestampFormat`      | `yyyy-MM-dd'T'HH:mm:ss.SSSXXX` | タイムスタンプ型の出力フォーマット     |
| `compression`          | 無し                           | 圧縮形式（`gzip`など）                 |
| `quoteAll`             | `false`                        | 全てのフィールドをクォートで囲む       |
| `escapeQuotes`         | `true`                         | クォート内のエスケープを有効にするか   |
| `emptyValue`           | 無し                           | 空文字列として出力する値               |
| `lineSep`              | 無し                           | 行区切り文字                           |
| `multiLine`            | `false`                        | 複数行にまたがるフィールドを許可するか |
| `locale`               | `en-US`                        | ロケール                               |

---

**備考:**

- 両方の一覧に記載されているオプションは、**入力・出力どちらでも利用可能**
- 詳細は[公式ドキュメント](https://spark.apache.org/docs/2.4.7/sql-data-sources-csv.html)を参照