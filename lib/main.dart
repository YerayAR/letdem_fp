import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flashy_flushbar/flashy_flushbar_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:here_sdk/core.dart';
import 'package:here_sdk/core.engine.dart';
import 'package:here_sdk/core.errors.dart';
import 'package:iconly/iconly.dart';
import 'package:letdem/constants/credentials.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/features/activities/activities_bloc.dart';
import 'package:letdem/features/activities/repositories/activity.repository.dart';
import 'package:letdem/features/auth/auth_bloc.dart';
import 'package:letdem/features/auth/repositories/auth.repository.dart';
import 'package:letdem/features/car/car_bloc.dart';
import 'package:letdem/features/car/repository/car.repository.dart';
import 'package:letdem/features/map/map_bloc.dart';
import 'package:letdem/features/map/repository/map.repository.dart';
import 'package:letdem/features/notifications/notifications_bloc.dart';
import 'package:letdem/features/notifications/repository/notification.repository.dart';
import 'package:letdem/features/scheduled_notifications/repository/schedule_notifications.repository.dart';
import 'package:letdem/features/scheduled_notifications/schedule_notifications_bloc.dart';
import 'package:letdem/features/search/repository/search_location.repository.dart';
import 'package:letdem/features/search/search_location_bloc.dart';
import 'package:letdem/features/users/repository/user.repository.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/global/popups/popup.dart';
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/global/widgets/chip.dart';
import 'package:letdem/notifiers/locale.notifier.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/services/toast/toast.dart';
import 'package:letdem/views/app/profile/screens/scheduled_notifications/scheduled_notifications.view.dart';
import 'package:letdem/views/app/profile/widgets/settings_container.widget.dart';
import 'package:letdem/views/auth/views/onboard/verify_account.view.dart';
import 'package:letdem/views/welcome/views/splash.view.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

Future _initializeHERESDK() async {
  try {
    print("HERE SDK init starting...");
    SdkContext.init(IsolateOrigin.main);

    String accessKeyId = AppCredentials.hereAccessKeyId;
    String accessKeySecret = AppCredentials.hereAccessKeySecret;

    AuthenticationMode authenticationMode =
        AuthenticationMode.withKeySecret(accessKeyId, accessKeySecret);
    SDKOptions sdkOptions =
        SDKOptions.withAuthenticationMode(authenticationMode);

    try {
      await SDKNativeEngine.makeSharedInstance(sdkOptions);
      print("HERE SDK initialized ✅");
    } on InstantiationException catch (e) {
      print("HERE SDK Instantiation failed ❌: $e");
    }
  } catch (e) {
    print("Error initializing HERE SDK ❌: $e");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeHERESDK();
  MapboxOptions.setAccessToken(AppCredentials.mapBoxAccessToken);
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print("FlutterError: ${details.exception}");
  };
  OneSignal.initialize(AppCredentials.oneSignalAppId);

  //getting the language preference and assign in into the app, if none default is japanese
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  final String? languageCode = sharedPreferences.getString('locale');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(
            defaultLocale: Locale(languageCode ?? "es"),
          ),
        ),
      ],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AuthRepository>(
            create: (_) => AuthRepository(),
          ),
          RepositoryProvider<UserRepository>(
            create: (_) => UserRepository(),
          ),
          RepositoryProvider<ActivityRepository>(
            create: (_) => ActivityRepository(),
          ),
          RepositoryProvider(
            create: (_) => SearchLocationRepository(),
          ),
          RepositoryProvider(
            create: (_) => CarRepository(),
          ),
          RepositoryProvider(
            create: (_) => MapRepository(),
          ),
          RepositoryProvider(
            create: (_) => ScheduleNotificationsRepository(),
          ),
          RepositoryProvider(
            create: (_) => NotificationRepository(),
          ),
        ],
        child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => MapBloc(
                  mapRepository: context.read<MapRepository>(),
                ),
              ),
              BlocProvider(
                create: (context) => ScheduleNotificationsBloc(
                  scheduleNotificationsRepository:
                      context.read<ScheduleNotificationsRepository>(),
                ),
              ),
              BlocProvider<NotificationsBloc>(
                create: (context) => NotificationsBloc(
                  notificationRepository:
                      context.read<NotificationRepository>(),
                ),
              ),
              BlocProvider<AuthBloc>(
                create: (context) => AuthBloc(
                  authRepository: context.read<AuthRepository>(),
                ),
              ),
              BlocProvider(
                create: (context) => SearchLocationBloc(
                  searchLocationRepository:
                      context.read<SearchLocationRepository>(),
                ),
              ),
              BlocProvider<UserBloc>(
                create: (context) => UserBloc(
                  userRepository: context.read<UserRepository>(),
                ),
              ),
              BlocProvider<ActivitiesBloc>(
                create: (context) => ActivitiesBloc(
                  activityRepository: context.read<ActivityRepository>(),
                ),
              ),
              BlocProvider(
                create: (context) => CarBloc(
                  carRepository: context.read<CarRepository>(),
                ),
              ),
            ],
            child: AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle.dark, child: const LetDemApp())),
      ),
    ),
  );
}

