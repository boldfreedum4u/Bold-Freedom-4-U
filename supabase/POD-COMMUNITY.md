# Blood Freedom — POD catalogue and customer community

This extends the base Supabase setup. Apply `schema.sql` first, then run `pod-community-migration.sql` in Supabase SQL Editor.

## 1. Admin POD design library
Upload your print-ready design files through the future Admin Dashboard. Each design has a name, description, category, source image and publication status. Initial categories are:
- Politics
- Corporate
- Sports
- Cartoons
- Text Dialogues
- Motivation

Admins can add, rename, reorder, deactivate or create more categories. Public customers see active categories and published designs only. Source artwork is kept in a private storage bucket; the original production file is not exposed as a public download.

## 2. Customer product journey
Recommended shopping flow:
1. Browse a design category.
2. Select a design.
3. Choose a garment: T-shirt, Hoodie or Sweatshirt.
4. Choose audience/fit: Male or Female.
5. Choose garment colour, print colour and size.
6. See the final product mock-up, price and availability before adding to bag.

The database keeps garment category (T-shirt/Hoodie/Sweatshirt) separate from audience/fit (male/female). Each design can be linked to one or more garment products. Only combinations approved by the admin should be published. Keep the approved Blood Freedom baby-handprint brand artwork unchanged; customer POD designs are a separate catalogue.

## 3. Customer stories and product photos
Provide a feedback/community section where signed-in customers can submit:
- A written story or feedback
- The product they purchased (optional association)
- Product photos
- A display name

Submissions remain private/pending until reviewed by an admin. The form must have separate, unchecked consent controls:
- Permission to display the story/photo publicly on the website
- Optional permission to reuse the content in marketing/promotions

Do not make marketing permission compulsory for submitting feedback. Do not publish or reuse any customer content unless the relevant permission is given and an admin approves it. Customers should be able to withdraw marketing permission; build a clear contact/withdrawal process before launch. Avoid collecting unnecessary personal information and show a short privacy notice near upload.

Customer photo storage is private. The future public gallery should deliver approved images using a server-side signed-URL flow that checks approval and consent. Do not make the customer upload bucket public.

## 4. Security and operational notes
- This first implementation assumes customer accounts are required to upload stories/photos. Guest submissions can be added later with abuse protection and a secure server-side upload endpoint.
- Admin permissions depend on trusted Supabase `app_metadata.role=admin`; never let a customer set their own role.
- Limit uploads to JPEG, PNG and WebP; source design files max 15 MB, customer photos max 5 MB in this initial schema.
- Review intellectual-property, defamation and moderation risks for user-uploaded political/cartoon/text designs before publishing. Admin approval is required.
- This schema adds the data foundation and storage policies only. The website UI, upload screens, image processing/mockups, customer story form, moderation dashboard and Supabase project connection still need to be built and tested.
