-- Study For You — migration 001: accounts, quiz decks, results, avatars.
-- Run once in Supabase Dashboard → SQL Editor → New query → paste → Run.

-- ---------------------------------------------------------------- profiles
create table if not exists public.profiles (
  id          uuid primary key references auth.users on delete cascade,
  username    text unique not null,
  name        text,
  birthday    date,
  avatar_path text,
  role        text not null default 'student' check (role in ('student', 'admin')),
  last_seen   timestamptz,
  created_at  timestamptz not null default now()
);

-- Create the profile row when someone signs up (username comes from metadata).
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, username)
  values (new.id, lower(coalesce(new.raw_user_meta_data->>'username', split_part(new.email, '@', 1))));
  return new;
end $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.profiles where id = auth.uid() and role = 'admin');
$$;

-- ---------------------------------------------------------------- decks
create table if not exists public.decks (
  id         text primary key,
  name       text not null,
  position   int not null default 0,
  created_by uuid references auth.users on delete set null default auth.uid(),
  created_at timestamptz not null default now()
);

create table if not exists public.questions (
  id            text primary key,
  deck_id       text not null references public.decks on delete cascade,
  section_index int not null,
  section_title text not null,
  position      int not null,
  number        int not null,
  text          text not null,
  options       text[] not null,
  answer        int,
  explanation   text
);
create index if not exists questions_deck_idx on public.questions (deck_id);

-- ---------------------------------------------------------------- progress
create table if not exists public.results (
  user_id     uuid not null references auth.users on delete cascade default auth.uid(),
  question_id text not null references public.questions on delete cascade,
  correct     boolean not null,
  updated_at  timestamptz not null default now(),
  primary key (user_id, question_id)
);

create table if not exists public.attempts (
  id          bigint generated always as identity primary key,
  user_id     uuid not null references auth.users on delete cascade default auth.uid(),
  deck_id     text references public.decks on delete cascade,
  at          timestamptz not null default now(),
  total       int not null,
  right_count int not null,
  wrong_count int not null,
  seconds     int not null
);
create index if not exists attempts_user_idx on public.attempts (user_id, at desc);

-- ---------------------------------------------------------------- row level security
alter table public.profiles  enable row level security;
alter table public.decks     enable row level security;
alter table public.questions enable row level security;
alter table public.results   enable row level security;
alter table public.attempts  enable row level security;

drop policy if exists "profiles: read own or admin" on public.profiles;
create policy "profiles: read own or admin" on public.profiles
  for select to authenticated using (id = auth.uid() or public.is_admin());
drop policy if exists "profiles: update own" on public.profiles;
create policy "profiles: update own" on public.profiles
  for update to authenticated using (id = auth.uid()) with check (id = auth.uid());
-- Users may edit their profile but never their role.
revoke update on public.profiles from authenticated;
grant update (name, birthday, avatar_path, last_seen) on public.profiles to authenticated;

drop policy if exists "decks: read" on public.decks;
create policy "decks: read" on public.decks for select to authenticated using (true);
drop policy if exists "decks: add" on public.decks;
create policy "decks: add" on public.decks for insert to authenticated with check (created_by = auth.uid());
drop policy if exists "decks: edit own or admin" on public.decks;
create policy "decks: edit own or admin" on public.decks for update to authenticated
  using (created_by = auth.uid() or public.is_admin());
drop policy if exists "decks: delete own or admin" on public.decks;
create policy "decks: delete own or admin" on public.decks for delete to authenticated
  using (created_by = auth.uid() or public.is_admin());

drop policy if exists "questions: read" on public.questions;
create policy "questions: read" on public.questions for select to authenticated using (true);
drop policy if exists "questions: add to own deck" on public.questions;
create policy "questions: add to own deck" on public.questions for insert to authenticated
  with check (exists (select 1 from public.decks d
                      where d.id = deck_id and (d.created_by = auth.uid() or public.is_admin())));

drop policy if exists "results: own" on public.results;
create policy "results: own" on public.results for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
drop policy if exists "results: admin reads" on public.results;
create policy "results: admin reads" on public.results for select to authenticated using (public.is_admin());

drop policy if exists "attempts: own" on public.attempts;
create policy "attempts: own" on public.attempts for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
drop policy if exists "attempts: admin reads" on public.attempts;
create policy "attempts: admin reads" on public.attempts for select to authenticated using (public.is_admin());

-- ---------------------------------------------------------------- avatars (private bucket)
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', false)
on conflict (id) do nothing;

drop policy if exists "avatars: own folder" on storage.objects;
create policy "avatars: own folder" on storage.objects for all to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text)
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);
drop policy if exists "avatars: admin reads" on storage.objects;
create policy "avatars: admin reads" on storage.objects for select to authenticated
  using (bucket_id = 'avatars' and public.is_admin());
