import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @enterDestination.
  ///
  /// In en, this message translates to:
  /// **'Enter destination'**
  String get enterDestination;

  /// No description provided for @whatDoYouWantToDo.
  ///
  /// In en, this message translates to:
  /// **'What do you want to do?'**
  String get whatDoYouWantToDo;

  /// No description provided for @publishSpace.
  ///
  /// In en, this message translates to:
  /// **'Publish space'**
  String get publishSpace;

  /// No description provided for @publishEvent.
  ///
  /// In en, this message translates to:
  /// **'Publish alert'**
  String get publishEvent;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @activities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activities;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @contributions.
  ///
  /// In en, this message translates to:
  /// **'Contributions'**
  String get contributions;

  /// No description provided for @scheduledNotifications.
  ///
  /// In en, this message translates to:
  /// **'Scheduled notifications'**
  String get scheduledNotifications;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment methods'**
  String get paymentMethods;

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// No description provided for @connectAccount.
  ///
  /// In en, this message translates to:
  /// **'Connect account'**
  String get connectAccount;

  /// Title for the confirmation dialog when the user chooses to cancel a reservation.
  ///
  /// In en, this message translates to:
  /// **'Cancel reservation?'**
  String get cancelReservationConfirmationTitle;

  /// Body text explaining the consequence of cancelling a reservation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this reservation? This action can’t be undone.'**
  String get cancelReservationConfirmationText;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic information'**
  String get basicInformation;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About us'**
  String get aboutUs;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get termsOfUse;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @cardholderName.
  ///
  /// In en, this message translates to:
  /// **'Cardholder Name'**
  String get cardholderName;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @notificationPaidSpaceReserved.
  ///
  /// In en, this message translates to:
  /// **'Paid space reserved'**
  String get notificationPaidSpaceReserved;

  /// No description provided for @notificationNewSpacePublished.
  ///
  /// In en, this message translates to:
  /// **'New space published'**
  String get notificationNewSpacePublished;

  /// No description provided for @notificationSpaceOccupied.
  ///
  /// In en, this message translates to:
  /// **'Space occupied'**
  String get notificationSpaceOccupied;

  /// No description provided for @notificationDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get notificationDisabled;

  /// No description provided for @notificationFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get notificationFree;

  /// No description provided for @notificationBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get notificationBlue;

  /// No description provided for @notificationGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get notificationGreen;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Message shown when user has no pending funds and withdrawal limits
  ///
  /// In en, this message translates to:
  /// **'You have no pending funds to be released. You can withdraw between {min} and {max}.'**
  String noPendingFundsMessage(Object min, Object max);

  /// No description provided for @selectDuration.
  ///
  /// In en, this message translates to:
  /// **'Select duration'**
  String get selectDuration;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'MIN'**
  String get minutes;

  /// No description provided for @sec.
  ///
  /// In en, this message translates to:
  /// **'SEC'**
  String get sec;

  /// No description provided for @proceed.
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get proceed;

  /// No description provided for @pleaseEnter.
  ///
  /// In en, this message translates to:
  /// **'Please enter'**
  String get pleaseEnter;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength;

  /// No description provided for @passwordRequireNumber.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one number'**
  String get passwordRequireNumber;

  /// No description provided for @passwordRequireSpecial.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one special character'**
  String get passwordRequireSpecial;

  /// No description provided for @passwordRequireUppercase.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one uppercase letter'**
  String get passwordRequireUppercase;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @validCard.
  ///
  /// In en, this message translates to:
  /// **'Valid card'**
  String get validCard;

  /// No description provided for @enterCardDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter card details'**
  String get enterCardDetails;

  /// No description provided for @passwordStrength.
  ///
  /// In en, this message translates to:
  /// **'Password Strength'**
  String get passwordStrength;

  /// No description provided for @passwordWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get passwordWeak;

  /// No description provided for @passwordFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get passwordFair;

  /// No description provided for @passwordGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get passwordGood;

  /// No description provided for @passwordStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get passwordStrong;

  /// No description provided for @missingInfo.
  ///
  /// In en, this message translates to:
  /// **'Missing info'**
  String get missingInfo;

  /// No description provided for @reservationExpired.
  ///
  /// In en, this message translates to:
  /// **'Reservation expired'**
  String get reservationExpired;

  /// No description provided for @lessThanAMinuteLeft.
  ///
  /// In en, this message translates to:
  /// **'Less than a minute left'**
  String get lessThanAMinuteLeft;

  /// Message showing remaining minutes to reserve a space
  ///
  /// In en, this message translates to:
  /// **'{minutes} mins left to reserve space'**
  String minutesLeftToReserve(Object minutes);

  /// No description provided for @meters.
  ///
  /// In en, this message translates to:
  /// **'meters'**
  String get meters;

  /// No description provided for @trafficLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get trafficLow;

  /// No description provided for @trafficModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get trafficModerate;

  /// No description provided for @trafficHeavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get trafficHeavy;

  /// No description provided for @homeLocationShort.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeLocationShort;

  /// No description provided for @transactionSpacePayment.
  ///
  /// In en, this message translates to:
  /// **'Payment received for space'**
  String get transactionSpacePayment;

  /// No description provided for @transactionWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal'**
  String get transactionWithdraw;

  /// No description provided for @transactionSpaceTransfer.
  ///
  /// In en, this message translates to:
  /// **'Space transfer'**
  String get transactionSpaceTransfer;

  /// No description provided for @transactionSpaceWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Space withdrawal'**
  String get transactionSpaceWithdrawal;

  /// No description provided for @transactionSpaceDeposit.
  ///
  /// In en, this message translates to:
  /// **'Space deposit'**
  String get transactionSpaceDeposit;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @blocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get blocked;

  /// No description provided for @work.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get work;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal info'**
  String get personalInfo;

  /// No description provided for @addressInfo.
  ///
  /// In en, this message translates to:
  /// **'Address info'**
  String get addressInfo;

  /// No description provided for @documentUpload.
  ///
  /// In en, this message translates to:
  /// **'Document upload'**
  String get documentUpload;

  /// No description provided for @bankAccountInfo.
  ///
  /// In en, this message translates to:
  /// **'Bank account info'**
  String get bankAccountInfo;

  /// No description provided for @submitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get submitted;

  /// No description provided for @policeAhead.
  ///
  /// In en, this message translates to:
  /// **'Police ahead'**
  String get policeAhead;

  /// No description provided for @roadClosedAhead.
  ///
  /// In en, this message translates to:
  /// **'Road closed ahead'**
  String get roadClosedAhead;

  /// No description provided for @accidentAhead.
  ///
  /// In en, this message translates to:
  /// **'Accident ahead'**
  String get accidentAhead;

  /// No description provided for @unknownEventAhead.
  ///
  /// In en, this message translates to:
  /// **'Unknown alert ahead'**
  String get unknownEventAhead;

  /// No description provided for @police.
  ///
  /// In en, this message translates to:
  /// **'Police'**
  String get police;

  /// No description provided for @closedRoad.
  ///
  /// In en, this message translates to:
  /// **'Closed Road'**
  String get closedRoad;

  /// No description provided for @accident.
  ///
  /// In en, this message translates to:
  /// **'Accident'**
  String get accident;

  /// No description provided for @freeSpace.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get freeSpace;

  /// No description provided for @blueZone.
  ///
  /// In en, this message translates to:
  /// **'Blue Zone'**
  String get blueZone;

  /// No description provided for @disabledSpace.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabledSpace;

  /// No description provided for @greenZone.
  ///
  /// In en, this message translates to:
  /// **'Green Zone'**
  String get greenZone;

  /// No description provided for @paidFreeSpace.
  ///
  /// In en, this message translates to:
  /// **'Paid free'**
  String get paidFreeSpace;

  /// No description provided for @paidBlueZone.
  ///
  /// In en, this message translates to:
  /// **'Paid blue zone'**
  String get paidBlueZone;

  /// No description provided for @paidDisabledSpace.
  ///
  /// In en, this message translates to:
  /// **'Paid disabled'**
  String get paidDisabledSpace;

  /// No description provided for @paidGreenZone.
  ///
  /// In en, this message translates to:
  /// **'Paid green zone'**
  String get paidGreenZone;

  /// No description provided for @selectEventType.
  ///
  /// In en, this message translates to:
  /// **'Select Alert type'**
  String get selectEventType;

  /// No description provided for @publishButtonText.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publishButtonText;

  /// No description provided for @eventPublishedTitle.
  ///
  /// In en, this message translates to:
  /// **'Alert published\nsuccessfully'**
  String get eventPublishedTitle;

  /// No description provided for @eventPublishedSubtext.
  ///
  /// In en, this message translates to:
  /// **'Your alert have been published successfully, people can now see this alert on map.'**
  String get eventPublishedSubtext;

  /// No description provided for @away.
  ///
  /// In en, this message translates to:
  /// **'away'**
  String get away;

  /// No description provided for @addPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Add payment method'**
  String get addPaymentMethod;

  /// No description provided for @cardEndingWith.
  ///
  /// In en, this message translates to:
  /// **'{brand} ending with {last4}'**
  String cardEndingWith(String brand, String last4);

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment successful'**
  String get paymentSuccessful;

  /// No description provided for @spaceReservedSuccess.
  ///
  /// In en, this message translates to:
  /// **'You have successfully reserved a paid space. You can get the details by clicking below.'**
  String get spaceReservedSuccess;

  /// No description provided for @arrivalTitle.
  ///
  /// In en, this message translates to:
  /// **'You’ve arrived!'**
  String get arrivalTitle;

  /// No description provided for @arrivalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby parking spots are now visible on the map. Tap a spot to start navigation.'**
  String get arrivalSubtitle;

  /// No description provided for @getSpaceDetails.
  ///
  /// In en, this message translates to:
  /// **'Get details of space'**
  String get getSpaceDetails;

  /// No description provided for @reserveSpace.
  ///
  /// In en, this message translates to:
  /// **'Reserve space'**
  String get reserveSpace;

  /// No description provided for @navigateToSpace.
  ///
  /// In en, this message translates to:
  /// **'Navigate to space'**
  String get navigateToSpace;

  /// No description provided for @regularSpace.
  ///
  /// In en, this message translates to:
  /// **'Regular space'**
  String get regularSpace;

  /// No description provided for @paidSpace.
  ///
  /// In en, this message translates to:
  /// **'Paid space'**
  String get paidSpace;

  /// No description provided for @importantNotice.
  ///
  /// In en, this message translates to:
  /// **'Important notice'**
  String get importantNotice;

  /// No description provided for @createCarProfileFirst.
  ///
  /// In en, this message translates to:
  /// **'You need to create a car profile to publish a paid space. Please create a car profile first.'**
  String get createCarProfileFirst;

  /// No description provided for @createEarningAccountFirst.
  ///
  /// In en, this message translates to:
  /// **'You need to create an earning account to publish a paid space. Please create an earning account first.'**
  String get createEarningAccountFirst;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location permission\nrequired'**
  String get locationPermissionRequired;

  /// No description provided for @locationPermissionDescription.
  ///
  /// In en, this message translates to:
  /// **'We need to get access to your location services to perform any action in the app'**
  String get locationPermissionDescription;

  /// No description provided for @openSystemSettings.
  ///
  /// In en, this message translates to:
  /// **'Open system settings'**
  String get openSystemSettings;

  /// No description provided for @spaceDetails.
  ///
  /// In en, this message translates to:
  /// **'Space details'**
  String get spaceDetails;

  /// No description provided for @confirmOrder.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmOrder;

  /// No description provided for @spaceReserved.
  ///
  /// In en, this message translates to:
  /// **'Space reserved'**
  String get spaceReserved;

  /// No description provided for @spaceReservedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your space has been reserved successfully.'**
  String get spaceReservedSuccessfully;

  /// No description provided for @confirmationCode.
  ///
  /// In en, this message translates to:
  /// **'Confirmation code'**
  String get confirmationCode;

  /// No description provided for @enterConfirmationCode.
  ///
  /// In en, this message translates to:
  /// **'The requester of the space will give you a 6-digit confirmation number, enter it here.'**
  String get enterConfirmationCode;

  /// No description provided for @confirmationCodeWarning.
  ///
  /// In en, this message translates to:
  /// **'Kindly ensure that the confirmation code works before you give out the space'**
  String get confirmationCodeWarning;

  /// No description provided for @pleaseEnterConfirmationCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the confirmation code'**
  String get pleaseEnterConfirmationCode;

  /// No description provided for @reserved.
  ///
  /// In en, this message translates to:
  /// **'Reserved'**
  String get reserved;

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get waiting;

  /// Title shown in the dialog when the user is about to delete a space
  ///
  /// In en, this message translates to:
  /// **'Delete space'**
  String get deleteSpaceTitle;

  /// Subtext shown in the dialog explaining that the space deletion is permanent
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this space? This action cannot be undone.'**
  String get deleteSpaceSubtext;

  /// Title shown when a space is successfully deleted
  ///
  /// In en, this message translates to:
  /// **'Space deleted'**
  String get spaceDeleted;

  /// Subtext shown to confirm the space deletion was successful
  ///
  /// In en, this message translates to:
  /// **'The space has been successfully deleted.'**
  String get spaceDeletedSubtext;

  /// No description provided for @reservedSpace.
  ///
  /// In en, this message translates to:
  /// **'Reserved space'**
  String get reservedSpace;

  /// No description provided for @confirmationCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirmation code'**
  String get confirmationCodeTitle;

  /// No description provided for @shareCodeOwner.
  ///
  /// In en, this message translates to:
  /// **'Share this code with the parking space owner'**
  String get shareCodeOwner;

  /// No description provided for @ownerPlateNumber.
  ///
  /// In en, this message translates to:
  /// **'The owner\'s plate number: '**
  String get ownerPlateNumber;

  /// No description provided for @callSpaceOwner.
  ///
  /// In en, this message translates to:
  /// **'Call space owner'**
  String get callSpaceOwner;

  /// No description provided for @couldNotLaunchDialer.
  ///
  /// In en, this message translates to:
  /// **'Could not launch dialer'**
  String get couldNotLaunchDialer;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @timeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Time remaining'**
  String get timeRemaining;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'€'**
  String get currency;

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get showAll;

  /// No description provided for @noContributions.
  ///
  /// In en, this message translates to:
  /// **'No contributions yet'**
  String get noContributions;

  /// No description provided for @noContributionsDescription.
  ///
  /// In en, this message translates to:
  /// **'Your contributions history will appear here, publish to see them'**
  String get noContributionsDescription;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @parkingSpace.
  ///
  /// In en, this message translates to:
  /// **'Parking space'**
  String get parkingSpace;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get events;

  /// No description provided for @verifyYourAccountFirst.
  ///
  /// In en, this message translates to:
  /// **'Your earnings account is not verified yet. Please verify your account by submitting your ID card and bank information.'**
  String get verifyYourAccountFirst;

  /// No description provided for @failedToLoadActivities.
  ///
  /// In en, this message translates to:
  /// **'Failed to load activities: {error}'**
  String failedToLoadActivities(String error);

  /// No description provided for @selectFilterActivities.
  ///
  /// In en, this message translates to:
  /// **'Select a filter to view activities'**
  String get selectFilterActivities;

  /// No description provided for @searchLocation.
  ///
  /// In en, this message translates to:
  /// **'Search location'**
  String get searchLocation;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @updatingLocation.
  ///
  /// In en, this message translates to:
  /// **'UPDATING {type} LOCATION'**
  String updatingLocation(String type);

  /// No description provided for @spaceOwnerCannotReserve.
  ///
  /// In en, this message translates to:
  /// **'Space owner cannot reserve their own space'**
  String get spaceOwnerCannotReserve;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @spaceDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Space details'**
  String get spaceDetailsTitle;

  /// No description provided for @locationType.
  ///
  /// In en, this message translates to:
  /// **'{type} LOCATION'**
  String locationType(Object type);

  /// No description provided for @setLocation.
  ///
  /// In en, this message translates to:
  /// **'Set {type}'**
  String setLocation(String type);

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @spaceOccupied.
  ///
  /// In en, this message translates to:
  /// **'Space occupied'**
  String get spaceOccupied;

  /// No description provided for @otherLocation.
  ///
  /// In en, this message translates to:
  /// **'Other location'**
  String get otherLocation;

  /// No description provided for @homeLocation.
  ///
  /// In en, this message translates to:
  /// **'Home location'**
  String get homeLocation;

  /// No description provided for @workLocation.
  ///
  /// In en, this message translates to:
  /// **'Work location'**
  String get workLocation;

  /// No description provided for @whereAreYouGoing.
  ///
  /// In en, this message translates to:
  /// **'Where are you going to?'**
  String get whereAreYouGoing;

  /// No description provided for @favourites.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get favourites;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @spacePublished.
  ///
  /// In en, this message translates to:
  /// **'Space published'**
  String get spacePublished;

  /// No description provided for @eventPublished.
  ///
  /// In en, this message translates to:
  /// **'Alert published'**
  String get eventPublished;

  /// No description provided for @pointsEarned.
  ///
  /// In en, this message translates to:
  /// **'+{points} Pts'**
  String pointsEarned(String points);

  /// No description provided for @noCarRegistered.
  ///
  /// In en, this message translates to:
  /// **'No car registered'**
  String get noCarRegistered;

  /// No description provided for @registerCarDetails.
  ///
  /// In en, this message translates to:
  /// **'Register your car with the car details\nfor safety and accessibility'**
  String get registerCarDetails;

  /// No description provided for @tapToRegisterCar.
  ///
  /// In en, this message translates to:
  /// **'Tap to register car'**
  String get tapToRegisterCar;

  /// No description provided for @registerCar.
  ///
  /// In en, this message translates to:
  /// **'Register car'**
  String get registerCar;

  /// No description provided for @updateCarDetails.
  ///
  /// In en, this message translates to:
  /// **'Update car details'**
  String get updateCarDetails;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @enterCarBrand.
  ///
  /// In en, this message translates to:
  /// **'Enter car brand'**
  String get enterCarBrand;

  /// No description provided for @enterPlateNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter plate number'**
  String get enterPlateNumber;

  /// No description provided for @brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// No description provided for @plateNumber.
  ///
  /// In en, this message translates to:
  /// **'Plate number'**
  String get plateNumber;

  /// No description provided for @selectTag.
  ///
  /// In en, this message translates to:
  /// **'Select tag'**
  String get selectTag;

  /// No description provided for @whatIsThis.
  ///
  /// In en, this message translates to:
  /// **'What\'s this?'**
  String get whatIsThis;

  /// No description provided for @whatTagMeans.
  ///
  /// In en, this message translates to:
  /// **'What tag means'**
  String get whatTagMeans;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @ecoLabel.
  ///
  /// In en, this message translates to:
  /// **'Eco Label'**
  String get ecoLabel;

  /// No description provided for @zeroEmissionLabel.
  ///
  /// In en, this message translates to:
  /// **'Zero Emission Label'**
  String get zeroEmissionLabel;

  /// No description provided for @bLabelYellow.
  ///
  /// In en, this message translates to:
  /// **'B Label Yellow'**
  String get bLabelYellow;

  /// No description provided for @cLabelGreen.
  ///
  /// In en, this message translates to:
  /// **'C Label Green'**
  String get cLabelGreen;

  /// No description provided for @noLabel.
  ///
  /// In en, this message translates to:
  /// **'No Label'**
  String get noLabel;

  /// No description provided for @ecoLabelPluginHybrids.
  ///
  /// In en, this message translates to:
  /// **'Plug-in hybrids with an electric range of less than 40 km.'**
  String get ecoLabelPluginHybrids;

  /// No description provided for @ecoLabelNonPluginHybrids.
  ///
  /// In en, this message translates to:
  /// **'Non-plug-in hybrids (HEV).'**
  String get ecoLabelNonPluginHybrids;

  /// No description provided for @ecoLabelGasPowered.
  ///
  /// In en, this message translates to:
  /// **'Gas-powered vehicles (LPG, CNG, or LNG).'**
  String get ecoLabelGasPowered;

  /// No description provided for @zeroLabelElectric.
  ///
  /// In en, this message translates to:
  /// **'100% electric vehicles (BEV).'**
  String get zeroLabelElectric;

  /// No description provided for @zeroLabelPluginHybrids.
  ///
  /// In en, this message translates to:
  /// **'Plug-in hybrids (PHEV) with an electric range of more than 40 km.'**
  String get zeroLabelPluginHybrids;

  /// No description provided for @zeroLabelHydrogen.
  ///
  /// In en, this message translates to:
  /// **'Hydrogen-powered vehicles.'**
  String get zeroLabelHydrogen;

  /// No description provided for @bLabelPetrol.
  ///
  /// In en, this message translates to:
  /// **'Petrol cars and vans registered from January 2001 onwards.'**
  String get bLabelPetrol;

  /// No description provided for @bLabelDiesel.
  ///
  /// In en, this message translates to:
  /// **'Diesel cars and vans registered from January 2006 onwards.'**
  String get bLabelDiesel;

  /// No description provided for @bLabelIndustrial.
  ///
  /// In en, this message translates to:
  /// **'Industrial vehicles and buses registered from 2005 onwards.'**
  String get bLabelIndustrial;

  /// No description provided for @cLabelPetrol.
  ///
  /// In en, this message translates to:
  /// **'Petrol cars and vans registered from January 2006 onwards.'**
  String get cLabelPetrol;

  /// No description provided for @cLabelDiesel.
  ///
  /// In en, this message translates to:
  /// **'Diesel cars and vans registered from September 2015 onwards.'**
  String get cLabelDiesel;

  /// No description provided for @cLabelIndustrial.
  ///
  /// In en, this message translates to:
  /// **'Industrial vehicles and buses registered from 2014 onwards.'**
  String get cLabelIndustrial;

  /// No description provided for @yourCarDetails.
  ///
  /// In en, this message translates to:
  /// **'Your car details'**
  String get yourCarDetails;

  /// No description provided for @editDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit details'**
  String get editDetails;

  /// No description provided for @lastPlaceParked.
  ///
  /// In en, this message translates to:
  /// **'Where is my car?'**
  String get lastPlaceParked;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @navigateToCar.
  ///
  /// In en, this message translates to:
  /// **'Navigate to car'**
  String get navigateToCar;

  /// No description provided for @errorConfirmSpaceReservation.
  ///
  /// In en, this message translates to:
  /// **'Unable to confirm space reservation'**
  String get errorConfirmSpaceReservation;

  /// No description provided for @errorReserveSpace.
  ///
  /// In en, this message translates to:
  /// **'Unable to reserve space'**
  String get errorReserveSpace;

  /// No description provided for @errorSendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Unable to send feedback'**
  String get errorSendFeedback;

  /// No description provided for @errorTakeSpace.
  ///
  /// In en, this message translates to:
  /// **'Unable to take space'**
  String get errorTakeSpace;

  /// No description provided for @errorPublishRoadEvent.
  ///
  /// In en, this message translates to:
  /// **'Unable to publish road alert'**
  String get errorPublishRoadEvent;

  /// No description provided for @errorLoadActivities.
  ///
  /// In en, this message translates to:
  /// **'Unable to load activities'**
  String get errorLoadActivities;

  /// No description provided for @errorPublishSpace.
  ///
  /// In en, this message translates to:
  /// **'Unable to publish space'**
  String get errorPublishSpace;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPassword;

  /// No description provided for @getHelp.
  ///
  /// In en, this message translates to:
  /// **'Get Help'**
  String get getHelp;

  /// No description provided for @enterEmailToReset.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address below to proceed with'**
  String get enterEmailToReset;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @enterEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get enterEmailAddress;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @setNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Set a new password'**
  String get setNewPassword;

  /// No description provided for @createStrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Create a strong password for your account'**
  String get createStrongPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @repeatPassword.
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get repeatPassword;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// Title for the section about publishing a paid space
  ///
  /// In en, this message translates to:
  /// **'How do I publish a paid space?'**
  String get howToPublishPaidSpaceTitle;

  /// Description for publishing a paid space
  ///
  /// In en, this message translates to:
  /// **'To publish a paid space, you must meet the following requirements:'**
  String get howToPublishPaidSpaceDescription;

  /// First requirement for publishing a paid space
  ///
  /// In en, this message translates to:
  /// **'Enter your vehicle information in the app so it can be used at the time of reservation.'**
  String get publishPaidSpaceRequirement1;

  /// Second requirement for publishing a paid space
  ///
  /// In en, this message translates to:
  /// **'Create an earnings account from your profile. You will need to register your tax information, which is required to receive payments in the app due to European anti-money laundering regulations.'**
  String get publishPaidSpaceRequirement2;

  /// Notification message shown when a reservation is pending confirmation. Includes the expiration time {expiresAt}.
  ///
  /// In en, this message translates to:
  /// **'If you do not confirm the space by {expiresAt}, this reservation will be cancelled and the money will be refunded to the requester.'**
  String reservationPendingNote(String expiresAt);

  /// Title for the section about earning money from paid space
  ///
  /// In en, this message translates to:
  /// **'How do I earn money from my paid space?'**
  String get howToEarnMoneyTitle;

  /// Description of how to earn money from paid space
  ///
  /// In en, this message translates to:
  /// **'To earn money from your space, it must be reserved by another user. Once the space is reserved, you must confirm the reservation using the confirmation code provided to the user who made the booking. After you receive this code, proceed with confirming the reservation.'**
  String get howToEarnMoneyDescription;

  /// Description of how earnings are transferred
  ///
  /// In en, this message translates to:
  /// **'Once the reservation is confirmed, the amount of your reservation — minus LetDem\'s service fees — will be transferred to you.'**
  String get earningsTransferDescription;

  /// No description provided for @minutesLeft.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes left'**
  String minutesLeft(Object minutes);

  /// No description provided for @secondsLeft.
  ///
  /// In en, this message translates to:
  /// **'{seconds} seconds left'**
  String secondsLeft(Object seconds);

  /// Description of where to find earnings information
  ///
  /// In en, this message translates to:
  /// **'You can see the total amount earned in the Earnings section of your profile.'**
  String get earningsLocationDescription;

  /// Title for the section about withdrawing funds
  ///
  /// In en, this message translates to:
  /// **'How do I withdraw my funds to a personal account?'**
  String get howToWithdrawFundsTitle;

  /// Description of how to withdraw funds
  ///
  /// In en, this message translates to:
  /// **'To withdraw funds, they first need to be released by the payment provider. This usually takes around 10 days. Once the funds are released, they will be available in the app, and you\'ll be able to withdraw them using one of your linked bank accounts.'**
  String get howToWithdrawFundsDescription;

  /// Label for the earnings section
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earningsSection;

  /// Reference to LetDem service fees
  ///
  /// In en, this message translates to:
  /// **'LetDem\'s service fees'**
  String get letdemServiceFees;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// Reference to vehicle information
  ///
  /// In en, this message translates to:
  /// **'vehicle information'**
  String get vehicleInformation;

  /// Reference to earnings account
  ///
  /// In en, this message translates to:
  /// **'earnings account'**
  String get earningsAccount;

  /// Reference to tax information
  ///
  /// In en, this message translates to:
  /// **'tax information'**
  String get taxInformation;

  /// Reference to payment provider
  ///
  /// In en, this message translates to:
  /// **'payment provider'**
  String get paymentProvider;

  /// No description provided for @pleaseEnterYourNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your number'**
  String get pleaseEnterYourNumber;

  /// Reference to linked bank accounts
  ///
  /// In en, this message translates to:
  /// **'linked bank accounts'**
  String get linkedBankAccounts;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordRequirements.
  ///
  /// In en, this message translates to:
  /// **'Ensure to use at least 8 characters, with a number, an uppercase letter, and one of the following special characters: \$, ., &, @'**
  String get passwordRequirements;

  /// No description provided for @emailSentTitle.
  ///
  /// In en, this message translates to:
  /// **'We sent you an email'**
  String get emailSentTitle;

  /// No description provided for @emailSentDescription.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent an OTP to your email. Enter it below to reset your password.'**
  String get emailSentDescription;

  /// No description provided for @mailSentTo.
  ///
  /// In en, this message translates to:
  /// **'Mail is sent to: '**
  String get mailSentTo;

  /// No description provided for @reservations.
  ///
  /// In en, this message translates to:
  /// **'Reservations'**
  String get reservations;

  /// No description provided for @notYou.
  ///
  /// In en, this message translates to:
  /// **'Not you? '**
  String get notYou;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get changeEmail;

  /// No description provided for @didntGetOtp.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get OTP? '**
  String get didntGetOtp;

  /// No description provided for @tapToResend.
  ///
  /// In en, this message translates to:
  /// **'Tap to resend.'**
  String get tapToResend;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in 00:{seconds}'**
  String resendIn(String seconds);

  /// No description provided for @howToCreateScheduledNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'How to create scheduled notifications?'**
  String get howToCreateScheduledNotificationsTitle;

  /// No description provided for @howToEarnPointsTitle.
  ///
  /// In en, this message translates to:
  /// **'How to earn LetDem Points?'**
  String get howToEarnPointsTitle;

  /// No description provided for @publishAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Publish an Alert'**
  String get publishAlertTitle;

  /// No description provided for @publishAlertDescription.
  ///
  /// In en, this message translates to:
  /// **'If another user confirms the existence of the alert.'**
  String get publishAlertDescription;

  /// No description provided for @point.
  ///
  /// In en, this message translates to:
  /// **'point'**
  String get point;

  /// No description provided for @howToEarnPointsDescription.
  ///
  /// In en, this message translates to:
  /// **'Earn LetDem Points by contributing to the community through these actions:'**
  String get howToEarnPointsDescription;

  /// No description provided for @reservePaidSpaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Reserve a paid parking space'**
  String get reservePaidSpaceTitle;

  /// No description provided for @reservePaidSpaceDescription.
  ///
  /// In en, this message translates to:
  /// **'To the user who reserves and pays for a space published by another user. Once this reservation is confirmed.'**
  String get reservePaidSpaceDescription;

  /// No description provided for @publishFreeSpaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Publish a free parking space'**
  String get publishFreeSpaceTitle;

  /// No description provided for @publishFreeSpaceDescription.
  ///
  /// In en, this message translates to:
  /// **'If another user uses it and selects “I’ll take it” as feedback after arriving at the location.'**
  String get publishFreeSpaceDescription;

  /// No description provided for @additionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional notes'**
  String get additionalNotes;

  /// No description provided for @pointsNote1.
  ///
  /// In en, this message translates to:
  /// **'The user who gives up a paid parking space doesn’t earn points, but does earn money.'**
  String get pointsNote1;

  /// No description provided for @pointsNote2.
  ///
  /// In en, this message translates to:
  /// **'In all actions, points are granted only if the contribution is useful and confirmed by another user.'**
  String get pointsNote2;

  /// No description provided for @howToCreateScheduledNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'To schedule a parking notification, follow these steps:'**
  String get howToCreateScheduledNotificationsDescription;

  /// No description provided for @searchDestinationTitle.
  ///
  /// In en, this message translates to:
  /// **'Search destination'**
  String get searchDestinationTitle;

  /// No description provided for @searchDestinationDescription.
  ///
  /// In en, this message translates to:
  /// **'Search for your destination using the search bar on the main screen.'**
  String get searchDestinationDescription;

  /// No description provided for @selectAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Select address'**
  String get selectAddressTitle;

  /// No description provided for @selectAddressDescription.
  ///
  /// In en, this message translates to:
  /// **'Select the desired address and tap the \"Notify me about available space\" button.'**
  String get selectAddressDescription;

  /// No description provided for @configureAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Configure alert'**
  String get configureAlertTitle;

  /// No description provided for @configureAlertDescription.
  ///
  /// In en, this message translates to:
  /// **'Select the time range and distance from your location to receive notifications.'**
  String get configureAlertDescription;

  /// No description provided for @scheduledNotificationsManagement.
  ///
  /// In en, this message translates to:
  /// **'Manage your notifications from the \'Scheduled Notifications\' section.'**
  String get scheduledNotificationsManagement;

  /// No description provided for @scheduledNotificationsAlert.
  ///
  /// In en, this message translates to:
  /// **'You’ll receive a notification whenever a space becomes available in your configured area.'**
  String get scheduledNotificationsAlert;

  /// No description provided for @createNewAccount.
  ///
  /// In en, this message translates to:
  /// **'CREATE NEW ACCOUNT'**
  String get createNewAccount;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get personalInformation;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name to proceed'**
  String get enterFullName;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @enterFirstName.
  ///
  /// In en, this message translates to:
  /// **'Enter your first name'**
  String get enterFirstName;

  /// No description provided for @enterLastName.
  ///
  /// In en, this message translates to:
  /// **'Enter your last name'**
  String get enterLastName;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @loginHere.
  ///
  /// In en, this message translates to:
  /// **'Login here'**
  String get loginHere;

  /// No description provided for @signUpWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google'**
  String get signUpWithGoogle;

  /// No description provided for @singInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get singInWithGoogle;

  /// No description provided for @agreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'By continuing, I agree to LetDem '**
  String get agreeToTerms;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// No description provided for @pleaseAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'Please accept the terms and conditions'**
  String get pleaseAcceptTerms;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @continuee.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continuee;

  /// No description provided for @unableToResendVerification.
  ///
  /// In en, this message translates to:
  /// **'Unable to resend verification code'**
  String get unableToResendVerification;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @unableToProcessRequest.
  ///
  /// In en, this message translates to:
  /// **'We were unable to process your request. Please try again later. The error is: {error}'**
  String unableToProcessRequest(String error);

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'The session has expired. Please login again.'**
  String get sessionExpired;

  /// No description provided for @verifyAccount.
  ///
  /// In en, this message translates to:
  /// **'Verify account'**
  String get verifyAccount;

  /// No description provided for @weWillSendOTP.
  ///
  /// In en, this message translates to:
  /// **'We sent you an email'**
  String get weWillSendOTP;

  /// No description provided for @verificationInstructions.
  ///
  /// In en, this message translates to:
  /// **'Kindly check the email you provided for an OTP to verify your email and enter it below'**
  String get verificationInstructions;

  /// No description provided for @resending.
  ///
  /// In en, this message translates to:
  /// **'Resending'**
  String get resending;

  /// No description provided for @verificationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Verification success'**
  String get verificationSuccess;

  /// No description provided for @verificationSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account email has been verified successfully. You can proceed to the app.'**
  String get verificationSuccessMessage;

  /// No description provided for @findShareParking.
  ///
  /// In en, this message translates to:
  /// **'Find & Share parking spaces near you'**
  String get findShareParking;

  /// No description provided for @parkingDescription.
  ///
  /// In en, this message translates to:
  /// **'Get access to wide range of parking spaces within your location and beyond'**
  String get parkingDescription;

  /// No description provided for @geolocationPermission.
  ///
  /// In en, this message translates to:
  /// **'Geolocation permission'**
  String get geolocationPermission;

  /// No description provided for @enableGeolocationDescription.
  ///
  /// In en, this message translates to:
  /// **'Kindly enable geolocation to allow the app to track your location automatically. This process must be completed to use the app.'**
  String get enableGeolocationDescription;

  /// No description provided for @enableGeolocation.
  ///
  /// In en, this message translates to:
  /// **'Enable geolocation'**
  String get enableGeolocation;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @loginToAccount.
  ///
  /// In en, this message translates to:
  /// **'LOGIN TO YOUR ACCOUNT'**
  String get loginToAccount;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @signUpHere.
  ///
  /// In en, this message translates to:
  /// **'Sign Up here'**
  String get signUpHere;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @forgotPasswordQuestion.
  ///
  /// In en, this message translates to:
  /// **'Forgot password? '**
  String get forgotPasswordQuestion;

  /// No description provided for @resetHere.
  ///
  /// In en, this message translates to:
  /// **'Reset here'**
  String get resetHere;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @connectAccountProgress.
  ///
  /// In en, this message translates to:
  /// **'Connect account progress'**
  String get connectAccountProgress;

  /// No description provided for @identityVerification.
  ///
  /// In en, this message translates to:
  /// **'Identity verification'**
  String get identityVerification;

  /// No description provided for @bankInformation.
  ///
  /// In en, this message translates to:
  /// **'Bank information'**
  String get bankInformation;

  /// No description provided for @addressInformationTitle.
  ///
  /// In en, this message translates to:
  /// **'Your address information'**
  String get addressInformationTitle;

  /// No description provided for @addressInformationDescription.
  ///
  /// In en, this message translates to:
  /// **'Input your full address and location of residence'**
  String get addressInformationDescription;

  /// No description provided for @enterAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter your address'**
  String get enterAddress;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @enterPostalCode.
  ///
  /// In en, this message translates to:
  /// **'Enter postal code'**
  String get enterPostalCode;

  /// No description provided for @postalCode.
  ///
  /// In en, this message translates to:
  /// **'Postal code'**
  String get postalCode;

  /// No description provided for @enterCity.
  ///
  /// In en, this message translates to:
  /// **'Enter city'**
  String get enterCity;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @bankInformationTitle.
  ///
  /// In en, this message translates to:
  /// **'Bank information'**
  String get bankInformationTitle;

  /// No description provided for @bankInformationDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your IBAN to complete this step'**
  String get bankInformationDescription;

  /// No description provided for @enterIBAN.
  ///
  /// In en, this message translates to:
  /// **'Enter your IBAN'**
  String get enterIBAN;

  /// No description provided for @ibanExample.
  ///
  /// In en, this message translates to:
  /// **'ES00 0000 0000 0000 0000 0000'**
  String get ibanExample;

  /// No description provided for @iban.
  ///
  /// In en, this message translates to:
  /// **'IBAN'**
  String get iban;

  /// No description provided for @bankAccountNote.
  ///
  /// In en, this message translates to:
  /// **'Kindly note that this bank account is required to receive payout from our payment provider.'**
  String get bankAccountNote;

  /// No description provided for @detailsSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Details submitted'**
  String get detailsSubmitted;

  /// No description provided for @gotItThanks.
  ///
  /// In en, this message translates to:
  /// **'Got it, thanks'**
  String get gotItThanks;

  /// No description provided for @accountDetailsSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your account connection details submitted successfully, you will soon be able to receive money for paid spaces.'**
  String get accountDetailsSuccess;

  /// No description provided for @selectCountry.
  ///
  /// In en, this message translates to:
  /// **'Select country'**
  String get selectCountry;

  /// No description provided for @selectCountryDescription.
  ///
  /// In en, this message translates to:
  /// **'Select your country of residence to continue'**
  String get selectCountryDescription;

  /// No description provided for @spain.
  ///
  /// In en, this message translates to:
  /// **'Spain'**
  String get spain;

  /// No description provided for @selectCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Select country'**
  String get selectCountryLabel;

  /// No description provided for @uploadIDCard.
  ///
  /// In en, this message translates to:
  /// **'Upload ID Card'**
  String get uploadIDCard;

  /// No description provided for @uploadIDDescription.
  ///
  /// In en, this message translates to:
  /// **'Upload your ID card both sides'**
  String get uploadIDDescription;

  /// No description provided for @uploadIDFront.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload ID Card front'**
  String get uploadIDFront;

  /// No description provided for @uploadIDBack.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload ID Card back'**
  String get uploadIDBack;

  /// No description provided for @imageSizeLimit.
  ///
  /// In en, this message translates to:
  /// **'Only images supported Max: 2MB'**
  String get imageSizeLimit;

  /// No description provided for @frontSideFilename.
  ///
  /// In en, this message translates to:
  /// **'front-side.png'**
  String get frontSideFilename;

  /// No description provided for @backSideFilename.
  ///
  /// In en, this message translates to:
  /// **'back-side.png'**
  String get backSideFilename;

  /// No description provided for @uploadCompleted.
  ///
  /// In en, this message translates to:
  /// **'Upload completed'**
  String get uploadCompleted;

  /// No description provided for @selectUploadType.
  ///
  /// In en, this message translates to:
  /// **'Select upload type'**
  String get selectUploadType;

  /// No description provided for @openCamera.
  ///
  /// In en, this message translates to:
  /// **'Open camera'**
  String get openCamera;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @pleaseUploadBothSides.
  ///
  /// In en, this message translates to:
  /// **'Please upload both sides of your ID'**
  String get pleaseUploadBothSides;

  /// No description provided for @selectIdType.
  ///
  /// In en, this message translates to:
  /// **'Select ID type'**
  String get selectIdType;

  /// No description provided for @selectIdDescription.
  ///
  /// In en, this message translates to:
  /// **'Select your ID type and upload the front & Back of your Identity Card'**
  String get selectIdDescription;

  /// No description provided for @nationalIdCard.
  ///
  /// In en, this message translates to:
  /// **'National ID Card'**
  String get nationalIdCard;

  /// No description provided for @nationalIdDescription.
  ///
  /// In en, this message translates to:
  /// **'Your government issued national identity card'**
  String get nationalIdDescription;

  /// No description provided for @residentPermit.
  ///
  /// In en, this message translates to:
  /// **'Resident Permit'**
  String get residentPermit;

  /// No description provided for @residentPermitDescription.
  ///
  /// In en, this message translates to:
  /// **'Your government issued national resident permit'**
  String get residentPermitDescription;

  /// No description provided for @personalInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Your personal information'**
  String get personalInfoTitle;

  /// No description provided for @personalInfoDescription.
  ///
  /// In en, this message translates to:
  /// **'Input your personal details as it is on your ID Card'**
  String get personalInfoDescription;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhoneNumber;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dateOfBirth;

  /// No description provided for @dateFormat.
  ///
  /// In en, this message translates to:
  /// **'YYYY/MM/DD'**
  String get dateFormat;

  /// No description provided for @selectDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Please select your date of birth'**
  String get selectDateOfBirth;

  /// No description provided for @clickToOpenCamera.
  ///
  /// In en, this message translates to:
  /// **'Click to open camera'**
  String get clickToOpenCamera;

  /// No description provided for @publishPaidSpace.
  ///
  /// In en, this message translates to:
  /// **'Publish paid space'**
  String get publishPaidSpace;

  /// No description provided for @waitingTime.
  ///
  /// In en, this message translates to:
  /// **'Waiting time'**
  String get waitingTime;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @enterPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter price'**
  String get enterPrice;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// Tooltip showing allowed waiting time range
  ///
  /// In en, this message translates to:
  /// **'This is the maximum amount of time the publisher can wait before leaving. The time must be between {min} and {max} minutes. After this time passes, the published space will expire.'**
  String waitingTimeTooltip(int min, int max);

  /// Shown when a user tries to publish a new paid space but already has an active reservation.
  ///
  /// In en, this message translates to:
  /// **'There’s an active reservation on your account. It needs to be finished or cancelled before you can publish a new paid space.'**
  String get activeReservationExists;

  /// No description provided for @whatIsThisWaitingTime.
  ///
  /// In en, this message translates to:
  /// **'What\'s this?'**
  String get whatIsThisWaitingTime;

  /// No description provided for @fetchingLocation.
  ///
  /// In en, this message translates to:
  /// **'Fetching location...'**
  String get fetchingLocation;

  /// Info message explaining pending funds and withdrawal limits
  ///
  /// In en, this message translates to:
  /// **'You can withdraw between {minAmount} and {maxAmount}. Funds held by the payment provider will be available within a maximum of 10 days.'**
  String pendingFundsInfo(String minAmount, String maxAmount);

  /// No description provided for @minWithdrawalAmountError.
  ///
  /// In en, this message translates to:
  /// **'You must have at least {amount} to withdraw.'**
  String minWithdrawalAmountError(Object amount);

  /// No description provided for @maxWithdrawalAmountError.
  ///
  /// In en, this message translates to:
  /// **'You cannot withdraw more than {amount} at once.'**
  String maxWithdrawalAmountError(Object amount);

  /// No description provided for @minWithdrawalToast.
  ///
  /// In en, this message translates to:
  /// **'The minimum amount you can withdraw is {amount}.'**
  String minWithdrawalToast(Object amount);

  /// No description provided for @maxWithdrawalToast.
  ///
  /// In en, this message translates to:
  /// **'The maximum amount you can withdraw is {amount}.'**
  String maxWithdrawalToast(Object amount);

  /// No description provided for @exceedsBalanceToast.
  ///
  /// In en, this message translates to:
  /// **'You cannot withdraw more than your available balance.'**
  String get exceedsBalanceToast;

  /// Error message when the waiting time is outside the allowed range
  ///
  /// In en, this message translates to:
  /// **'The waiting time must be between {min} and {max} minutes.'**
  String timeToWaitMustBeBetween(String min, String max);

  /// Warning shown when user is too close to a location
  ///
  /// In en, this message translates to:
  /// **'You are very close to this location (less than {distance} meters). Please choose a spot a bit further away.'**
  String closeToLocationDescription(int distance);

  /// Error message shown when price is not within allowed range
  ///
  /// In en, this message translates to:
  /// **'The price must be between {min} and {max}.'**
  String priceMustBeBetween(String min, String max);

  /// No description provided for @pleaseEnterAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get pleaseEnterAllFields;

  /// No description provided for @spacePublishedSuccesfully.
  ///
  /// In en, this message translates to:
  /// **'Space published successfully'**
  String get spacePublishedSuccesfully;

  /// No description provided for @spacePublishedDescription.
  ///
  /// In en, this message translates to:
  /// **'Your space have been published successfully, people can now have access to use space.'**
  String get spacePublishedDescription;

  /// No description provided for @speedLimitAlert.
  ///
  /// In en, this message translates to:
  /// **'Speed limit alert'**
  String get speedLimitAlert;

  /// No description provided for @speedLimitWarning.
  ///
  /// In en, this message translates to:
  /// **'You are driving at speed limit, slow down'**
  String get speedLimitWarning;

  /// No description provided for @kmPerHour.
  ///
  /// In en, this message translates to:
  /// **'Km/h'**
  String get kmPerHour;

  /// No description provided for @speedLimit.
  ///
  /// In en, this message translates to:
  /// **'Speed limit'**
  String get speedLimit;

  /// No description provided for @codeConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get codeConfirmation;

  /// No description provided for @routeDeviationDetected.
  ///
  /// In en, this message translates to:
  /// **'Route deviation detected'**
  String get routeDeviationDetected;

  /// No description provided for @recalculatingRoute.
  ///
  /// In en, this message translates to:
  /// **'Recalculating route...'**
  String get recalculatingRoute;

  /// No description provided for @youHaveArrived.
  ///
  /// In en, this message translates to:
  /// **'You have arrived at your destination!'**
  String get youHaveArrived;

  /// No description provided for @navigatingToParking.
  ///
  /// In en, this message translates to:
  /// **'Navigating to parking space'**
  String get navigatingToParking;

  /// No description provided for @preparingNavigation.
  ///
  /// In en, this message translates to:
  /// **'Preparing your navigation...'**
  String get preparingNavigation;

  /// No description provided for @navigationError.
  ///
  /// In en, this message translates to:
  /// **'Could not calculate route. Please try again.'**
  String get navigationError;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @fatigueAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Fatigue alert'**
  String get fatigueAlertTitle;

  /// No description provided for @fatigueAlertMessage.
  ///
  /// In en, this message translates to:
  /// **'You have been driving for 3 hours. Please consider taking a break.'**
  String get fatigueAlertMessage;

  /// No description provided for @fatigueAlertVoice.
  ///
  /// In en, this message translates to:
  /// **'You have been driving for three hours. Please take a rest.'**
  String get fatigueAlertVoice;

  /// No description provided for @addEvent.
  ///
  /// In en, this message translates to:
  /// **'Add alert'**
  String get addEvent;

  /// No description provided for @ahead.
  ///
  /// In en, this message translates to:
  /// **'ahead'**
  String get ahead;

  /// No description provided for @navigateToSpaceButton.
  ///
  /// In en, this message translates to:
  /// **'Navigate to space'**
  String get navigateToSpaceButton;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionDeniedPermanently.
  ///
  /// In en, this message translates to:
  /// **'Location permissions permanently denied, please enable in settings'**
  String get locationPermissionDeniedPermanently;

  /// No description provided for @failedToLoadMap.
  ///
  /// In en, this message translates to:
  /// **'Failed to load map'**
  String get failedToLoadMap;

  /// No description provided for @failedToInitializeLocation.
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize location services'**
  String get failedToInitializeLocation;

  /// No description provided for @failedToInitNavigation.
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize navigation'**
  String get failedToInitNavigation;

  /// No description provided for @failedToStartNavigation.
  ///
  /// In en, this message translates to:
  /// **'Failed to start navigation visualization'**
  String get failedToStartNavigation;

  /// No description provided for @freeCameraMode.
  ///
  /// In en, this message translates to:
  /// **'Free camera'**
  String get freeCameraMode;

  /// No description provided for @lockPositionMode.
  ///
  /// In en, this message translates to:
  /// **'Lock to position'**
  String get lockPositionMode;

  /// No description provided for @cameraAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera alert'**
  String get cameraAlertTitle;

  /// No description provided for @radarAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Radar alert'**
  String get radarAlertTitle;

  /// No description provided for @cameraAlertMessage.
  ///
  /// In en, this message translates to:
  /// **'You are in a CCTV camera surveillance zone'**
  String get cameraAlertMessage;

  /// No description provided for @radarAlertMessage.
  ///
  /// In en, this message translates to:
  /// **'You are approaching a nearby radar zone'**
  String get radarAlertMessage;

  /// No description provided for @unnamedRoad.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Road'**
  String get unnamedRoad;

  /// No description provided for @couldNotRecalculateRoute.
  ///
  /// In en, this message translates to:
  /// **'Could not recalculate route'**
  String get couldNotRecalculateRoute;

  /// No description provided for @noPaymentsYet.
  ///
  /// In en, this message translates to:
  /// **'No payments yet'**
  String get noPaymentsYet;

  /// No description provided for @noPaymentsDescription.
  ///
  /// In en, this message translates to:
  /// **'Your payments history will appear here, once you make a payment'**
  String get noPaymentsDescription;

  /// No description provided for @tooCloseToLocation.
  ///
  /// In en, this message translates to:
  /// **'Too close to location'**
  String get tooCloseToLocation;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @trafficLevel.
  ///
  /// In en, this message translates to:
  /// **'Traffic'**
  String get trafficLevel;

  /// No description provided for @toArriveBy.
  ///
  /// In en, this message translates to:
  /// **'To arrive by {time}'**
  String toArriveBy(String time);

  /// No description provided for @notifyAvailableSpace.
  ///
  /// In en, this message translates to:
  /// **'Notify me of available space in this area'**
  String get notifyAvailableSpace;

  /// No description provided for @dateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateAndTime;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @refunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get refunded;

  /// No description provided for @notificationRadius.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications up to (meters)'**
  String get notificationRadius;

  /// No description provided for @startRoute.
  ///
  /// In en, this message translates to:
  /// **'Start route'**
  String get startRoute;

  /// No description provided for @radiusLessThan.
  ///
  /// In en, this message translates to:
  /// **'Radius cannot be less than {meters} meters'**
  String radiusLessThan(int meters);

  /// No description provided for @notificationScheduled.
  ///
  /// In en, this message translates to:
  /// **'Notification scheduled'**
  String get notificationScheduled;

  /// No description provided for @notificationScheduledDescription.
  ///
  /// In en, this message translates to:
  /// **'You will be notified when a space is available in this area'**
  String get notificationScheduledDescription;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'mins'**
  String get minutesShort;

  /// No description provided for @hoursShort.
  ///
  /// In en, this message translates to:
  /// **'hrs'**
  String get hoursShort;

  /// No description provided for @metersShort.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get metersShort;

  /// No description provided for @kilometersShort.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get kilometersShort;

  /// No description provided for @timesRequired.
  ///
  /// In en, this message translates to:
  /// **'Start and end times are required'**
  String get timesRequired;

  /// No description provided for @startBeforeEnd.
  ///
  /// In en, this message translates to:
  /// **'Start time should be before end time'**
  String get startBeforeEnd;

  /// No description provided for @timeGreaterThanCurrent.
  ///
  /// In en, this message translates to:
  /// **'Start and end times should be greater than the current time'**
  String get timeGreaterThanCurrent;

  /// No description provided for @maxScheduleDays.
  ///
  /// In en, this message translates to:
  /// **'You can only schedule up to 5 days'**
  String get maxScheduleDays;

  /// No description provided for @distanceTraveled.
  ///
  /// In en, this message translates to:
  /// **'Distance traveled: {distance} m'**
  String distanceTraveled(int distance);

  /// No description provided for @youHaveTraveled.
  ///
  /// In en, this message translates to:
  /// **'You have traveled {distance} meters'**
  String youHaveTraveled(int distance);

  /// No description provided for @estimatedArrival.
  ///
  /// In en, this message translates to:
  /// **'Estimated arrival in {time} with {distance} meters remaining'**
  String estimatedArrival(String time, int distance);

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'{count} seconds'**
  String seconds(int count);

  /// No description provided for @minutesAndSeconds.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min {seconds} sec'**
  String minutesAndSeconds(int minutes, int seconds);

  /// No description provided for @minutesOnly.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes'**
  String minutesOnly(int minutes);

  /// No description provided for @hoursAndMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours} hr {minutes} min'**
  String hoursAndMinutes(int hours, int minutes);

  /// No description provided for @hoursOnly.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours'**
  String hoursOnly(int hours);

  /// No description provided for @locationPermissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permissions permanently denied, please enable in settings'**
  String get locationPermissionPermanentlyDenied;

  /// No description provided for @failedToInitializeLocationServices.
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize location services'**
  String get failedToInitializeLocationServices;

  /// No description provided for @failedToGetCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Failed to get current location'**
  String get failedToGetCurrentLocation;

  /// No description provided for @failedToStartNavigationSimulation.
  ///
  /// In en, this message translates to:
  /// **'Failed to start navigation simulation'**
  String get failedToStartNavigationSimulation;

  /// No description provided for @failedToInitializeRouting.
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize routing'**
  String get failedToInitializeRouting;

  /// No description provided for @couldNotCalculateRoute.
  ///
  /// In en, this message translates to:
  /// **'Could not calculate route. Please try again.'**
  String get couldNotCalculateRoute;

  /// No description provided for @failedToInitializeNavigation.
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize navigation'**
  String get failedToInitializeNavigation;

  /// No description provided for @metersAhead.
  ///
  /// In en, this message translates to:
  /// **'{distance}m ahead'**
  String metersAhead(int distance);

  /// No description provided for @preparingYourNavigation.
  ///
  /// In en, this message translates to:
  /// **'Preparing your navigation...'**
  String get preparingYourNavigation;

  /// No description provided for @metersAway.
  ///
  /// In en, this message translates to:
  /// **'{distance} away'**
  String metersAway(String distance);

  /// No description provided for @gotItThankYou.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotItThankYou;

  /// No description provided for @feedbackButton.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackButton;

  /// No description provided for @feedbackSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Your feedback has been submitted'**
  String get feedbackSubmitted;

  /// No description provided for @thankYouForInput.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your input!'**
  String get thankYouForInput;

  /// No description provided for @eventFeedback.
  ///
  /// In en, this message translates to:
  /// **'Alert feedback'**
  String get eventFeedback;

  /// No description provided for @stillThere.
  ///
  /// In en, this message translates to:
  /// **'It\'s still there'**
  String get stillThere;

  /// No description provided for @notThere.
  ///
  /// In en, this message translates to:
  /// **'It\'s not there'**
  String get notThere;

  /// No description provided for @illTakeIt.
  ///
  /// In en, this message translates to:
  /// **'I\'ll take it'**
  String get illTakeIt;

  /// No description provided for @itsInUse.
  ///
  /// In en, this message translates to:
  /// **'It\'s in use'**
  String get itsInUse;

  /// No description provided for @notUseful.
  ///
  /// In en, this message translates to:
  /// **'Not useful'**
  String get notUseful;

  /// No description provided for @prohibited.
  ///
  /// In en, this message translates to:
  /// **'Prohibited'**
  String get prohibited;

  /// No description provided for @unableToLogin.
  ///
  /// In en, this message translates to:
  /// **'Unable to login'**
  String get unableToLogin;

  /// No description provided for @unableToRegister.
  ///
  /// In en, this message translates to:
  /// **'Unable to register'**
  String get unableToRegister;

  /// No description provided for @unableToVerifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Unable to verify email'**
  String get unableToVerifyEmail;

  /// No description provided for @unableToResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Unable to reset password'**
  String get unableToResetPassword;

  /// No description provided for @unableToValidateReset.
  ///
  /// In en, this message translates to:
  /// **'Unable to validate reset password'**
  String get unableToValidateReset;

  /// No description provided for @unableToFindAccount.
  ///
  /// In en, this message translates to:
  /// **'Unable to find Account'**
  String get unableToFindAccount;

  /// No description provided for @unableToResendCode.
  ///
  /// In en, this message translates to:
  /// **'Unable to resend verification code'**
  String get unableToResendCode;

  /// No description provided for @arrivedAtDestination.
  ///
  /// In en, this message translates to:
  /// **'You have arrived at your destination.'**
  String get arrivedAtDestination;

  /// No description provided for @rateThisParkingSpace.
  ///
  /// In en, this message translates to:
  /// **'How would you like to rate this parking space?'**
  String get rateThisParkingSpace;

  /// No description provided for @customNavigation.
  ///
  /// In en, this message translates to:
  /// **'Custom navigation'**
  String get customNavigation;

  /// No description provided for @startButton.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startButton;

  /// No description provided for @stopButton.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopButton;

  /// No description provided for @toggleButton.
  ///
  /// In en, this message translates to:
  /// **'Toggle'**
  String get toggleButton;

  /// No description provided for @colorButton.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorButton;

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @yourSpaceLocatedAt.
  ///
  /// In en, this message translates to:
  /// **'Your space located at '**
  String get yourSpaceLocatedAt;

  /// No description provided for @hasBeenOccupied.
  ///
  /// In en, this message translates to:
  /// **' has been occupied'**
  String get hasBeenOccupied;

  /// No description provided for @aNewSpaceHasBeenPublished.
  ///
  /// In en, this message translates to:
  /// **'A new space has been published within '**
  String get aNewSpaceHasBeenPublished;

  /// No description provided for @around.
  ///
  /// In en, this message translates to:
  /// **' around '**
  String get around;

  /// No description provided for @hasBeenReserved.
  ///
  /// In en, this message translates to:
  /// **' has been reserved'**
  String get hasBeenReserved;

  /// No description provided for @receivedPositiveFeedback.
  ///
  /// In en, this message translates to:
  /// **' Received positive feedback'**
  String get receivedPositiveFeedback;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @notificationsWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Your app notifications will appear here\nwhenever there is a new activity'**
  String get notificationsWillAppear;

  /// No description provided for @noScheduledNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No scheduled notifications yet'**
  String get noScheduledNotificationsYet;

  /// No description provided for @scheduledNotificationsWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Your app scheduled notifications will appear\nhere whenever you set this reminder'**
  String get scheduledNotificationsWillAppear;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @viewSpace.
  ///
  /// In en, this message translates to:
  /// **'View space'**
  String get viewSpace;

  /// No description provided for @noPaymentMethodsAdded.
  ///
  /// In en, this message translates to:
  /// **'No payment methods added'**
  String get noPaymentMethodsAdded;

  /// No description provided for @noPaymentMethodsDescription.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t added any payment methods yet.\nAdd one to make payments easily.'**
  String get noPaymentMethodsDescription;

  /// No description provided for @paymentMethodAdded.
  ///
  /// In en, this message translates to:
  /// **'Payment Method Added'**
  String get paymentMethodAdded;

  /// No description provided for @paymentMethodAddedDescription.
  ///
  /// In en, this message translates to:
  /// **'Your payment method has been successfully added.'**
  String get paymentMethodAddedDescription;

  /// No description provided for @pleaseCompleteCardDetails.
  ///
  /// In en, this message translates to:
  /// **'Please complete the card details'**
  String get pleaseCompleteCardDetails;

  /// No description provided for @failedToAddPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Failed to add payment method. Please try again.'**
  String get failedToAddPaymentMethod;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card number'**
  String get cardNumber;

  /// No description provided for @addNewCard.
  ///
  /// In en, this message translates to:
  /// **'Add new card'**
  String get addNewCard;

  /// No description provided for @defaultt.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultt;

  /// No description provided for @expireDate.
  ///
  /// In en, this message translates to:
  /// **'Expire date: {date}'**
  String expireDate(String date);

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethod;

  /// No description provided for @makeDefault.
  ///
  /// In en, this message translates to:
  /// **'Make default'**
  String get makeDefault;

  /// No description provided for @confirmDeleteCard.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete Card'**
  String get confirmDeleteCard;

  /// No description provided for @deleteCardConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete Card ending with {last4}? This action cannot be undone.'**
  String deleteCardConfirmation(String last4);

  /// No description provided for @noKeepCard.
  ///
  /// In en, this message translates to:
  /// **'No, keep card'**
  String get noKeepCard;

  /// No description provided for @yesDeleteCard.
  ///
  /// In en, this message translates to:
  /// **'Yes, delete card'**
  String get yesDeleteCard;

  /// No description provided for @noPayoutMethodsYet.
  ///
  /// In en, this message translates to:
  /// **'No payout methods yet'**
  String get noPayoutMethodsYet;

  /// No description provided for @payoutMethodsDescription.
  ///
  /// In en, this message translates to:
  /// **'Your added payout methods will appear\nhere once you set them up in your profile'**
  String get payoutMethodsDescription;

  /// No description provided for @payoutMethodAdded.
  ///
  /// In en, this message translates to:
  /// **'Payout method added'**
  String get payoutMethodAdded;

  /// No description provided for @payoutMethodAddedDescription.
  ///
  /// In en, this message translates to:
  /// **'Your payout method has been added successfully.'**
  String get payoutMethodAddedDescription;

  /// No description provided for @addPayoutMethod.
  ///
  /// In en, this message translates to:
  /// **'Add bank account'**
  String get addPayoutMethod;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account number'**
  String get accountNumber;

  /// No description provided for @accountNumberExample.
  ///
  /// In en, this message translates to:
  /// **'ES00 0000 0000 0000 0000 0000'**
  String get accountNumberExample;

  /// No description provided for @makeDefaultPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Make as default payment method'**
  String get makeDefaultPaymentMethod;

  /// No description provided for @pleaseEnterAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter account number'**
  String get pleaseEnterAccountNumber;

  /// No description provided for @payoutMethods.
  ///
  /// In en, this message translates to:
  /// **'Bank accounts'**
  String get payoutMethods;

  /// No description provided for @payoutMethodOptions.
  ///
  /// In en, this message translates to:
  /// **'Bank account options'**
  String get payoutMethodOptions;

  /// No description provided for @rescheduleNotification.
  ///
  /// In en, this message translates to:
  /// **'Reschedule notification'**
  String get rescheduleNotification;

  /// No description provided for @reschedule.
  ///
  /// In en, this message translates to:
  /// **'Reschedule'**
  String get reschedule;

  /// No description provided for @notificationRescheduledSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Notification rescheduled successfully'**
  String get notificationRescheduledSuccessfully;

  /// No description provided for @spaceReminder.
  ///
  /// In en, this message translates to:
  /// **'Space reminder'**
  String get spaceReminder;

  /// No description provided for @rescheduleReminder.
  ///
  /// In en, this message translates to:
  /// **'Reschedule reminder'**
  String get rescheduleReminder;

  /// No description provided for @deleteReminder.
  ///
  /// In en, this message translates to:
  /// **'Delete reminder'**
  String get deleteReminder;

  /// No description provided for @youHaveReminderForSpace.
  ///
  /// In en, this message translates to:
  /// **'You have a reminder for a space at '**
  String get youHaveReminderForSpace;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @activeMayus.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get activeMayus;

  /// No description provided for @antiMoneyLaunderingMessage.
  ///
  /// In en, this message translates to:
  /// **'The Anti-money Laundering Directive forces us to verify your identity in order to receive payment for your online sales. You will only need to verify yourself once.'**
  String get antiMoneyLaunderingMessage;

  /// No description provided for @couldNotOpenTermsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Could not open Terms & Conditions link'**
  String get couldNotOpenTermsAndConditions;

  /// No description provided for @byAgreementStripe.
  ///
  /// In en, this message translates to:
  /// **'By continuing, I agree to the '**
  String get byAgreementStripe;

  /// No description provided for @stripeConnectedAccountAgreement.
  ///
  /// In en, this message translates to:
  /// **'Stripe Connected Account Agreement'**
  String get stripeConnectedAccountAgreement;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// No description provided for @stripeTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Stripe Terms of Service'**
  String get stripeTermsOfService;

  /// No description provided for @accountInformationChanged.
  ///
  /// In en, this message translates to:
  /// **'Account information changed successfully'**
  String get accountInformationChanged;

  /// No description provided for @accountInformationChangedDescription.
  ///
  /// In en, this message translates to:
  /// **'Your account information has been changed successfully,'**
  String get accountInformationChangedDescription;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get orders;

  /// No description provided for @errorLoadingOrders.
  ///
  /// In en, this message translates to:
  /// **'Error loading bookings'**
  String get errorLoadingOrders;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(int days);

  /// No description provided for @oneWeekAgo.
  ///
  /// In en, this message translates to:
  /// **'1 week ago'**
  String get oneWeekAgo;

  /// No description provided for @twoWeeksAgo.
  ///
  /// In en, this message translates to:
  /// **'2 weeks ago'**
  String get twoWeeksAgo;

  /// No description provided for @threeWeeksAgo.
  ///
  /// In en, this message translates to:
  /// **'3 weeks ago'**
  String get threeWeeksAgo;

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No bookings yet'**
  String get noOrdersYet;

  /// No description provided for @noOrdersDescription.
  ///
  /// In en, this message translates to:
  /// **'You have not made any orders yet.\nStart exploring and make your first order!'**
  String get noOrdersDescription;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email notifications'**
  String get emailNotifications;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get pushNotifications;

  /// No description provided for @availableSpaces.
  ///
  /// In en, this message translates to:
  /// **'Available spaces'**
  String get availableSpaces;

  /// No description provided for @radarAlerts.
  ///
  /// In en, this message translates to:
  /// **'Radar alerts'**
  String get radarAlerts;

  /// No description provided for @cameraAlerts.
  ///
  /// In en, this message translates to:
  /// **'Camera alerts'**
  String get cameraAlerts;

  /// No description provided for @prohibitedZoneAlert.
  ///
  /// In en, this message translates to:
  /// **'Prohibited zone alert'**
  String get prohibitedZoneAlert;

  /// No description provided for @fatigueAlert.
  ///
  /// In en, this message translates to:
  /// **'Fatigue alert'**
  String get fatigueAlert;

  /// No description provided for @policeAlert.
  ///
  /// In en, this message translates to:
  /// **'Police alert'**
  String get policeAlert;

  /// No description provided for @accidentAlert.
  ///
  /// In en, this message translates to:
  /// **'Accident alert'**
  String get accidentAlert;

  /// No description provided for @roadClosedAlert.
  ///
  /// In en, this message translates to:
  /// **'Road closed alert'**
  String get roadClosedAlert;

  /// No description provided for @nameNotProvided.
  ///
  /// In en, this message translates to:
  /// **'Name not provided'**
  String get nameNotProvided;

  /// No description provided for @letdemPoints.
  ///
  /// In en, this message translates to:
  /// **'LetDem Points'**
  String get letdemPoints;

  /// No description provided for @walletBalance.
  ///
  /// In en, this message translates to:
  /// **'Wallet balance'**
  String get walletBalance;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// No description provided for @withdrawals.
  ///
  /// In en, this message translates to:
  /// **'Withdrawals'**
  String get withdrawals;

  /// No description provided for @payouts.
  ///
  /// In en, this message translates to:
  /// **'Banks'**
  String get payouts;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Last transactions'**
  String get transactionHistory;

  /// No description provided for @transactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactionTitle;

  /// No description provided for @fromDate.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromDate;

  /// No description provided for @toDate.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toDate;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @transactionsHistoryMessage.
  ///
  /// In en, this message translates to:
  /// **'Your transactions history will be listed here when you have any activity to show.'**
  String get transactionsHistoryMessage;

  /// No description provided for @loadingTransactions.
  ///
  /// In en, this message translates to:
  /// **'Loading transactions'**
  String get loadingTransactions;

  /// No description provided for @noPayoutMethodsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No payout methods available'**
  String get noPayoutMethodsAvailable;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @withdrawalRequestSuccess.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal request has been sent successfully.'**
  String get withdrawalRequestSuccess;

  /// No description provided for @withdrawalToBank.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal to bank {method}'**
  String withdrawalToBank(String method);

  /// No description provided for @successful.
  ///
  /// In en, this message translates to:
  /// **'Successful'**
  String get successful;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @noWithdrawalsYet.
  ///
  /// In en, this message translates to:
  /// **'No withdrawals yet'**
  String get noWithdrawalsYet;

  /// No description provided for @withdrawalHistoryMessage.
  ///
  /// In en, this message translates to:
  /// **'Your withdrawal history will appear here\nwhenever you make a withdrawal'**
  String get withdrawalHistoryMessage;

  /// No description provided for @amountCannotExceed.
  ///
  /// In en, this message translates to:
  /// **'Amount cannot exceed {balance} €'**
  String amountCannotExceed(String balance);

  /// No description provided for @amountToReceive.
  ///
  /// In en, this message translates to:
  /// **'Amount to receive'**
  String get amountToReceive;

  /// No description provided for @pendingToBeCleared.
  ///
  /// In en, this message translates to:
  /// **'{amount} € Awaiting clearance'**
  String pendingToBeCleared(String amount);

  /// No description provided for @paymentMethodAddedTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment method added'**
  String get paymentMethodAddedTitle;

  /// No description provided for @paymentMethodAddedSubtext.
  ///
  /// In en, this message translates to:
  /// **'Your payment method has been successfully added.'**
  String get paymentMethodAddedSubtext;

  /// No description provided for @addPaymentMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'Add payment method'**
  String get addPaymentMethodTitle;

  /// No description provided for @cardDetails.
  ///
  /// In en, this message translates to:
  /// **'Card details'**
  String get cardDetails;

  /// No description provided for @enterTheNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter the number'**
  String get enterTheNumber;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @pleaseEnterYourName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterYourName;

  /// No description provided for @paymentSuccessfulReservation.
  ///
  /// In en, this message translates to:
  /// **'Your payment was successful. The space is now reserved.'**
  String get paymentSuccessfulReservation;

  /// No description provided for @paymentFailedRequiresAction.
  ///
  /// In en, this message translates to:
  /// **'Payment failed or requires further action'**
  String get paymentFailedRequiresAction;

  /// No description provided for @connectionPending.
  ///
  /// In en, this message translates to:
  /// **'Connection pending'**
  String get connectionPending;

  /// No description provided for @connectionPendingMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account connection is still pending, you will be notified when the connection is complete'**
  String get connectionPendingMessage;

  /// No description provided for @somethingWentWrongGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrongGeneric;

  /// No description provided for @contactSupportMessage.
  ///
  /// In en, this message translates to:
  /// **'There seems to be an issue with your account. Please contact support for assistance.'**
  String get contactSupportMessage;

  /// No description provided for @insufficientBalance.
  ///
  /// In en, this message translates to:
  /// **'You do not have enough balance to withdraw'**
  String get insufficientBalance;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @confirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get confirmation;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @successGeneric.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get successGeneric;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Error occurred'**
  String get errorOccurred;

  /// No description provided for @pleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please try again'**
  String get pleaseTryAgain;

  /// No description provided for @reservationConfirmedTitle.
  ///
  /// In en, this message translates to:
  /// **'Reservation confirmed'**
  String get reservationConfirmedTitle;

  /// No description provided for @reservationConfirmedDescription.
  ///
  /// In en, this message translates to:
  /// **'Your reservation has been confirmed successfully, we will update your balance shortly.'**
  String get reservationConfirmedDescription;

  /// No description provided for @reservationCancelledOwnerTitle.
  ///
  /// In en, this message translates to:
  /// **'Reservation cancelled'**
  String get reservationCancelledOwnerTitle;

  /// No description provided for @reservationCancelledOwnerDescription.
  ///
  /// In en, this message translates to:
  /// **'Now we will proceed to refund the total amount of reservation to the requester.'**
  String get reservationCancelledOwnerDescription;

  /// No description provided for @reservationCancelledRequesterTitle.
  ///
  /// In en, this message translates to:
  /// **'Reservation cancelled'**
  String get reservationCancelledRequesterTitle;

  /// No description provided for @reservationCancelledRequesterDescription.
  ///
  /// In en, this message translates to:
  /// **'Now we will refund the total amount of reservation to your bank account.'**
  String get reservationCancelledRequesterDescription;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get networkError;

  /// No description provided for @published.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get published;

  /// No description provided for @activeStatus.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeStatus;

  /// No description provided for @minsAgo.
  ///
  /// In en, this message translates to:
  /// **'mins ago'**
  String get minsAgo;

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'hours ago'**
  String get hoursAgo;

  /// Tooltip explaining the price input, including min and max values for parking space
  ///
  /// In en, this message translates to:
  /// **'This is the price for a parking space. The maximum price you can set is {max}, and the minimum is {min}.'**
  String priceTooltip(String max, String min);

  /// No description provided for @myLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get myLocation;

  /// No description provided for @requester.
  ///
  /// In en, this message translates to:
  /// **'Requester'**
  String get requester;

  /// No description provided for @trackingLocation.
  ///
  /// In en, this message translates to:
  /// **'Tracking Location'**
  String get trackingLocation;

  /// No description provided for @waitingForLocation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for location...'**
  String get waitingForLocation;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get currentLocation;

  /// No description provided for @carPlate.
  ///
  /// In en, this message translates to:
  /// **'Car plate'**
  String get carPlate;

  /// No description provided for @tracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get tracking;

  /// No description provided for @zoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom In'**
  String get zoomIn;

  /// No description provided for @zoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom Out'**
  String get zoomOut;

  /// No description provided for @toggleView.
  ///
  /// In en, this message translates to:
  /// **'Toggle view'**
  String get toggleView;

  /// No description provided for @newNotification.
  ///
  /// In en, this message translates to:
  /// **'New notification'**
  String get newNotification;

  /// No description provided for @tapToView.
  ///
  /// In en, this message translates to:
  /// **'Tap to view'**
  String get tapToView;

  /// No description provided for @markAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get markAsRead;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials'**
  String get invalidCredentials;

  /// No description provided for @checkInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection'**
  String get checkInternetConnection;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @registrationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Registration successful'**
  String get registrationSuccessful;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created'**
  String get accountCreated;

  /// No description provided for @welcomeToLetdem.
  ///
  /// In en, this message translates to:
  /// **'Welcome to LetDem'**
  String get welcomeToLetdem;

  /// No description provided for @searchHere.
  ///
  /// In en, this message translates to:
  /// **'Search here...'**
  String get searchHere;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recentSearches;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get clearHistory;

  /// No description provided for @carRegisteredSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Car registered successfully'**
  String get carRegisteredSuccessfully;

  /// No description provided for @invalidPlateNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid plate number'**
  String get invalidPlateNumber;

  /// No description provided for @selectValidCarType.
  ///
  /// In en, this message translates to:
  /// **'Please select a valid car type'**
  String get selectValidCarType;

  /// No description provided for @accountSetupComplete.
  ///
  /// In en, this message translates to:
  /// **'Account setup complete'**
  String get accountSetupComplete;

  /// No description provided for @verificationPending.
  ///
  /// In en, this message translates to:
  /// **'Verification pending'**
  String get verificationPending;

  /// No description provided for @documentsUploadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Documents uploaded successfully'**
  String get documentsUploadedSuccessfully;

  /// No description provided for @defaultPayment.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultPayment;

  /// No description provided for @expires.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get expires;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmation;

  /// No description provided for @deleteCard.
  ///
  /// In en, this message translates to:
  /// **'Delete card'**
  String get deleteCard;

  /// No description provided for @setAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as default'**
  String get setAsDefault;

  /// No description provided for @bankAccount.
  ///
  /// In en, this message translates to:
  /// **'Bank account'**
  String get bankAccount;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @pendingVerification.
  ///
  /// In en, this message translates to:
  /// **'Pending verification'**
  String get pendingVerification;

  /// No description provided for @primary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get primary;

  /// No description provided for @gpsDisabled.
  ///
  /// In en, this message translates to:
  /// **'GPS is disabled'**
  String get gpsDisabled;

  /// No description provided for @unableToGetLocation.
  ///
  /// In en, this message translates to:
  /// **'Unable to get location'**
  String get unableToGetLocation;

  /// No description provided for @locationServicesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location services unavailable'**
  String get locationServicesUnavailable;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// No description provided for @connectionTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timeout'**
  String get connectionTimeout;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error'**
  String get serverError;

  /// No description provided for @requestFailed.
  ///
  /// In en, this message translates to:
  /// **'Request failed'**
  String get requestFailed;

  /// No description provided for @invalidEmailFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get invalidEmailFormat;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password too short'**
  String get passwordTooShort;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Field is required'**
  String get fieldRequired;

  /// No description provided for @invalidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get invalidPhoneNumber;

  /// No description provided for @todayDate.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayDate;

  /// No description provided for @yesterdayDate.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterdayDate;

  /// No description provided for @tomorrowDate.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrowDate;

  /// No description provided for @justNowTime.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNowTime;

  /// No description provided for @minuteAgo.
  ///
  /// In en, this message translates to:
  /// **'minute ago'**
  String get minuteAgo;

  /// No description provided for @minutesAgoTime.
  ///
  /// In en, this message translates to:
  /// **'minutes ago'**
  String get minutesAgoTime;

  /// No description provided for @hourAgo.
  ///
  /// In en, this message translates to:
  /// **'hour ago'**
  String get hourAgo;

  /// No description provided for @hoursAgoTime.
  ///
  /// In en, this message translates to:
  /// **'hours ago'**
  String get hoursAgoTime;

  /// No description provided for @dayAgo.
  ///
  /// In en, this message translates to:
  /// **'day ago'**
  String get dayAgo;

  /// No description provided for @daysAgoTime.
  ///
  /// In en, this message translates to:
  /// **'days ago'**
  String get daysAgoTime;

  /// No description provided for @weekAgo.
  ///
  /// In en, this message translates to:
  /// **'week ago'**
  String get weekAgo;

  /// No description provided for @weeksAgo.
  ///
  /// In en, this message translates to:
  /// **'weeks ago'**
  String get weeksAgo;

  /// No description provided for @monthAgo.
  ///
  /// In en, this message translates to:
  /// **'month ago'**
  String get monthAgo;

  /// No description provided for @monthsAgo.
  ///
  /// In en, this message translates to:
  /// **'months ago'**
  String get monthsAgo;

  /// No description provided for @paymentReceived.
  ///
  /// In en, this message translates to:
  /// **'Payment received'**
  String get paymentReceived;

  /// No description provided for @withdrawalProcessed.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal processed'**
  String get withdrawalProcessed;

  /// No description provided for @refundIssued.
  ///
  /// In en, this message translates to:
  /// **'Refund issued'**
  String get refundIssued;

  /// No description provided for @transactionFailed.
  ///
  /// In en, this message translates to:
  /// **'Transaction failed'**
  String get transactionFailed;

  /// No description provided for @securitySettings.
  ///
  /// In en, this message translates to:
  /// **'Security settings'**
  String get securitySettings;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get deleteAccountConfirmation;

  /// No description provided for @pleaseEnterYourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterYourPhoneNumber;

  /// No description provided for @monthJan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get monthJan;

  /// No description provided for @monthFeb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get monthFeb;

  /// No description provided for @monthMar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get monthMar;

  /// No description provided for @monthApr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get monthApr;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get monthJun;

  /// No description provided for @monthJul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get monthJul;

  /// No description provided for @monthAug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get monthAug;

  /// No description provided for @monthSep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get monthSep;

  /// No description provided for @monthOct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get monthOct;

  /// No description provided for @monthNov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get monthNov;

  /// No description provided for @monthDec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get monthDec;

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faqTitle;

  /// No description provided for @faqPublishPaidSpaceQuestion.
  ///
  /// In en, this message translates to:
  /// **'How do i publish a paid space?'**
  String get faqPublishPaidSpaceQuestion;

  /// No description provided for @faqPublishPaidSpaceAnswer.
  ///
  /// In en, this message translates to:
  /// **'To publish a paid space, you must meet the following requirements:\n\n• Enter your vehicle information in the app so it can be used at the time of reservation.\n• Create an earnings account from your profile. You will need to register your tax information, which is required to receive payments in the app due to European anti-money laundering regulations.'**
  String get faqPublishPaidSpaceAnswer;

  /// No description provided for @faqEarnMoneyQuestion.
  ///
  /// In en, this message translates to:
  /// **'How do i earn money from my paid space?'**
  String get faqEarnMoneyQuestion;

  /// No description provided for @faqEarnMoneyAnswer.
  ///
  /// In en, this message translates to:
  /// **'To earn money from your space, it must be reserved by another user. Once the space is reserved, you must confirm the reservation using the confirmation code provided to the user who made the booking. After you receive this code, proceed with confirming the reservation.\n\nOnce the reservation is confirmed, the amount of your reservation — minus LetDem\'s service fees — will be transferred to you.\n\nYou can see the total amount earned in the Earnings section of your profile.'**
  String get faqEarnMoneyAnswer;

  /// No description provided for @faqWithdrawFundsQuestion.
  ///
  /// In en, this message translates to:
  /// **'How do i withdraw my funds to a personal account?'**
  String get faqWithdrawFundsQuestion;

  /// No description provided for @faqWithdrawFundsAnswer.
  ///
  /// In en, this message translates to:
  /// **'To withdraw funds, they first need to be released by the payment provider. This usually takes around 10 days. Once the funds are released, they will be available in the app, and you\'ll be able to withdraw them using one of your linked bank accounts.'**
  String get faqWithdrawFundsAnswer;

  /// No description provided for @helpLetDemPointsTitle.
  ///
  /// In en, this message translates to:
  /// **'How to earn LetDem Points?'**
  String get helpLetDemPointsTitle;

  /// No description provided for @helpLetDemPointsReserveTitle.
  ///
  /// In en, this message translates to:
  /// **'Reserve a paid parking space'**
  String get helpLetDemPointsReserveTitle;

  /// No description provided for @helpLetDemPointsReserveDescription.
  ///
  /// In en, this message translates to:
  /// **'to the user who reserves and pays for a space published by another user. Once this reservation is confirmed.'**
  String get helpLetDemPointsReserveDescription;

  /// No description provided for @helpLetDemPointsPublishTitle.
  ///
  /// In en, this message translates to:
  /// **'Publish a free parking space'**
  String get helpLetDemPointsPublishTitle;

  /// No description provided for @helpLetDemPointsPublishDescription.
  ///
  /// In en, this message translates to:
  /// **'if another user uses it and selects \"I\'ll take it\" as feedback after arriving at the location.'**
  String get helpLetDemPointsPublishDescription;

  /// No description provided for @helpLetDemPointsAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Publish an alert (Police, Road Closed, Accident)'**
  String get helpLetDemPointsAlertTitle;

  /// No description provided for @helpLetDemPointsAlertDescription.
  ///
  /// In en, this message translates to:
  /// **'if another user confirms the existence of the alert.'**
  String get helpLetDemPointsAlertDescription;

  /// No description provided for @helpLetDemPointsAdditionalNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes'**
  String get helpLetDemPointsAdditionalNotesTitle;

  /// No description provided for @helpLetDemPointsAdditionalNote1.
  ///
  /// In en, this message translates to:
  /// **'• The user who gives up a paid parking space doesn\'t earn points, but does earn money.'**
  String get helpLetDemPointsAdditionalNote1;

  /// No description provided for @helpLetDemPointsAdditionalNote2.
  ///
  /// In en, this message translates to:
  /// **'• In all actions, points are granted only if the contribution is useful and confirmed by another user.'**
  String get helpLetDemPointsAdditionalNote2;

  /// No description provided for @helpScheduledNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'How to create scheduled space notifications?'**
  String get helpScheduledNotificationsTitle;

  /// No description provided for @helpScheduledNotificationsIntro.
  ///
  /// In en, this message translates to:
  /// **'To schedule a parking notification:'**
  String get helpScheduledNotificationsIntro;

  /// No description provided for @helpScheduledNotificationsStep1.
  ///
  /// In en, this message translates to:
  /// **'Search for your destination using the search bar on the main screen.'**
  String get helpScheduledNotificationsStep1;

  /// No description provided for @helpScheduledNotificationsStep2.
  ///
  /// In en, this message translates to:
  /// **'Select the desired address and tap the \"Notify me about available space\" button.'**
  String get helpScheduledNotificationsStep2;

  /// No description provided for @helpScheduledNotificationsStep3.
  ///
  /// In en, this message translates to:
  /// **'Configure the alert by selecting:'**
  String get helpScheduledNotificationsStep3;

  /// No description provided for @helpScheduledNotificationsStep3Detail1.
  ///
  /// In en, this message translates to:
  /// **'• The time range during which you want to receive notifications.'**
  String get helpScheduledNotificationsStep3Detail1;

  /// No description provided for @helpScheduledNotificationsStep3Detail2.
  ///
  /// In en, this message translates to:
  /// **'• The distance in meters from the selected location that should be considered as the notification area.'**
  String get helpScheduledNotificationsStep3Detail2;

  /// No description provided for @helpScheduledNotificationsInfo1.
  ///
  /// In en, this message translates to:
  /// **'Once the alert is created, you can manage it from your profile in the \"Scheduled Notifications\" section, where you\'ll see all your active or expired alerts.'**
  String get helpScheduledNotificationsInfo1;

  /// No description provided for @helpScheduledNotificationsInfo2.
  ///
  /// In en, this message translates to:
  /// **'Whenever a parking space is published within the configured area, you\'ll receive a notification so you can quickly head to the space.'**
  String get helpScheduledNotificationsInfo2;

  /// No description provided for @unhandledError.
  ///
  /// In en, this message translates to:
  /// **'Unhandled error'**
  String get unhandledError;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get paymentFailed;

  /// No description provided for @changePaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Change payment method'**
  String get changePaymentMethod;

  /// No description provided for @paymentFailedDescription.
  ///
  /// In en, this message translates to:
  /// **'The reservation failed because your payment didn\'t go through successfully'**
  String get paymentFailedDescription;

  /// No description provided for @errorReserveSpaceDescription.
  ///
  /// In en, this message translates to:
  /// **'Please try again later. If the issue persists, contact support.'**
  String get errorReserveSpaceDescription;

  /// Voice message for speed limit alert
  ///
  /// In en, this message translates to:
  /// **'Speed limit is {speedLimit} kilometers per hour'**
  String speedLimitVoiceAlert(String speedLimit);

  /// No description provided for @waitingForNavigation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for navigation to start...'**
  String get waitingForNavigation;

  /// No description provided for @locationNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Location data not available'**
  String get locationNotAvailable;

  /// No description provided for @stops.
  ///
  /// In en, this message translates to:
  /// **'Stops'**
  String get stops;

  /// No description provided for @onTheWay.
  ///
  /// In en, this message translates to:
  /// **'On the way...'**
  String get onTheWay;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @addAnotherStop.
  ///
  /// In en, this message translates to:
  /// **'Add another stop'**
  String get addAnotherStop;

  /// No description provided for @addStop.
  ///
  /// In en, this message translates to:
  /// **'Add stop'**
  String get addStop;

  /// No description provided for @searchStop.
  ///
  /// In en, this message translates to:
  /// **'Search stop...'**
  String get searchStop;

  /// No description provided for @customStop.
  ///
  /// In en, this message translates to:
  /// **'Custom stop'**
  String get customStop;

  /// No description provided for @stopAddedToRoute.
  ///
  /// In en, this message translates to:
  /// **'Stop added to route'**
  String get stopAddedToRoute;

  /// No description provided for @changeRoute.
  ///
  /// In en, this message translates to:
  /// **'Change route'**
  String get changeRoute;

  /// Toast message when arriving at a stop
  ///
  /// In en, this message translates to:
  /// **'You arrived at stop: {stopName}'**
  String arrivedAtStop(String stopName);

  /// No description provided for @purchaseHistory.
  ///
  /// In en, this message translates to:
  /// **'Purchase history'**
  String get purchaseHistory;

  /// No description provided for @pendingCards.
  ///
  /// In en, this message translates to:
  /// **'Pending cards'**
  String get pendingCards;

  /// No description provided for @generateCard.
  ///
  /// In en, this message translates to:
  /// **'Generate card'**
  String get generateCard;

  /// No description provided for @transactionsHistory.
  ///
  /// In en, this message translates to:
  /// **'Transactions history'**
  String get transactionsHistory;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// No description provided for @finalDestination.
  ///
  /// In en, this message translates to:
  /// **'final destination'**
  String get finalDestination;

  /// No description provided for @arrivedAtYourStop.
  ///
  /// In en, this message translates to:
  /// **'You\'ve arrived at your stop!'**
  String get arrivedAtYourStop;

  /// No description provided for @continueToNextStop.
  ///
  /// In en, this message translates to:
  /// **'Continue to next stop'**
  String get continueToNextStop;

  /// No description provided for @goToFinalDestination.
  ///
  /// In en, this message translates to:
  /// **'Go to final destination'**
  String get goToFinalDestination;

  /// No description provided for @findParking.
  ///
  /// In en, this message translates to:
  /// **'Find parking'**
  String get findParking;

  /// Message shown when arriving at a stop
  ///
  /// In en, this message translates to:
  /// **'You can search for available parking on the map or continue to {destination}'**
  String canSearchParkingOrContinueTo(String destination);

  /// No description provided for @noMoreRouteOptions.
  ///
  /// In en, this message translates to:
  /// **'No more route options were found.'**
  String get noMoreRouteOptions;

  /// No description provided for @alternativeRoutes.
  ///
  /// In en, this message translates to:
  /// **'Alternative routes'**
  String get alternativeRoutes;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
