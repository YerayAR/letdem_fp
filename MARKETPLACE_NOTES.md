# Notas de integración Marketplace / Wallet / Puntos

## 1. Infraestructura API (`lib/infrastructure/api/api`)

### 1.1 `endpoints.dart`

Base URLs:
- `EndPoints.baseURL`: se toma de `API_BASE_URL` con valor por defecto `https://api-staging.letdem.org/v1`.
- `authBaseURL`: constante `https://api-staging.letdem.org/v1`.

Endpoints relevantes para reservas / pedidos / créditos / marketplace:

- Historial de reservas:
  - `getReservationHistoryEndpoint`: `GET /credits/reservations`.
- Historial de pedidos (bookings):
  - `getOrdersEndpoint`: `GET /credits/orders?page_size=100&page=1`.
- Retiros y métodos de pago / cobro:
  - `getWithdrawals`: `GET /credits/withdrawals`.
  - `getPayoutMethods`: `GET /credits/payout-methods`.
  - `addPayoutMethod`: `POST /credits/payout-methods`.
  - `deletePayoutMethod(String id)`: `DELETE /credits/payout-methods/{id}`.
  - `withdrawMoney`: `POST /credits/withdrawals`.
- Transferencias de dinero y puntos entre usuarios:
  - `sendMoneyTransfer`: `POST /credits/transfers/money` con `MoneyTransferDTO`.
  - `sendPointsTransfer`: `POST /credits/transfers/points` con `PointsTransferDTO`.
- Transacciones / movimientos de wallet:
  - `getTransactions`: `GET /credits/transactions`.
- Earnings / cuenta de ingresos (KYC, documentos, banco):
  - `submitEarningsAccount`: `POST /credits/earnings/account`.
  - `submitEarningsAddress`: `POST /credits/earnings/address`.
  - `submitEarningsDocument`: `POST /credits/earnings/document`.
  - `submitBankAccount`: `POST /credits/earnings/bank-account`.

Otros endpoints clave que afectan a marketplace/monetización:
- `getTransactions`, `getPaymentMethods`, `addPaymentMethod`, `removePaymentMethod`, `setDefaultPaymentMethod`.
- `updatePreferencesEndpoint`, `updateLanguageEndpoint` (preferencias de usuario para notificaciones / idioma).

### 1.2 `api.service.dart`

- Nueva infraestructura HTTP basada en **Dio** (`package:dio/dio.dart`).
- `ApiService.sendRequest` y `sendMultiPartRequest` usan `EndPoints.baseURL` y construyen URLs con `endpoint.baseURL ?? EndPoints.baseURL`.
- Manejo de errores de red (`DioException`, timeouts, handshake) centralizado en `_handleDioError`.
- Usa `BaseApiService.getHeaders` para añadir `Authorization: Token <token>` y `Accept-Language`.

### 1.3 `models/endpoint.dart`

- Clase `Endpoint<T extends DTO>` general para describir:
  - `url`, `method` (`HTTPMethod`), `isProtected`, `baseURL`, `tokenKey`, `queryParameter`, `dto`, `images`.
- Métodos auxiliares:
  - `copyWithDTO`, `copyWitURL`, `copyWithImages`.
  - `checkDTO()` lanza `ApiError` si es `POST` y no hay DTO cuando `dtoNullable == false`.

### 1.4 `models/response.model.dart`

- `ApiResponse { Map<String, dynamic> data, RequestStatus status, bool success }`.

### 1.5 `sub/base.dart`

- `BaseApiService.getHeaders`:
  - Siempre añade `Content-Type: application/json; charset=UTF-8`.
  - Añade `Accept-Language` según locale actual (`Localizations.localeOf`).
  - Si `mustAuthenticated == true`, lee el token desde `SecureStorageHelper` (clave por defecto `access_token`) y añade `Authorization: Token <token>`.

## 2. WebSockets (`lib/infrastructure/ws/web_socket.service.dart`)

Actualmente SÓLO se usan para:
- `LocationWebSocketService` → `/maps/nearby?token=...`.
- `UserWebSocketService` → `/users/refresh?token=...`.

No hay integraciones directas de marketplace/compras/puntos en WebSocket, solo ubicación y refresco de datos de usuario.

## 3. Localización (`lib/l10n`)

### 3.1 Claves nuevas relacionadas con transferencias de dinero, historial de compras y tarjetas

