import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flashy_flushbar/flashy_flushbar_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/core.engine.dart';
import 'package:here_sdk/core.errors.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/credentials.dart';
import 'package:letdem/features/activities/activities_bloc.dart';
import 'package:letdem/features/activities/repositories/activity.repository.dart';
import 'package:letdem/features/auth/auth_bloc.dart';
import 'package:letdem/features/auth/presentation/views/onboard/splash.view.dart';
import 'package:letdem/features/auth/repositories/auth.repository.dart';
import 'package:letdem/features/car/car_bloc.dart';
import 'package:letdem/features/car/repository/car.repository.dart';
import 'package:letdem/features/earning_account/earning_account_bloc.dart';
import 'package:letdem/features/earning_account/repository/earning.repository.dart';
import 'package:letdem/features/map/map_bloc.dart';
import 'package:letdem/features/map/repository/map.repository.dart';
import 'package:letdem/features/notifications/notifications_bloc.dart';
import 'package:letdem/features/notifications/repository/notification.repository.dart';
import 'package:letdem/features/payment_methods/payment_method_bloc.dart';
import 'package:letdem/features/payment_methods/repository/payments.repository.dart';
import 'package:letdem/features/payout_methods/payout_method_bloc.dart';
import 'package:letdem/features/payout_methods/repository/payout.repository.dart';
import 'package:letdem/features/scheduled_notifications/repository/schedule_notifications.repository.dart';
import 'package:letdem/features/scheduled_notifications/schedule_notifications_bloc.dart';
import 'package:letdem/features/search/repository/search_location.repository.dart';
import 'package:letdem/features/search/search_location_bloc.dart';
import 'package:letdem/features/users/repository/user.repository.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/features/wallet/repository/transaction.repository.dart';
import 'package:letdem/features/wallet/wallet_bloc.dart';
import 'package:letdem/features/withdrawals/repository/withdrawal.repository.dart';
import 'package:letdem/features/withdrawals/withdrawal_bloc.dart';
import 'package:letdem/features/marketplace/data/marketplace_repository.dart';
import 'package:letdem/features/marketplace/presentation/bloc/store_catalog_bloc.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/l10n/app_localizations.dart';
import 'package:letdem/l10n/locales.dart';
import 'package:letdem/notifiers/locale.notifier.dart';
import 'package:letdem/onboarding.view.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

import 'firebase_options.dart';
import 'infrastructure/services/notification/notification.service.dart';

