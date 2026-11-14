# Blood Freedom — Supabase setup

## Database choice
Supabase is the selected backend: managed PostgreSQL, authentication, image storage and row-level security in one service. It supports the India-first INR catalogue and the planned admin dashboard.

## Create the project
1. Sign in at https://supabase.com/ and create a new project.
2. Choose a strong, unique database password and store it safely outside GitHub.
3. Select a region suitable for the India-first audience (for example, the closest available India region).
4. Open **SQL Editor** in the Supabase dashboard.
5. Open `schema.sql` from this folder, copy its full contents into the SQL Editor, and run it.
6. In **Project Settings → API**, note the Project URL and publishable/anon key. These can be used by the browser app; never expose the secret/service_role key.

## Admin security
- Create the first admin user through Supabase Authentication.
- Assign the `role=admin` claim in that user's trusted `app_metadata` using a secure server-side/admin process. Do not let users set their own admin role through profile metadata or a public signup form.
- The SQL policies permit public read access only to active products and available variants. Product writes and image uploads are admin-only.
- Do not deploy the admin dashboard until authentication, role assignment and RLS policies have been tested.

## Catalogue structure
- `products`: product identity, description, category and publication status.
- `product_variants`: garment colour, baby-handprint print colour, size, INR price and stock.
- `product-images` storage bucket: public product image delivery, admin-only upload/update/delete.

Allowed categories: `tshirt`, `hoodie`, `sweatshirt`.
Allowed sizes: XS, S, M, L, XL, XXL.
Print colour is restricted to red or white. Confirm the final garment/print combinations and prices before adding products.

## Brand asset rule
Use the exact approved baby-handprint artwork supplied by the owner. Do not redraw, regenerate, recolour, distort or replace the official artwork. The catalogue schema stores the print colour selection; the actual approved image assets still need to be uploaded.

## Not done by this database setup
This creates the database foundation only. It does not create the Supabase project, admin user, storefront integration, admin dashboard, checkout, payments, shipping or live orders. Those require the owner's Supabase project and credentials plus further implementation and testing.
