# Blood Freedom

A responsive storefront starter for **Blood Freedom**, an independent casual/lifestyle clothing brand.

**Brand direction:** bold, minimal, expressive.  
**Website target:** https://www.bloodfreedom.com (domain connection and deployment are not configured yet).

## What's included

- Responsive homepage and brand story
- Product showcase for T-shirts, hoodies and sweatshirts
- Category filters
- Interactive shopping bag with quantity controls and subtotal
- Newsletter form preview
- Mobile-friendly layout

## Run locally

No build tools are required. Open `index.html` in a browser, or use a local static server:

```bash
python -m http.server 8000
```

Then visit `http://localhost:8000`.

## Before accepting orders

The current catalogue contains sample products and illustrative prices. Replace them with approved product details, real product photography, sizes, colours, stock and final prices. Connect a secure checkout/payment provider, shipping, tax, order notifications, customer support details and privacy/returns policies before launch. The newsletter form is currently a front-end preview only.

## Deployment

This is a static site and can be deployed with GitHub Pages or another static hosting provider. Add the custom domain only after registering and configuring `bloodfreedom.com` with the selected host.

## Project structure

- `index.html` — page structure
- `styles.css` — responsive styling
- `script.js` — catalogue filters and demo shopping bag
