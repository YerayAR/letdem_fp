// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get enterDestination => 'Ingresar destino';

  @override
  String get whatDoYouWantToDo => '¿Qué quieres hacer?';

  @override
  String get publishSpace => 'Publicar aparcamiento';

  @override
  String get publishEvent => 'Publicar alerta';

  @override
  String get home => 'Inicio';

  @override
  String get activities => 'Actividades';

  @override
  String get profile => 'Perfil';

  @override
  String get contributions => 'Contribuciones';

  @override
  String get scheduledNotifications => 'Notificaciones programadas';

  @override
  String get paymentMethods => 'Métodos de pago';

  @override
  String get earnings => 'Ganancias';

  @override
  String get connectAccount => 'Conectar cuenta';

  @override
  String get cancelReservationConfirmationTitle => '¿Cancelar la reserva?';

  @override
  String get cancelReservationConfirmationText =>
      '¿Seguro que quieres cancelar esta reserva? Esta acción no se puede deshacer.';

  @override
  String get basicInformation => 'Información básica';

  @override
  String get preferences => 'Preferencias';

  @override
  String get security => 'Seguridad';

  @override
  String get help => 'Ayuda';

  @override
  String get aboutUs => 'Sobre nosotros';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get termsOfUse => 'Términos de uso';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get language => 'Idioma';

  @override
  String get save => 'Guardar';

  @override
  String get english => 'Inglés';

  @override
  String get spanish => 'Español';

  @override
  String get cardholderName => 'Nombre del titular';

  @override
  String get enterYourName => 'Ingrese su nombre';

  @override
  String get cancel => 'Cancelar';

  @override
  String get notificationPaidSpaceReserved => 'Aparcamiento de pago reservado';

  @override
  String get notificationNewSpacePublished => 'Nuevo aparcamiento publicado';

  @override
  String get notificationSpaceOccupied => 'Aparcamiento ocupado';

  @override
  String get notificationDisabled => 'Deshabilitado';

  @override
  String get notificationFree => 'Gratis';

  @override
  String get notificationBlue => 'Azul';

  @override
  String get notificationGreen => 'Verde';

  @override
  String get done => 'Listo';

  @override
  String noPendingFundsMessage(Object min, Object max) {
    return 'No tienes fondos pendientes de liberar. Puedes retirar entre $min y $max.';
  }

  @override
  String get selectDuration => 'Seleccionar duración';

  @override
  String get minutes => 'MIN';

  @override
  String get sec => 'SEG';

  @override
  String get proceed => 'Continuar';

  @override
  String get pleaseEnter => 'Por favor ingrese';

  @override
  String get passwordMinLength =>
      'La contraseña debe tener al menos 8 caracteres';

  @override
  String get passwordRequireNumber =>
      'La contraseña debe contener al menos un número';

  @override
  String get passwordRequireSpecial =>
      'La contraseña debe contener al menos un carácter especial';

  @override
  String get passwordRequireUppercase =>
      'La contraseña debe contener al menos una letra mayúscula';

  @override
  String get pleaseEnterValidEmail => 'Por favor ingrese un email válido';

  @override
  String get validCard => 'Tarjeta válida';

  @override
  String get enterCardDetails => 'Ingrese los datos de la tarjeta';

  @override
  String get passwordStrength => 'Seguridad de la contraseña';

  @override
  String get passwordWeak => 'Débil';

  @override
  String get passwordFair => 'Regular';

  @override
  String get passwordGood => 'Buena';

  @override
  String get passwordStrong => 'Fuerte';

  @override
  String get missingInfo => 'Información faltante';

  @override
  String get reservationExpired => 'Reserva expirada';

  @override
  String get lessThanAMinuteLeft => 'Queda menos de un minuto';

  @override
  String minutesLeftToReserve(Object minutes) {
    return 'Quedan $minutes minutos para reservar';
  }

  @override
  String get meters => 'metros';

  @override
  String get trafficLow => 'Bajo';

  @override
  String get trafficModerate => 'Moderado';

  @override
  String get trafficHeavy => 'Intenso';

  @override
  String get homeLocationShort => 'Casa';

  @override
  String get transactionSpacePayment => 'Pago recibido por el aparcamiento';

  @override
  String get transactionWithdraw => 'Retiro';

  @override
  String get transactionSpaceTransfer => 'Transferencia de aparcamiento';

  @override
  String get transactionSpaceWithdrawal => 'Retirada de fondos';

  @override
  String get transactionSpaceDeposit => 'Depósito por aparcamiento';

  @override
  String get pending => 'Pendiente';

  @override
  String get rejected => 'Rechazado';

  @override
  String get blocked => 'Bloqueado';

  @override
  String get work => 'Trabajo';

  @override
  String get accepted => 'Aceptado';

  @override
  String get personalInfo => 'Información personal';

  @override
  String get addressInfo => 'Información de la dirección';

  @override
  String get documentUpload => 'Subir documentos';

  @override
  String get bankAccountInfo => 'Información bancaria';

  @override
  String get submitted => 'Enviado';

  @override
  String get policeAhead => 'Policía adelante';

  @override
  String get roadClosedAhead => 'Vía cerrada adelante';

  @override
  String get accidentAhead => 'Accidente adelante';

  @override
  String get unknownEventAhead => 'Alerta desconocida adelante';

  @override
  String get police => 'Policía';

  @override
  String get closedRoad => 'Vía cortada';

  @override
  String get accident => 'Accidente';

  @override
  String get freeSpace => 'Espacio gratuito';

  @override
  String get blueZone => 'Zona azul';

  @override
  String get disabledSpace => 'Espacio de minusválidos';

  @override
  String get greenZone => 'Zona verde';

  @override
  String get paidFreeSpace => 'Zona gratuita';

  @override
  String get paidBlueZone => 'Zona azul de pago';

  @override
  String get paidDisabledSpace => 'Espacio pago de minusválidos';

  @override
  String get paidGreenZone => 'Zona verde de pago';

  @override
  String get selectEventType => 'Seleccionar tipo de alerta';

  @override
  String get publishButtonText => 'Publicar';

  @override
  String get eventPublishedTitle => 'Alerta publicada\nexitosamente';

  @override
  String get eventPublishedSubtext =>
      'Tu alerta ha sido publicada exitosamente, las personas ahora pueden ver esta alerta en el mapa.';

  @override
  String get away => 'de distancia';

  @override
  String get addPaymentMethod => 'Agregar un método de pago';

  @override
  String cardEndingWith(String brand, String last4) {
    return '$brand terminada en $last4';
  }

  @override
  String get paymentSuccessful => 'Pago exitoso';

  @override
  String get spaceReservedSuccess =>
      'Has reservado exitosamente un aparcamiento de pago. Puedes ver los detalles haciendo clic abajo.';

  @override
  String get arrivalTitle => '¡Has llegado!';

  @override
  String get arrivalSubtitle =>
      'Las plazas de aparcamiento cercanas ahora están visibles en el mapa. Pulsa una para iniciar la navegación.';

  @override
  String get getSpaceDetails => 'Ver detalles del aparcamiento';

  @override
  String get reserveSpace => 'Reservar aparcamiento';

  @override
  String get navigateToSpace => 'Navegar al aparcamiento';

  @override
  String get regularSpace => 'Aparcamiento regular';

  @override
  String get paidSpace => 'Aparcamiento de pago';

  @override
  String get importantNotice => 'Aviso importante';

  @override
  String get createCarProfileFirst =>
      'Necesitas crear un perfil de coche para publicar un aparcamiento de pago. Por favor, crea un perfil de coche primero.';

  @override
  String get createEarningAccountFirst =>
      'Necesitas crear una cuenta de ganancias para publicar un aparcamiento de pago. Por favor, crea una cuenta de ganancias primero.';

  @override
  String get continueText => 'Continuar';

  @override
  String get locationPermissionRequired => 'Permiso de ubicación\nrequerido';

  @override
  String get locationPermissionDescription =>
      'Necesitamos acceder a tus servicios de ubicación para realizar cualquier acción en la aplicación';

  @override
  String get openSystemSettings => 'Abrir configuración del sistema';

  @override
  String get spaceDetails => 'Detalles del aparcamiento';

  @override
  String get confirmOrder => 'Confirmar';

  @override
  String get spaceReserved => 'Aparcamiento reservado';

  @override
  String get spaceReservedSuccessfully =>
      'Tu aparcamiento ha sido reservado exitosamente.';

  @override
  String get confirmationCode => 'Código de confirmación';

  @override
  String get enterConfirmationCode =>
      'El solicitante del aparcamiento te dará un número de confirmación de 6 dígitos, ingrésalo aquí.';

  @override
  String get confirmationCodeWarning =>
      'Por favor, asegúrate de que el código de confirmación funcione antes de entregar el aparcamiento';

  @override
  String get pleaseEnterConfirmationCode =>
      'Por favor ingresa el código de confirmación';

  @override
  String get reserved => 'Reservado';

  @override
  String get waiting => 'Esperando';

  @override
  String get deleteSpaceTitle => 'Eliminar aparcamiento';

  @override
  String get deleteSpaceSubtext =>
      '¿Estás seguro de que deseas eliminar este aparcamiento? Esta acción no se puede deshacer.';

  @override
  String get spaceDeleted => 'Aparcamiento eliminado';

  @override
  String get spaceDeletedSubtext =>
      'El aparcamiento ha sido eliminado con éxito.';

  @override
  String get reservedSpace => 'Aparcamiento reservado';

  @override
  String get confirmationCodeTitle => 'Código de confirmación';

  @override
  String get shareCodeOwner =>
      'Comparte este código con el propietario del aparcamiento';

  @override
  String get ownerPlateNumber => 'Matrícula del propietario: ';

  @override
  String get callSpaceOwner => 'Llamar al propietario';

  @override
  String get couldNotLaunchDialer => 'No se pudo abrir el teléfono';

  @override
  String get viewDetails => 'Ver detalles';

  @override
  String get free => 'Gratuito';

  @override
  String get timeRemaining => 'Tiempo restante';

  @override
  String get currency => '€';

  @override
  String get showAll => 'Ver todo';

  @override
  String get noContributions => 'Todavía no tienes contribuciones';

  @override
  String get noContributionsDescription =>
      'Tu historial de contribuciones aparecerá aquí.';

  @override
  String get all => 'Todos';

  @override
  String get parkingSpace => 'Aparcamiento';

  @override
  String get events => 'Alertas';

  @override
  String get verifyYourAccountFirst =>
      'Tu cuenta de ganancias aún no está verificada. Por favor verifica tu cuenta enviando tu DNI e información bancaria.';

  @override
  String failedToLoadActivities(String error) {
    return 'Error al cargar actividades: $error';
  }

  @override
  String get selectFilterActivities =>
      'Selecciona un filtro para ver actividades';

  @override
  String get searchLocation => 'Buscar ubicación';

  @override
  String get back => 'Atrás';

  @override
  String updatingLocation(String type) {
    return 'ACTUALIZANDO UBICACIÓN DE $type';
  }

  @override
  String get spaceOwnerCannotReserve =>
      'El propietario del aparcamiento no puede reservar su propio aparcamiento';

  @override
  String get location => 'Ubicación';

  @override
  String get spaceDetailsTitle => 'Detalles del aparcamiento';

  @override
  String locationType(Object type) {
    return 'Ubicación de $type';
  }

  @override
  String setLocation(String type) {
    return 'Establecer $type';
  }

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get spaceOccupied => 'Aparcamiento ocupado';

  @override
  String get otherLocation => 'Otra ubicación';

  @override
  String get homeLocation => 'Ubicación de casa';

  @override
  String get workLocation => 'Ubicación de trabajo';

  @override
  String get whereAreYouGoing => '¿A dónde vas?';

  @override
  String get favourites => 'Favoritos';

  @override
  String get recent => 'Recientes';

  @override
  String get clearAll => 'Borrar todo';

  @override
  String get spacePublished => 'Aparcamiento publicado';

  @override
  String get eventPublished => 'Alerta publicada';

  @override
  String pointsEarned(String points) {
    return '+$points Pts';
  }

  @override
  String get noCarRegistered => 'Sin coche registrado';

  @override
  String get registerCarDetails =>
      'Registra tu coche con los detalles\npor seguridad y accesibilidad';

  @override
  String get tapToRegisterCar => 'Toca para registrar coche';

  @override
  String get registerCar => 'Registrar coche';

  @override
  String get updateCarDetails => 'Actualizar detalles del coche';

  @override
  String get update => 'Actualizar';

  @override
  String get register => 'Registrar';

  @override
  String get enterCarBrand => 'Ingresa la marca del coche';

  @override
  String get enterPlateNumber => 'Ingresa la matrícula';

  @override
  String get brand => 'Marca';

  @override
  String get plateNumber => 'Matrícula';

  @override
  String get selectTag => 'Seleccionar etiqueta';

  @override
  String get whatIsThis => '¿Qué es esto?';

  @override
  String get whatTagMeans => 'Qué significan las etiquetas';

  @override
  String get gotIt => 'Entendido';

  @override
  String get ecoLabel => 'Etiqueta ECO';

  @override
  String get zeroEmissionLabel => 'Etiqueta Cero Emisiones';

  @override
  String get bLabelYellow => 'Etiqueta B amarilla';

  @override
  String get cLabelGreen => 'Etiqueta C verde';

  @override
  String get noLabel => 'Sin etiqueta';

  @override
  String get ecoLabelPluginHybrids =>
      'Híbridos enchufables con autonomía eléctrica inferior a 40 km.';

  @override
  String get ecoLabelNonPluginHybrids => 'Híbridos no enchufables (HEV).';

  @override
  String get ecoLabelGasPowered =>
      'Vehículos propulsados por gas (GLP, GNC o GNL).';

  @override
  String get zeroLabelElectric => 'Vehículos 100% eléctricos (BEV).';

  @override
  String get zeroLabelPluginHybrids =>
      'Híbridos enchufables (PHEV) con autonomía eléctrica superior a 40 km.';

  @override
  String get zeroLabelHydrogen => 'Vehículos propulsados por hidrógeno.';

  @override
  String get bLabelPetrol =>
      'Coches y furgonetas de gasolina matriculados desde enero de 2001.';

  @override
  String get bLabelDiesel =>
      'Coches y furgonetas diésel matriculados desde enero de 2006.';

  @override
  String get bLabelIndustrial =>
      'Vehículos industriales y autobuses matriculados desde 2005.';

  @override
  String get cLabelPetrol =>
      'Coches y furgonetas de gasolina matriculados desde enero de 2006.';

  @override
  String get cLabelDiesel =>
      'Coches y furgonetas diésel matriculados desde septiembre de 2015.';

  @override
  String get cLabelIndustrial =>
      'Vehículos industriales y autobuses matriculados desde 2014.';

  @override
  String get yourCarDetails => 'Detalles de tu coche';

  @override
  String get editDetails => 'Editar detalles';

  @override
  String get lastPlaceParked => '¿Dónde está mi coche?';

  @override
  String get unknown => 'Desconocido';

  @override
  String get navigateToCar => 'Navegar al coche';

  @override
  String get errorConfirmSpaceReservation =>
      'No se pudo confirmar la reserva del aparcamiento';

  @override
  String get errorReserveSpace => 'No se pudo reservar el aparcamiento';

  @override
  String get errorSendFeedback => 'No se pudo enviar el feeback';

  @override
  String get errorTakeSpace => 'No se pudo tomar el aparcamiento';

  @override
  String get errorPublishRoadEvent => 'No se pudo publicar la alerta en la vía';

  @override
  String get errorLoadActivities => 'No se pudieron cargar las actividades';

  @override
  String get errorPublishSpace => 'No se pudo publicar el aparcamiento';

  @override
  String get forgotPassword => 'Olvidé mi contraseña';

  @override
  String get getHelp => 'Ayuda';

  @override
  String get enterEmailToReset =>
      'Ingresa tu dirección de correo electrónico para continuar';

  @override
  String get emailAddress => 'Correo electrónico';

  @override
  String get enterEmailAddress => 'Ingresa tu correo electrónico';

  @override
  String get resetPassword => 'Restablecer contraseña';

  @override
  String get setNewPassword => 'Establecer nueva contraseña';

  @override
  String get createStrongPassword =>
      'Crea una contraseña segura para tu cuenta';

  @override
  String get newPassword => 'Nueva contraseña';

  @override
  String get repeatPassword => 'Repetir contraseña';

  @override
  String get enterPassword => 'Ingresa tu contraseña';

  @override
  String get howToPublishPaidSpaceTitle =>
      '¿Cómo puedo publicar un aparcamiento de pago?';

  @override
  String get howToPublishPaidSpaceDescription =>
      'Para publicar un aparcamiento de pago, debes cumplir con los siguientes requisitos:';

  @override
  String get publishPaidSpaceRequirement1 =>
      'Registrar los datos de tu vehículo en la aplicación, ya que serán necesarios al momento de la reserva.';

  @override
  String get publishPaidSpaceRequirement2 =>
      'Crear una cuenta de beneficios desde tu perfil. Para ello, deberás ingresar tu información fiscal, la cual es obligatoria para recibir pagos en la aplicación conforme a la normativa europea de prevención de lavado de dinero.';

  @override
  String reservationPendingNote(String expiresAt) {
    return 'Si no confirmas el aparcamiento antes de $expiresAt, esta reserva será cancelada y el dinero será reembolsado al solicitante.';
  }

  @override
  String get howToEarnMoneyTitle =>
      '¿Cómo obtengo ganancias por mi aparcamiento de pago?';

  @override
  String get howToEarnMoneyDescription =>
      'Para generar ganancias con tu aparcamiento, este debe ser reservado por otro usuario. Una vez realizada la reserva, deberás confirmar la operación ingresando el código de confirmación que se le proporciona al usuario que reservó. Tras recibir el código, podrás confirmar la reserva.';

  @override
  String get earningsTransferDescription =>
      'Cuando la reserva es confirmada, recibirás el importe correspondiente menos las comisiones aplicadas por LetDem por la operación.';

  @override
  String minutesLeft(Object minutes) {
    return 'Quedan $minutes minutos';
  }

  @override
  String secondsLeft(Object seconds) {
    return 'Quedan $seconds segundos';
  }

  @override
  String get earningsLocationDescription =>
      'El monto total de tus beneficios se reflejará en la sección ganancias de tu perfil.';

  @override
  String get howToWithdrawFundsTitle =>
      '¿Cómo retiro mis fondos a una cuenta personal?';

  @override
  String get howToWithdrawFundsDescription =>
      'Para retirar tus fondos, estos deben ser liberados previamente por el proveedor de pagos. Este proceso suele tardar aproximadamente 10 días. Una vez liberados, los fondos estarán disponibles en la app y podrás retirarlos utilizando una de las cuentas bancarias que hayas asociado previamente.';

  @override
  String get earningsSection => 'Ganancias';

  @override
  String get letdemServiceFees => 'comisiones aplicadas por LetDem';

  @override
  String get helpAndSupport => 'Ayuda y Soporte';

  @override
  String get vehicleInformation => 'datos de tu vehículo';

  @override
  String get earningsAccount => 'Cuenta de beneficios';

  @override
  String get taxInformation => 'Información fiscal';

  @override
  String get paymentProvider => 'Proveedor de pagos';

  @override
  String get pleaseEnterYourNumber => 'Por favor ingresa tu número de teléfono';

  @override
  String get linkedBankAccounts => 'Cuentas bancarias asociadas';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get passwordRequirements =>
      'Asegúrate de usar al menos 8 caracteres, con un número, una letra mayúscula y uno de los siguientes caracteres especiales: \$, ., &, @';

  @override
  String get emailSentTitle => 'Te enviamos un correo';

  @override
  String get emailSentDescription =>
      'Hemos enviado un código a tu correo. Ingrésalo abajo para restablecer tu contraseña.';

  @override
  String get mailSentTo => 'Correo enviado a: ';

  @override
  String get reservations => 'Reservas solicitadas';

  @override
  String get notYou => '¿No eres tú? ';

  @override
  String get changeEmail => 'Cambiar correo';

  @override
  String get didntGetOtp => '¿No recibiste el código? ';

  @override
  String get tapToResend => 'Toca para reenviar.';

  @override
  String resendIn(String seconds) {
    return 'Reenviar en 00:$seconds';
  }

  @override
  String get howToCreateScheduledNotificationsTitle =>
      '¿Cómo crear notificaciones programadas?';

  @override
  String get howToEarnPointsTitle => '¿Cómo ganar Puntos LetDem?';

  @override
  String get publishAlertTitle => 'Publicar una alerta';

  @override
  String get publishAlertDescription =>
      'Si otro usuario confirma la existencia de la alerta.';

  @override
  String get point => 'punto';

  @override
  String get howToEarnPointsDescription =>
      'Gana Puntos LetDem contribuyendo a la comunidad con estas acciones:';

  @override
  String get reservePaidSpaceTitle => 'Reservar un Aparcamiento de Pago';

  @override
  String get reservePaidSpaceDescription =>
      'Para el usuario que reserva y paga un aparcamiento publicado por otro usuario y una vez que la reserva es confirmada.';

  @override
  String get publishFreeSpaceTitle => 'Publicar un Aparcamiento Gratuito';

  @override
  String get publishFreeSpaceDescription =>
      'Si otro usuario lo utiliza y selecciona “Me lo quedo” como valoración al llegar al lugar.';

  @override
  String get additionalNotes => 'Notas Adicionales';

  @override
  String get pointsNote1 =>
      'El usuario que cede un aparcamiento de pago no gana puntos, pero sí gana dinero.';

  @override
  String get pointsNote2 =>
      'En todas las acciones, los puntos se otorgan únicamente si la contribución es útil y confirmada por otro usuario.';

  @override
  String get howToCreateScheduledNotificationsDescription =>
      'Para programar una notificación de aparcamiento, sigue estos pasos:';

  @override
  String get searchDestinationTitle => 'Buscar Destino';

  @override
  String get searchDestinationDescription =>
      'Busca tu destino utilizando la barra de búsqueda en la pantalla principal.';

  @override
  String get selectAddressTitle => 'Seleccionar Dirección';

  @override
  String get selectAddressDescription =>
      'Selecciona la dirección deseada y pulsa el botón \"Avisarme por aparcamientos disponibles\".';

  @override
  String get configureAlertTitle => 'Configurar alerta';

  @override
  String get configureAlertDescription =>
      'Selecciona la franja horaria y la distancia desde tu ubicación para recibir notificaciones.';

  @override
  String get scheduledNotificationsManagement =>
      'Gestiona tus notificaciones desde la sección \'Notificaciones programadas\'.';

  @override
  String get scheduledNotificationsAlert =>
      'Recibirás una notificación cada vez que se publique un aparcamiento dentro del área configurada.';

  @override
  String get createNewAccount => 'CREAR NUEVA CUENTA';

  @override
  String get personalInformation => 'Información personal';

  @override
  String get enterFullName => 'Ingresa tu nombre completo para continuar';

  @override
  String get firstName => 'Nombre';

  @override
  String get lastName => 'Apellido';

  @override
  String get enterFirstName => 'Ingresa tu nombre';

  @override
  String get enterLastName => 'Ingresa tu apellido';

  @override
  String get getStarted => 'Empezar';

  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta? ';

  @override
  String get loginHere => 'Inicia sesión aquí';

  @override
  String get signUpWithGoogle => 'Registrarse con google';

  @override
  String get singInWithGoogle => 'Iniciar sesión con google';

  @override
  String get agreeToTerms => 'Al continuar, acepto los ';

  @override
  String get termsAndConditions => 'Términos y condiciones';

  @override
  String get pleaseAcceptTerms => 'Por favor acepta los términos y condiciones';

  @override
  String get password => 'Contraseña';

  @override
  String get continuee => 'Continuar';

  @override
  String get unableToResendVerification =>
      'No se pudo reenviar el código de verificación';

  @override
  String get somethingWentWrong => 'Algo salió mal';

  @override
  String unableToProcessRequest(String error) {
    return 'No pudimos procesar tu solicitud. Por favor, inténtalo de nuevo más tarde. El error es: $error';
  }

  @override
  String get retry => 'Reintentar';

  @override
  String get sessionExpired =>
      'La sesión ha expirado. Por favor, inicia sesión nuevamente.';

  @override
  String get verifyAccount => 'Verificar cuenta';

  @override
  String get weWillSendOTP => 'Te enviamos un correo';

  @override
  String get verificationInstructions =>
      'Por favor revisa el correo proporcionado para obtener un código de un solo uso y verifica tu correo. Ingrésalo abajo';

  @override
  String get resending => 'Reenviando';

  @override
  String get verificationSuccess => 'Verificación exitosa';

  @override
  String get verificationSuccessMessage =>
      'Tu correo ha sido verificado exitosamente. Puedes proceder a la aplicación.';

  @override
  String get findShareParking =>
      'Encuentra y comparte aparcamientos cerca de ti';

  @override
  String get parkingDescription =>
      'Accede a una amplia gama de aparcamientos dentro y fuera de tu ubicación';

  @override
  String get geolocationPermission => 'Permiso de geolocalización';

  @override
  String get enableGeolocationDescription =>
      'Para mejorar tu experiencia, necesitamos acceder a tu ubicación actual. Esto nos permitirá mostrarte los aparcamientos de estacionamiento más cercanos y relevantes.';

  @override
  String get enableGeolocation => 'Habilitar geolocalización';

  @override
  String get openSettings => 'Abrir configuración';

  @override
  String get notNow => 'No ahora';

  @override
  String get loginToAccount => 'INICIAR SESIÓN EN TU CUENTA';

  @override
  String get welcomeBack => '¡Bienvenido de nuevo!';

  @override
  String get dontHaveAccount => '¿No tienes una cuenta? ';

  @override
  String get signUpHere => 'Regístrate aquí';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get forgotPasswordQuestion => '¿Olvidaste tu contraseña? ';

  @override
  String get resetHere => 'Restablecer aquí';

  @override
  String get next => 'Siguiente';

  @override
  String get goBack => 'Volver';

  @override
  String get connectAccountProgress => 'Progreso de conexión de cuenta';

  @override
  String get identityVerification => 'Verificación de identidad';

  @override
  String get bankInformation => 'Información bancaria';

  @override
  String get addressInformationTitle => 'Tu información de dirección';

  @override
  String get addressInformationDescription =>
      'Ingresa tu dirección completa y ubicación de residencia';

  @override
  String get enterAddress => 'Ingresa tu dirección';

  @override
  String get address => 'Dirección';

  @override
  String get enterPostalCode => 'Ingresa código postal';

  @override
  String get postalCode => 'Código postal';

  @override
  String get enterCity => 'Ingresa ciudad';

  @override
  String get city => 'Ciudad';

  @override
  String get bankInformationTitle => 'Información bancaria';

  @override
  String get bankInformationDescription =>
      'Ingresa tu IBAN para completar este paso';

  @override
  String get enterIBAN => 'Ingresa tu IBAN';

  @override
  String get ibanExample => 'ES00 0000 0000 0000 0000 0000';

  @override
  String get iban => 'IBAN';

  @override
  String get bankAccountNote =>
      'Ten en cuenta que esta cuenta bancaria es necesaria para recibir pagos de nuestro proveedor de pagos.';

  @override
  String get detailsSubmitted => 'Detalles enviados';

  @override
  String get gotItThanks => 'Entendido';

  @override
  String get accountDetailsSuccess =>
      'Los detalles de conexión de su cuenta se enviaron correctamente, pronto podrá recibir dinero por aparcamientos de pago.';

  @override
  String get selectCountry => 'Seleccionar país';

  @override
  String get selectCountryDescription =>
      'Selecciona tu país de residencia para continuar';

  @override
  String get spain => 'España';

  @override
  String get selectCountryLabel => 'Seleccionar país';

  @override
  String get uploadIDCard => 'Subir DNI';

  @override
  String get uploadIDDescription => 'Sube ambos lados de tu DNI';

  @override
  String get uploadIDFront => 'Toca para subir el anverso del DNI';

  @override
  String get uploadIDBack => 'Toca para subir el reverso del DNI';

  @override
  String get imageSizeLimit => 'Solo imágenes soportadas Máx: 2MB';

  @override
  String get frontSideFilename => 'lado-frontal.png';

  @override
  String get backSideFilename => 'lado-posterior.png';

  @override
  String get uploadCompleted => 'Subida completada';

  @override
  String get selectUploadType => 'Seleccionar tipo de subida';

  @override
  String get openCamera => 'Abrir cámara';

  @override
  String get upload => 'Subir';

  @override
  String get pleaseUploadBothSides => 'Por favor sube ambos lados de tu DNI';

  @override
  String get selectIdType => 'Seleccionar tipo de identificación';

  @override
  String get selectIdDescription =>
      'Selecciona tu tipo de identificación y sube el frente y reverso de tu documento';

  @override
  String get nationalIdCard => 'DNI';

  @override
  String get nationalIdDescription =>
      'Tu documento nacional de identidad emitido por el gobierno';

  @override
  String get residentPermit => 'Permiso de residencia';

  @override
  String get residentPermitDescription =>
      'Tu permiso de residencia emitido por el gobierno';

  @override
  String get personalInfoTitle => 'Tu información personal';

  @override
  String get personalInfoDescription =>
      'Ingresa tus datos personales como aparecen en tu DNI';

  @override
  String get phoneNumber => 'Número de teléfono';

  @override
  String get enterPhoneNumber => 'Ingresa número de teléfono';

  @override
  String get dateOfBirth => 'Fecha de nacimiento';

  @override
  String get dateFormat => 'AAAA/MM/DD';

  @override
  String get selectDateOfBirth => 'Por favor selecciona tu fecha de nacimiento';

  @override
  String get clickToOpenCamera => 'Haz clic para abrir la cámara';

  @override
  String get publishPaidSpace => 'Publicar aparcamiento de pago';

  @override
  String get waitingTime => 'Tiempo de espera';

  @override
  String get price => 'Precio';

  @override
  String get enterPrice => 'Ingresa el precio';

  @override
  String get publish => 'Publicar';

  @override
  String waitingTimeTooltip(int min, int max) {
    return 'Este es el tiempo máximo que el publicador puede esperar antes de salir. El tiempo debe estar entre $min y $max minutos. Una vez transcurrido este tiempo, el aparcamiento publicado expirará.';
  }

  @override
  String get activeReservationExists =>
      'Hay una reserva activa en tu cuenta. Debe completarse o cancelarse antes de que puedas publicar un nuevo aparcamiento de pago.';

  @override
  String get whatIsThisWaitingTime => '¿En qué consiste?';

  @override
  String get fetchingLocation => 'Obteniendo ubicación...';

  @override
  String pendingFundsInfo(String minAmount, String maxAmount) {
    return 'Puedes retirar entre $minAmount y $maxAmount. Los fondos retenidos por el proveedor de pagos estarán disponibles en un plazo máximo de 10 días.';
  }

  @override
  String minWithdrawalAmountError(Object amount) {
    return 'Debes tener al menos $amount para retirar.';
  }

  @override
  String maxWithdrawalAmountError(Object amount) {
    return 'No puedes retirar más de $amount a la vez.';
  }

  @override
  String minWithdrawalToast(Object amount) {
    return 'La cantidad mínima que puedes retirar es $amount.';
  }

  @override
  String maxWithdrawalToast(Object amount) {
    return 'La cantidad máxima que puedes retirar es $amount.';
  }

  @override
  String get exceedsBalanceToast =>
      'No puedes retirar más que tu saldo disponible.';

  @override
  String timeToWaitMustBeBetween(String min, String max) {
    return 'El tiempo de espera debe estar entre $min y $max minutos.';
  }

  @override
  String closeToLocationDescription(int distance) {
    return 'Estás muy cerca de esta ubicación (a menos de $distance metros). Por favor, elige un lugar un poco más alejado.';
  }

  @override
  String priceMustBeBetween(String min, String max) {
    return 'El precio debe estar entre $min y $max.';
  }

  @override
  String get pleaseEnterAllFields => 'Por favor completa todos los campos';

  @override
  String get spacePublishedSuccesfully => 'Aparcamiento publicado exitosamente';

  @override
  String get spacePublishedDescription =>
      'Tu aparcamiento ha sido publicado exitosamente, las personas ahora pueden tener acceso para usar el aparcamiento.';

  @override
  String get speedLimitAlert => 'Alerta de límite de velocidad';

  @override
  String get speedLimitWarning =>
      'Estás conduciendo al límite de velocidad, reduce la velocidad';

  @override
  String get kmPerHour => 'Km/h';

  @override
  String get speedLimit => 'Límite de velocidad';

  @override
  String get codeConfirmation => 'Código';

  @override
  String get routeDeviationDetected => 'Desviación de ruta detectada';

  @override
  String get recalculatingRoute => 'Recalculando ruta...';

  @override
  String get youHaveArrived => '¡Has llegado a tu destino!';

  @override
  String get navigatingToParking =>
      'Navegando al aparcamiento de estacionamiento';

  @override
  String get preparingNavigation => 'Preparando tu navegación...';

  @override
  String get navigationError =>
      'No se pudo calcular la ruta. Por favor, inténtalo de nuevo.';

  @override
  String get tryAgain => 'Intentar de nuevo';

  @override
  String get fatigueAlertTitle => 'Alerta de fatiga';

  @override
  String get fatigueAlertMessage =>
      'Has estado conduciendo durante 3 horas. Por favor considera tomar un descanso.';

  @override
  String get fatigueAlertVoice =>
      'Has estado conduciendo durante tres horas. Por favor toma un descanso.';

  @override
  String get addEvent => 'Agregar alerta';

  @override
  String get ahead => 'por delante';

  @override
  String get navigateToSpaceButton => 'Navegar al aparcamiento';

  @override
  String get locationPermissionDenied => 'Permiso de ubicación denegado';

  @override
  String get locationPermissionDeniedPermanently =>
      'Permisos de ubicación denegados permanentemente, por favor habilítalos en configuración';

  @override
  String get failedToLoadMap => 'Error al cargar el mapa';

  @override
  String get failedToInitializeLocation =>
      'Error al inicializar los servicios de ubicación';

  @override
  String get failedToInitNavigation => 'Error al inicializar la navegación';

  @override
  String get failedToStartNavigation =>
      'Error al iniciar la visualización de navegación';

  @override
  String get freeCameraMode => 'Cámara libre';

  @override
  String get lockPositionMode => 'Bloquear posición';

  @override
  String get cameraAlertTitle => 'Alerta de cámara';

  @override
  String get radarAlertTitle => 'Alerta de radar';

  @override
  String get cameraAlertMessage =>
      'Estás en una zona de vigilancia con cámaras CCTV';

  @override
  String get radarAlertMessage => 'Te estás acercando a una zona con radar';

  @override
  String get unnamedRoad => 'Calle sin nombre';

  @override
  String get couldNotRecalculateRoute => 'No se pudo recalcular la ruta';

  @override
  String get noPaymentsYet => 'Aún no hay pagos';

  @override
  String get noPaymentsDescription => 'Tu historial de pagos aparecerá aquí.';

  @override
  String get tooCloseToLocation => 'Demasiado cerca de la ubicación';

  @override
  String get close => 'Cerrar';

  @override
  String get trafficLevel => 'Tráfico';

  @override
  String toArriveBy(String time) {
    return 'Para llegar a las $time';
  }

  @override
  String get notifyAvailableSpace =>
      'Notificarme de aparcamientos disponibles en esta área';

  @override
  String get dateAndTime => 'Fecha y Hora';

  @override
  String get paid => 'Pago';

  @override
  String get cancelled => 'Cancelado';

  @override
  String get refunded => 'Reembolsado';

  @override
  String get notificationRadius => 'Recibir notificaciones hasta (metros)';

  @override
  String get startRoute => 'Iniciar ruta';

  @override
  String radiusLessThan(int meters) {
    return 'El radio no puede ser menor a $meters metros';
  }

  @override
  String get notificationScheduled => 'Notificación programada';

  @override
  String get notificationScheduledDescription =>
      'Se te notificará cuando haya un aparcamiento disponible en esta área';

  @override
  String get minutesShort => 'min';

  @override
  String get hoursShort => 'hrs';

  @override
  String get metersShort => 'm';

  @override
  String get kilometersShort => 'km';

  @override
  String get timesRequired => 'Las horas de inicio y fin son requeridas';

  @override
  String get startBeforeEnd =>
      'La hora de inicio debe ser anterior a la hora de fin';

  @override
  String get timeGreaterThanCurrent =>
      'Las horas de inicio y fin deben ser posteriores a la hora actual';

  @override
  String get maxScheduleDays => 'Solo puedes programar hasta 5 días';

  @override
  String distanceTraveled(int distance) {
    return 'Distancia recorrida: $distance m';
  }

  @override
  String youHaveTraveled(int distance) {
    return 'Has recorrido $distance metros';
  }

  @override
  String estimatedArrival(String time, int distance) {
    return 'Llegada estimada en $time con $distance metros restantes';
  }

  @override
  String seconds(int count) {
    return '$count segundos';
  }

  @override
  String minutesAndSeconds(int minutes, int seconds) {
    return '$minutes min $seconds seg';
  }

  @override
  String minutesOnly(int minutes) {
    return '$minutes minutos';
  }

  @override
  String hoursAndMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String hoursOnly(int hours) {
    return '$hours horas';
  }

  @override
  String get locationPermissionPermanentlyDenied =>
      'Permisos de ubicación denegados permanentemente, habilítalos en la configuración';

  @override
  String get failedToInitializeLocationServices =>
      'Error al inicializar los servicios de ubicación';

  @override
  String get failedToGetCurrentLocation =>
      'Error al obtener la ubicación actual';

  @override
  String get failedToStartNavigationSimulation =>
      'Error al iniciar la simulación de navegación';

  @override
  String get failedToInitializeRouting =>
      'Error al inicializar el enrutamiento';

  @override
  String get couldNotCalculateRoute =>
      'No se pudo calcular la ruta. Por favor, inténtelo de nuevo.';

  @override
  String get failedToInitializeNavigation =>
      'Error al inicializar la navegación';

  @override
  String metersAhead(int distance) {
    return '$distance metros por delante';
  }

  @override
  String get preparingYourNavigation => 'Preparando tu navegación...';

  @override
  String metersAway(String distance) {
    return '$distance de distancia';
  }

  @override
  String get gotItThankYou => 'Entendido';

  @override
  String get feedbackButton => 'Comentarios';

  @override
  String get feedbackSubmitted => 'Tu comentario ha sido enviado';

  @override
  String get thankYouForInput => '¡Gracias por tu aporte!';

  @override
  String get eventFeedback => 'Comentarios sobre la alerta';

  @override
  String get stillThere => 'Todavía está ahí';

  @override
  String get notThere => 'Ya no está ahí';

  @override
  String get illTakeIt => 'Me lo quedo';

  @override
  String get itsInUse => 'Ocupado';

  @override
  String get notUseful => 'No me sirve';

  @override
  String get prohibited => 'Prohibido';

  @override
  String get unableToLogin => 'No se pudo iniciar sesión';

  @override
  String get unableToRegister => 'No se pudo registrar';

  @override
  String get unableToVerifyEmail =>
      'No se pudo verificar el correo electrónico';

  @override
  String get unableToResetPassword => 'No se pudo restablecer la contraseña';

  @override
  String get unableToValidateReset => 'No se pudo validar la contraseña';

  @override
  String get unableToFindAccount =>
      'No se pudo encontrar la cuenta de recuperación';

  @override
  String get unableToResendCode => 'No se pudo reenviar el código';

  @override
  String get arrivedAtDestination => 'Has llegado a tu destino.';

  @override
  String get rateThisParkingSpace => '¿Cómo calificarías este aparcamiento?';

  @override
  String get customNavigation => 'Navegación personalizada';

  @override
  String get startButton => 'Iniciar';

  @override
  String get stopButton => 'Detener';

  @override
  String get toggleButton => 'Cambiar';

  @override
  String get colorButton => 'Color';

  @override
  String get unread => 'No leídas';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get yourSpaceLocatedAt => 'Tu aparcamiento ubicado en ';

  @override
  String get hasBeenOccupied => ' ha sido ocupado';

  @override
  String get aNewSpaceHasBeenPublished =>
      'Se ha publicado un nuevo aparcamiento dentro de ';

  @override
  String get around => ' alrededor de ';

  @override
  String get hasBeenReserved => ' ha sido reservado';

  @override
  String get receivedPositiveFeedback => ' Recibió comentarios positivos';

  @override
  String get noNotificationsYet => 'Aún no hay notificaciones';

  @override
  String get notificationsWillAppear =>
      'Las notificaciones de la aplicación aparecerán aquí\ncuando haya una nueva actividad';

  @override
  String get noScheduledNotificationsYet =>
      'Aún no hay notificaciones programadas';

  @override
  String get scheduledNotificationsWillAppear =>
      'Las notificaciones programadas aparecerán\naquí cuando configures este recordatorio';

  @override
  String get justNow => 'Ahora mismo';

  @override
  String get viewSpace => 'Ver aparcamiento';

  @override
  String get noPaymentMethodsAdded => 'No se han añadido métodos de pago';

  @override
  String get noPaymentMethodsDescription =>
      'Aún no has añadido ningún método de pago.\nAñade uno para realizar pagos fácilmente.';

  @override
  String get paymentMethodAdded => 'Método de pago añadido';

  @override
  String get paymentMethodAddedDescription =>
      'Tu método de pago ha sido agregado correctamente.';

  @override
  String get pleaseCompleteCardDetails =>
      'Por favor completa los detalles de la tarjeta';

  @override
  String get failedToAddPaymentMethod =>
      'Error al agregar método de pago. Por favor, inténtalo de nuevo.';

  @override
  String get cardNumber => 'Número de tarjeta';

  @override
  String get addNewCard => 'Agregar nueva tarjeta';

  @override
  String get defaultt => 'Por defecto';

  @override
  String expireDate(String date) {
    return 'Fecha de vencimiento: $date';
  }

  @override
  String get paymentMethod => 'Método de pago';

  @override
  String get makeDefault => 'Establecer como predeterminado';

  @override
  String get confirmDeleteCard => 'Confirmar eliminación de tarjeta';

  @override
  String deleteCardConfirmation(String last4) {
    return '¿Estás seguro de que quieres eliminar la tarjeta que termina en $last4? Esta acción no se puede deshacer.';
  }

  @override
  String get noKeepCard => 'No, mantener tarjeta';

  @override
  String get yesDeleteCard => 'Sí, eliminar tarjeta';

  @override
  String get noPayoutMethodsYet => 'Aún no hay métodos de pago';

  @override
  String get payoutMethodsDescription =>
      'Tus métodos de pago añadidos aparecerán\naquí una vez que los configures en tu perfil';

  @override
  String get payoutMethodAdded => 'Método de pago añadido';

  @override
  String get payoutMethodAddedDescription =>
      'Tu método de pago ha sido agregado correctamente.';

  @override
  String get addPayoutMethod => 'Añadir cuenta bancaria';

  @override
  String get accountNumber => 'Número de cuenta';

  @override
  String get accountNumberExample => 'ES00 0000 0000 0000 0000 0000';

  @override
  String get makeDefaultPaymentMethod =>
      'Establecer como método de pago predeterminado';

  @override
  String get pleaseEnterAccountNumber =>
      'Por favor ingresa el número de cuenta';

  @override
  String get payoutMethods => 'Cuentas bancarias';

  @override
  String get payoutMethodOptions => 'Opciones de cuenta bancaria';

  @override
  String get rescheduleNotification => 'Reprogramar notificación';

  @override
  String get reschedule => 'Reprogramar';

  @override
  String get notificationRescheduledSuccessfully =>
      'Notificación reprogramada correctamente';

  @override
  String get spaceReminder => 'Recordatorio de aparcamiento';

  @override
  String get rescheduleReminder => 'Reprogramar recordatorio';

  @override
  String get deleteReminder => 'Eliminar recordatorio';

  @override
  String get youHaveReminderForSpace =>
      'Tienes un recordatorio para un aparcamiento en ';

  @override
  String get expired => 'Expirado';

  @override
  String get active => 'Activo';

  @override
  String get activeMayus => 'Activo';

  @override
  String get antiMoneyLaunderingMessage =>
      'La Directiva Antiblanqueo de Capitales (UE) 2015/849 nos obliga a verificar tu identidad para que puedas recibir pagos por tus ventas en línea. Solo tendrás que verificarte una vez.';

  @override
  String get couldNotOpenTermsAndConditions =>
      'No se pudo abrir el enlace de Términos y Condiciones';

  @override
  String get byAgreementStripe => 'Al continuar, acepto el ';

  @override
  String get stripeConnectedAccountAgreement =>
      'Acuerdo de cuenta conectada de Stripe';

  @override
  String get and => ' y ';

  @override
  String get stripeTermsOfService => 'Términos de Servicio de Stripe';

  @override
  String get accountInformationChanged =>
      'Información de cuenta cambiada correctamente';

  @override
  String get accountInformationChangedDescription =>
      'La información de tu cuenta ha sido cambiada correctamente,';

  @override
  String get orders => 'Reservas';

  @override
  String get errorLoadingOrders => 'Error al cargar pedidos';

  @override
  String get confirmed => 'Confirmado';

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';

  @override
  String daysAgo(int days) {
    return 'hace $days días';
  }

  @override
  String get oneWeekAgo => 'hace 1 semana';

  @override
  String get twoWeeksAgo => 'hace 2 semanas';

  @override
  String get threeWeeksAgo => 'hace 3 semanas';

  @override
  String get noOrdersYet => 'Aún no hay reservas';

  @override
  String get noOrdersDescription =>
      'Aún no has realizado ningún pedido.\n¡Comienza a explorar y haz tu primer pedido!';

  @override
  String get alerts => 'Alertas';

  @override
  String get emailNotifications => 'Notificaciones por correo';

  @override
  String get pushNotifications => 'Notificaciones móviles';

  @override
  String get availableSpaces => 'Aparcamientos disponibles';

  @override
  String get radarAlerts => 'Alertas de radar';

  @override
  String get cameraAlerts => 'Alertas de cámara';

  @override
  String get prohibitedZoneAlert => 'Alerta de zona prohibida';

  @override
  String get fatigueAlert => 'Alerta de fatiga';

  @override
  String get policeAlert => 'Alerta de policía';

  @override
  String get accidentAlert => 'Alerta de accidente';

  @override
  String get roadClosedAlert => 'Alerta de carretera cerrada';

  @override
  String get nameNotProvided => 'Nombre no proporcionado';

  @override
  String get letdemPoints => 'Puntos LetDem';

  @override
  String get walletBalance => 'Saldo en cartera';

  @override
  String get withdraw => 'Retirar';

  @override
  String get withdrawals => 'Retiradas';

  @override
  String get payouts => 'Bancos';

  @override
  String get transactionHistory => 'Últimas transacciones';

  @override
  String get transactionTitle => 'Transacciones';

  @override
  String get fromDate => 'Desde';

  @override
  String get toDate => 'Hasta';

  @override
  String get seeAll => 'Ver todo';

  @override
  String get noTransactionsYet => 'Todavía no hay transacciones';

  @override
  String get transactionsHistoryMessage =>
      'Tu historial de transacciones aparecerá aquí cuando tengas alguna para mostrar.';

  @override
  String get loadingTransactions => 'Cargando transacciones';

  @override
  String get noPayoutMethodsAvailable => 'No hay métodos de pago disponibles';

  @override
  String get success => 'Éxito';

  @override
  String get withdrawalRequestSuccess =>
      'La solicitud de retiro ha sido enviada correctamente.';

  @override
  String withdrawalToBank(String method) {
    return 'Retiro al banco $method';
  }

  @override
  String get successful => 'Exitoso';

  @override
  String get failed => 'Fallido';

  @override
  String get noWithdrawalsYet => 'Aún no hay retiradas';

  @override
  String get withdrawalHistoryMessage =>
      'Tu historial de retiradas aparecerá aquí\ncuando realices un retiro';

  @override
  String amountCannotExceed(String balance) {
    return 'El monto no puede exceder $balance €';
  }

  @override
  String get amountToReceive => 'Monto a recibir';

  @override
  String pendingToBeCleared(String amount) {
    return '$amount € Pendiente de liberar';
  }

  @override
  String get paymentMethodAddedTitle => 'Método de pago añadido';

  @override
  String get paymentMethodAddedSubtext =>
      'Tu método de pago ha sido agregado correctamente.';

  @override
  String get addPaymentMethodTitle => 'Agregar método de pago';

  @override
  String get cardDetails => 'Detalles de la tarjeta';

  @override
  String get enterTheNumber => 'Ingresa el número';

  @override
  String get create => 'Crear';

  @override
  String get pleaseEnterYourName => 'Por favor ingresa tu nombre';

  @override
  String get paymentSuccessfulReservation =>
      'Tu pago se ha realizado con éxito. El aparcamiento ya está reservado.';

  @override
  String get paymentFailedRequiresAction =>
      'El pago falló o requiere acción adicional';

  @override
  String get defaultCardTagline =>
      'LetDem te desea que disfrutes de tu compra.';

  @override
  String get connectionPending => 'Conexión pendiente';

  @override
  String get connectionPendingMessage =>
      'La conexión de tu cuenta aún está pendiente, serás notificado cuando la conexión esté completa';

  @override
  String get somethingWentWrongGeneric => 'Algo salió mal';

  @override
  String get contactSupportMessage =>
      'Parece que hay un problema con tu cuenta. Por favor contacta con soporte para asistencia.';

  @override
  String get insufficientBalance => 'No tienes suficiente saldo para retirar';

  @override
  String get loading => 'Cargando...';

  @override
  String get continueButton => 'Continuar';

  @override
  String get error => 'Error';

  @override
  String get warning => 'Advertencia';

  @override
  String get confirmation => 'Confirmación';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get successGeneric => 'Éxito';

  @override
  String get errorOccurred => 'Ocurrió un error';

  @override
  String get pleaseTryAgain => 'Por favor inténtalo de nuevo';

  @override
  String get reservationConfirmedTitle => 'Reserva confirmada';

  @override
  String get reservationConfirmedDescription =>
      'Tu reserva ha sido confirmada correctamente, actualizaremos tu saldo en breve.';

  @override
  String get reservationCancelledOwnerTitle => 'Reserva cancelada';

  @override
  String get reservationCancelledOwnerDescription =>
      'Ahora procedemos a la devolución del importe completo de la reserva al solicitante.';

  @override
  String get reservationCancelledRequesterTitle => 'Reserva cancelada';

  @override
  String get reservationCancelledRequesterDescription =>
      'Ahora procedemos a la devolución del importe completo de la reserva a tu cuenta bancaria.';

  @override
  String get networkError => 'Error de red';

  @override
  String get published => 'Publicado';

  @override
  String get activeStatus => 'Activo';

  @override
  String get minsAgo => 'min atrás';

  @override
  String get hoursAgo => 'horas atrás';

  @override
  String priceTooltip(String max, String min) {
    return 'Este es el precio de una plaza de aparcamiento. El precio máximo que puedes establecer es $max y el mínimo es $min.';
  }

  @override
  String get myLocation => 'Mi ubicación';

  @override
  String get requester => 'Solicitante';

  @override
  String get trackingLocation => 'Rastreando Ubicación';

  @override
  String get waitingForLocation => 'Esperando ubicación...';

  @override
  String get currentLocation => 'Ubicación actual';

  @override
  String get carPlate => 'Matrícula';

  @override
  String get tracking => 'Rastreando';

  @override
  String get zoomIn => 'Acercar';

  @override
  String get zoomOut => 'Alejar';

  @override
  String get toggleView => 'Cambiar vista';

  @override
  String get newNotification => 'Nueva notificación';

  @override
  String get tapToView => 'Toca para ver';

  @override
  String get markAsRead => 'Marcar como leído';

  @override
  String get invalidCredentials => 'Credenciales inválidas';

  @override
  String get checkInternetConnection =>
      'Por favor verifica tu conexión a internet';

  @override
  String get loginFailed => 'Error al iniciar sesión';

  @override
  String get registrationSuccessful => 'Registro exitoso';

  @override
  String get accountCreated => 'Cuenta creada';

  @override
  String get welcomeToLetdem => 'Bienvenido a LetDem';

  @override
  String get searchHere => 'Buscar aquí...';

  @override
  String get noResultsFound => 'No se encontraron resultados';

  @override
  String get recentSearches => 'Búsquedas recientes';

  @override
  String get clearHistory => 'Limpiar historial';

  @override
  String get carRegisteredSuccessfully => 'Coche registrado exitosamente';

  @override
  String get invalidPlateNumber => 'Matrícula inválida';

  @override
  String get selectValidCarType =>
      'Por favor selecciona un tipo de coche válido';

  @override
  String get accountSetupComplete => 'Configuración de cuenta completa';

  @override
  String get verificationPending => 'Verificación pendiente';

  @override
  String get documentsUploadedSuccessfully => 'Documentos subidos exitosamente';

  @override
  String get defaultPayment => 'Por defecto';

  @override
  String get expires => 'Expira';

  @override
  String get logoutConfirmation =>
      '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get deleteCard => 'Eliminar tarjeta';

  @override
  String get setAsDefault => 'Establecer como predeterminado';

  @override
  String get bankAccount => 'Cuenta bancaria';

  @override
  String get verified => 'Verificado';

  @override
  String get pendingVerification => 'Verificación pendiente';

  @override
  String get primary => 'Principal';

  @override
  String get gpsDisabled => 'GPS deshabilitado';

  @override
  String get unableToGetLocation => 'No se pudo obtener ubicación';

  @override
  String get locationServicesUnavailable =>
      'Servicios de ubicación no disponibles';

  @override
  String get noInternetConnection => 'Sin conexión a internet';

  @override
  String get connectionTimeout => 'Tiempo de espera de conexión agotado';

  @override
  String get serverError => 'Error del servidor';

  @override
  String get requestFailed => 'Falló la solicitud';

  @override
  String get invalidEmailFormat => 'Formato de email inválido';

  @override
  String get passwordTooShort => 'Contraseña muy corta';

  @override
  String get fieldRequired => 'Campo requerido';

  @override
  String get invalidPhoneNumber => 'Número de teléfono inválido';

  @override
  String get todayDate => 'Hoy';

  @override
  String get yesterdayDate => 'Ayer';

  @override
  String get tomorrowDate => 'Mañana';

  @override
  String get justNowTime => 'Ahora mismo';

  @override
  String get minuteAgo => 'minuto atrás';

  @override
  String get minutesAgoTime => 'minutos atrás';

  @override
  String get hourAgo => 'hora atrás';

  @override
  String get hoursAgoTime => 'horas atrás';

  @override
  String get dayAgo => 'día atrás';

  @override
  String get daysAgoTime => 'días atrás';

  @override
  String get weekAgo => 'semana atrás';

  @override
  String get weeksAgo => 'semanas atrás';

  @override
  String get monthAgo => 'mes atrás';

  @override
  String get monthsAgo => 'meses atrás';

  @override
  String get paymentReceived => 'Pago recibido';

  @override
  String get withdrawalProcessed => 'Retiro procesado';

  @override
  String get refundIssued => 'Reembolso emitido';

  @override
  String get transactionFailed => 'Transacción falló';

  @override
  String get securitySettings => 'Configuración de seguridad';

  @override
  String get changePassword => 'Cambiar contraseña';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get deleteAccountConfirmation =>
      '¿Estás seguro de que quieres eliminar tu cuenta? Esta acción no se puede deshacer.';

  @override
  String get pleaseEnterYourPhoneNumber =>
      'Por favor ingrese su número de teléfono';

  @override
  String get monthJan => 'Ene';

  @override
  String get monthFeb => 'Feb';

  @override
  String get monthMar => 'Mar';

  @override
  String get monthApr => 'Abr';

  @override
  String get monthMay => 'May';

  @override
  String get monthJun => 'Jun';

  @override
  String get monthJul => 'Jul';

  @override
  String get monthAug => 'Ago';

  @override
  String get monthSep => 'Sep';

  @override
  String get monthOct => 'Oct';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthDec => 'Dic';

  @override
  String get faqTitle => 'FAQ';

  @override
  String get faqPublishPaidSpaceQuestion =>
      '¿Cómo puedo publicar un aparcamiento de pago?';

  @override
  String get faqPublishPaidSpaceAnswer =>
      'Para publicar un aparcamiento de pago, debes cumplir con los siguientes requisitos:\n\n• Registrar los datos de tu vehículo en la aplicación, ya que serán necesarios al momento de la reserva.\n• Crear una cuenta de beneficios desde tu perfil. Para ello, deberás ingresar tu información fiscal, la cual es obligatoria para recibir pagos en la aplicación conforme a la normativa europea de prevención de lavado de dinero.';

  @override
  String get faqEarnMoneyQuestion =>
      '¿Cómo obtengo ganancias por mi aparcamiento de pago?';

  @override
  String get faqEarnMoneyAnswer =>
      'Para generar ganancias con tu aparcamiento, este debe ser reservado por otro usuario. Una vez realizada la reserva, deberás confirmar la operación ingresando el código de confirmación que se le proporciona al usuario que reservó. Tras recibir el código, podrás confirmar la reserva.\n\nCuando la reserva es confirmada, recibirás el importe correspondiente menos las comisiones aplicadas por LetDem por la operación.\n\nEl monto total de tus ganancias se reflejará en la sección \"Ganancias\" de tu perfil.';

  @override
  String get faqWithdrawFundsQuestion =>
      '¿Cómo retiro mis fondos a una cuenta personal?';

  @override
  String get faqWithdrawFundsAnswer =>
      'Para retirar tus fondos, estos deben ser liberados previamente por el proveedor de pagos. Este proceso suele tardar aproximadamente 10 días. Una vez liberados, los fondos estarán disponibles en la app y podrás retirarlos utilizando una de las cuentas bancarias que hayas asociado previamente.';

  @override
  String get helpLetDemPointsTitle => '¿Cómo ganar Puntos LetDem?';

  @override
  String get helpLetDemPointsReserveTitle => 'Reservar un aparcamiento de pago';

  @override
  String get helpLetDemPointsReserveDescription =>
      'para el usuario que reserva y paga un aparcamiento publicado por otro usuario y una vez que la reserva es confirmada mediante el código de confirmación.';

  @override
  String get helpLetDemPointsPublishTitle =>
      'Publicar un aparcamiento gratuito';

  @override
  String get helpLetDemPointsPublishDescription =>
      'Si otro usuario lo utiliza y selecciona \"Me lo quedo\" como valoración al llegar al lugar.';

  @override
  String get helpLetDemPointsAlertTitle =>
      'Publicar una alerta (Policía, Vía cortada, Accidente)';

  @override
  String get helpLetDemPointsAlertDescription =>
      'Si otro usuario confirma la existencia de la alerta.';

  @override
  String get helpLetDemPointsAdditionalNotesTitle => 'Notas adicionales';

  @override
  String get helpLetDemPointsAdditionalNote1 =>
      '• El usuario que cede un aparcamiento de pago no gana puntos, pero sí gana dinero.';

  @override
  String get helpLetDemPointsAdditionalNote2 =>
      '• En todas las acciones, los puntos se otorgan únicamente si la contribución es útil y confirmada por otro usuario.';

  @override
  String get helpScheduledNotificationsTitle =>
      '¿Cómo crear notificaciones programadas de aparcamientos?';

  @override
  String get helpScheduledNotificationsIntro =>
      'Para programar una notificación de aparcamiento:';

  @override
  String get helpScheduledNotificationsStep1 =>
      'Busca tu destino utilizando la barra de búsqueda en la pantalla principal.';

  @override
  String get helpScheduledNotificationsStep2 =>
      'Selecciona la dirección deseada y pulsa el botón \"Avisarme por aparcamientos disponibles\".';

  @override
  String get helpScheduledNotificationsStep3 =>
      'Configura la alerta seleccionando:';

  @override
  String get helpScheduledNotificationsStep3Detail1 =>
      '• La franja horaria en la que deseas recibir notificaciones.';

  @override
  String get helpScheduledNotificationsStep3Detail2 =>
      '• La distancia en metros desde la ubicación seleccionada que se debe considerar como área de notificación.';

  @override
  String get helpScheduledNotificationsInfo1 =>
      'Una vez creada la alerta, podrás gestionarla desde tu perfil, en la sección \"Notificaciones programadas\", donde verás todas tus alertas activas o expiradas.';

  @override
  String get helpScheduledNotificationsInfo2 =>
      'Siempre que se publique un aparcamiento dentro del área configurada, recibirás una notificación para que puedas dirigirte rápidamente al lugar.';

  @override
  String get unhandledError => 'Unhandled error';

  @override
  String get paymentFailed => 'Payment failed';

  @override
  String get changePaymentMethod => 'Cambiar método de pago';

  @override
  String get paymentFailedDescription =>
      'La reserva falló porque el pago no se procesó correctamente';

  @override
  String get errorReserveSpaceDescription =>
      'Por favor, inténtalo de nuevo más tarde. Si el problema persiste, contacta con soporte.';

  @override
  String speedLimitVoiceAlert(String speedLimit) {
    return 'El límite de velocidad es $speedLimit kilómetros por hora';
  }

  @override
  String get waitingForNavigation => 'Esperando a que inicie la navegación...';

  @override
  String get locationNotAvailable => 'Ubicación no disponible';

  @override
  String get stops => 'Paradas';

  @override
  String get onTheWay => 'En camino...';

  @override
  String get completed => 'Completada';

  @override
  String get current => 'Actual';

  @override
  String get addAnotherStop => 'Añadir otra parada';

  @override
  String get addStop => 'Añadir parada';

  @override
  String get searchStop => 'Buscar parada...';

  @override
  String get customStop => 'Parada personalizada';

  @override
  String get stopAddedToRoute => 'Parada añadida a la ruta';

  @override
  String get changeRoute => 'Cambiar ruta';

  @override
  String arrivedAtStop(String stopName) {
    return 'Llegaste a parada: $stopName';
  }

  @override
  String get purchaseHistory => 'Historial de compras';

  @override
  String get pendingCards => 'Tarjetas pendientes';

  @override
  String get generateCard => 'Generar tarjeta';

  @override
  String get transactionsHistory => 'Historial de transacciones';

  @override
  String get buy => 'Comprar';

  @override
  String get finalDestination => 'destino final';

  @override
  String get arrivedAtYourStop => '¡Llegaste a tu parada!';

  @override
  String get continueToNextStop => 'Continuar a siguiente parada';

  @override
  String get goToFinalDestination => 'Ir a destino final';

  @override
  String get findParking => 'Buscar estacionamiento';

  @override
  String canSearchParkingOrContinueTo(String destination) {
    return 'Puedes buscar estacionamiento disponible en el mapa o continuar a $destination';
  }

  @override
  String get noMoreRouteOptions =>
      'No se encontraron más opciones de ruta disponibles.';

  @override
  String get alternativeRoutes => 'Rutas alternativas';

  @override
  String get enterValidAmount => 'Introduce una cantidad válida.';

  @override
  String get moneySentSuccessfully => 'Dinero enviado correctamente';

  @override
  String moneySentDescription(Object amount, Object alias) {
    return 'Has enviado $amount € a $alias.';
  }

  @override
  String get sendMoney => 'Enviar dinero';

  @override
  String get recipientAlias => 'Alias del destinatario';

  @override
  String get enterRecipientAlias => 'Introduce el alias del destinatario';

  @override
  String get amountToSend => 'Cantidad a enviar';

  @override
  String get alias => 'Alias';

  @override
  String get enterAlias =>
      'Elige un alias para que otros usuarios te envíen dinero';

  @override
  String get brandModel => 'Marca / modelo del coche';

  @override
  String get licensePlate => 'Matrícula';

  @override
  String get noVehicleRegistered => 'No hay ningún vehículo registrado';

  @override
  String get sendMoneyTitle => 'Enviar dinero desde tu monedero';

  @override
  String get sendMoneySubtitle =>
      'Transfiere dinero al instante a otro usuario de LetDem usando su alias.';

  @override
  String get sendMoneyWarning =>
      'Revisa bien el alias y la cantidad antes de enviar. Las transferencias no se pueden revertir.';
}
