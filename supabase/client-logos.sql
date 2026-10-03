-- Client logos: run once in the Supabase SQL editor (Dashboard > SQL Editor).
-- Mirrors the private 'engagement-letters' bucket: files are private and the app
-- shows them through short-lived signed URLs.

-- 1. Columns on clients (path inside the bucket + original file name)
alter table public.clients
  add column if not exists logo_file text,
  add column if not exists logo_file_name text;

-- 2. Private bucket, images only, 5 MB cap (the app checks the same limits)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('client-logos', 'client-logos', false, 5242880,
        array['image/png','image/jpeg','image/svg+xml','image/webp'])
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

-- 3. Policies. Any active signed-in user can view logos; the roles that can edit
--    clients in the app (CAP.editClients in index.html) can upload, replace and remove.
--    Adjust if your engagement-letters policies use a different rule.
drop policy if exists "client logos read" on storage.objects;
create policy "client logos read" on storage.objects for select to authenticated
  using (
    bucket_id = 'client-logos'
    and exists (select 1 from public.profiles p where p.id = auth.uid() and p.active)
  );

drop policy if exists "client logos insert" on storage.objects;
create policy "client logos insert" on storage.objects for insert to authenticated
  with check (
    bucket_id = 'client-logos'
    and exists (select 1 from public.profiles p where p.id = auth.uid() and p.active
                and p.role in ('partner','finance','office_admin','compliance','compliance_officer'))
  );

drop policy if exists "client logos update" on storage.objects;
create policy "client logos update" on storage.objects for update to authenticated
  using (
    bucket_id = 'client-logos'
    and exists (select 1 from public.profiles p where p.id = auth.uid() and p.active
                and p.role in ('partner','finance','office_admin','compliance','compliance_officer'))
  );

drop policy if exists "client logos delete" on storage.objects;
create policy "client logos delete" on storage.objects for delete to authenticated
  using (
    bucket_id = 'client-logos'
    and exists (select 1 from public.profiles p where p.id = auth.uid() and p.active
                and p.role in ('partner','finance','office_admin','compliance','compliance_officer'))
  );