Future _initializeHERESDK() async {
  // Initialize Stripe separately with its own error handling
  try {
    print("Stripe init starting...");
    Stripe.publishableKey = AppCredentials.stripePublishableKey;
    await Stripe.instance.applySettings();
    print("Stripe initialized ✅");
  } catch (e, st) {
    print("Stripe initialization error: $e");
    print("Stack trace: $st");
    // Don't stop HERE SDK initialization if Stripe fails
  }

  // Initialize HERE SDK
  try {
    print("HERE SDK init starting...");
    SdkContext.init(IsolateOrigin.main);

    String accessKeyId = AppCredentials.hereAccessKeyId;
    String accessKeySecret = AppCredentials.hereAccessKeySecret;

    AuthenticationMode authenticationMode = AuthenticationMode.withKeySecret(
      accessKeyId,
      accessKeySecret,
    );
    SDKOptions sdkOptions = SDKOptions.withAuthenticationMode(
      authenticationMode,
    );

    try {
      await SDKNativeEngine.makeSharedInstance(sdkOptions);
      print("HERE SDK initialized ✅");
    } on InstantiationException catch (e, st) {
      print("Stack trace: $st");
      print("HERE SDK Instantiation failed ❌: $e");
    }
  } catch (e, st) {
    print("Stack trace: $st");
    print("Error initializing HERE SDK ❌: $e");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeHERESDK();
  MapboxOptions.setAccessToken(AppCredentials.mapBoxAccessToken);

  // OneSignal initialization
  OneSignal.initialize(AppCredentials.oneSignalAppId);

  // Configure language for OneSignal notifications
  final String defaultLocale =
      Platform.localeName; // Returns locale string in the form 'en_US'
  //getting the language preference and assign in into the app, if none default is japanese
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  final String? languageCode = sharedPreferences.getString('locale');

  // Set OneSignal language
  final String appLanguage = languageCode ?? defaultLocale.split('_')[0];
  OneSignal.User.setLanguage(appLanguage);

  OneSignal.Notifications.addClickListener((event) {
    final data = event.notification.additionalData;
    final handler = NotificationHandler(
      NavigatorHelper.navigatorKey.currentContext!,
    );
    handler.handleNotification(data);
  });

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            const fallbackLocale = Locale('es');
            final resolvedLocale =
                (languageCode != null)
                    ? Locale(languageCode)
                    : (L10n.all.contains(Locale(defaultLocale))
                        ? Locale(defaultLocale)
                        : fallbackLocale);

            return LocaleProvider(defaultLocale: resolvedLocale);
          },
        ),
      ],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AuthRepository>(create: (_) => AuthRepository()),
          RepositoryProvider<PaymentMethodRepository>(
            create: (_) => PaymentMethodRepository(),
          ),
          RepositoryProvider<TransactionRepository>(
            create: (_) => TransactionRepository(),
          ),
          RepositoryProvider<UserRepository>(create: (_) => UserRepository()),
          RepositoryProvider<PayoutMethodRepository>(
            create: (_) => PayoutMethodRepository(),
          ),
          RepositoryProvider<ActivityRepository>(
            create: (_) => ActivityRepository(),
          ),
          RepositoryProvider<EarningsRepository>(
            create: (_) => EarningsRepository(),
          ),
          RepositoryProvider<WithdrawalRepository>(
            create: (_) => WithdrawalRepository(),
          ),
          RepositoryProvider(create: (_) => SearchLocationRepository()),
          RepositoryProvider(create: (_) => CarRepository()),
          RepositoryProvider(create: (_) => MapRepository()),
          RepositoryProvider(create: (_) => ScheduleNotificationsRepository()),
          RepositoryProvider(create: (_) => NotificationRepository()),
          RepositoryProvider(create: (_) => MarketplaceRepository()),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create:
                  (context) => PayoutMethodBloc(
                    payoutMethodRepository:
                        context.read<PayoutMethodRepository>(),
                  ),
            ),
            BlocProvider(
              create:
                  (context) => WithdrawalBloc(
                    withdrawalRepository: context.read<WithdrawalRepository>(),
                  ),
            ),
            BlocProvider(
              create:
                  (context) => EarningsBloc(
                    repository: context.read<EarningsRepository>(),
                  ),
            ),
            BlocProvider(
              create:
                  (context) => PaymentMethodBloc(
                    repository: context.read<PaymentMethodRepository>(),
                  ),
            ),
            BlocProvider(
              create:
                  (context) => WalletBloc(
                    transactionRepository:
                        context.read<TransactionRepository>(),
                  ),
            ),
            BlocProvider(
              create:
                  (context) =>
                      MapBloc(mapRepository: context.read<MapRepository>()),
            ),
            BlocProvider(
              create:
                  (context) => ScheduleNotificationsBloc(
                    scheduleNotificationsRepository:
                        context.read<ScheduleNotificationsRepository>(),
                  ),
            ),
            BlocProvider<NotificationsBloc>(
              create:
                  (context) => NotificationsBloc(
                    notificationRepository:
                        context.read<NotificationRepository>(),
                  ),
            ),
            BlocProvider<AuthBloc>(
              create:
                  (context) =>
                      AuthBloc(authRepository: context.read<AuthRepository>()),
            ),
            BlocProvider(
              create:
                  (context) => SearchLocationBloc(
                    searchLocationRepository:
                        context.read<SearchLocationRepository>(),
                  ),
            ),
            BlocProvider<UserBloc>(
              create:
                  (context) =>
                      UserBloc(userRepository: context.read<UserRepository>()),
            ),
            BlocProvider<ActivitiesBloc>(
              create:
                  (context) => ActivitiesBloc(
                    activityRepository: context.read<ActivityRepository>(),
                  ),
            ),
            BlocProvider(
              create:
                  (context) =>
                      CarBloc(carRepository: context.read<CarRepository>()),
            ),
            BlocProvider(
              create:
                  (context) => StoreCatalogBloc(
                    repository: context.read<MarketplaceRepository>(),
                  ),
            ),
          ],
          child: const AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark,
            child: LetDemApp(),
          ),
        ),
      ),
    ),
  );
}

class LetDemApp extends StatelessWidget {
  const LetDemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp(
        darkTheme: ThemeData.light(), // Optional, will be ignored as
        themeMode: ThemeMode.light, // Forces light theme always
        locale: context.watch<LocaleProvider>().defaultLocale,
        localizationsDelegates: const [
          AppLocalizations.delegate, // Add this line
          //:Q
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English
          Locale('es'), // Spanish
        ],
        builder: FlashyFlushbarProvider.init(),
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.scaffoldColor,
            titleTextStyle: TextStyle(
              color: AppColors.neutral600,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
            elevation: 0,
          ),
          scaffoldBackgroundColor: AppColors.scaffoldColor,
          fontFamily: 'DMSans',
        ),
        navigatorKey: NavigatorHelper.navigatorKey,
        debugShowCheckedModeBanner: false,
        debugShowMaterialGrid: false,
        home: const AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarColor: Colors.black54,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: SplashView(),
        ),
      ),
    );
  }
}
