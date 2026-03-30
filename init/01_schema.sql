-- ============================================================
-- Supabase ローカル擬似環境 初期スキーマ定義
-- このファイルはコンテナ初回起動時に自動で実行される
-- ============================================================

-- ------------------------------------------------------------
-- 1. スキーマ（名前空間）の作成
--    Supabase は public / auth / storage の3スキーマを持つ
-- ------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS storage;

-- ------------------------------------------------------------
-- 2. auth.users テーブル
--    Supabase の認証ユーザー情報を管理するテーブル
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS auth.users (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email       TEXT UNIQUE NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------
-- 3. public スキーマにアプリ用テーブルを作成
--    例：profiles テーブル（ユーザープロフィール）
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.profiles (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username    TEXT UNIQUE,
  full_name   TEXT,
  avatar_url  TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------
-- 4. updated_at を自動更新するトリガー関数
--    レコード更新時に updated_at を現在時刻にセットする
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- profiles テーブルにトリガーを設定
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
