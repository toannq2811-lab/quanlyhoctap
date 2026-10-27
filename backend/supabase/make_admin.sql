-- Give an account the admin role (can sign in to the admin website at /admin/).
-- Replace the username, then run in Supabase Dashboard → SQL Editor.
update public.profiles set role = 'admin' where username = 'admin';
