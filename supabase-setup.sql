-- ============================================================
-- HKM BidDesk — Supabase Database Setup
-- Run this entire file in your Supabase SQL Editor
-- ============================================================

-- 1. Create the main data table
CREATE TABLE IF NOT EXISTS app_data (
  key         TEXT PRIMARY KEY,
  data        JSONB,
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Enable Row Level Security (required for anon key access)
ALTER TABLE app_data ENABLE ROW LEVEL SECURITY;

-- 3. Allow anyone with your anon key to read AND write
--    (This is fine — only people you share the URL+key with can access it)
CREATE POLICY "team_read"  ON app_data FOR SELECT USING (true);
CREATE POLICY "team_write" ON app_data FOR INSERT WITH CHECK (true);
CREATE POLICY "team_update" ON app_data FOR UPDATE USING (true) WITH CHECK (true);

-- Done! Your database is ready.
-- Go back to the app and paste your Project URL + Anon Key.
