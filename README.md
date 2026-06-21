# Courier Customer App

Flutter mobile app shell for the multitenant Courier SaaS customer portal.

## Flow

1. Customer enters a courier code.
2. App resolves public courier branding from Laravel.
3. Courier workspace is saved on-device.
4. Customer logs into that courier only.
5. App opens a tenant-scoped customer dashboard.
6. Customers can add/switch couriers without mixing sessions.

## Expected Laravel API

Base path: `/api/mobile`

- `POST /tenant/resolve`
- `POST /login`
- `POST /logout`
- `GET /bootstrap`
- `GET /packages`
- `GET /invoices`
- `GET /delivery-requests`
- `GET /addresses`
- `GET /pre-alerts`
- `GET /purchase-requests`
- `GET /wallet`
- `GET /notifications`
- `POST /invoices/{invoice}/receipt`
- `POST /device-token`

All authenticated endpoints should use Sanctum bearer tokens and scope data by `auth()->user()->tenant_id` and customer id.

## Run

Flutter is not installed in this workspace right now. On a Flutter-enabled machine:

```bash
cd mobile_customer_app
flutter pub get
flutter run --dart-define=API_BASE_URL=https://freitora.online/api/mobile
```

## Current App Modules

- Courier code resolution and branded login
- Multi-courier account switcher
- Dashboard summary
- Shipping addresses
- Packages
- Pre-alert and purchase request list views
- Delivery request list view
- Invoice list with payment receipt upload
- Wallet / loyalty summary
- Notifications list

## Next Native Setup Step

After Flutter is installed, run `flutter create .` inside this folder to generate the native Android/iOS project folders. Then configure Firebase Cloud Messaging for push notifications and call `POST /api/mobile/device-token` after login for each tenant account.
## Codemagic APK Build

Use the included `codemagic.yaml` workflow named `android-apk`. It runs `flutter create .` first, so Codemagic can build even when the generated `android/` folder is not committed yet.

The release APK is built with:

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://freitora.online/api/mobile
```
