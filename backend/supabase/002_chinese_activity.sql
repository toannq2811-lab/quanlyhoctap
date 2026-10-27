-- Study For You — migration 002: Chinese vocabulary + daily activity (streaks).
-- Run once in Supabase Dashboard → SQL Editor → New query → paste → Run.

-- ---------------------------------------------------------------- daily activity
create table if not exists public.daily_activity (
  user_id uuid not null references auth.users on delete cascade default auth.uid(),
  day     date not null,
  count   int  not null default 0,
  primary key (user_id, day)
);

alter table public.daily_activity enable row level security;
drop policy if exists "activity: own" on public.daily_activity;
create policy "activity: own" on public.daily_activity for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
drop policy if exists "activity: admin reads" on public.daily_activity;
create policy "activity: admin reads" on public.daily_activity for select to authenticated
  using (public.is_admin());

-- Adds n answers to the caller's count for that day (works from several devices).
create or replace function public.bump_activity(p_day date, p_n int)
returns void language sql security invoker set search_path = public as $$
  insert into public.daily_activity (user_id, day, count)
  values (auth.uid(), p_day, p_n)
  on conflict (user_id, day) do update set count = daily_activity.count + excluded.count;
$$;

-- ---------------------------------------------------------------- vocabulary lists added from files
create table if not exists public.vocab_lists (
  id         text primary key,
  name       text not null,
  position   int  not null default 0,
  created_by uuid references auth.users on delete set null default auth.uid(),
  created_at timestamptz not null default now()
);

create table if not exists public.vocab_words (
  id       text primary key,
  list_id  text not null references public.vocab_lists on delete cascade,
  position int  not null,
  hanzi    text not null,
  pinyin   text not null default '',
  meaning  text not null default ''
);
create index if not exists vocab_words_list_idx on public.vocab_words (list_id);

alter table public.vocab_lists enable row level security;
alter table public.vocab_words enable row level security;

drop policy if exists "vocab_lists: read" on public.vocab_lists;
create policy "vocab_lists: read" on public.vocab_lists for select to authenticated using (true);
drop policy if exists "vocab_lists: add" on public.vocab_lists;
create policy "vocab_lists: add" on public.vocab_lists for insert to authenticated
  with check (created_by = auth.uid());
drop policy if exists "vocab_lists: edit own or admin" on public.vocab_lists;
create policy "vocab_lists: edit own or admin" on public.vocab_lists for update to authenticated
  using (created_by = auth.uid() or public.is_admin());
drop policy if exists "vocab_lists: delete own or admin" on public.vocab_lists;
create policy "vocab_lists: delete own or admin" on public.vocab_lists for delete to authenticated
  using (created_by = auth.uid() or public.is_admin());

drop policy if exists "vocab_words: read" on public.vocab_words;
create policy "vocab_words: read" on public.vocab_words for select to authenticated using (true);
drop policy if exists "vocab_words: add to own list" on public.vocab_words;
create policy "vocab_words: add to own list" on public.vocab_words for insert to authenticated
  with check (exists (select 1 from public.vocab_lists l
                      where l.id = list_id and (l.created_by = auth.uid() or public.is_admin())));

-- ---------------------------------------------------------------- vocabulary progress
-- word_id is "hsk1-爱" for built-in words or the vocab_words id for imported ones.
create table if not exists public.vocab_progress (
  user_id    uuid not null references auth.users on delete cascade default auth.uid(),
  word_id    text not null,
  known      boolean not null default false,
  correct    int not null default 0,
  wrong      int not null default 0,
  updated_at timestamptz not null default now(),
  primary key (user_id, word_id)
);

alter table public.vocab_progress enable row level security;
drop policy if exists "vocab_progress: own" on public.vocab_progress;
create policy "vocab_progress: own" on public.vocab_progress for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
drop policy if exists "vocab_progress: admin reads" on public.vocab_progress;
create policy "vocab_progress: admin reads" on public.vocab_progress for select to authenticated
  using (public.is_admin());
