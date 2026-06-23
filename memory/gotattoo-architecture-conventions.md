---
name: gotattoo-architecture-conventions
description: Architecture, DI and testing conventions adopted in the GoTattoo Flutter app
metadata:
  type: project
---

GoTattoo is a Flutter marketplace for discovering tattoo designs (products) and artists. As of 2026-06-16 it was refactored to clean architecture + SOLID. Conventions to keep:

- **Layers:** `domain` (entities w/ Equatable, repository interfaces, use cases), `data` (models extending entities w/ `fromJson`/`fromEntity`, datasources throwing typed exceptions, repository impls), `presentation` (bloc + pages + widgets). Core in `lib/core` (error/exceptions, error/failures w/ Equatable, usecases/UseCase+NoParams+IdParams, constants, di).
- **DI:** `get_it` service locator in `lib/core/di/injection_container.dart` (`sl`), initialized in `main()` via `initDependencies()`. Blocs = `registerFactory`; use cases/repos/datasources = `registerLazySingleton`. Never instantiate dependencies inside `build()`.
- **Blocs depend only on use cases**, never on repositories. Events/States extend Equatable.
- **Error flow:** datasource throws `ServerException`/`CacheException`/`NotFoundException` → repository `_guard()` maps to `ServerFailure`/`CacheFailure`/`NotFoundFailure` (never leak `e.toString()`).
- **Category filtering lives in `ProductBloc`** (`FilterProductsByCategoryEvent` over a cached `_allProducts`), not in widgets. Category source of truth: `core/constants/tattoo_categories.dart`.
- **ProductDetailPage owns its own scoped `ProductBloc`** (via `BlocProvider(create: sl<ProductBloc>())`) so loading one product never clobbers the home catalog state.
- **Persistence:** `shared_preferences`, wrapped behind repositories (`CartRepository`, `SessionRepository`) registered in DI. `initDependencies()` is **async** (awaits `SharedPreferences.getInstance()`); `main()` awaits it. Cart + Session blocs load on app start (`LoadCart`, `SessionCubit.load()`) and persist on change.
- **Roles:** `UserRole {client, artist}` held by `SessionCubit` (a Cubit, persisted). Home `Drawer` toggles role; artist gets `ArtistDashboardPage` → `ManageTattoosPage` (CRUD) + `PayoutAccountPage`.
- **Platform fee:** single source `core/constants/platform_fee.dart` (10% take rate), surfaced in `CheckoutPage`. Real payments are roadmap (see ROADMAP.md).
- **Testing:** `mocktail` + `bloc_test`. Helpers in `test/helpers/`: `mocks.dart` (mock blocs + `InMemoryCartRepository`/`InMemorySessionRepository` fakes), `fixtures.dart`, `mock_network_image.dart` (wrap widget tests that load `Image.network` in `mockNetworkImages(() async {...})`). For tests touching `sl` or `shared_preferences`, `await sl.reset()` and `SharedPreferences.setMockInitialValues({})`. 103 tests cover all layers + screens.

- **Supabase (Phase 2 — catalog/orders):** `supabase/migrations/0002_phase2_catalog_orders.sql` adds `specialty`/`rating` to profiles, `products`, `orders`, `order_items` (+RLS), a `sales_for_artist(uuid)` security-definer RPC (returns json orders containing that artist's items), and a seed (5 demo artist auth users with fixed UUIDs `1111..`–`5555..`, password `gotattoo`, + 16 products). Artists = profiles where `role='artist'`. Supabase repos: `SupabaseArtistRepository` (profiles), `SupabaseProductRepository` (products CRUD; `_toRow` omits `id` so insert uses DB-generated uuid), `SupabaseOrderRepository` (nested `order_items` select for buyer, RPC for artist sales). DI swaps Product/Artist/Order repos to Supabase when configured. Cart + payout (SessionCubit) stay device-local for now.
- **Supabase (Phase 1 — auth/profiles/avatar):** `lib/core/config/supabase_config.dart` reads `SUPABASE_URL` + `SUPABASE_KEY` (the new `sb_publishable_*` key) via `String.fromEnvironment`. When both are set, `main()` calls `Supabase.initialize(publishableKey: ...)` and DI registers `SupabaseAuthRepository` instead of the local `AuthRepositoryImpl`; otherwise the app runs fully local. So **release builds MUST pass the dart-defines**, e.g.:
  `flutter build apk --release --dart-define=SUPABASE_URL=https://uonpcpeqjrqhrplgaqbi.supabase.co --dart-define=SUPABASE_KEY=sb_publishable_...`
  Tests get no dart-defines → stay in local mode (don't init Supabase). SQL schema: `supabase/migrations/0001_phase1_auth_profiles.sql` (profiles table + RLS + signup trigger + `avatars` storage bucket). Avatar display goes through `core/utils/avatar_image.dart` (handles both Supabase URL and local file path). Phase 2 (artists/products/orders → Postgres) is pending.
- **Android Gradle (bumped for Supabase plugins):** `android/app/build.gradle.kts` `minSdk = 23`, `ndkVersion = "27.0.12077973"`; `android/settings.gradle.kts` Kotlin plugin `2.1.0`. Don't revert these or the Supabase build breaks.

See [[gotattoo-missing-features]] for known product gaps.
