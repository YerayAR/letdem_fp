class ErrorMessageHelper {
  static String getMessage(String code,
      {bool isSpanish = false, String serverMessage = ""}) {
    final messages = isSpanish ? _spanishMessages : _englishMessages;

    if (messages.containsKey(code)) {
      return '${messages[code]!} $serverMessage';
    } else {
      if (serverMessage.isNotEmpty) {
        return serverMessage;
      }
      return 'An unexpected error occurred. Please try again later.';
    }
  }

  static const Map<String, String> _englishMessages = {
    // Accounts
    'INVALID_CREDENTIALS': 'Invalid credentials. Please try again.',
    'INVALID_CURRENT_PASSWORD': 'The current password is incorrect.',
    'REPEATED_PASSWORD': 'New password cannot be the same as the old password.',
    'INACTIVE_ACCOUNT': 'Your account is inactive.',
    'EMAIL_ALREADY_EXISTS': 'This email is already registered.',
    'INVALID_SOCIAL_TOKEN': 'Invalid social login token.',
    'card_declined':
        'Your card was declined. Please check your payment details.',
    'INVALID_OTP': 'Invalid OTP code.',
    'ACCOUNT_ALREADY_ACTIVATED': 'Account is already activated.',
    'BALANCE_LOWER_THAN_MINIMUM':
        'Your balance is below the minimum payout threshold.',
    'EMAIL_NOT_FOUND': 'Email address not found.',
    'OTP_NOT_VALIDATED': 'OTP has not been validated.',
    'CAR_ALREADY_CREATED': 'You have already added a car.',
    'USER_DOES_NOT_HAVE_CAR': 'No car is associated with this user.',
    'SOCIAL_USER_CANNOT_RESET_PASSWORD':
        'Password reset is not allowed for social login users.',
    'ENDS_TIME_SHOULD_BE_GREATER': 'End time must be greater than start time.',
    'ENDS_AND_START_TIME_SHOULD_BE_GREATER_THAN_NOW':
        'Start and end time must be in the future.',
    'NOTIFICATION_ALREADY_SCHEDULED_IN_PLACE':
        'A notification is already scheduled for this place.',

    // Credits
    'EARNING_ACCOUNT_ALREADY_EXISTS': 'Earning account already exists.',
    'EARNING_ACCOUNT_REQUIRED': 'Earning account is required.',
    'EARNING_ACCOUNT_IS_NOT_ACCEPTED': 'Earning account is not accepted.',
    'COUNTRY_NOT_SUPPORTED': 'This country is not supported.',
    'BAD_REQUEST_FOR_CURRENT_STEP': 'Invalid request for the current step.',
    'INVALID_ADDRESS_COUNTRY': 'The address country is invalid.',
    'INVALID_PAYOUT_METHOD_FOR_ACCOUNT_COUNTRY':
        'This payout method is not available in your country.',
    'PAYMENT_METHOD_NOT_FOUND': 'Payment method not found.',
    'PAYMENT_METHOD_ALREADY_EXISTS': 'Payment method already exists.',
    'PAYOUT_METHOD_NOT_FOUND': 'Payout method not found.',
    'PAYMENT_REQUIRES_ACTION':
        'Payment requires additional action. Please check your payment method.',
    'PAYMENT_FAILED': 'Payment failed. Please try again later.',

    // Events
    'EVENT_PUBLICATION_ERROR': 'An error occurred while publishing the event.',
    'EVENT_NOT_FUND': 'Event not found.',
    'EVENT_FEEDBACK_ALREADY_CREATED':
        'Feedback has already been submitted for this event.',
    'EVENT_OWNER_CANNOT_SEND_FEEDBACK': 'Event owners cannot send feedback.',

    // Reservations
    'SPACE_ALREADY_RESERVED': 'This space is already reserved.',
    'SPACE_OWNER_CANNOT_RESERVE': 'You cannot reserve your own space.',
    'RESERVATION_NOT_FOUND': 'Reservation not found.',
    'INVALID_CONFIRMATION_CODE': 'Invalid confirmation code.',

    // Spaces
    'SPACE_PUBLISHED_NEARBY_RECENTLY':
        'A space has been published nearby recently.',
    'SPACE_NOT_FUND': 'Space not found.',
    'INVALID_PHONE': 'Invalid phone number.',
    'SPACE_FEEDBACK_ALREADY_CREATED':
        'Feedback has already been submitted for this space.',
    'SPACE_OWNER_CANNOT_SEND_FEEDBACK': 'Space owners cannot send feedback.',
    'SPACE_INVALID_PRICE':
        'The price set for the space is invalid. Space price should be in range of 3 - 20',
    'SPACE_INVALID_TIME_TO_WAIT':
        'The waiting time specified is invalid. Should be in range of 20 - 60',
  };

  static const Map<String, String> _spanishMessages = {
    // Accounts
    'INVALID_CREDENTIALS': 'Credenciales inválidas. Intenta nuevamente.',
    'card_declined':
        'Tu tarjeta fue rechazada. Verifica los detalles de tu pago.',
    'INVALID_CURRENT_PASSWORD': 'La contraseña actual es incorrecta.',
    'REPEATED_PASSWORD':
        'La nueva contraseña no puede ser igual a la anterior.',

    'INACTIVE_ACCOUNT': 'Tu cuenta está inactiva.',
    'EMAIL_ALREADY_EXISTS': 'Este correo electrónico ya está registrado.',
    'INVALID_SOCIAL_TOKEN': 'Token de inicio de sesión social inválido.',
    'INVALID_OTP': 'Código OTP inválido.',
    'ACCOUNT_ALREADY_ACTIVATED': 'La cuenta ya está activada.',
    'EMAIL_NOT_FOUND': 'Correo electrónico no encontrado.',
    'OTP_NOT_VALIDATED': 'El OTP no ha sido validado.',
    'CAR_ALREADY_CREATED': 'Ya has añadido un coche.',
    'USER_DOES_NOT_HAVE_CAR': 'No hay un coche asociado a este usuario.',
    'SOCIAL_USER_CANNOT_RESET_PASSWORD':
        'No se puede restablecer la contraseña para usuarios sociales.',
    'ENDS_TIME_SHOULD_BE_GREATER':
        'La hora de finalización debe ser mayor que la de inicio.',
    'ENDS_AND_START_TIME_SHOULD_BE_GREATER_THAN_NOW':
        'La hora de inicio y finalización deben estar en el futuro.',
    'NOTIFICATION_ALREADY_SCHEDULED_IN_PLACE':
        'Ya hay una notificación programada para este lugar.',

    // Credits
    'EARNING_ACCOUNT_ALREADY_EXISTS': 'La cuenta de ingresos ya existe.',
    'BALANCE_LOWER_THAN_MINIMUM':
        'Tu saldo está por debajo del mínimo para retiros.',
    'EARNING_ACCOUNT_REQUIRED': 'Se requiere una cuenta de ingresos.',
    'EARNING_ACCOUNT_IS_NOT_ACCEPTED': 'La cuenta de ingresos no es aceptada.',
    'COUNTRY_NOT_SUPPORTED': 'Este país no es compatible.',
    'BAD_REQUEST_FOR_CURRENT_STEP': 'Solicitud inválida para el paso actual.',
    'INVALID_ADDRESS_COUNTRY': 'El país de la dirección no es válido.',
    'INVALID_PAYOUT_METHOD_FOR_ACCOUNT_COUNTRY':
        'Este método de pago no está disponible en tu país.',
    'PAYMENT_METHOD_NOT_FOUND': 'Método de pago no encontrado.',
    'PAYMENT_METHOD_ALREADY_EXISTS': 'El método de pago ya existe.',
    'PAYOUT_METHOD_NOT_FOUND': 'Método de retiro no encontrado.',
    'INVALID_PHONE': 'Número de teléfono inválido.',
    'PAYMENT_REQUIRES_ACTION':
        'El pago requiere una acción adicional. Verifica tu método de pago.',
    'PAYMENT_FAILED': 'El pago falló. Intenta nuevamente más tarde.',

    // Events
    'EVENT_PUBLICATION_ERROR': 'Error al publicar el evento.',
    'EVENT_NOT_FUND': 'Evento no encontrado.',
    'EVENT_FEEDBACK_ALREADY_CREATED':
        'Ya se ha enviado una reseña para este evento.',
    'EVENT_OWNER_CANNOT_SEND_FEEDBACK':
        'Los propietarios del evento no pueden enviar reseñas.',

    // Reservations
    'SPACE_ALREADY_RESERVED': 'Este espacio ya está reservado.',
    'SPACE_OWNER_CANNOT_RESERVE': 'No puedes reservar tu propio espacio.',
    'RESERVATION_NOT_FOUND': 'Reserva no encontrada.',
    'INVALID_CONFIRMATION_CODE': 'Código de confirmación inválido.',

    // Spaces
    'SPACE_PUBLISHED_NEARBY_RECENTLY':
        'Ya se publicó un espacio cerca recientemente.',
    'SPACE_NOT_FUND': 'Espacio no encontrado.',
    'SPACE_FEEDBACK_ALREADY_CREATED':
        'Ya se ha enviado una reseña para este espacio.',
    'SPACE_OWNER_CANNOT_SEND_FEEDBACK':
        'Los propietarios del espacio no pueden enviar reseñas.',
    'SPACE_INVALID_PRICE': 'El precio del espacio es inválido.',
    'SPACE_INVALID_TIME_TO_WAIT':
        'El tiempo de espera especificado es inválido.',
  };
}
