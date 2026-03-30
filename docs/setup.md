# セットアップ手順書

何もない状態からローカル PostgreSQL テスト環境を構築するまでの手順。

---

## 全体の流れ

```
① Docker Desktop をインストールする
       ↓
② このリポジトリをクローンする（docker-compose.yml 等が手元に揃う）
       ↓
③ .env ファイルを作成してパスワードを設定する
       ↓
④ docker compose up -d を実行する
       ↓
   Docker Hub から postgres:15 イメージを自動ダウンロード（pull）
       ↓
   コンテナが起動
       ↓
   init/01_schema.sql が自動実行（テーブル作成）
       ↓
⑤ docker compose exec db psql -U postgres -d postgres で接続できる状態になる
```

> `docker-compose.yml` に `image: postgres:15` と書いてあるため、
> `docker compose up` が「手元にイメージがなければ Docker Hub から取ってくる」という動作をする。
> イメージを手動で pull する必要はない。

---

## 前提条件

- Docker Desktop がインストール済みであること
- `docker compose` コマンドが使えること

### Docker Desktop のインストール（未インストールの場合）

```bash
brew install --cask docker
```

インストール後、アプリケーションから `Docker.app` を起動する（メニューバーにクジラのアイコンが出ればOK）。

動作確認：

```bash
docker --version
docker compose version
```

両方バージョンが表示されれば準備完了。

---

## ステップ1：リポジトリのクローン

```bash
git clone <repository-url>
cd database-docker
```

---

## ステップ2：ファイル構成の確認

以下の構成になっていることを確認する。

```
database-docker/
├── docker-compose.yml
├── .env.example
├── .gitignore
├── init/
│   └── 01_schema.sql
├── seed/
│   └── seed.sql
└── README.md
```

---

## ステップ3：`.env` ファイルを作成する

```bash
cp .env.example .env
```

`.env` をエディタで開き、パスワードを設定する。

```
POSTGRES_USER=postgres
POSTGRES_PASSWORD=任意のパスワード
POSTGRES_DB=postgres
```

> ⚠️ `.env` は Git にコミットしない。`.gitignore` で除外済み。

---

## ステップ4：コンテナを起動する

```bash
docker compose up -d
```

初回は `postgres:15` イメージのダウンロードが走る（数十秒〜数分）。

起動確認：

```bash
docker compose ps
```

`STATUS` が `healthy` または `Up` になっていれば成功。

---

## ステップ5：データベースに接続する

```bash
docker compose exec db psql -U postgres -d postgres
```

`postgres=#` プロンプトが出たら接続成功。

---

## ステップ6：テーブルを確認する

psql 内で以下を実行する。

```sql
-- スキーマ一覧
\dn

-- テーブル一覧
\dt auth.*
\dt public.*
```

`auth.users` と `public.profiles` が表示されれば初期化成功。

psql を終了する：

```sql
\q
```

---

## ステップ7：テストデータを投入する

```bash
docker compose exec db psql -U postgres -d postgres -f /seed/seed.sql
```

以下のような結果が返れば成功：

```
TRUNCATE TABLE
TRUNCATE TABLE
INSERT 0 3
INSERT 0 3
                   id                   |        email         | username |     full_name
--------------------------------------+----------------------+----------+-------------------
 a0000000-0000-0000-0000-000000000001 | alice@example.com   | alice    | Alice Smith
 a0000000-0000-0000-0000-000000000002 | bob@example.com     | bob      | Bob Johnson
 a0000000-0000-0000-0000-000000000003 | carol@example.com   | carol    | Carol Williams
```

---

## よく使うコマンド

| コマンド | 説明 |
|----------|------|
| `docker compose up -d` | コンテナをバックグラウンドで起動 |
| `docker compose down` | コンテナを停止 |
| `docker compose down -v` | コンテナ＋データを完全削除（リセット） |
| `docker compose ps` | 起動状態を確認 |
| `docker compose logs db` | ログを確認（エラー調査に使う） |
| `docker compose exec db psql -U postgres -d postgres` | DB に接続 |

---

## スキーマを変更したいとき

`init/01_schema.sql` を編集した後、以下でリセット＆再起動する。

```bash
docker compose down -v
docker compose up -d
```

> ⚠️ `-v` を忘れると古いデータが残り、SQL が再実行されない。

---

## 注意事項

- `.env` の `POSTGRES_USER` は必ず `postgres` にする
  - 他の値にすると `role "xxx" does not exist` エラーになる
- `supabase/postgres` イメージは使わない
  - 独自認証マップ（`supabase_map`）のせいで単体では psql 接続できない
  - Auth・JWT 等が必要なら Supabase CLI（`supabase start`）を使う → [log.md](./log.md) 参照
