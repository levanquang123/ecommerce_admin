# QMarket Admin Web

Flutter web dashboard for managing the QMarket e-commerce system. The admin
app connects to the QMarket API to manage catalog data, stock, orders, coupons,
posters, and customer notifications.

## Role in the System

QMarket is split into three main projects:

| Project | Role |
| --- | --- |
| `ecommerce_api` | Node.js/Express + MongoDB backend. Handles auth, catalog, cart, orders, coupons, payments, reviews, Cloudinary, OneSignal, and monitoring. |
| `ecommerce_client` | Flutter mobile shopping app for customers. Customers browse products, manage carts, pay, track orders, review products, and receive push notifications. |
| `ecommerce_admin` | Flutter web dashboard for admins and superadmins. Manages the data used by the mobile app and storefront through the API. |

Main flow:

```txt
Admin Web  --->  QMarket API  --->  MongoDB / Stripe / Cloudinary / OneSignal
Client App --->  QMarket API  --->  MongoDB / Stripe / Cloudinary / OneSignal
```

The admin app is where operational data is created and maintained. The mobile
client is where customers shop. The API is the central layer that enforces
authorization, pricing, stock, payments, and data consistency across apps.

## Live Services

- API: https://api.levanquang.com/
- Storefront/admin domain: https://shop.levanquang.com/
- Privacy policy: https://policy.levanquang.com/
- Mobile app: Flutter Android/iOS, store release in progress

## Features

- Admin and superadmin login with JWT access tokens and refresh tokens.
- Auth guard for `admin` and `superadmin` roles.
- Product dashboard with all products, out-of-stock products, and limited-stock products.
- Category, sub-category, brand, variant type, and variant management.
- Product, SKU/variant, price, offer price, stock, and image management.
- Poster/banner management for client-side displays.
- Coupon code management.
- Order management and order status updates.
- Notification sending and tracking through the backend/OneSignal flow.
- Sentry monitoring with sensitive data scrubbing before events are sent.

## Tech Stack

- Flutter Web
- GetX routing and helpers
- Provider for module state management
- GetStorage for local auth/session state
- HTTP client for QMarket API calls
- Sentry Flutter for monitoring
- Vercel deployment for static Flutter web builds

## API Configuration

The admin app reads its API base URL from the Dart define `MAIN_URL`.

Default value in source:

```txt
http://localhost:3000/
```

Run against the production API:

```powershell
flutter run -d chrome --dart-define=MAIN_URL=https://api.levanquang.com/
```

Run against a local API:

```powershell
flutter run -d chrome --dart-define=MAIN_URL=http://localhost:3000/
```

Sentry can also be configured with Dart defines:

```powershell
flutter run -d chrome `
  --dart-define=MAIN_URL=https://api.levanquang.com/ `
  --dart-define=SENTRY_ENV=production `
  --dart-define=SENTRY_DSN=https://your-public-key@sentry.io/project-id
```

## Installation

Requirements:

- Flutter SDK
- Chrome or another browser supported by Flutter web
- A running local or production API

Install dependencies:

```powershell
flutter pub get
```

Check the Flutter environment:

```powershell
flutter doctor
```

## Run Locally

If the API is running locally at `http://localhost:3000`:

```powershell
flutter run -d chrome --dart-define=MAIN_URL=http://localhost:3000/
```

To test against the production API:

```powershell
flutter run -d chrome --dart-define=MAIN_URL=https://api.levanquang.com/
```

The signed-in account must have the `admin` or `superadmin` role. Regular user
accounts are blocked by the AuthGuard.

## Production Build

Build Flutter web:

```powershell
flutter build web --release `
  --dart-define=MAIN_URL=https://api.levanquang.com/ `
  --dart-define=SENTRY_ENV=production `
  --dart-define=SENTRY_DSN=https://your-public-key@sentry.io/project-id
```

Output:

```txt
build/web
```

`vercel.json` is configured to:

- use `build/web` as the output directory
- rewrite all routes to `index.html` so Flutter routing works
- disable cache for important bootstrap files such as `main.dart.js`

## Checks

Analyze code:

```powershell
flutter analyze
```

Run tests:

```powershell
flutter test
```

Check the API before testing the admin app:

```powershell
curl https://api.levanquang.com/health
curl https://api.levanquang.com/ready
```

## API Integration

The admin app primarily uses these endpoint groups:

- `/users/login`, `/users/refresh-token`, `/users/logout`
- `/categories`, `/subCategories`, `/brands`
- `/variantTypes`, `/variants`
- `/products`, `/posters`
- `/couponCodes`
- `/orders`
- `/notification/*`

The backend owns request validation, admin authorization, image uploads to
Cloudinary, stock and price rules, and notification delivery. The admin app
should only send the operational data needed by the API and should not duplicate
critical business rules on the client side.

## Security Notes

- Do not commit tokens, private Sentry values, or local configuration files with secrets.
- Production API CORS must allow the deployed admin/storefront domain.
- Only `admin` and `superadmin` accounts should access the dashboard.
- After deployment, hard refresh or clear browser cache if the browser still serves an old Flutter bundle.

## Author

Le Van Quang

- Email: levanquang27122005@gmail.com
- API: https://api.levanquang.com/
- Storefront/Admin: https://shop.levanquang.com/
- Privacy Policy: https://policy.levanquang.com/
