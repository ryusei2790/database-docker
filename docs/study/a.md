# SQL 解答集

> 解答を見る前に、まず自分でSQLを書いて実行してみましょう。

---

## 第2章　SELECT — データを取得する

### A2-1

```sql
SELECT * FROM public.profiles;
```

**ポイント：** `*` は「全カラム」を意味します。

---

### A2-2

```sql
SELECT username, full_name FROM public.profiles;
```

**ポイント：** 取得したいカラム名をカンマ区切りで指定します。

---

### A2-3

```sql
SELECT * FROM auth.users;
```

**ポイント：** `auth` スキーマのテーブルは `auth.テーブル名` で指定します。

---

### A2-4

```sql
SELECT id, username, created_at FROM public.profiles;
```

---

### A2-5

```sql
SELECT email FROM auth.users;
```

---

## 第3章　WHERE — 条件で絞り込む

### A3-1

```sql
SELECT * FROM public.profiles WHERE username = 'alice';
```

**ポイント：** 文字列の値はシングルクォート `'` で囲みます。

---

### A3-2

```sql
SELECT * FROM public.profiles WHERE username <> 'bob';
```

**ポイント：** `!=` でも同じ意味です。

```sql
SELECT * FROM public.profiles WHERE username != 'bob';
```

---

### A3-3

```sql
SELECT * FROM public.profiles WHERE avatar_url IS NULL;
```

**ポイント：** NULL の比較は `= NULL` ではなく `IS NULL` を使います。

---

### A3-4

```sql
SELECT * FROM public.profiles WHERE full_name LIKE 'A%';
```

**ポイント：** `%` は「0文字以上の任意の文字列」を意味するワイルドカードです。

---

### A3-5

```sql
SELECT * FROM auth.users WHERE email LIKE '%example.com%';
```

**ポイント：** 前後に `%` をつけると「含む」の検索になります。

---

### A3-6

```sql
SELECT * FROM public.profiles WHERE username = 'alice' OR username = 'carol';
```

**別解：** `IN` を使うとすっきり書けます。

```sql
SELECT * FROM public.profiles WHERE username IN ('alice', 'carol');
```

---

## 第4章　ORDER BY / LIMIT — 並び替えと件数制限

### A4-1

```sql
SELECT * FROM public.profiles ORDER BY username ASC;
```

**ポイント：** `ASC` は昇順（省略可）。アルファベット順では alice → bob → carol になります。

---

### A4-2

```sql
SELECT * FROM public.profiles ORDER BY username DESC;
```

**ポイント：** `DESC` は降順。carol → bob → alice になります。

---

### A4-3

```sql
SELECT * FROM public.profiles ORDER BY created_at DESC LIMIT 2;
```

**ポイント：** 「新しい順」は `DESC`、そこから2件なので `LIMIT 2` を組み合わせます。

---

### A4-4

```sql
SELECT * FROM public.profiles ORDER BY username ASC LIMIT 2 OFFSET 1;
```

**ポイント：** `OFFSET 1` は先頭1件をスキップします。
昇順だと alice → bob → carol なので、aliceをスキップして bob・carol が返ります。

---

## 第5章　JOIN — テーブルの結合

### A5-1

```sql
SELECT
  u.email,
  p.username,
  p.full_name
FROM auth.users u
INNER JOIN public.profiles p ON u.id = p.id;
```

**ポイント：**
- `u` と `p` はエイリアス（別名）。テーブル名の代わりに短く書けます。
- `ON u.id = p.id` が結合条件。両テーブルの `id` が一致する行をつなぎます。

---

### A5-2

```sql
SELECT
  u.email,
  p.username,
  p.full_name
FROM auth.users u
INNER JOIN public.profiles p ON u.id = p.id
ORDER BY p.username ASC;
```

---

### A5-3

```sql
SELECT
  p.full_name
FROM auth.users u
INNER JOIN public.profiles p ON u.id = p.id
WHERE u.email = 'bob@example.com';
```

**ポイント：** JOIN後にWHEREで絞り込むことができます。どのテーブルのカラムか `u.` や `p.` で明示します。

---

## 第6章　集計 — COUNT / GROUP BY

### A6-1

```sql
SELECT COUNT(*) FROM public.profiles;
```

**期待される結果：** `3`

---

### A6-2

```sql
SELECT COUNT(*) FROM public.profiles WHERE avatar_url IS NULL;
```

**期待される結果：** `3`（seed.sqlでは全員 avatar_url が未設定のため）

---

### A6-3

```sql
SELECT COUNT(*) FROM auth.users;
```

**期待される結果：** `3`

---

## 第7章　INSERT / UPDATE / DELETE

### A7-1

```sql
-- Step 1: auth.users に追加
INSERT INTO auth.users (id, email)
VALUES ('a0000000-0000-0000-0000-000000000004', 'dave@example.com');

-- Step 2: public.profiles に追加
INSERT INTO public.profiles (id, username, full_name)
VALUES ('a0000000-0000-0000-0000-000000000004', 'dave', 'Dave Brown');

-- 確認
SELECT COUNT(*) FROM public.profiles;
```

**ポイント：**
- `profiles.id` は `auth.users.id` を参照しているので、先に `auth.users` に追加する必要があります。
- 順番を逆にすると「外部キー制約違反」エラーになります。

---

### A7-2

```sql
UPDATE public.profiles
SET full_name = 'Dave Wilson'
WHERE username = 'dave';

-- 確認
SELECT * FROM public.profiles WHERE username = 'dave';
```

**ポイント：** `WHERE` を忘れると全レコードが更新されるので必ず指定します。

---

### A7-3

```sql
-- profiles から先に削除（外部キー制約のため）
DELETE FROM public.profiles WHERE username = 'dave';

-- auth.users からも削除
DELETE FROM auth.users WHERE email = 'dave@example.com';

-- 確認
SELECT COUNT(*) FROM public.profiles;
```

**ポイント：**
- `profiles.id` は `auth.users.id` を参照しているため、子テーブル（profiles）から先に削除します。
- ただし `ON DELETE CASCADE` が設定されているので、`auth.users` を先に削除しても `profiles` は自動で削除されます。

**別解（CASCADE を利用）：**

```sql
-- auth.users を削除すると profiles も自動で削除される
DELETE FROM auth.users WHERE email = 'dave@example.com';

-- 確認
SELECT COUNT(*) FROM public.profiles;
```

---

## 総合問題

### A8-1

```sql
SELECT
  u.email,
  p.username,
  p.full_name
FROM auth.users u
INNER JOIN public.profiles p ON u.id = p.id
WHERE p.full_name LIKE '%son%'
ORDER BY u.email ASC;
```

**期待される結果：** Bob Johnson（full_name に 'son' を含む）

---

### A8-2

```sql
-- Step 1: 現在の updated_at を確認
SELECT username, updated_at FROM public.profiles WHERE username = 'alice';

-- Step 2: full_name を更新
UPDATE public.profiles
SET full_name = 'Alice Wonder'
WHERE username = 'alice';

-- Step 3: updated_at が変わったことを確認
SELECT username, full_name, updated_at FROM public.profiles WHERE username = 'alice';
```

**ポイント：** `updated_at` が自動で現在時刻に更新されているはずです。
これは `init/01_schema.sql` で定義されている `set_updated_at` トリガーが動いているからです。

---

### A8-3

```sql
SELECT username, full_name
FROM public.profiles
ORDER BY username ASC
LIMIT 2;
```

**ポイント：** SELECT・ORDER BY・LIMIT を組み合わせます。
昇順なので alice・bob の2件が返ります。
