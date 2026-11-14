-- Blood Freedom: Supabase / PostgreSQL foundation
-- Run this in Supabase Dashboard > SQL Editor.
-- Admin access is granted only through trusted app_metadata (role=admin).
-- Never put the Supabase service_role key in browser code.

create extension if not exists pgcrypto;

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  description text not null default '',
  category text not null check (category in ('tshirt', 'hoodie', 'sweatshirt')),
  is_active boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.product_variants (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  sku text unique,
  colour_name text not null,
  garment_colour text not null,
  print_colour text not null check (print_colour in ('red', 'white')),
  size text not null check (size in ('XS', 'S', 'M', 'L', 'XL', 'XXL')),
  price_inr integer not null check (price_inr >= 0),
  stock_quantity integer not null default 0 check (stock_quantity >= 0),
  is_available boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (product_id, garment_colour, print_colour, size)
);

create index if not exists product_variants_product_id_idx
  on public.product_variants(product_id);
create index if not exists products_active_category_idx
  on public.products(is_active, category);

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists products_set_updated_at on public.products;
create trigger products_set_updated_at before update on public.products
for each row execute function public.set_updated_at();

drop trigger if exists product_variants_set_updated_at on public.product_variants;
create trigger product_variants_set_updated_at before update on public.product_variants
for each row execute function public.set_updated_at();

alter table public.products enable row level security;
alter table public.product_variants enable row level security;

-- Public storefront can read active products and available variants only.
drop policy if exists "Public can read active products" on public.products;
create policy "Public can read active products"
on public.products for select to anon, authenticated
using (is_active = true);

drop policy if exists "Admins can manage products" on public.products;
create policy "Admins can manage products"
on public.products for all to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

drop policy if exists "Public can read variants of active products" on public.product_variants;
create policy "Public can read variants of active products"
on public.product_variants for select to anon, authenticated
using (
  is_available = true and exists (
    select 1 from public.products p
    where p.id = product_id and p.is_active = true
  )
);

drop policy if exists "Admins can manage product variants" on public.product_variants;
create policy "Admins can manage product variants"
on public.product_variants for all to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

-- Product image bucket. Uploads/changes are restricted to authenticated admins.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('product-images', 'product-images', true, 5242880,
        array['image/jpeg','image/png','image/webp'])
on conflict (id) do nothing;

drop policy if exists "Public can view product images" on storage.objects;
create policy "Public can view product images"
on storage.objects for select to anon, authenticated
using (bucket_id = 'product-images');

drop policy if exists "Admins can upload product images" on storage.objects;
create policy "Admins can upload product images"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'product-images'
  and (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
);

drop policy if exists "Admins can update product images" on storage.objects;
create policy "Admins can update product images"
on storage.objects for update to authenticated
using (
  bucket_id = 'product-images'
  and (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
)
with check (
  bucket_id = 'product-images'
  and (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
);

drop policy if exists "Admins can delete product images" on storage.objects;
create policy "Admins can delete product images"
on storage.objects for delete to authenticated
using (
  bucket_id = 'product-images'
  and (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
);

-- No sample catalogue or prices are inserted: those must be confirmed by the owner.
