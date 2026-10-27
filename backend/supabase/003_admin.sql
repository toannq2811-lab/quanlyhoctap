-- Study For You — migration 003: permissions for the admin website.
-- Run once in Supabase Dashboard → SQL Editor → New query → paste → Run (after 001 and 002).

-- Edit / delete questions of a deck (deck owner or admin).
drop policy if exists "questions: edit own deck or admin" on public.questions;
create policy "questions: edit own deck or admin" on public.questions for update to authenticated
  using (public.is_admin() or exists (select 1 from public.decks d
                                      where d.id = deck_id and d.created_by = auth.uid()));
drop policy if exists "questions: delete own deck or admin" on public.questions;
create policy "questions: delete own deck or admin" on public.questions for delete to authenticated
  using (public.is_admin() or exists (select 1 from public.decks d
                                      where d.id = deck_id and d.created_by = auth.uid()));

-- Edit / delete words of an imported vocabulary list (list owner or admin).
drop policy if exists "vocab_words: edit own list or admin" on public.vocab_words;
create policy "vocab_words: edit own list or admin" on public.vocab_words for update to authenticated
  using (public.is_admin() or exists (select 1 from public.vocab_lists l
                                      where l.id = list_id and l.created_by = auth.uid()));
drop policy if exists "vocab_words: delete own list or admin" on public.vocab_words;
create policy "vocab_words: delete own list or admin" on public.vocab_words for delete to authenticated
  using (public.is_admin() or exists (select 1 from public.vocab_lists l
                                      where l.id = list_id and l.created_by = auth.uid()));

-- Admins may grant or remove the admin role (never their own, so one admin always remains).
create or replace function public.admin_set_role(p_user uuid, p_role text)
returns void language plpgsql security definer set search_path = public as $$
begin
  if not public.is_admin() then
    raise exception 'only admins can change roles';
  end if;
  if p_role not in ('student', 'admin') then
    raise exception 'unknown role %', p_role;
  end if;
  if p_user = auth.uid() then
    raise exception 'cannot change your own role';
  end if;
  update public.profiles set role = p_role where id = p_user;
end $$;

-- Admins may correct a learner's name / birthday.
create or replace function public.admin_update_profile(p_user uuid, p_name text, p_birthday date)
returns void language plpgsql security definer set search_path = public as $$
begin
  if not public.is_admin() then
    raise exception 'only admins can edit other profiles';
  end if;
  update public.profiles set name = nullif(trim(p_name), ''), birthday = p_birthday where id = p_user;
end $$;
