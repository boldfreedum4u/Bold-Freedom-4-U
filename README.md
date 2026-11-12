# Blood Freedom

A responsive storefront starter for **Blood Freedom**, an India-first casual/lifestyle clothing brand.

- **Initial market:** India
- **Currency:** Indian Rupees (INR / ₹)
- **Planned delivery coverage:** Across India, subject to courier serviceability and final shipping setup
- **Brand direction:** bold, minimal, expressive
- **Target domain:** https://www.bloodfreedom.com (registration, DNS and deployment are not yet configured)

## What's included

- Responsive homepage and brand story
- Product showcase for T-shirts, hoodies and sweatshirts
- Category filters
- Interactive demo shopping bag with quantity controls and INR subtotal
- Newsletter form preview
- Mobile-friendly layout

## Important: preview only

The catalogue contains sample products and illustrative prices. The shopping bag is a front-end demonstration; the website is **not accepting orders** and does not collect payments.

## Before launch

1. Confirm brand name, logo, domain ownership and trademark checks.
2. Add actual product photos, descriptions, fabric details, colours, sizes, stock and final INR prices.
3. Confirm shipping charges, courier partner, PIN-code serviceability, delivery estimates and return/exchange rules.
4. Publish business contact details, privacy policy, terms, shipping policy and returns/refund policy.
5. Connect a secure payment gateway and test successful, failed and refunded transactions.
6. Add order confirmation, fulfilment, tracking and customer-support workflows.
7. Test the site on mobile and desktop before public launch.

## Run locally

No build tools are required. Open `index.html` in a browser, or use a local static server:

```bash
python -m http.server 8000
```

Then visit `http://localhost:8000`.

## Deployment

This static starter can be deployed with GitHub Pages or another static hosting provider. Configure the custom domain only after registering and configuring `bloodfreedom.com` with the selected host.

## Project structure

- `index.html` — page structure and India-first storefront content
- `styles.css` — responsive styling
- `script.js` — sample catalogue, filters and demo shopping bag