class LetDemApp extends StatelessWidget {
  const LetDemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        locale: context.watch<LocaleProvider>().defaultLocale,
        localizationsDelegates: const [
          AppLocalizations.delegate, // Add this line

          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
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
            child: SplashView()));
  }
}

class NavigateNotificationCard extends StatefulWidget {
  final ScheduledNotification notification;

  final bool hideToggle;
  const NavigateNotificationCard(
      {super.key, required this.notification, required this.hideToggle});

  @override
  State<NavigateNotificationCard> createState() =>
      _NavigateNotificationCardState();
}

class _NavigateNotificationCardState extends State<NavigateNotificationCard> {
  bool notifyAvailableSpace = false;
  double radius = 100;

  bool isLocationAvailable = false;

  double distance = 0.0;

  TimeOfDay _fromTime = TimeOfDay.now();
  final TimeOfDay _toTime = TimeOfDay.now();

  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    getDistance();
  }

  void getDistance() async {
    // Check if location services are enabled
    setState(() {
      isLocationAvailable = false;
    });

    var currentLocation = await geolocator.Geolocator.getCurrentPosition(
        desiredAccuracy: geolocator.LocationAccuracy.best);

    // Get distance between two points
    distance = geolocator.Geolocator.distanceBetween(
        widget.notification.location.point.latitude,
        widget.notification.location.point.longitude,
        currentLocation.latitude,
        currentLocation.longitude);
    print('Distance: $distance');

    setState(() {
      isLocationAvailable = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScheduleNotificationsBloc, ScheduleNotificationsState>(
      listener: (context, state) {
        if (state is ScheduleNotificationCreated) {
          AppPopup.showDialogSheet(
            context,
            SuccessDialog(
              title: "Notification Scheduled",
              subtext:
                  "You will be notified when a space is available in this area",
              onProceed: () {
                Navigator.pop(context);
              },
            ),
          );
        }
        // TODO: implement listener
      },
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: isLocationAvailable
                ? [
                    const SizedBox(
                      height: 100,
                      child: Center(
                        child: CupertinoActivityIndicator(),
                      ),
                    ),
                  ]
                : [
                    // Time and distance row
                    Row(
                      children: [
                        Text(
                          // Format distance to miles to kilometers

                          "00 mins ${(distance / 1000).toStringAsFixed(1)} km",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Text(
                              "Traffic Level",
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            DecoratedChip(
                              text: "Moderate",
                              textStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary500,
                              ),
                              color: AppColors.primary500,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Location
                    Row(
                      children: [
                        const Icon(IconlyLight.location, color: Colors.grey),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            widget.notification.location.streetName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Arrival time
                    const Row(
                      children: [
                        Icon(IconlyLight.time_circle, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(
                          "To Arrive in by 12:38pm",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Divider(color: Colors.grey.withOpacity(0.2)),
                    const SizedBox(height: 16),

                    // Notification toggle
                    Row(
                      children: widget.hideToggle
                          ? []
                          : [
                              const Icon(IconlyLight.notification,
                                  color: Colors.grey),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  "Notify me of available space in this area",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              ToggleSwitch(
                                value: notifyAvailableSpace,
                                onChanged: (value) {
                                  setState(() {
                                    notifyAvailableSpace = value;
                                  });
                                },
                              ),
                            ],
                    ),
                    SizedBox(height: widget.hideToggle ? 0 : 16),

                    // Time selection buttons
                    Column(
                      children: !notifyAvailableSpace
                          ? []
                          : [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  PlatformTimePickerButton(
                                      initialTime: _fromTime,
                                      onTimeSelected: (time) {
                                        setState(() {
                                          _fromTime = time;
                                        });
                                      }),
                                  const SizedBox(width: 16),
                                  PlatformTimePickerButton(
                                      initialTime: _toTime,
                                      onTimeSelected: (time) {
                                        setState(() {
                                          _fromTime = time;
                                        });
                                      }),
                                ],
                              ),
                              Row(
                                children: [
                                  PlatformDatePickerButton(
                                      initialDate: _fromDate,
                                      onDateSelected: (date) {
                                        setState(() {
                                          _fromDate = date;
                                        });
                                      }),
                                  const SizedBox(width: 16),
                                  PlatformDatePickerButton(
                                      initialDate: _toDate,
                                      onDateSelected: (date) {
                                        setState(() {
                                          _toDate = date;
                                        });
                                      }),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Radius slider
                              Row(
                                children: [
                                  const Text(
                                    "Radius (Meters)",
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    radius.toStringAsFixed(0),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: Colors.purple,
                                  inactiveTrackColor:
                                      Colors.purple.withOpacity(0.2),
                                  thumbColor: Colors.white,
                                  overlayColor: Colors.purple.withOpacity(0.2),
                                  thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 8),
                                ),
                                child: Slider(
                                  value: radius,
                                  min: 100,
                                  max: 9000,
                                  onChanged: (value) {
                                    setState(() {
                                      radius = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                    ),
                    const SizedBox(height: 24),

                    // Reschedule button
                    PrimaryButton(
                      isLoading: state is ScheduleNotificationsLoading,
                      onTap: () {
                        if (notifyAvailableSpace) {
                          DateTime start = DateTime(
                            _fromDate.year,
                            _fromDate.month,
                            _fromDate.day,
                            _fromTime.hour,
                            _fromTime.minute,
                          );

                          DateTime end = DateTime(
                            _toDate.year,
                            _toDate.month,
                            _toDate.day,
                            _toTime.hour,
                            _toTime.minute,
                          );

                          if (end.isBefore(start)) {
                            Toast.show('End time cannot be before start time');
                            return;
                          }

                          // check if the start or end time is in the past
                          if (start.isBefore(DateTime.now())) {
                            Toast.show('Start time cannot be in the past');
                            return;
                          }
                          if (end.isBefore(DateTime.now())) {
                            Toast.show('End time cannot be in the past');
                            return;
                          }

                          if (radius < 100) {
                            Toast.show('Radius cannot be less than 100 meters');
                            return;
                          }

                          context
                              .read<ScheduleNotificationsBloc>()
                              .add(CreateScheduledNotificationEvent(
                                startsAt: DateTime(
                                  _fromDate.year,
                                  _fromDate.month,
                                  _fromDate.day,
                                  _fromTime.hour,
                                  _fromTime.minute,
                                ),
                                endsAt: DateTime(
                                  _toDate.year,
                                  _toDate.month,
                                  _toDate.day,
                                  _toTime.hour,
                                  _toTime.minute,
                                ),
                                radius: radius.toDouble(),
                                location: widget.notification.location,
                              ));
                        }
                        // Schedule notification
                        // Navigator.pop(context);
                      },
                      icon: !notifyAvailableSpace ? IconlyBold.location : null,
                      text: notifyAvailableSpace ? "Save" : "Start Route",
                    ),
                    Dimens.space(2)
                  ],
          ),
        );
      },
    );
  }
}
