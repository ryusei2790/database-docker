# 開発ログ

## 2026-03-30

### ✅ 実施内容
- Docker Compose を使ったローカル PostgreSQL テスト環境の構築
- `supabase/postgres` イメージの接続問題を調査・解決
- `postgres:15` への切り替えで接続成功　データベースしか使用できなくなったけど、本来の目標はデータベースを実際にいじってみることだったから、目標から逸れずに済んだ。
次はsupabaseCLIを使用したローカル開発環境の構築と開発プロセスを試してみる。

### 🔧 変更ファイル
- `docker-compose.yml`：`supabase/postgres:15.8.1.060` → `postgres:15` に変更
- `.env`：`POSTGRES_USER=postgres` に修正（初期値が `root` になっていた）

### 💡 決定事項・理由

#### なぜ `supabase/postgres` をやめたか
`supabase/postgres` は `pg_hba.conf` に独自の認証マップ（`supabase_map`）が設定されており、
単体での `psql` 接続ができなかった。
このイメージは Supabase の全スタック（GoTrue・PostgREST・Kong 等）と
組み合わせて使う前提で設計されているため。

#### 現在の構成でできること・できないこと

| 機能 | 状態 |
|------|------|
| SQL でテーブル作成・操作 | ✅ 使える |
| スキーマ設計・検証 | ✅ 使える |
| Auth（signUp / signIn / JWT） | ❌ 使えない |
| OAuth（Google・GitHub ログイン） | ❌ 使えない |
| Storage | ❌ 使えない |
| Row Level Security と Auth の連携 | ❌ 使えない |

#### Auth 等を使いたい場合
Supabase CLI を使ってフルスタック環境を起動する必要がある。

```bash
brew install supabase/tap/supabase
supabase init
supabase start
```

`supabase start` で以下が全て起動する：

| コンテナ | 役割 |
|----------|------|
| `supabase/postgres` | DB 本体 |
| `supabase/gotrue` | Auth API（signUp/signIn/JWT） |
| `supabase/postgrest` | DB への REST API |
| `supabase/realtime` | リアルタイム通信 |
| `supabase/storage-api` | ファイルストレージ |
| `kong` | API ゲートウェイ |

### ⚠️ 残課題・次のステップ
- Auth 機能が必要になったら Supabase CLI 環境に移行する
- 現状は SQL・スキーマ設計の練習環境として使う

---

### 🔥 トラブルシューティング記録

#### `role "postgres" does not exist`

**原因①：** `.env` の `POSTGRES_USER` が `postgres` 以外になっていた
**原因②：** `supabase/postgres` イメージが環境変数を無視して独自ユーザーで動いていた
**解決策：**
1. `.env` を `POSTGRES_USER=postgres` に修正
2. イメージを `postgres:15` に変更
3. `docker compose down -v && docker compose up -d` でリセット

#### ボリュームが残っていて初期化がスキップされる

PostgreSQL は既存データがあると `/docker-entrypoint-initdb.d/` の SQL を**再実行しない**。
スキーマを変更したいときは必ず `-v` でボリュームを削除してから再起動する。

```bash
docker compose down -v
docker compose up -d
```
