---
name: gotattoo-missing-features
description: Known product/feature gaps in the GoTattoo app as of 2026-06-16
metadata:
  type: project
---

Gaps in GoTattoo (a tattoo design + artist marketplace). Updated 2026-06-17.

DONE:
- ✅ **Artist↔product link + filter** (`Product.artistId`, `FilterProductsByArtistEvent`).
- ✅ **Cart** (`CartItem` + `CartBloc`, singleton, badge) — and **persisted** via `CartRepository`/`shared_preferences` (`LoadCart` on start, save on each mutation).
- ✅ **Search** (`SearchProductsEvent` query filter in `ProductBloc`; `SearchPage` with its own scoped bloc; wired to the app-bar icon).
- ✅ **Checkout** (`CheckoutPage`) with a transparent **platform-fee** breakdown (`core/constants/platform_fee.dart`, 10%); confirming clears the cart.
- ✅ **Roles client/artist**: `UserRole`, `SessionCubit` + `SessionRepository` (persisted), role-switch `Drawer` on the home.
- ✅ **Artist views**: `ArtistDashboardPage`, `ManageTattoosPage` (full CRUD via existing use cases), `PayoutAccountPage` (PayPal-style `PayoutAccount`).

- ✅ **Search** (`SearchProductsEvent`, `SearchPage`).
- ✅ **Platform fee = 3% EMBEDDED in the price** (`core/constants/platform_fee.dart`): customer sees only the final price (no fee line at checkout); the artist sees the breakdown (fee + net payout) in `ProductForm` and a "Faturamento estimado" (net) card in `ArtistDashboardPage`.
- ✅ **Auth** (local mock): `AuthUser` + `AuthRepository`/`AuthRepositoryImpl` (shared_preferences, plain-text passwords — demo only), `AuthCubit` + `AuthState`, `LoginPage`/`SignUpPage`. Role is chosen at sign-up; app is gated by `_AuthGate` in main.dart. Role moved OUT of `SessionCubit` (now payout-only) INTO `AuthUser`. Drawer shows user + logout.
- ✅ **Order history**: `Order` entity, `OrderRepository`/Impl (shared_preferences), `OrdersCubit`. Checkout records an order tied to the user id; `OrdersPage` (bottom-nav "Pedidos") lists history.

Still not implemented (see ROADMAP.md):
- **Real payment integration** (Stripe Connect / PayPal) — checkout is simulated; `PayoutAccount` is a stand-in.
- **Fee floor for cheap tattoos** — flat 3% doesn't cover the payment-processor's fixed cost on low tickets; consider `max(3%, R$ floor)`. Discussed, not yet built.
- **Real backend** — data sources are still in-memory mocks; persistence is device-local via `shared_preferences`.
- **Bottom nav** items 1–3 (Categorias / Minha Conta / Pedidos) only show SnackBars — no real screens.
- **Admin `ProductForm` is not routed** anywhere; the CRUD use cases (Add/Update/Delete) exist but no screen drives them.
- **No routing abstraction** — pages use `Navigator.push` directly.
- **No real persistence / backend** — datasources are in-memory mocks with fake delays.
- **Location picker** is static/mock data.

See [[gotattoo-architecture-conventions]].
