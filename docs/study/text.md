# SQL 参考書 — PostgreSQL 入門

> このドキュメントはデータベースを動かさなくても読むだけで学べる参考書です。
> 実際に手を動かす場合は `q.md`（問題集）を使ってください。

---

## 第1章　データベースとは何か

### 1-1. データベースの概念

**データベース（Database）** とは、データを整理して保存・取り出しできる仕組みです。

Excelのスプレッドシートをイメージするとわかりやすいです。

| id | email | created_at |
|----|-------|------------|
| 1 | alice@example.com | 2024-01-01 |
| 2 | bob@example.com | 2024-01-02 |

このような「表」のことを **テーブル（Table）** と呼びます。

### 1-2. 重要な用語

| 用語 | 意味 | Excelでの例え |
|------|------|--------------|
| **テーブル** | データを格納する表 | シート |
| **カラム（列）** | データの種類（縦の概念） | 列ヘッダー |
| **レコード（行）** | 1件分のデータ（横の概念） | 1行 |
| **主キー（PRIMARY KEY）** | レコードを一意に識別する値 | 出席番号 |

### 1-3. スキーマとは

**スキーマ（Schema）** はテーブルをグループ化する「フォルダ」のようなものです。

このプロジェクトでは以下の2つのスキーマを使っています。

```
postgres データベース
├── auth スキーマ        ← 認証関連のテーブル
│   └── users           ← ユーザー情報
└── public スキーマ      ← アプリのメインテーブル
    └── profiles        ← ユーザープロフィール
```

### 1-4. SQL とは

**SQL（Structured Query Language）** はデータベースを操作するための言語です。

主な操作は4種類あります。

| 操作 | SQL文 | 意味 |
|------|-------|------|
| 取得 | `SELECT` | データを読み取る |
| 追加 | `INSERT` | データを追加する |
| 更新 | `UPDATE` | データを書き換える |
| 削除 | `DELETE` | データを削除する |

---

## 第2章　データの取得 — SELECT

### 2-1. 基本構文

```sql
SELECT カラム名 FROM テーブル名;
```

**全カラムを取得する場合は `*` を使います。**

```sql
SELECT * FROM public.profiles;
```

実行結果のイメージ：

| id | username | full_name | avatar_url | created_at | updated_at |
|----|----------|-----------|------------|------------|------------|
| a000...0001 | alice | Alice Smith | null | 2024-01-01 | 2024-01-01 |
| a000...0002 | bob | Bob Johnson | null | 2024-01-01 | 2024-01-01 |
| a000...0003 | carol | Carol Williams | null | 2024-01-01 | 2024-01-01 |

### 2-2. 特定のカラムだけ取得する

```sql
SELECT username, full_name FROM public.profiles;
```

実行結果：

| username | full_name |
|----------|-----------|
| alice | Alice Smith |
| bob | Bob Johnson |
| carol | Carol Williams |

### 2-3. スキーマ名の指定

PostgreSQL では `スキーマ名.テーブル名` の形式でテーブルを指定します。

```sql
-- public スキーマの profiles テーブル
SELECT * FROM public.profiles;

-- auth スキーマの users テーブル
SELECT * FROM auth.users;
```

---

## 第3章　条件で絞り込む — WHERE

### 3-1. WHERE の基本

```sql
SELECT * FROM テーブル名 WHERE 条件;
```

例：username が 'alice' のレコードだけ取得

```sql
SELECT * FROM public.profiles WHERE username = 'alice';
```

### 3-2. 比較演算子

| 演算子 | 意味 | 例 |
|--------|------|-----|
| `=` | 等しい | `WHERE username = 'alice'` |
| `<>` または `!=` | 等しくない | `WHERE username <> 'bob'` |
| `>` | より大きい | `WHERE id > 10` |
| `<` | より小さい | `WHERE id < 10` |
| `>=` | 以上 | `WHERE id >= 10` |
| `<=` | 以下 | `WHERE id <= 10` |

### 3-3. AND / OR で複数条件

```sql
-- AND：両方の条件を満たすレコード
SELECT * FROM public.profiles
WHERE username = 'alice' AND full_name = 'Alice Smith';

-- OR：どちらかの条件を満たすレコード
SELECT * FROM public.profiles
WHERE username = 'alice' OR username = 'bob';
```

### 3-4. LIKE であいまい検索

```sql
-- % は「0文字以上の任意の文字列」を意味する
SELECT * FROM public.profiles WHERE full_name LIKE 'Alice%';  -- Aliceで始まる
SELECT * FROM public.profiles WHERE full_name LIKE '%Smith';  -- Smithで終わる
SELECT * FROM public.profiles WHERE full_name LIKE '%li%';   -- liを含む
```

### 3-5. IS NULL / IS NOT NULL

```sql
-- avatar_url が未設定（NULL）のレコード
SELECT * FROM public.profiles WHERE avatar_url IS NULL;

-- avatar_url が設定済みのレコード
SELECT * FROM public.profiles WHERE avatar_url IS NOT NULL;
```

> **NULLとは？**
> 値が「存在しない・未設定」であることを表す特殊な値です。
> `= NULL` では比較できないので `IS NULL` を使います。

---

## 第4章　並び替えと件数制限 — ORDER BY / LIMIT

### 4-1. ORDER BY で並び替え

```sql
-- 昇順（小さい順）※デフォルト
SELECT * FROM public.profiles ORDER BY username ASC;

-- 降順（大きい順）
SELECT * FROM public.profiles ORDER BY username DESC;
```

### 4-2. LIMIT で件数を制限

```sql
-- 最初の2件だけ取得
SELECT * FROM public.profiles LIMIT 2;
```

### 4-3. OFFSET でスキップ

