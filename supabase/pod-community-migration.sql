-- Blood Freedom: POD designs, audience options and customer stories
-- Apply AFTER schema.sql in Supabase SQL Editor.
-- Customer story/photo submission requires a signed-in customer account in this first version.
-- Marketing permission is explicit and separate from public display permission.

create table if not exists public.design_categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  slug text not null unique,
  description text not null default '',
  sort_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

insert into public.design_categories (name, slug, sort_order) values
 ('Politics', 'politics', 1),
 ('Corporate', 'corporate', 2),
 ('Sports', 'sports', 3),
 ('Cartoons', 'cartoons', 4),
 ('Text Dialogues', 'text-dialogues', 5),
 ('Motivation', 'motivation', 6)
on conflict (slug) do nothing;

create table if not exists public.pod_designs (
  id uuid primary key default gen_random_uuid(),
  category_id uuid not null references public.design_categories(id),
  name text not null,
  description text not null default '',
  image_path text not null,
  preview_image_path text,
  is_active boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists pod_designs_category_active_idx
  on public.pod_designs(category_id, is_active);

-- Keep products.category as the garment type; add audience/fit as a separate field.
alter table public.products
  add column if not exists audience_gender text
  check (audience_gender in ('male', 'female'));

-- Each design can be offered on one or more garment types.
create table if not exists public.design_product_options (
  id uuid primary key default gen_random_uuid(),
  design_id uuid not null references public.pod_designs(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  is_active boolean not null default true,
  unique (design_id, product_id)
);

create index if not exists design_product_options_design_idx
  on public.design_product_options(design_id, is_active);

-- Customer story / product feedback submissions. Admin moderation is required
-- before public display. Marketing consent is a separate explicit opt-in.
create table if not exists public.customer_stories (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid not null references auth.users(id) on delete cascade,
  display_name text not null,
  story text not null,
  product_id uuid references public.products(id) on delete set null,
  design_id uuid references public.pod_designs(id) on delete set null,
  photo_paths text[] not null default '{}',
  allow_public_display boolean not null default false,
  allow_marketing_use boolean not null default false,
  moderation_status text not null default 'pending'
    check (moderation_status in ('pending', 'approved', 'rejected')),
  admin_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists customer_stories_moderation_idx
  on public.customer_stories(moderation_status, allow_public_display, created_at desc);

drop trigger if exists pod_designs_set_updated_at on public.pod_designs;
create trigger pod_designs_set_updated_at before update on public.pod_designs
for each row execute function public.set_updated_at();

drop trigger if exists customer_stories_set_updated_at on public.customer_stories;
create trigger customer_stories_set_updated_at before update on public.customer_stories
for each row execute function public.set_updated_at();

alter table public.design_categories enable row level security;
alter table public.pod_designs enable row level security;
alter table public.design_product_options enable row level security;
alter table public.customer_stories enable row level security;

-- Public can browse active design categories and published designs only.
drop policy if exists "Public can read active design categories" on public.design_categories;
create policy "Public can read active design categories"
on public.design_categories for select to anon, authenticated
using (is_active = true);

drop policy if exists "Admins can manage design categories" on public.design_categories;
create policy "Admins can manage design categories"
on public.design_categories for all to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

drop policy if exists "Public can read active POD designs" on public.pod_designs;
create policy "Public can read active POD designs"
on public.pod_designs for select to anon, authenticated
using (is_active = true);

drop policy if exists "Admins can manage POD designs" on public.pod_designs;
create policy "Admins can manage POD designs"
on public.pod_designs for all to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

drop policy if exists "Public can read active design product options" on public.design_product_options;
create policy "Public can read active design product options"
on public.design_product_options for select to anon, authenticated
using (
  is_active = true
  and exists (select 1 from public.pod_designs d where d.id = design_id and d.is_active = true)
  and exists (select 1 from public.products p where p.id = product_id and p.is_active = true)
);

drop policy if exists "Admins can manage design product options" on public.design_product_options;
create policy "Admins can manage design product options"
on public.design_product_options for all to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

-- A customer may create and read only their own submission.
drop policy if exists "Customers can submit their own stories" on public.customer_stories;
create policy "Customers can submit their own stories"
on public.customer_stories for insert to authenticated
with check (
  customer_id = auth.uid()
  and moderation_status = 'pending'
  and allow_public_display in (true, false)
  and allow_marketing_use in (true, false)
);

drop policy if exists "Customers can read their own stories" on public.customer_stories;
create policy "Customers can read their own stories"
on public.customer_stories for select to authenticated
using (customer_id = auth.uid());

drop policy if exists "Public can read approved stories with display consent" on public.customer_stories;
create policy "Public can read approved stories with display consent"
on public.customer_stories for select to anon, authenticated
using (moderation_status = 'approved' and allow_public_display = true);

drop policy if exists "Admins can manage customer stories" on public.customer_stories;
create policy "Admins can manage customer stories"
on public.customer_stories for all to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

-- POD source files are private: customers never receive original production files.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('pod-design-source', 'pod-design-source', false, 15728640,
        array['image/jpeg','image/png','image/webp'])
on conflict (id) do nothing;

drop policy if exists "Admins manage POD source images" on storage.objects;
create policy "Admins manage POD source images"
on storage.objects for all to authenticated
using (
  bucket_id = 'pod-design-source'
  and (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
)
with check (
  bucket_id = 'pod-design-source'
  and (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
);

-- Customer feedback images are private. Admins can moderate; customers can
-- upload/read only within their own auth.uid() folder. Public gallery delivery
-- should use a server-side signed URL only after consent + approval checks.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('customer-story-photos', 'customer-story-photos', false, 5242880,
        array['image/jpeg','image/png','image/webp'])
on conflict (id) do nothing;

drop policy if exists "Customers upload own story photos" on storage.objects;
create policy "Customers upload own story photos"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'customer-story-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Customers read own story photos" on storage.objects;
create policy "Customers read own story photos"
on storage.objects for select to authenticated
using (
  bucket_id = 'customer-story-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Admins manage customer story photos" on storage.objects;
create policy "Admins manage customer story photos"
on storage.objects for all to authenticated
using (
  bucket_id = 'customer-story-photos'
  and (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
)
with check (
  bucket_id = 'customer-story-photos'
  and (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
);

-- No customer story is approved automatically. Marketing use requires
-- allow_marketing_use=true AND allow_public_display=true AND admin approval.
