# Blood Freedom — Master Admin Dashboard

The private dashboard is available at `/admin.html` after deployment.

## Features in this first admin build
- Single master-admin sign-in through Supabase Auth.
- Upload POD source artwork to the private `pod-design-source` bucket.
- Create design categories and enable/disable them.
- Publish/unpublish POD designs after review.
- Create male/female T-shirt, hoodie and sweatshirt product records.
- Upload optional storefront product images to `product-images`.

## One-time setup
1. Create a Supabase project.
2. In Supabase SQL Editor, run `supabase/schema.sql`.
3. Run `supabase/pod-community-migration.sql`.
4. Run `supabase/admin-dashboard-setup.sql`.
5. Create exactly one admin user in Authentication > Users.
6. Assign that user's trusted **app_metadata** role as `{"role":"admin"}`. Do not use editable user_metadata for authorization. If the Dashboard does not let you edit app_metadata, use a trusted server-side Admin API or ask for help setting up a one-time secure function. Never expose a service-role key in browser code.
7. Copy the Project URL and publishable/anon key from Project Settings > API into `supabase-config.js`.
8. Deploy the static site. Visit `/admin.html` and sign in.

## Security
- `supabase-config.js` contains only the public project URL and publishable/anon key. These are expected to be visible in the browser.
- Never put a service-role/secret key, database password or admin password in this repository.
- Admin access is enforced by Supabase RLS policies checking `auth.jwt().app_metadata.role = admin`.
- POD source artwork and customer-story photos are stored in private buckets.
- This is an initial management dashboard. Variant pricing/stock editor, design-to-product mapping, customer-story moderation, order management and payment integration remain future build steps.

## Important
The dashboard cannot sign in until a live Supabase project is configured and the master admin account is assigned the trusted app_metadata role. Do not enter real product data until the database migrations have been applied.