```sql
-- 最初の1件をスキップして2件取得
SELECT * FROM public.profiles LIMIT 2 OFFSET 1;
```

> **LIMITとOFFSETの使いどころ**
> ページネーション（1ページ目、2ページ目...）の実装に使います。

---

## 第5章　テーブルの結合 — JOIN

### 5-1. JOINとは

複数のテーブルを「共通するカラム」でつなぎ合わせることです。

このプロジェクトでは `auth.users` と `public.profiles` は `id` カラムで紐づいています。

```
auth.users                    public.profiles
┌──────────┬───────────┐     ┌──────────┬──────────┬───────────┐
│    id    │   email   │     │    id    │ username │ full_name │
├──────────┼───────────┤     ├──────────┼──────────┼───────────┤
│ ...0001  │ alice@... │◄───►│ ...0001  │  alice   │Alice Smith│
│ ...0002  │  bob@...  │◄───►│ ...0002  │   bob    │Bob Johnson│
└──────────┴───────────┘     └──────────┴──────────┴───────────┘
```

### 5-2. INNER JOIN の基本構文

```sql
SELECT
  u.email,
  p.username,
  p.full_name
FROM auth.users u
INNER JOIN public.profiles p ON u.id = p.id;
```

> `u` と `p` は **エイリアス（別名）** です。
> テーブル名が長いときに短縮して書くための仕組みです。

実行結果：

| email | username | full_name |
|-------|----------|-----------|
| alice@example.com | alice | Alice Smith |
| bob@example.com | bob | Bob Johnson |
| carol@example.com | carol | Carol Williams |

### 5-3. JOINの種類

| 種類 | 意味 |
|------|------|
| `INNER JOIN` | 両方のテーブルに存在するレコードだけ取得 |
| `LEFT JOIN` | 左テーブルは全件取得。右テーブルにない場合はNULL |
| `RIGHT JOIN` | 右テーブルは全件取得。左テーブルにない場合はNULL |

---

## 第6章　集計 — COUNT / GROUP BY

### 6-1. COUNT で件数を数える

```sql
-- テーブルの全件数
SELECT COUNT(*) FROM public.profiles;

-- 条件付きで件数を数える
SELECT COUNT(*) FROM public.profiles WHERE avatar_url IS NOT NULL;
```

### 6-2. 集計関数一覧

| 関数 | 意味 | 使用例 |
|------|------|--------|
| `COUNT(*)` | 件数 | `SELECT COUNT(*) FROM profiles` |
| `MAX(カラム)` | 最大値 | `SELECT MAX(created_at) FROM profiles` |
| `MIN(カラム)` | 最小値 | `SELECT MIN(created_at) FROM profiles` |

### 6-3. GROUP BY でグループ化

```sql
-- avatar_urlの有無別に件数を集計
SELECT
  avatar_url IS NULL AS no_avatar,
  COUNT(*) AS count
FROM public.profiles
GROUP BY avatar_url IS NULL;
```

---

## 第7章　データの追加・更新・削除

### 7-1. INSERT でデータを追加

```sql
-- auth.users に追加
INSERT INTO auth.users (id, email)
VALUES ('a0000000-0000-0000-0000-000000000099', 'dave@example.com');

-- public.profiles に追加
INSERT INTO public.profiles (id, username, full_name)
VALUES ('a0000000-0000-0000-0000-000000000099', 'dave', 'Dave Brown');
```

### 7-2. UPDATE でデータを更新

```sql
-- alice の full_name を変更する
UPDATE public.profiles
SET full_name = 'Alice Wonder'
WHERE username = 'alice';
```

> **⚠️ WHERE を忘れると全件更新されるので注意！**

### 7-3. DELETE でデータを削除

```sql
-- dave のプロフィールを削除
DELETE FROM public.profiles
WHERE username = 'dave';
```

> **⚠️ WHERE を忘れると全件削除されるので注意！**

---

## 第8章　PostgreSQL 固有の機能

### 8-1. UUID 型

このプロジェクトの `id` カラムは **UUID** という型を使っています。

```
a0000000-0000-0000-0000-000000000001
```

- 世界中で重複しないランダムな識別子
- Supabase では主キーにUUIDを使うのが一般的
- `gen_random_uuid()` 関数で自動生成できる

### 8-2. TIMESTAMPTZ 型

タイムゾーン付きの日時型です。

```sql
-- 現在時刻を取得
SELECT NOW();
```

### 8-3. トリガー（Trigger）

特定のイベント（INSERT / UPDATE / DELETE）が発生したときに自動実行される処理です。

このプロジェクトでは `updated_at` を自動更新するトリガーが設定されています。

```sql
-- profiles を更新すると updated_at が自動で現在時刻に書き換わる
UPDATE public.profiles SET full_name = 'Alice Wonder' WHERE username = 'alice';
-- → updated_at が自動更新される
```

### 8-4. 外部キー（FOREIGN KEY）

テーブル間の「親子関係」を定義する制約です。

```sql
-- profiles.id は auth.users.id を参照している
id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE
```

`ON DELETE CASCADE` は「親（auth.users）のレコードが削除されたら、子（profiles）も自動削除する」という意味です。

---

## まとめ

| 章 | 学んだこと |
|----|-----------|
| 1章 | データベース・テーブル・SQL の基本概念 |
| 2章 | SELECT でデータを取得する |
| 3章 | WHERE で条件を指定して絞り込む |
| 4章 | ORDER BY / LIMIT で並び替え・件数制限 |
| 5章 | JOIN で複数テーブルを結合する |
| 6章 | COUNT / GROUP BY で集計する |
| 7章 | INSERT / UPDATE / DELETE でデータを操作する |
| 8章 | PostgreSQL 固有の UUID / トリガー / 外部キー |

次は `q.md` の問題集で実際に手を動かして練習しましょう！
