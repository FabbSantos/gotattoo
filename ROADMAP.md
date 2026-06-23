# GoTattoo — Roadmap

GoTattoo is a marketplace for discovering tattoo designs and the artists who make
them. Customers browse and "buy" tattoo designs; artists publish their work.

## Status

### ✅ Done
- Clean architecture (domain / data / presentation) + `get_it` DI.
- Catalog browsing, **filter by category and by artist**.
- Product detail with quantity selector.
- **Cart** (add/merge/increment/decrement/remove/clear) with live badge.
- **Search** across the catalog.
- **Checkout** screen with a transparent platform-fee breakdown.
- **Cart persistence** across app restarts (`shared_preferences`).
- **Two roles — Client and Artist:**
  - Client: browse, filter, search, cart, checkout.
  - Artist: manage their tattoos (CRUD) and register a payout account.
- 80+ automated tests across all layers.

### 🎨 Polish / branding (later)
- **Splash screen** (launch screen): logo with a short animation shown while the
  app boots, before the home/login. Use `flutter_native_splash` for the native
  static splash + a Flutter animated splash widget over the auth-gate bootstrap.
- **App launcher icon**: a proper GoTattoo icon for the home screen / app drawer.
  Use `flutter_launcher_icons` (one source PNG → all Android/iOS sizes).

### 🔜 Next (booking system follow-ups)
- **No double-booking + tattoo duration**: each tattoo has a service duration; the booking slot picker must hide times that overlap an existing booking for that artist (needs a `duration_hours` on products/bookings + a security-definer RPC `occupied_hours(artist, day)` since RLS hides other clients' bookings). Also a DB-level guard against the insert race.
- **Dispute / appeal flow**: when the client forgets or refuses to confirm completion even though the tattoo was done, the artist needs a way to contact / appeal / escalate (and a timeout that auto-releases or goes to mediation).
- **Cleanup**: cart/checkout/payment/orders code (`CartBloc`, `OrdersCubit`, `cart_page`, `checkout_page`, `payment_page`, `orders_page`, `sales_page`) is now unreachable after bookings replaced the purchase flow — remove or repurpose.

### 🔜 Next
- Real **search** ranking / debounced remote search.
- **Authentication** (sign up / log in, real per-user identity instead of a role toggle).
- **Order history** and order status for both roles.
- Backend + real persistence (currently in-memory mock data sources).

## 💸 Payments (planned)

The business model: **the app is free; GoTattoo takes a percentage of each tattoo
sale as a platform fee.** This keeps the incentives aligned — we only earn when an
artist earns.

- **Take rate:** start at **10%** (`PlatformFee.rate` in `lib/core/constants/`),
  configurable. Industry marketplaces sit at ~8–15%.
- The fee is already **shown transparently at checkout** (subtotal + platform fee
  = total) so both sides understand the split before any real money moves.

### Implementation plan (not yet built)
1. **Processor: Stripe Connect** (recommended over PayPal for marketplaces).
   - Onboard artists as connected accounts (handles KYC/compliance).
   - Use *destination charges* with `application_fee_amount` so the platform fee
     is retained automatically and the remainder is paid out to the artist.
   - PayPal Payouts/Marketplace is a viable alternative the team considered; the
     current `PayoutAccount` entity stores a PayPal-style identifier as a stand-in.
2. **Order entity + backend**: persist orders, link to a Stripe PaymentIntent.
3. **Payout dashboard** for artists (balance, transfers, history).
4. **Compliance:** marketplace facilitator tax/VAT, refunds, dispute handling.

### Open questions
- Flat take rate vs. tiered by artist volume?
- Who absorbs Stripe's processing fee — platform, artist, or pass-through to the
  customer line item?
