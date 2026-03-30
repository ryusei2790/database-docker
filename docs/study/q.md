# SQL 問題集

> このドキュメントはdatabase-dockerのDBを実際に起動してSQLを実行しながら解く問題集です。
>
> **事前準備**
> ```bash
> # 1. コンテナを起動
> docker compose up -d
>
> # 2. DBに接続
> docker compose exec db psql -U postgres -d postgres
>
> # 3. テストデータを投入（初回のみ）
> docker compose exec db psql -U postgres -d postgres -f /seed/seed.sql
> ```
>
> 解答は `a.md` を参照してください。

---

## 第2章　SELECT — データを取得する

### Q2-1
`public.profiles` テーブルの全レコード・全カラムを取得してください。

---

### Q2-2
`public.profiles` テーブルから `username` と `full_name` の2カラムだけを取得してください。

---

### Q2-3
`auth.users` テーブルの全レコードを取得してください。

---

### Q2-4
`public.profiles` テーブルから `id`、`username`、`created_at` の3カラムを取得してください。

---

### Q2-5
`auth.users` テーブルから `email` カラムだけを取得してください。

---

## 第3章　WHERE — 条件で絞り込む

### Q3-1
`public.profiles` テーブルから `username` が `'alice'` のレコードを取得してください。

---

### Q3-2
`public.profiles` テーブルから `username` が `'bob'` **ではない** レコードを取得してください。

---

### Q3-3
`public.profiles` テーブルから `avatar_url` が `NULL`（未設定）のレコードを取得してください。

---

### Q3-4
`public.profiles` テーブルから `full_name` が `'A'` で始まるレコードを取得してください。

---

### Q3-5
`auth.users` テーブルから `email` に `'example.com'` を含むレコードを取得してください。

---

### Q3-6
`public.profiles` テーブルから `username` が `'alice'` **または** `'carol'` のレコードを取得してください。

---

## 第4章　ORDER BY / LIMIT — 並び替えと件数制限

### Q4-1
`public.profiles` テーブルを `username` の昇順（アルファベット順）で取得してください。

---

### Q4-2
`public.profiles` テーブルを `username` の降順で取得してください。

---

### Q4-3
`public.profiles` テーブルから `created_at` が新しい順に2件だけ取得してください。

---

### Q4-4
`public.profiles` テーブルを `username` の昇順で並べ、最初の1件をスキップして2件取得してください。

---

## 第5章　JOIN — テーブルの結合

### Q5-1
`auth.users` と `public.profiles` を `id` で結合して、`email`・`username`・`full_name` を取得してください。

---

### Q5-2
Q5-1 の結果を `username` の昇順で並び替えてください。

---

### Q5-3
`auth.users` と `public.profiles` を結合して、`email` が `'bob@example.com'` のユーザーの `full_name` を取得してください。

---

## 第6章　集計 — COUNT / GROUP BY

### Q6-1
`public.profiles` テーブルの全件数を取得してください。

---

### Q6-2
`public.profiles` テーブルの中で `avatar_url` が `NULL` のレコード件数を取得してください。

---

### Q6-3
`auth.users` テーブルの全件数を取得してください。

---

## 第7章　INSERT / UPDATE / DELETE

### Q7-1
以下の情報で新しいユーザーを追加してください。
- `auth.users` に追加：id = `'a0000000-0000-0000-0000-000000000004'`、email = `'dave@example.com'`
- `public.profiles` に追加：id = 同上、username = `'dave'`、full_name = `'Dave Brown'`

追加後、`public.profiles` の全件数が4件になっていることを確認してください。

---

### Q7-2
Q7-1 で追加した `dave` の `full_name` を `'Dave Wilson'` に更新してください。

更新後、`SELECT * FROM public.profiles WHERE username = 'dave'` で確認してください。

---

### Q7-3
Q7-1 で追加した `dave` のプロフィールを削除してください。

削除後、`public.profiles` の件数が3件に戻っていることを確認してください。

---

## 総合問題

### Q8-1
`auth.users` と `public.profiles` を結合して、以下の条件で取得してください。
- 取得カラム：`email`、`username`、`full_name`
- 条件：`full_name` に `'son'` を含む
- 並び順：`email` の昇順

---

### Q8-2
以下のSQLを実行して、`updated_at` のトリガーが動くことを確認してください。

1. まず `alice` の現在の `updated_at` を確認する
2. `alice` の `full_name` を `'Alice Wonder'` に更新する
3. 再度 `alice` の `updated_at` を確認して、値が変わっていることを確認する

---

### Q8-3
`public.profiles` テーブルから以下を1つのSQLで取得してください。
- `username` の昇順
- 先頭2件のみ
- 取得カラムは `username` と `full_name` のみ
