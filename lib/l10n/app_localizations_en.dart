// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get enterDestination => 'Enter destination';

  @override
  String get whatDoYouWantToDo => 'What do you want to do?';

  @override
  String get publishSpace => 'Publish space';

  @override
  String get publishEvent => 'Publish alert';

  @override
  String get home => 'Home';

  @override
  String get activities => 'Activities';

  @override
  String get profile => 'Profile';

  @override
  String get contributions => 'Contributions';

  @override
  String get scheduledNotifications => 'Scheduled notifications';

  @override
  String get paymentMethods => 'Payment methods';

  @override
  String get earnings => 'Earnings';

  @override
  String get connectAccount => 'Connect account';

  @override
  String get cancelReservationConfirmationTitle => 'Cancel reservation?';

  @override
  String get cancelReservationConfirmationText =>
      'Are you sure you want to cancel this reservation? This action can’t be undone.';

  @override
  String get basicInformation => 'Basic information';

  @override
  String get preferences => 'Preferences';

  @override
  String get security => 'Security';

  @override
  String get help => 'Help';

  @override
  String get aboutUs => 'About us';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get termsOfUse => 'Terms of use';

  @override
  String get logout => 'Logout';

  @override
  String get language => 'Language';

  @override
  String get save => 'Save';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Spanish';

  @override
  String get cardholderName => 'Cardholder Name';

  @override
  String get enterYourName => 'Enter your name';

  @override
  String get cancel => 'Cancel';

  @override
  String get notificationPaidSpaceReserved => 'Paid space reserved';

  @override
  String get notificationNewSpacePublished => 'New space published';

  @override
  String get notificationSpaceOccupied => 'Space occupied';

  @override
  String get notificationDisabled => 'Disabled';

  @override
  String get notificationFree => 'Free';

  @override
  String get notificationBlue => 'Blue';

  @override
  String get notificationGreen => 'Green';

  @override
  String get done => 'Done';

  @override
  String noPendingFundsMessage(Object min, Object max) {
    return 'You have no pending funds to be released. You can withdraw between $min and $max.';
  }

  @override
  String get selectDuration => 'Select duration';

  @override
  String get minutes => 'MIN';

  @override
  String get sec => 'SEC';

  @override
  String get proceed => 'Proceed';

  @override
  String get pleaseEnter => 'Please enter';

  @override
  String get passwordMinLength => 'Password must be at least 8 characters';

  @override
  String get passwordRequireNumber =>
      'Password must contain at least one number';

  @override
  String get passwordRequireSpecial =>
      'Password must contain at least one special character';

  @override
  String get passwordRequireUppercase =>
      'Password must contain at least one uppercase letter';

  @override
  String get pleaseEnterValidEmail => 'Please enter valid email';

  @override
  String get validCard => 'Valid card';

  @override
  String get enterCardDetails => 'Enter card details';

  @override
  String get passwordStrength => 'Password Strength';

  @override
  String get passwordWeak => 'Weak';

  @override
  String get passwordFair => 'Fair';

  @override
  String get passwordGood => 'Good';

  @override
  String get passwordStrong => 'Strong';

  @override
  String get missingInfo => 'Missing info';

  @override
  String get reservationExpired => 'Reservation expired';

  @override
  String get lessThanAMinuteLeft => 'Less than a minute left';

  @override
  String minutesLeftToReserve(Object minutes) {
    return '$minutes mins left to reserve space';
  }

  @override
  String get meters => 'meters';

  @override
  String get trafficLow => 'Low';

  @override
  String get trafficModerate => 'Moderate';

  @override
  String get trafficHeavy => 'Heavy';

  @override
  String get homeLocationShort => 'Home';

  @override
  String get transactionSpacePayment => 'Payment received for space';

  @override
  String get transactionWithdraw => 'Withdrawal';

  @override
  String get transactionSpaceTransfer => 'Space transfer';

  @override
  String get transactionSpaceWithdrawal => 'Space withdrawal';

  @override
  String get transactionSpaceDeposit => 'Space deposit';

  @override
  String get pending => 'Pending';

  @override
  String get rejected => 'Rejected';

  @override
  String get blocked => 'Blocked';

  @override
  String get work => 'Work';

  @override
  String get accepted => 'Accepted';

  @override
  String get personalInfo => 'Personal info';

  @override
  String get addressInfo => 'Address info';

  @override
  String get documentUpload => 'Document upload';

  @override
  String get bankAccountInfo => 'Bank account info';

  @override
  String get submitted => 'Submitted';

  @override
  String get policeAhead => 'Police ahead';

  @override
  String get roadClosedAhead => 'Road closed ahead';

  @override
  String get accidentAhead => 'Accident ahead';

  @override
  String get unknownEventAhead => 'Unknown alert ahead';

  @override
  String get police => 'Police';

  @override
  String get closedRoad => 'Closed Road';

  @override
  String get accident => 'Accident';

  @override
  String get freeSpace => 'Free';

  @override
  String get blueZone => 'Blue Zone';

  @override
  String get disabledSpace => 'Disabled';

  @override
  String get greenZone => 'Green Zone';

  @override
  String get paidFreeSpace => 'Paid free';

  @override
  String get paidBlueZone => 'Paid blue zone';

  @override
  String get paidDisabledSpace => 'Paid disabled';

  @override
  String get paidGreenZone => 'Paid green zone';

  @override
  String get selectEventType => 'Select Alert type';

  @override
  String get publishButtonText => 'Publish';

  @override
  String get eventPublishedTitle => 'Alert published\nsuccessfully';

  @override
  String get eventPublishedSubtext =>
      'Your alert have been published successfully, people can now see this alert on map.';

  @override
  String get away => 'away';

  @override
  String get addPaymentMethod => 'Add payment method';

  @override
  String cardEndingWith(String brand, String last4) {
    return '$brand ending with $last4';
  }

  @override
  String get paymentSuccessful => 'Payment successful';

  @override
  String get spaceReservedSuccess =>
      'You have successfully reserved a paid space. You can get the details by clicking below.';

  @override
  String get arrivalTitle => 'You’ve arrived!';

  @override
  String get arrivalSubtitle =>
      'Nearby parking spots are now visible on the map. Tap a spot to start navigation.';

  @override
  String get getSpaceDetails => 'Get details of space';

  @override
  String get reserveSpace => 'Reserve space';

  @override
  String get navigateToSpace => 'Navigate to space';

  @override
  String get regularSpace => 'Regular space';

  @override
  String get paidSpace => 'Paid space';

  @override
  String get importantNotice => 'Important notice';

  @override
  String get createCarProfileFirst =>
      'You need to create a car profile to publish a paid space. Please create a car profile first.';

  @override
  String get createEarningAccountFirst =>
      'You need to create an earning account to publish a paid space. Please create an earning account first.';

  @override
  String get continueText => 'Continue';

  @override
  String get locationPermissionRequired => 'Location permission\nrequired';

  @override
  String get locationPermissionDescription =>
      'We need to get access to your location services to perform any action in the app';

  @override
  String get openSystemSettings => 'Open system settings';

  @override
  String get spaceDetails => 'Space details';

  @override
  String get confirmOrder => 'Confirm';

  @override
  String get spaceReserved => 'Space reserved';

  @override
  String get spaceReservedSuccessfully =>
      'Your space has been reserved successfully.';

  @override
  String get confirmationCode => 'Confirmation code';

  @override
  String get enterConfirmationCode =>
      'The requester of the space will give you a 6-digit confirmation number, enter it here.';

  @override
  String get confirmationCodeWarning =>
      'Kindly ensure that the confirmation code works before you give out the space';

  @override
  String get pleaseEnterConfirmationCode =>
      'Please enter the confirmation code';

  @override
  String get reserved => 'Reserved';

  @override
  String get waiting => 'Waiting';

  @override
  String get deleteSpaceTitle => 'Delete space';

  @override
  String get deleteSpaceSubtext =>
      'Are you sure you want to delete this space? This action cannot be undone.';

  @override
  String get spaceDeleted => 'Space deleted';

  @override
  String get spaceDeletedSubtext => 'The space has been successfully deleted.';

  @override
  String get reservedSpace => 'Reserved space';

  @override
  String get confirmationCodeTitle => 'Confirmation code';

  @override
  String get shareCodeOwner => 'Share this code with the parking space owner';

  @override
  String get ownerPlateNumber => 'The owner\'s plate number: ';

  @override
  String get callSpaceOwner => 'Call space owner';

  @override
  String get couldNotLaunchDialer => 'Could not launch dialer';

  @override
  String get viewDetails => 'View details';

  @override
  String get free => 'Free';

  @override
  String get timeRemaining => 'Time remaining';

  @override
  String get currency => '€';

  @override
  String get showAll => 'Show all';

  @override
  String get noContributions => 'No contributions yet';

  @override
  String get noContributionsDescription =>
      'Your contributions history will appear here, publish to see them';

  @override
  String get all => 'All';

  @override
  String get parkingSpace => 'Parking space';

  @override
  String get events => 'Alerts';

  @override
  String get verifyYourAccountFirst =>
      'Your earnings account is not verified yet. Please verify your account by submitting your ID card and bank information.';

  @override
  String failedToLoadActivities(String error) {
    return 'Failed to load activities: $error';
  }

  @override
  String get selectFilterActivities => 'Select a filter to view activities';

  @override
  String get searchLocation => 'Search location';

  @override
  String get back => 'Back';

  @override
  String updatingLocation(String type) {
    return 'UPDATING $type LOCATION';
  }

  @override
  String get spaceOwnerCannotReserve =>
      'Space owner cannot reserve their own space';

  @override
  String get location => 'Location';

  @override
  String get spaceDetailsTitle => 'Space details';

  @override
  String locationType(Object type) {
    return '$type LOCATION';
  }

  @override
  String setLocation(String type) {
    return 'Set $type';
  }

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get spaceOccupied => 'Space occupied';

  @override
  String get otherLocation => 'Other location';

  @override
  String get homeLocation => 'Home location';

  @override
  String get workLocation => 'Work location';

  @override
  String get whereAreYouGoing => 'Where are you going to?';

  @override
  String get favourites => 'Favourites';

  @override
  String get recent => 'Recent';

  @override
  String get clearAll => 'Clear all';

  @override
  String get spacePublished => 'Space published';

  @override
  String get eventPublished => 'Alert published';

  @override
  String pointsEarned(String points) {
    return '+$points Pts';
  }

  @override
  String get noCarRegistered => 'No car registered';

  @override
  String get registerCarDetails =>
      'Register your car with the car details\nfor safety and accessibility';

  @override
  String get tapToRegisterCar => 'Tap to register car';

  @override
  String get registerCar => 'Register car';

  @override
  String get updateCarDetails => 'Update car details';

  @override
  String get update => 'Update';

  @override
  String get register => 'Register';

  @override
  String get enterCarBrand => 'Enter car brand';

  @override
  String get enterPlateNumber => 'Enter plate number';

  @override
  String get brand => 'Brand';

  @override
  String get plateNumber => 'Plate number';

  @override
  String get selectTag => 'Select tag';

  @override
  String get whatIsThis => 'What\'s this?';

  @override
  String get whatTagMeans => 'What tag means';

  @override
  String get gotIt => 'Got it';

  @override
  String get ecoLabel => 'Eco Label';

  @override
  String get zeroEmissionLabel => 'Zero Emission Label';

  @override
  String get bLabelYellow => 'B Label Yellow';

  @override
  String get cLabelGreen => 'C Label Green';

  @override
  String get noLabel => 'No Label';

  @override
  String get ecoLabelPluginHybrids =>
      'Plug-in hybrids with an electric range of less than 40 km.';

  @override
  String get ecoLabelNonPluginHybrids => 'Non-plug-in hybrids (HEV).';

  @override
  String get ecoLabelGasPowered => 'Gas-powered vehicles (LPG, CNG, or LNG).';

  @override
  String get zeroLabelElectric => '100% electric vehicles (BEV).';

  @override
  String get zeroLabelPluginHybrids =>
      'Plug-in hybrids (PHEV) with an electric range of more than 40 km.';

  @override
  String get zeroLabelHydrogen => 'Hydrogen-powered vehicles.';

  @override
  String get bLabelPetrol =>
      'Petrol cars and vans registered from January 2001 onwards.';

  @override
  String get bLabelDiesel =>
      'Diesel cars and vans registered from January 2006 onwards.';

  @override
  String get bLabelIndustrial =>
      'Industrial vehicles and buses registered from 2005 onwards.';

  @override
  String get cLabelPetrol =>
      'Petrol cars and vans registered from January 2006 onwards.';

  @override
  String get cLabelDiesel =>
      'Diesel cars and vans registered from September 2015 onwards.';

  @override
  String get cLabelIndustrial =>
      'Industrial vehicles and buses registered from 2014 onwards.';

  @override
  String get yourCarDetails => 'Your car details';

  @override
  String get editDetails => 'Edit details';

  @override
  String get lastPlaceParked => 'Where is my car?';

  @override
  String get unknown => 'Unknown';

  @override
  String get navigateToCar => 'Navigate to car';

  @override
  String get errorConfirmSpaceReservation =>
      'Unable to confirm space reservation';

  @override
  String get errorReserveSpace => 'Unable to reserve space';

  @override
  String get errorSendFeedback => 'Unable to send feedback';

  @override
  String get errorTakeSpace => 'Unable to take space';

  @override
  String get errorPublishRoadEvent => 'Unable to publish road alert';

  @override
  String get errorLoadActivities => 'Unable to load activities';

  @override
  String get errorPublishSpace => 'Unable to publish space';

  @override
  String get forgotPassword => 'Forgot password';

  @override
  String get getHelp => 'Get Help';

  @override
  String get enterEmailToReset =>
      'Enter your email address below to proceed with';

  @override
  String get emailAddress => 'Email address';

  @override
  String get enterEmailAddress => 'Enter your email address';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get setNewPassword => 'Set a new password';

  @override
  String get createStrongPassword =>
      'Create a strong password for your account';

  @override
  String get newPassword => 'New password';

  @override
  String get repeatPassword => 'Repeat password';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get howToPublishPaidSpaceTitle => 'How do I publish a paid space?';

  @override
  String get howToPublishPaidSpaceDescription =>
      'To publish a paid space, you must meet the following requirements:';

  @override
  String get publishPaidSpaceRequirement1 =>
      'Enter your vehicle information in the app so it can be used at the time of reservation.';

  @override
  String get publishPaidSpaceRequirement2 =>
      'Create an earnings account from your profile. You will need to register your tax information, which is required to receive payments in the app due to European anti-money laundering regulations.';

  @override
  String reservationPendingNote(String expiresAt) {
    return 'If you do not confirm the space by $expiresAt, this reservation will be cancelled and the money will be refunded to the requester.';
  }

  @override
  String get howToEarnMoneyTitle => 'How do I earn money from my paid space?';

  @override
  String get howToEarnMoneyDescription =>
      'To earn money from your space, it must be reserved by another user. Once the space is reserved, you must confirm the reservation using the confirmation code provided to the user who made the booking. After you receive this code, proceed with confirming the reservation.';

  @override
  String get earningsTransferDescription =>
      'Once the reservation is confirmed, the amount of your reservation — minus LetDem\'s service fees — will be transferred to you.';

  @override
  String minutesLeft(Object minutes) {
    return '$minutes minutes left';
  }

  @override
  String secondsLeft(Object seconds) {
    return '$seconds seconds left';
  }

  @override
  String get earningsLocationDescription =>
      'You can see the total amount earned in the Earnings section of your profile.';

  @override
  String get howToWithdrawFundsTitle =>
      'How do I withdraw my funds to a personal account?';

  @override
  String get howToWithdrawFundsDescription =>
      'To withdraw funds, they first need to be released by the payment provider. This usually takes around 10 days. Once the funds are released, they will be available in the app, and you\'ll be able to withdraw them using one of your linked bank accounts.';

  @override
  String get earningsSection => 'Earnings';

  @override
  String get letdemServiceFees => 'LetDem\'s service fees';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get vehicleInformation => 'Vehicle information';

  @override
  String get alias => 'Alias';

  @override
  String get enterAlias => 'Enter an alias for transfers';

  @override
  String get brandModel => 'Brand and model';

  @override
  String get licensePlate => 'License plate';

  @override
  String get noVehicleRegistered => 'No vehicle registered';

  @override
  String get earningsAccount => 'earnings account';

  @override
  String get taxInformation => 'tax information';

  @override
  String get paymentProvider => 'payment provider';

  @override
  String get pleaseEnterYourNumber => 'Please enter your number';

  @override
  String get linkedBankAccounts => 'linked bank accounts';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordRequirements =>
      'Ensure to use at least 8 characters, with a number, an uppercase letter, and one of the following special characters: \$, ., &, @';

  @override
  String get emailSentTitle => 'We sent you an email';

  @override
  String get emailSentDescription =>
      'We\'ve sent an OTP to your email. Enter it below to reset your password.';

  @override
  String get mailSentTo => 'Mail is sent to: ';

  @override
  String get reservations => 'Reservations';

  @override
  String get notYou => 'Not you? ';

  @override
  String get changeEmail => 'Change email';

  @override
  String get didntGetOtp => 'Didn\'t get OTP? ';

  @override
  String get tapToResend => 'Tap to resend.';

  @override
  String resendIn(String seconds) {
    return 'Resend in 00:$seconds';
  }

  @override
  String get howToCreateScheduledNotificationsTitle =>
      'How to create scheduled notifications?';

  @override
  String get howToEarnPointsTitle => 'How to earn LetDem Points?';

  @override
  String get publishAlertTitle => 'Publish an Alert';

  @override
  String get publishAlertDescription =>
      'If another user confirms the existence of the alert.';

  @override
  String get point => 'point';

  @override
  String get howToEarnPointsDescription =>
      'Earn LetDem Points by contributing to the community through these actions:';

  @override
  String get reservePaidSpaceTitle => 'Reserve a paid parking space';

  @override
  String get reservePaidSpaceDescription =>
      'To the user who reserves and pays for a space published by another user. Once this reservation is confirmed.';

  @override
  String get publishFreeSpaceTitle => 'Publish a free parking space';

  @override
  String get publishFreeSpaceDescription =>
      'If another user uses it and selects “I’ll take it” as feedback after arriving at the location.';

  @override
  String get additionalNotes => 'Additional notes';

  @override
  String get pointsNote1 =>
      'The user who gives up a paid parking space doesn’t earn points, but does earn money.';

  @override
  String get pointsNote2 =>
      'In all actions, points are granted only if the contribution is useful and confirmed by another user.';

  @override
  String get howToCreateScheduledNotificationsDescription =>
      'To schedule a parking notification, follow these steps:';

  @override
  String get searchDestinationTitle => 'Search destination';

  @override
  String get searchDestinationDescription =>
      'Search for your destination using the search bar on the main screen.';

  @override
  String get selectAddressTitle => 'Select address';

  @override
  String get selectAddressDescription =>
      'Select the desired address and tap the \"Notify me about available space\" button.';

  @override
  String get configureAlertTitle => 'Configure alert';

  @override
  String get configureAlertDescription =>
      'Select the time range and distance from your location to receive notifications.';

  @override
  String get scheduledNotificationsManagement =>
      'Manage your notifications from the \'Scheduled Notifications\' section.';

  @override
  String get scheduledNotificationsAlert =>
      'You’ll receive a notification whenever a space becomes available in your configured area.';

  @override
  String get createNewAccount => 'CREATE NEW ACCOUNT';

  @override
  String get personalInformation => 'Personal information';

  @override
  String get enterFullName => 'Enter your full name to proceed';

  @override
  String get firstName => 'First name';

  @override
  String get lastName => 'Last name';

  @override
  String get enterFirstName => 'Enter your first name';

  @override
  String get enterLastName => 'Enter your last name';

  @override
  String get getStarted => 'Get Started';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get loginHere => 'Login here';

  @override
  String get signUpWithGoogle => 'Sign up with Google';

  @override
  String get singInWithGoogle => 'Sign in with Google';

  @override
  String get agreeToTerms => 'By continuing, I agree to LetDem ';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get pleaseAcceptTerms => 'Please accept the terms and conditions';

  @override
  String get password => 'Password';

  @override
  String get continuee => 'Continue';

  @override
  String get unableToResendVerification => 'Unable to resend verification code';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String unableToProcessRequest(String error) {
    return 'We were unable to process your request. Please try again later. The error is: $error';
  }

  @override
  String get retry => 'Retry';

  @override
  String get sessionExpired => 'The session has expired. Please login again.';

  @override
  String get verifyAccount => 'Verify account';

  @override
  String get weWillSendOTP => 'We sent you an email';

  @override
  String get verificationInstructions =>
      'Kindly check the email you provided for an OTP to verify your email and enter it below';

  @override
  String get resending => 'Resending';

  @override
  String get verificationSuccess => 'Verification success';

  @override
  String get verificationSuccessMessage =>
      'Your account email has been verified successfully. You can proceed to the app.';

  @override
  String get findShareParking => 'Find & Share parking spaces near you';

  @override
  String get parkingDescription =>
      'Get access to wide range of parking spaces within your location and beyond';

  @override
  String get geolocationPermission => 'Geolocation permission';

  @override
  String get enableGeolocationDescription =>
      'Kindly enable geolocation to allow the app to track your location automatically. This process must be completed to use the app.';

  @override
  String get enableGeolocation => 'Enable geolocation';

  @override
  String get openSettings => 'Open settings';

  @override
  String get notNow => 'Not now';

  @override
  String get loginToAccount => 'LOGIN TO YOUR ACCOUNT';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get signUpHere => 'Sign Up here';

  @override
  String get login => 'Login';

  @override
  String get forgotPasswordQuestion => 'Forgot password? ';

  @override
  String get resetHere => 'Reset here';

  @override
  String get next => 'Next';

  @override
  String get goBack => 'Go Back';

  @override
  String get connectAccountProgress => 'Connect account progress';

  @override
  String get identityVerification => 'Identity verification';

  @override
  String get bankInformation => 'Bank information';

  @override
  String get addressInformationTitle => 'Your address information';

  @override
  String get addressInformationDescription =>
      'Input your full address and location of residence';

  @override
  String get enterAddress => 'Enter your address';

  @override
  String get address => 'Address';

  @override
  String get enterPostalCode => 'Enter postal code';

  @override
  String get postalCode => 'Postal code';

  @override
  String get enterCity => 'Enter city';

  @override
  String get city => 'City';

  @override
  String get bankInformationTitle => 'Bank information';

  @override
  String get bankInformationDescription =>
      'Enter your IBAN to complete this step';

  @override
  String get enterIBAN => 'Enter your IBAN';

  @override
  String get ibanExample => 'ES00 0000 0000 0000 0000 0000';

  @override
  String get iban => 'IBAN';

  @override
  String get bankAccountNote =>
      'Kindly note that this bank account is required to receive payout from our payment provider.';

  @override
  String get detailsSubmitted => 'Details submitted';

  @override
  String get gotItThanks => 'Got it, thanks';

  @override
  String get accountDetailsSuccess =>
      'Your account connection details submitted successfully, you will soon be able to receive money for paid spaces.';

  @override
  String get selectCountry => 'Select country';

  @override
  String get selectCountryDescription =>
      'Select your country of residence to continue';

  @override
  String get spain => 'Spain';

  @override
  String get selectCountryLabel => 'Select country';

  @override
  String get uploadIDCard => 'Upload ID Card';

  @override
  String get uploadIDDescription => 'Upload your ID card both sides';

  @override
  String get uploadIDFront => 'Tap to upload ID Card front';

  @override
  String get uploadIDBack => 'Tap to upload ID Card back';

  @override
  String get imageSizeLimit => 'Only images supported Max: 2MB';

  @override
  String get frontSideFilename => 'front-side.png';

  @override
  String get backSideFilename => 'back-side.png';

  @override
  String get uploadCompleted => 'Upload completed';

  @override
  String get selectUploadType => 'Select upload type';

  @override
  String get openCamera => 'Open camera';

  @override
  String get upload => 'Upload';

  @override
  String get pleaseUploadBothSides => 'Please upload both sides of your ID';

  @override
  String get selectIdType => 'Select ID type';

  @override
  String get selectIdDescription =>
      'Select your ID type and upload the front & Back of your Identity Card';

  @override
  String get nationalIdCard => 'National ID Card';

  @override
  String get nationalIdDescription =>
      'Your government issued national identity card';

  @override
  String get residentPermit => 'Resident Permit';

  @override
  String get residentPermitDescription =>
      'Your government issued national resident permit';

  @override
  String get personalInfoTitle => 'Your personal information';

  @override
  String get personalInfoDescription =>
      'Input your personal details as it is on your ID Card';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get enterPhoneNumber => 'Enter phone number';

  @override
  String get dateOfBirth => 'Date of birth';

  @override
  String get dateFormat => 'YYYY/MM/DD';

  @override
  String get selectDateOfBirth => 'Please select your date of birth';

  @override
  String get clickToOpenCamera => 'Click to open camera';

  @override
  String get publishPaidSpace => 'Publish paid space';

  @override
  String get waitingTime => 'Waiting time';

  @override
  String get price => 'Price';

  @override
  String get enterPrice => 'Enter price';

  @override
  String get publish => 'Publish';

  @override
  String waitingTimeTooltip(int min, int max) {
    return 'This is the maximum amount of time the publisher can wait before leaving. The time must be between $min and $max minutes. After this time passes, the published space will expire.';
  }

  @override
  String get activeReservationExists =>
      'There’s an active reservation on your account. It needs to be finished or cancelled before you can publish a new paid space.';

  @override
  String get whatIsThisWaitingTime => 'What\'s this?';

  @override
  String get fetchingLocation => 'Fetching location...';

  @override
  String pendingFundsInfo(String minAmount, String maxAmount) {
    return 'You can withdraw between $minAmount and $maxAmount. Funds held by the payment provider will be available within a maximum of 10 days.';
  }

  @override
  String minWithdrawalAmountError(Object amount) {
    return 'You must have at least $amount to withdraw.';
  }

  @override
  String maxWithdrawalAmountError(Object amount) {
    return 'You cannot withdraw more than $amount at once.';
  }

  @override
  String minWithdrawalToast(Object amount) {
    return 'The minimum amount you can withdraw is $amount.';
  }

  @override
  String maxWithdrawalToast(Object amount) {
    return 'The maximum amount you can withdraw is $amount.';
  }

  @override
  String get exceedsBalanceToast =>
      'You cannot withdraw more than your available balance.';

  @override
  String timeToWaitMustBeBetween(String min, String max) {
    return 'The waiting time must be between $min and $max minutes.';
  }

  @override
  String closeToLocationDescription(int distance) {
    return 'You are very close to this location (less than $distance meters). Please choose a spot a bit further away.';
  }

  @override
  String priceMustBeBetween(String min, String max) {
    return 'The price must be between $min and $max.';
  }

  @override
  String get pleaseEnterAllFields => 'Please fill all fields';

  @override
  String get spacePublishedSuccesfully => 'Space published successfully';

  @override
  String get spacePublishedDescription =>
      'Your space have been published successfully, people can now have access to use space.';

  @override
  String get speedLimitAlert => 'Speed limit alert';

  @override
  String get speedLimitWarning => 'You are driving at speed limit, slow down';

  @override
  String get kmPerHour => 'Km/h';

  @override
  String get speedLimit => 'Speed limit';

  @override
  String get codeConfirmation => 'Code';

  @override
  String get recalculatingRoute => 'Recalculating route...';

  @override
  String get youHaveArrived => 'You have arrived at your destination!';

  @override
  String get navigatingToParking => 'Navigating to parking space';

  @override
  String get preparingNavigation => 'Preparing your navigation...';

  @override
  String get navigationError => 'Could not calculate route. Please try again.';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get fatigueAlertTitle => 'Fatigue alert';

  @override
  String get fatigueAlertMessage =>
      'You have been driving for 3 hours. Please consider taking a break.';

  @override
  String get fatigueAlertVoice =>
      'You have been driving for three hours. Please take a rest.';

  @override
  String get addEvent => 'Add alert';

  @override
  String get ahead => 'ahead';

  @override
  String get navigateToSpaceButton => 'Navigate to space';

  @override
  String get locationPermissionDenied => 'Location permission denied';

  @override
  String get locationPermissionDeniedPermanently =>
      'Location permissions permanently denied, please enable in settings';

  @override
  String get failedToLoadMap => 'Failed to load map';

  @override
  String get failedToInitializeLocation =>
      'Failed to initialize location services';

  @override
  String get failedToInitNavigation => 'Failed to initialize navigation';

  @override
  String get failedToStartNavigation =>
      'Failed to start navigation visualization';

  @override
  String get freeCameraMode => 'Free camera';

  @override
  String get lockPositionMode => 'Lock to position';

  @override
  String get cameraAlertTitle => 'Camera alert';

  @override
  String get radarAlertTitle => 'Radar alert';

  @override
  String get cameraAlertMessage => 'You are in a CCTV camera surveillance zone';

  @override
  String get radarAlertMessage => 'You are approaching a nearby radar zone';

  @override
  String get unnamedRoad => 'Unnamed Road';

  @override
  String get couldNotRecalculateRoute => 'Could not recalculate route';

  @override
  String get noPaymentsYet => 'No payments yet';

  @override
  String get noPaymentsDescription =>
      'Your payments history will appear here, once you make a payment';

  @override
  String get tooCloseToLocation => 'Too close to location';

  @override
  String get close => 'Close';

  @override
  String get trafficLevel => 'Traffic';

  @override
  String toArriveBy(String time) {
    return 'To arrive by $time';
  }

  @override
  String get notifyAvailableSpace =>
      'Notify me of available space in this area';

  @override
  String get dateAndTime => 'Date & Time';

  @override
  String get paid => 'Paid';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get refunded => 'Refunded';

  @override
  String get notificationRadius => 'Receive notifications up to (meters)';

  @override
  String get startRoute => 'Start route';

  @override
  String radiusLessThan(int meters) {
    return 'Radius cannot be less than $meters meters';
  }

  @override
  String get notificationScheduled => 'Notification scheduled';

  @override
  String get notificationScheduledDescription =>
      'You will be notified when a space is available in this area';

  @override
  String get minutesShort => 'mins';

  @override
  String get hoursShort => 'hrs';

  @override
  String get metersShort => 'm';

  @override
  String get kilometersShort => 'km';

  @override
  String get timesRequired => 'Start and end times are required';

  @override
  String get startBeforeEnd => 'Start time should be before end time';

  @override
  String get timeGreaterThanCurrent =>
      'Start and end times should be greater than the current time';

  @override
  String get maxScheduleDays => 'You can only schedule up to 5 days';

  @override
  String distanceTraveled(int distance) {
    return 'Distance traveled: $distance m';
  }

  @override
  String youHaveTraveled(int distance) {
    return 'You have traveled $distance meters';
  }

  @override
  String estimatedArrival(String time, int distance) {
    return 'Estimated arrival in $time with $distance meters remaining';
  }

  @override
  String seconds(int count) {
    return '$count seconds';
  }

  @override
  String minutesAndSeconds(int minutes, int seconds) {
    return '$minutes min $seconds sec';
  }

  @override
  String minutesOnly(int minutes) {
    return '$minutes minutes';
  }

  @override
  String hoursAndMinutes(int hours, int minutes) {
    return '$hours hr $minutes min';
  }

  @override
  String hoursOnly(int hours) {
    return '$hours hours';
  }

  @override
  String get locationPermissionPermanentlyDenied =>
      'Location permissions permanently denied, please enable in settings';

  @override
  String get failedToInitializeLocationServices =>
      'Failed to initialize location services';

  @override
  String get failedToGetCurrentLocation => 'Failed to get current location';

  @override
  String get failedToStartNavigationSimulation =>
      'Failed to start navigation simulation';

  @override
  String get failedToInitializeRouting => 'Failed to initialize routing';

  @override
  String get couldNotCalculateRoute =>
      'Could not calculate route. Please try again.';

  @override
  String get failedToInitializeNavigation => 'Failed to initialize navigation';

  @override
  String metersAhead(int distance) {
    return '${distance}m ahead';
  }

  @override
  String get preparingYourNavigation => 'Preparing your navigation...';

  @override
  String metersAway(String distance) {
    return '$distance away';
  }

  @override
  String get gotItThankYou => 'Got it';

  @override
  String get feedbackButton => 'Feedback';

  @override
  String get feedbackSubmitted => 'Your feedback has been submitted';

  @override
  String get thankYouForInput => 'Thank you for your input!';

  @override
  String get eventFeedback => 'Alert feedback';

  @override
  String get stillThere => 'It\'s still there';

  @override
  String get notThere => 'It\'s not there';

  @override
  String get illTakeIt => 'I\'ll take it';

  @override
  String get itsInUse => 'It\'s in use';

  @override
  String get notUseful => 'Not useful';

  @override
  String get prohibited => 'Prohibited';

  @override
  String get unableToLogin => 'Unable to login';

  @override
  String get unableToRegister => 'Unable to register';

  @override
  String get unableToVerifyEmail => 'Unable to verify email';

  @override
  String get unableToResetPassword => 'Unable to reset password';

  @override
  String get unableToValidateReset => 'Unable to validate reset password';

  @override
  String get unableToFindAccount => 'Unable to find Account';

  @override
  String get unableToResendCode => 'Unable to resend verification code';

  @override
  String get arrivedAtDestination => 'You have arrived at your destination.';

  @override
  String get rateThisParkingSpace =>
      'How would you like to rate this parking space?';

  @override
  String get customNavigation => 'Custom navigation';

  @override
  String get startButton => 'Start';

  @override
  String get stopButton => 'Stop';

  @override
  String get toggleButton => 'Toggle';

  @override
  String get colorButton => 'Color';

  @override
  String get unread => 'Unread';

  @override
  String get notifications => 'Notifications';

  @override
  String get yourSpaceLocatedAt => 'Your space located at ';

  @override
  String get hasBeenOccupied => ' has been occupied';

  @override
  String get aNewSpaceHasBeenPublished =>
      'A new space has been published within ';

  @override
  String get around => ' around ';

  @override
  String get hasBeenReserved => ' has been reserved';

  @override
  String get receivedPositiveFeedback => ' Received positive feedback';

  @override
  String get noNotificationsYet => 'No notifications yet';

  @override
  String get notificationsWillAppear =>
      'Your app notifications will appear here\nwhenever there is a new activity';

  @override
  String get noScheduledNotificationsYet => 'No scheduled notifications yet';

  @override
  String get scheduledNotificationsWillAppear =>
      'Your app scheduled notifications will appear\nhere whenever you set this reminder';

  @override
  String get justNow => 'Just now';

  @override
  String get viewSpace => 'View space';

  @override
  String get noPaymentMethodsAdded => 'No payment methods added';

  @override
  String get noPaymentMethodsDescription =>
      'You haven\'t added any payment methods yet.\nAdd one to make payments easily.';

  @override
  String get paymentMethodAdded => 'Payment Method Added';

  @override
  String get paymentMethodAddedDescription =>
      'Your payment method has been successfully added.';

  @override
  String get pleaseCompleteCardDetails => 'Please complete the card details';

  @override
  String get failedToAddPaymentMethod =>
      'Failed to add payment method. Please try again.';

  @override
  String get cardNumber => 'Card number';

  @override
  String get addNewCard => 'Add new card';

  @override
  String get defaultt => 'Default';

  @override
  String expireDate(String date) {
    return 'Expire date: $date';
  }

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get makeDefault => 'Make default';

  @override
  String get confirmDeleteCard => 'Confirm Delete Card';

  @override
  String deleteCardConfirmation(String last4) {
    return 'Are you sure you want to delete Card ending with $last4? This action cannot be undone.';
  }

  @override
  String get noKeepCard => 'No, keep card';

  @override
  String get yesDeleteCard => 'Yes, delete card';

  @override
  String get noPayoutMethodsYet => 'No payout methods yet';

  @override
  String get payoutMethodsDescription =>
      'Your added payout methods will appear\nhere once you set them up in your profile';

  @override
  String get payoutMethodAdded => 'Payout method added';

  @override
  String get payoutMethodAddedDescription =>
      'Your payout method has been added successfully.';

  @override
  String get addPayoutMethod => 'Add bank account';

  @override
  String get accountNumber => 'Account number';

  @override
  String get accountNumberExample => 'ES00 0000 0000 0000 0000 0000';

  @override
  String get makeDefaultPaymentMethod => 'Make as default payment method';

  @override
  String get pleaseEnterAccountNumber => 'Please enter account number';

  @override
  String get payoutMethods => 'Bank accounts';

  @override
  String get payoutMethodOptions => 'Bank account options';

  @override
  String get rescheduleNotification => 'Reschedule notification';

  @override
  String get reschedule => 'Reschedule';

  @override
  String get notificationRescheduledSuccessfully =>
      'Notification rescheduled successfully';

  @override
  String get spaceReminder => 'Space reminder';

  @override
  String get rescheduleReminder => 'Reschedule reminder';

  @override
  String get deleteReminder => 'Delete reminder';

  @override
  String get youHaveReminderForSpace => 'You have a reminder for a space at ';

  @override
  String get expired => 'Expired';

  @override
  String get active => 'Active';

  @override
  String get activeMayus => 'ACTIVE';

  @override
  String get antiMoneyLaunderingMessage =>
      'The Anti-money Laundering Directive forces us to verify your identity in order to receive payment for your online sales. You will only need to verify yourself once.';

  @override
  String get couldNotOpenTermsAndConditions =>
      'Could not open Terms & Conditions link';

  @override
  String get byAgreementStripe => 'By continuing, I agree to the ';

  @override
  String get stripeConnectedAccountAgreement =>
      'Stripe Connected Account Agreement';

  @override
  String get and => ' and ';

  @override
  String get stripeTermsOfService => 'Stripe Terms of Service';

  @override
  String get accountInformationChanged =>
      'Account information changed successfully';

  @override
  String get accountInformationChangedDescription =>
      'Your account information has been changed successfully,';

  @override
  String get orders => 'Bookings';

  @override
  String get errorLoadingOrders => 'Error loading bookings';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get oneWeekAgo => '1 week ago';

  @override
  String get twoWeeksAgo => '2 weeks ago';

  @override
  String get threeWeeksAgo => '3 weeks ago';

  @override
  String get noOrdersYet => 'No bookings yet';

  @override
  String get noOrdersDescription =>
      'You have not made any orders yet.\nStart exploring and make your first order!';

  @override
  String get alerts => 'Alerts';

  @override
  String get emailNotifications => 'Email notifications';

  @override
  String get pushNotifications => 'Push notifications';

  @override
  String get availableSpaces => 'Available spaces';

  @override
  String get radarAlerts => 'Radar alerts';

  @override
  String get cameraAlerts => 'Camera alerts';

  @override
  String get prohibitedZoneAlert => 'Prohibited zone alert';

  @override
  String get fatigueAlert => 'Fatigue alert';

  @override
  String get policeAlert => 'Police alert';

  @override
  String get accidentAlert => 'Accident alert';

  @override
  String get roadClosedAlert => 'Road closed alert';

  @override
  String get nameNotProvided => 'Name not provided';

  @override
  String get letdemPoints => 'LetDem Points';

  @override
  String get walletBalance => 'Wallet balance';

  @override
  String get withdraw => 'Withdraw';

  @override
  String get withdrawals => 'Withdrawals';

  @override
  String get payouts => 'Banks';

  @override
  String get transactionHistory => 'Last transactions';

  @override
  String get transactionTitle => 'Transactions';

  @override
  String get fromDate => 'From';

  @override
  String get toDate => 'To';

  @override
  String get seeAll => 'See all';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get transactionsHistoryMessage =>
      'Your transactions history will be listed here when you have any activity to show.';

  @override
  String get loadingTransactions => 'Loading transactions';

  @override
  String get noPayoutMethodsAvailable => 'No payout methods available';

  @override
  String get success => 'Success';

  @override
  String get withdrawalRequestSuccess =>
      'Withdrawal request has been sent successfully.';

  @override
  String withdrawalToBank(String method) {
    return 'Withdrawal to bank $method';
  }

  @override
  String get successful => 'Successful';

  @override
  String get failed => 'Failed';

  @override
  String get noWithdrawalsYet => 'No withdrawals yet';

  @override
  String get withdrawalHistoryMessage =>
      'Your withdrawal history will appear here\nwhenever you make a withdrawal';

  @override
  String amountCannotExceed(String balance) {
    return 'Amount cannot exceed $balance €';
  }

  @override
  String get amountToReceive => 'Amount to receive';

  @override
  String pendingToBeCleared(String amount) {
    return '$amount € Awaiting clearance';
  }

  @override
  String get paymentMethodAddedTitle => 'Payment method added';

  @override
  String get paymentMethodAddedSubtext =>
      'Your payment method has been successfully added.';

  @override
  String get addPaymentMethodTitle => 'Add payment method';

  @override
  String get cardDetails => 'Card details';

  @override
  String get enterTheNumber => 'Enter the number';

  @override
  String get create => 'Create';

  @override
  String get pleaseEnterYourName => 'Please enter your name';

  @override
  String get paymentSuccessfulReservation =>
      'Your payment was successful. The space is now reserved.';

  @override
  String get paymentFailedRequiresAction =>
      'Payment failed or requires further action';

  @override
  String get connectionPending => 'Connection pending';

  @override
  String get connectionPendingMessage =>
      'Your account connection is still pending, you will be notified when the connection is complete';

  @override
  String get somethingWentWrongGeneric => 'Something went wrong';

  @override
  String get contactSupportMessage =>
      'There seems to be an issue with your account. Please contact support for assistance.';

  @override
  String get insufficientBalance =>
      'You do not have enough balance to withdraw';

  @override
  String get loading => 'Loading...';

  @override
  String get continueButton => 'Continue';

  @override
  String get error => 'Error';

  @override
  String get warning => 'Warning';

  @override
  String get confirmation => 'Confirmation';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get successGeneric => 'Success';

  @override
  String get errorOccurred => 'Error occurred';

  @override
  String get pleaseTryAgain => 'Please try again';

  @override
  String get reservationConfirmedTitle => 'Reservation confirmed';

  @override
  String get reservationConfirmedDescription =>
      'Your reservation has been confirmed successfully, we will update your balance shortly.';

  @override
  String get reservationCancelledOwnerTitle => 'Reservation cancelled';

  @override
  String get reservationCancelledOwnerDescription =>
      'Now we will proceed to refund the total amount of reservation to the requester.';

  @override
  String get reservationCancelledRequesterTitle => 'Reservation cancelled';

  @override
  String get reservationCancelledRequesterDescription =>
      'Now we will refund the total amount of reservation to your bank account.';

  @override
  String get networkError => 'Network error';

  @override
  String get published => 'Published';

  @override
  String get activeStatus => 'Active';

  @override
  String get minsAgo => 'mins ago';

  @override
  String get hoursAgo => 'hours ago';

  @override
  String priceTooltip(String max, String min) {
    return 'This is the price for a parking space. The maximum price you can set is $max, and the minimum is $min.';
  }

  @override
  String get myLocation => 'My location';

  @override
  String get zoomIn => 'Zoom In';

  @override
  String get zoomOut => 'Zoom Out';

  @override
  String get toggleView => 'Toggle view';

  @override
  String get newNotification => 'New notification';

  @override
  String get tapToView => 'Tap to view';

  @override
  String get markAsRead => 'Mark as read';

  @override
  String get invalidCredentials => 'Invalid credentials';

  @override
  String get checkInternetConnection => 'Please check your internet connection';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get registrationSuccessful => 'Registration successful';

  @override
  String get accountCreated => 'Account created';

  @override
  String get welcomeToLetdem => 'Welcome to LetDem';

  @override
  String get searchHere => 'Search here...';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get clearHistory => 'Clear history';

  @override
  String get carRegisteredSuccessfully => 'Car registered successfully';

  @override
  String get invalidPlateNumber => 'Invalid plate number';

  @override
  String get selectValidCarType => 'Please select a valid car type';

  @override
  String get accountSetupComplete => 'Account setup complete';

  @override
  String get verificationPending => 'Verification pending';

  @override
  String get documentsUploadedSuccessfully => 'Documents uploaded successfully';

  @override
  String get defaultPayment => 'Default';

  @override
  String get expires => 'Expires';

  @override
  String get logoutConfirmation => 'Are you sure you want to log out?';

  @override
  String get deleteCard => 'Delete card';

  @override
  String get setAsDefault => 'Set as default';

  @override
  String get bankAccount => 'Bank account';

  @override
  String get verified => 'Verified';

  @override
  String get pendingVerification => 'Pending verification';

  @override
  String get primary => 'Primary';

  @override
  String get gpsDisabled => 'GPS is disabled';

  @override
  String get unableToGetLocation => 'Unable to get location';

  @override
  String get locationServicesUnavailable => 'Location services unavailable';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String get connectionTimeout => 'Connection timeout';

  @override
  String get serverError => 'Server error';

  @override
  String get requestFailed => 'Request failed';

  @override
  String get invalidEmailFormat => 'Invalid email format';

  @override
  String get passwordTooShort => 'Password too short';

  @override
  String get fieldRequired => 'Field is required';

  @override
  String get invalidPhoneNumber => 'Invalid phone number';

  @override
  String get todayDate => 'Today';

  @override
  String get yesterdayDate => 'Yesterday';

  @override
  String get tomorrowDate => 'Tomorrow';

  @override
  String get justNowTime => 'Just now';

  @override
  String get minuteAgo => 'minute ago';

  @override
  String get minutesAgoTime => 'minutes ago';

  @override
  String get hourAgo => 'hour ago';

  @override
  String get hoursAgoTime => 'hours ago';

  @override
  String get dayAgo => 'day ago';

  @override
  String get daysAgoTime => 'days ago';

  @override
  String get weekAgo => 'week ago';

  @override
  String get weeksAgo => 'weeks ago';

  @override
  String get monthAgo => 'month ago';

  @override
  String get monthsAgo => 'months ago';

  @override
  String get paymentReceived => 'Payment received';

  @override
  String get withdrawalProcessed => 'Withdrawal processed';

  @override
  String get refundIssued => 'Refund issued';

  @override
  String get transactionFailed => 'Transaction failed';

  @override
  String get securitySettings => 'Security settings';

  @override
  String get changePassword => 'Change password';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountConfirmation =>
      'Are you sure you want to delete your account? This action cannot be undone.';

  @override
  String get pleaseEnterYourPhoneNumber => 'Please enter your phone number';

  @override
  String get monthJan => 'Jan';

  @override
  String get monthFeb => 'Feb';

  @override
  String get monthMar => 'Mar';

  @override
  String get monthApr => 'Apr';

  @override
  String get monthMay => 'May';

  @override
  String get monthJun => 'Jun';

  @override
  String get monthJul => 'Jul';

  @override
  String get monthAug => 'Aug';

  @override
  String get monthSep => 'Sep';

  @override
  String get monthOct => 'Oct';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthDec => 'Dec';

  @override
  String get faqTitle => 'FAQ';

  @override
  String get faqPublishPaidSpaceQuestion => 'How do i publish a paid space?';

  @override
  String get faqPublishPaidSpaceAnswer =>
      'To publish a paid space, you must meet the following requirements:\n\n• Enter your vehicle information in the app so it can be used at the time of reservation.\n• Create an earnings account from your profile. You will need to register your tax information, which is required to receive payments in the app due to European anti-money laundering regulations.';

  @override
  String get faqEarnMoneyQuestion => 'How do i earn money from my paid space?';

  @override
  String get faqEarnMoneyAnswer =>
      'To earn money from your space, it must be reserved by another user. Once the space is reserved, you must confirm the reservation using the confirmation code provided to the user who made the booking. After you receive this code, proceed with confirming the reservation.\n\nOnce the reservation is confirmed, the amount of your reservation — minus LetDem\'s service fees — will be transferred to you.\n\nYou can see the total amount earned in the Earnings section of your profile.';

  @override
  String get faqWithdrawFundsQuestion =>
      'How do i withdraw my funds to a personal account?';

  @override
  String get faqWithdrawFundsAnswer =>
      'To withdraw funds, they first need to be released by the payment provider. This usually takes around 10 days. Once the funds are released, they will be available in the app, and you\'ll be able to withdraw them using one of your linked bank accounts.';

  @override
  String get helpLetDemPointsTitle => 'How to earn LetDem Points?';

  @override
  String get helpLetDemPointsReserveTitle => 'Reserve a paid parking space';

  @override
  String get helpLetDemPointsReserveDescription =>
      'to the user who reserves and pays for a space published by another user. Once this reservation is confirmed.';

  @override
  String get helpLetDemPointsPublishTitle => 'Publish a free parking space';

  @override
  String get helpLetDemPointsPublishDescription =>
      'if another user uses it and selects \"I\'ll take it\" as feedback after arriving at the location.';

  @override
  String get helpLetDemPointsAlertTitle =>
      'Publish an alert (Police, Road Closed, Accident)';

  @override
  String get helpLetDemPointsAlertDescription =>
      'if another user confirms the existence of the alert.';

  @override
  String get helpLetDemPointsAdditionalNotesTitle => 'Additional Notes';

  @override
  String get helpLetDemPointsAdditionalNote1 =>
      '• The user who gives up a paid parking space doesn\'t earn points, but does earn money.';

  @override
  String get helpLetDemPointsAdditionalNote2 =>
      '• In all actions, points are granted only if the contribution is useful and confirmed by another user.';

  @override
  String get helpScheduledNotificationsTitle =>
      'How to create scheduled space notifications?';

  @override
  String get helpScheduledNotificationsIntro =>
      'To schedule a parking notification:';

  @override
  String get helpScheduledNotificationsStep1 =>
      'Search for your destination using the search bar on the main screen.';

  @override
  String get helpScheduledNotificationsStep2 =>
      'Select the desired address and tap the \"Notify me about available space\" button.';

  @override
  String get helpScheduledNotificationsStep3 =>
      'Configure the alert by selecting:';

  @override
  String get helpScheduledNotificationsStep3Detail1 =>
      '• The time range during which you want to receive notifications.';

  @override
  String get helpScheduledNotificationsStep3Detail2 =>
      '• The distance in meters from the selected location that should be considered as the notification area.';

  @override
  String get helpScheduledNotificationsInfo1 =>
      'Once the alert is created, you can manage it from your profile in the \"Scheduled Notifications\" section, where you\'ll see all your active or expired alerts.';

  @override
  String get helpScheduledNotificationsInfo2 =>
      'Whenever a parking space is published within the configured area, you\'ll receive a notification so you can quickly head to the space.';

  @override
  String get unhandledError => 'Unhandled error';

  @override
  String get paymentFailed => 'Payment failed';

  @override
  String get changePaymentMethod => 'Change payment method';

  @override
  String get paymentFailedDescription =>
      'The reservation failed because your payment didn\'t go through successfully';

  @override
  String get errorReserveSpaceDescription =>
      'Please try again later. If the issue persists, contact support.';

  @override
  String speedLimitVoiceAlert(String speedLimit) {
    return 'Speed limit is $speedLimit kilometers per hour';
  }

  @override
  String get waitingForNavigation => 'Waiting for navigation to start...';

  @override
  String get locationNotAvailable => 'Location data not available';
}