En `app_en.arb`:
- Enviar dinero / transferencias:
  - `sendMoney`: "Send money".
  - `recipientAlias`: "Recipient alias".
  - `enterRecipientAlias`: "Enter recipient alias".
  - `amountToSend`: "Amount to send".
  - `pleaseEnterAlias`: "Please enter alias".
  - `pleaseEnterAmount`: "Please enter amount".
  - `enterValidAmount`: "Enter a valid amount".
  - `sendMoneyTitle`: "Transfer funds".
  - `sendMoneySubtitle`: "Send money to another user using their alias.".
  - `sendMoneyWarning`: "Verify the alias before sending. Transfers cannot be reversed.".
  - `moneySentSuccessfully`: "Money sent successfully".
  - `moneySentDescription`: "You have sent {amount}€ to {alias} successfully." con placeholders `amount`, `alias`.

- Historial de compras y tarjetas:
  - `purchaseHistory`: "Purchase history".
  - `pendingCards`: "Pending cards".
  - `generateCard`: "Generate card".
  - `transactionsHistory`: "Transactions history".
  - `buy`: "Buy".

En `app_es.arb` (equivalentes en español):
- `sendMoney`: "Enviar dinero".
- `recipientAlias`: "Alias del destinatario".
- `enterRecipientAlias`: "Ingresa el alias del destinatario".
- `amountToSend`: "Monto a enviar".
- `pleaseEnterAlias`: "Por favor ingresa el alias".
- `pleaseEnterAmount`: "Por favor ingresa el monto".
- `enterValidAmount`: "Ingresa un monto válido".
- `sendMoneyTitle`: "Transferir fondos".
- `sendMoneySubtitle`: "Envía dinero a otro usuario usando su alias identificativo.".
- `sendMoneyWarning`: "Verifica el alias antes de enviar. Las transferencias no se pueden revertir.".
- `moneySentSuccessfully`: "Dinero enviado exitosamente".
- `moneySentDescription`: "Has enviado {amount}€ a {alias} correctamente.".

- `purchaseHistory`: "Historial de compras".
- `pendingCards`: "Tarjetas pendientes".
- `generateCard`: "Generar tarjeta".
- `transactionsHistory`: "Historial transacciones".
- `buy`: "Comprar".

### 3.2 `app_localizations.dart`

Se añadieron getters y métodos abstractos correspondientes:
- `String get sendMoney;`
- `String get recipientAlias;`
- `String get enterRecipientAlias;`
- `String get amountToSend;`
- `String get pleaseEnterAlias;`
- `String get pleaseEnterAmount;`
- `String get enterValidAmount;`
- `String get sendMoneyTitle;`
- `String get sendMoneySubtitle;`
- `String get sendMoneyWarning;`
- `String get moneySentSuccessfully;`
- `String moneySentDescription(String amount, String alias);`
- `String get purchaseHistory;`
- `String get pendingCards;`
- `String get generateCard;`
- `String get transactionsHistory;`
- `String get buy;`

### 3.3 `app_localizations_en.dart` / `app_localizations_es.dart`

Implementaciones concretas de esos getters y del método `moneySentDescription(...)` en inglés y español con los textos indicados en 3.1.

## 4. Configuración (`pubspec.yaml` y `pubspec.lock`)

### 4.1 `pubspec.yaml`

Dependencias relevantes añadidas para infraestructura de API / conectividad (usadas también por marketplace/wallet):

- `connectivity_plus: ^7.0.0`  
  Para comprobar estado de red (usado p.ej. en navegación, pero también útil para manejar errores de red en flujos de pago/marketplace).
- `dio: ^5.4.0`  
  Cliente HTTP usado en `ApiService` para todas las llamadas a `EndPoints` (incluidas reservas, créditos, transferencias, etc.).

**Nota:** No documentamos aquí cambios de Mapbox porque forman parte del módulo de mapas de tus compañeros y no son específicos de marketplace/pagos.

### 4.2 `pubspec.lock`

- Refleja la inclusión de `dio` y sus dependencias (`dio_web_adapter`, etc.).
- No es necesario copiar a mano; bastará con:
  - Mantener `dio` en `pubspec.yaml`.
  - Ejecutar `flutter pub get` después de reañadir la dependencia para regenerar el lock.

---

Estas notas sirven como referencia para, después de restaurar `api/`, `ws/`, `l10n/`, `pubspec.yaml` y `pubspec.lock` desde `origin`, volver a añadir SOLO lo necesario de marketplace (endpoints de créditos/transferencias, textos de i18n y dependencia `dio`) sin tocar nada de mapas ni de otros módulos.