-- Run after schema.sql and pod-community-migration.sql.
-- Adds product image storage metadata for the Admin Dashboard.
alter table public.products add column if not exists image_path text;

-- Single-master-admin model:
-- 1. Create one user in Supabase Dashboard > Authentication > Users.
-- 2. Open that user and edit User Metadata is NOT sufficient.
-- 3. Set app_metadata to: {"role":"admin"} using a trusted server/admin method.
--    You may use the Supabase Dashboard user editor if it exposes App Metadata.
-- 4. Do not create additional admin users. The dashboard checks app_metadata.role
--    and all table/storage policies independently enforce the same role.
--
-- Never put the service_role key in the website or commit it to GitHub.
