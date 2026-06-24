import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import 'core/config/supabase_config.dart';
import 'core/constants/brand.dart';
import 'core/di/injection_container.dart';
import 'core/route_observer.dart';
import 'core/services/local_notifications_service.dart';
import 'core/services/payment_service.dart';
import 'core/services/push_service.dart';
import 'presentation/bloc/chat/conversations_cubit.dart';
import 'presentation/bloc/notification/notifications_cubit.dart';
import 'presentation/pages/onboarding/onboarding_page.dart';
import 'presentation/bloc/artist/artist_bloc.dart';
import 'presentation/bloc/artist/artist_event.dart';
import 'presentation/bloc/auth/auth_cubit.dart';
import 'presentation/bloc/auth/auth_state.dart';
import 'presentation/bloc/category/categories_cubit.dart';
import 'presentation/bloc/cart/cart_bloc.dart';
import 'presentation/bloc/cart/cart_event.dart';
import 'presentation/bloc/orders/orders_cubit.dart';
import 'presentation/bloc/product/product_bloc.dart';
import 'presentation/bloc/product/product_event.dart';
import 'presentation/bloc/session/session_cubit.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/splash/splash_screen.dart';
import 'presentation/pages/user/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    );
  }
  await initDependencies();
  // Best-effort: ads are passive — ignore any init failure.
  unawaited(MobileAds.instance.initialize());
  await sl<LocalNotificationsService>().init();
  await sl<PushService>().init();
  await sl<PaymentService>().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<ProductBloc>()..add(const GetProductsEvent()),
        ),
        BlocProvider(
          create: (_) => sl<ArtistBloc>()..add(const GetArtistsEvent()),
        ),
        BlocProvider(create: (_) => sl<CartBloc>()..add(const LoadCart())),
        BlocProvider(create: (_) => sl<SessionCubit>()..load()),
        BlocProvider(create: (_) => sl<OrdersCubit>()),
        BlocProvider(create: (_) => sl<CategoriesCubit>()..load()),
        BlocProvider(create: (_) => sl<NotificationsCubit>()),
        BlocProvider(create: (_) => sl<ConversationsCubit>()),
        BlocProvider(create: (_) => sl<AuthCubit>()..checkAuth()),
      ],
      child: MaterialApp(
        title: 'GoTattoo',
        theme: ThemeData(
          useMaterial3: true,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Brand.red,
            primary: Brand.red,
          ),
          primaryColor: Brand.red,
          scaffoldBackgroundColor: Colors.white,
          // Playfair Display on the display/heading slots; body stays sans.
          textTheme: Brand.display(ThemeData.light().textTheme),
        ),
        debugShowCheckedModeBanner: false,
        navigatorObservers: [appRouteObserver],
        home: const _AuthGate(),
      ),
    );
  }
}

/// Shows the first-launch onboarding once, then routes between login and home
/// based on the current auth status.
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  late bool _onboardingSeen =
      sl<SharedPreferences>().getBool(kOnboardingSeenKey) ?? false;

  @override
  Widget build(BuildContext context) {
    if (!_onboardingSeen) {
      return OnboardingPage(
        onDone: () => setState(() => _onboardingSeen = true),
      );
    }
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        // Start/stop notification tracking as the session changes.
        final notifications = context.read<NotificationsCubit>();
        final user = state.user;
        final conversations = context.read<ConversationsCubit>();
        if (state.status == AuthStatus.authenticated && user != null) {
          notifications.start(user.id);
          conversations.start(user.id);
          sl<PushService>().registerFor(user.id);
        } else if (state.status == AuthStatus.unauthenticated) {
          notifications.stop();
          conversations.stop();
          sl<PushService>().unregister();
          // Drop any pushed routes (e.g. Minha Conta) so the login screen the
          // gate now builds isn't left hidden under them.
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.authenticated:
            return const HomePage();
          case AuthStatus.unauthenticated:
            return const LoginPage();
          case AuthStatus.unknown:
            return const SplashScreen();
        }
      },
    );
  }
}
