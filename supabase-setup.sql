-- HKM BidDesk — Supabase Database Setup
-- Run this once in your Supabase SQL Editor after creating your project
-- Go to: your project → SQL Editor → New Query → paste this → Run

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- Casinos table
create table if not exists casinos (
  id text primary key,
  name text not null,
  short text,
  city text,
  cats text[] default array['Asian','Beef','Dairy','Pork','Poultry','Seafood'],
  created_at timestamptz default now()
);

-- Items per casino+category (in casino's exact order)
create table if not exists items (
  id uuid primary key default uuid_generate_v4(),
  casino_id text references casinos(id),
  category text not null,
  sort_order integer not null,
  item_num text not null,
  description text,
  unit text,
  hkm_code text,
  created_at timestamptz default now(),
  unique(casino_id, category, item_num)
);

-- LPS / VOL data (from QBE upload — your Power Query replacement)
create table if not exists lps_data (
  id uuid primary key default uuid_generate_v4(),
  casino_id text references casinos(id),
  item_num text not null,
  lp_date text,
  lp_price numeric(10,4),
  vol_90d integer default 0,
  vol_365d integer default 0,
  vol_90d_orders integer default 0,
  vol_30d integer default 0,
  vol_7d integer default 0,
  rev_365d numeric(12,2) default 0,
  updated_at timestamptz default now(),
  unique(casino_id, item_num)
);

-- Bid price history (weekly + monthly submissions)
create table if not exists bid_history (
  id uuid primary key default uuid_generate_v4(),
  casino_id text references casinos(id),
  category text not null,
  item_num text not null,
  week_id text not null,        -- e.g. 'w21' matches the WEEKS array in app
  week_label text,              -- e.g. '03/22-03/28'
  bid_price numeric(10,4),
  bid_type text default 'W',    -- 'W' = weekly, 'M' = monthly
  month_label text,             -- e.g. 'MTH-RW,FB,SILV' for monthly bids
  submitted_at timestamptz default now(),
  unique(casino_id, category, item_num, week_id)
);

-- QB Price List periods (rolling history)
create table if not exists price_periods (
  id uuid primary key default uuid_generate_v4(),
  label text not null,          -- e.g. 'Weekly 03/22' or 'MTH - RW, FB, SILV'
  period_date text,             -- e.g. '03/22/26'
  sort_order integer default 0, -- 0 = current, 1 = previous, etc.
  created_at timestamptz default now()
);

-- Price data per period per item
create table if not exists price_period_data (
  id uuid primary key default uuid_generate_v4(),
  period_id uuid references price_periods(id) on delete cascade,
  item_code text not null,
  cost numeric(10,4),
  reg_price numeric(10,4),
  unique(period_id, item_code)
);

-- Insert default RWLV casino
insert into casinos (id, name, short, city)
values ('rwlv', 'Resorts World Las Vegas', 'RWLV', 'Las Vegas, NV')
on conflict (id) do nothing;

-- Enable Row Level Security (optional but recommended for team access)
-- alter table casinos enable row level security;
-- alter table items enable row level security;
-- alter table lps_data enable row level security;
-- alter table bid_history enable row level security;
-- alter table price_periods enable row level security;
-- alter table price_period_data enable row level security;

-- For now with anon key access, create permissive policies:
-- create policy "allow all" on casinos for all using (true);
-- (repeat for each table)

-- Done! Your database is ready.
-- Next step: Open index.html in your browser and enter your Supabase URL + anon key.
