import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/common/popups/success_dialog.dart';
import 'package:letdem/common/widgets/appbar.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/common/widgets/textfield.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/core/extensions/user.dart';
import 'package:letdem/features/payment_methods/dto/add_payment.dto.dart';
import 'package:letdem/features/payment_methods/payment_method_bloc.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';
import 'package:letdem/models/payment/payment.model.dart';

enum FailureCode {
  CardDeclined,
  ExpiredCard,
  IncorrectCvc,
  ProcessingError,
  IncorrectNumber,
}

class AddPaymentMethod extends StatefulWidget {
  final Function(PaymentMethodModel m)? onPaymentMethodAdded;
  const AddPaymentMethod({super.key, this.onPaymentMethodAdded});

  @override
  _AddPaymentMethodState createState() => _AddPaymentMethodState();
}

class _AddPaymentMethodState extends State<AddPaymentMethod> {
  final _nameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();

  // Focus nodes for better UX
  final _nameFocusNode = FocusNode();
  final _cardNumberFocusNode = FocusNode();
  final _expiryFocusNode = FocusNode();
  final _cvcFocusNode = FocusNode();

  bool _isLoading = false;
  bool _isCardNumberValid = false;
  bool _isExpiryValid = false;
  bool _isCvcValid = false;
  bool _isNameValid = false;

  // Error messages
  String? _nameError;
  String? _cardNumberError;
  String? _expiryError;
  String? _cvcError;

  String _cardBrand = '';

  // Regex patterns for validation
  final RegExp _cardNumberRegex = RegExp(r'^[0-9]{13,19}$');
  final RegExp _expiryRegex = RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$');
  final RegExp _cvcRegex = RegExp(r'^[0-9]{3,4}$');
  final RegExp _nameRegex = RegExp(r'^[a-zA-Z\s]{2,50}$');

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateName);
    _cardNumberController.addListener(_validateCardNumber);
    _expiryController.addListener(_validateExpiry);
    _cvcController.addListener(_validateCvc);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();

    _nameFocusNode.dispose();
    _cardNumberFocusNode.dispose();
    _expiryFocusNode.dispose();
    _cvcFocusNode.dispose();
    super.dispose();
  }

  void _validateName() {
    setState(() {
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        _nameError = 'Cardholder name is required';
        _isNameValid = false;
      } else if (!_nameRegex.hasMatch(name)) {
        _nameError =
            'Please enter a valid name (2-50 characters, letters only)';
        _isNameValid = false;
      } else {
        _nameError = null;
        _isNameValid = true;
      }
    });
  }

  void _validateCardNumber() {
    final cleanNumber = _cardNumberController.text.replaceAll(' ', '');
    setState(() {
      if (cleanNumber.isEmpty) {
        _cardNumberError = 'Card number is required';
        _isCardNumberValid = false;
        _cardBrand = '';
      } else if (!_cardNumberRegex.hasMatch(cleanNumber)) {
        _cardNumberError = 'Card number must be 13-19 digits';
        _isCardNumberValid = false;
        _cardBrand = _getCardBrand(cleanNumber);
      } else if (!_luhnCheck(cleanNumber)) {
        _cardNumberError = 'Invalid card number';
        _isCardNumberValid = false;
        _cardBrand = _getCardBrand(cleanNumber);
      } else {
        _cardNumberError = null;
        _isCardNumberValid = true;
        _cardBrand = _getCardBrand(cleanNumber);
      }
    });
  }

  void _validateExpiry() {
    setState(() {
      final expiry = _expiryController.text;
      if (expiry.isEmpty) {
        _expiryError = 'Expiry date is required';
        _isExpiryValid = false;
      } else if (!_expiryRegex.hasMatch(expiry)) {
        _expiryError = 'Format: MM/YY';
        _isExpiryValid = false;
      } else if (!_isValidExpiry(expiry)) {
        _expiryError = 'Card has expired';
        _isExpiryValid = false;
      } else {
        _expiryError = null;
        _isExpiryValid = true;
      }
    });
  }

  void _validateCvc() {
    setState(() {
      final cvc = _cvcController.text;
      if (cvc.isEmpty) {
        _cvcError = 'CVC is required';
        _isCvcValid = false;
      } else if (!_cvcRegex.hasMatch(cvc)) {
        _cvcError =
            _cardBrand == 'amex' ? '4 digits required' : '3 digits required';
        _isCvcValid = false;
      } else if (_cardBrand == 'amex' && cvc.length != 4) {
        _cvcError = '4 digits required for Amex';
        _isCvcValid = false;
      } else if (_cardBrand != 'amex' && cvc.length != 3) {
        _cvcError = '3 digits required';
        _isCvcValid = false;
      } else {
        _cvcError = null;
        _isCvcValid = true;
      }
    });
  }

  bool _luhnCheck(String cardNumber) {
    int sum = 0;
    bool alternate = false;

    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  String _getCardBrand(String cardNumber) {
    if (cardNumber.startsWith('4')) {
      return 'visa';
    } else if (cardNumber.startsWith('5') || cardNumber.startsWith('2')) {
      return 'mastercard';
    } else if (cardNumber.startsWith('34') || cardNumber.startsWith('37')) {
      return 'amex';
    } else if (cardNumber.startsWith('6011') || cardNumber.startsWith('65')) {
      return 'discover';
    }
    return 'unknown';
  }

  bool _isValidExpiry(String expiry) {
    if (!_expiryRegex.hasMatch(expiry)) return false;

    final parts = expiry.split('/');
    final month = int.parse(parts[0]);
    final year = int.parse('20${parts[1]}');
    final now = DateTime.now();
    final expiryDate = DateTime(year, month + 1, 0);

    return expiryDate.isAfter(now);
  }

  bool get _isFormValid =>
      _isNameValid && _isCardNumberValid && _isExpiryValid && _isCvcValid;

  Widget _buildCardIcon() {
    Widget cardIcon;

    switch (_cardBrand) {
      case 'visa':
        cardIcon = Container(
          width: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(),
          child: Center(
            child: Text(
              'VISA',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
        break;
      case 'mastercard':
        cardIcon = Container(
          width: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(),
          child: Center(
            child: Text(
              'MC',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
        break;
      case 'amex':
        cardIcon = Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Text(
            'AMEX',
            style: TextStyle(
              color: Colors.green.shade700,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        break;
      case 'discover':
        cardIcon = Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Text(
            'DISC',
            style: TextStyle(
              color: Colors.orange.shade700,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        break;
      default:
        cardIcon =
            Icon(Icons.credit_card, color: Colors.grey.shade400, size: 24);
    }

    return cardIcon;
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    String? errorText,
    bool isValid = false,
    Widget? suffix,
    List<TextInputFormatter>? formatters,
    TextInputType? keyboardType,
    int? maxLength,
    VoidCallback? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black.withOpacity(0.05),
            //     blurRadius: 8,
            //     offset: const Offset(0, 2),
            //   ),
            // ],
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            inputFormatters: formatters,
            maxLength: maxLength,
            onFieldSubmitted: (_) => onSubmitted?.call(),
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: suffix,
              // filled: true,
              // fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
              hintStyle: Typo.largeBody.copyWith(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
              errorStyle: Typo.smallBody.copyWith(
                color: Colors.redAccent,
                fontWeight: FontWeight.w500,
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10000),
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10000),
                borderSide: BorderSide(
                  color: AppColors.neutral100.withOpacity(0.8),
                ), // Border color when not focused
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10000),
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                ), // Border color when focused
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10000),
                borderSide: BorderSide(
                    color: AppColors.primary400), // Border color when focused
              ),
              counterText: '',
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.error_outline, size: 16, color: Colors.red.shade400),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  errorText,
                  style: TextStyle(
                    color: Colors.red.shade400,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ] else if (isValid) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.check_circle, size: 16, color: Colors.green.shade400),
              const SizedBox(width: 4),
              Text(
                'Looks good!',
                style: TextStyle(
                  color: Colors.green.shade400,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: BlocConsumer<PaymentMethodBloc, PaymentMethodState>(
          listener: (context, state) {
            if (state is PaymentMethodAdded) {
              setState(() => _isLoading = false);

              if (widget.onPaymentMethodAdded != null) {
                widget.onPaymentMethodAdded!(state.paymentMethod);
              }
              context.read<PaymentMethodBloc>().add(
                    const FetchPaymentMethods(),
                  );

              AppPopup.showDialogSheet(
                  context,
                  SuccessDialog(
                    title: context.l10n.paymentMethodAdded,
                    subtext: context.l10n.paymentMethodAddedDescription,
                    onProceed: () {
                      NavigatorHelper.pop();
                      NavigatorHelper.pop();
                    },
                  ));
            } else if (state is PaymentMethodError) {
              context.read<PaymentMethodBloc>().add(
                    const FetchPaymentMethods(),
                  );
              Toast.showError(state.message);
              setState(() => _isLoading = false);
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Container(
                color: Colors.grey.shade50,
                child: StyledBody(
                  children: [
                    StyledAppBar(
                      onTap: () => NavigatorHelper.pop(),
                      title: context.l10n.addPaymentMethod,
                      icon: Icons.close,
                    ),

                    Dimens.space(3),
                    // Payment form card
                    Container(
                      // padding: const EdgeInsets.all(24),
                      // decoration: BoxDecoration(
                      //   color: Colors.white,
                      //   borderRadius: BorderRadius.circular(16),
                      //   boxShadow: [
                      //     BoxShadow(
                      //       color: Colors.black.withOpacity(0.08),
                      //       blurRadius: 20,
                      //       offset: const Offset(0, 4),
                      //     ),
                      //   ],
                      // ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header

                          const SizedBox(height: 24),

                          // Cardholder Name
                          TextInputField(
                            label: context.l10n.cardholderName,
                            controller: _nameController,
                            placeHolder: context.l10n.enterYourName,
                          ),

                          const SizedBox(height: 20),

                          // Card Number
                          _buildCustomTextField(
                            controller: _cardNumberController,
                            focusNode: _cardNumberFocusNode,
                            label: 'Card Number',
                            hint: '1234 5678 9012 3456',
                            errorText: _cardNumberError,
                            isValid: _isCardNumberValid,
                            suffix: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: _buildCardIcon(),
                            ),
                            formatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              CardNumberInputFormatter(),
                            ],
                            keyboardType: TextInputType.number,
                            maxLength: 23, // Account for spaces
                            onSubmitted: () => _expiryFocusNode.requestFocus(),
                          ),

                          const SizedBox(height: 20),

                          // Expiry and CVC Row
                          Row(
                            children: [
                              Expanded(
                                child: _buildCustomTextField(
                                  controller: _expiryController,
                                  focusNode: _expiryFocusNode,
                                  label: 'Expiry Date',
                                  hint: 'MM/YY',
                                  errorText: _expiryError,
                                  isValid: _isExpiryValid,
                                  formatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    ExpiryDateInputFormatter(),
                                  ],
                                  keyboardType: TextInputType.number,
                                  maxLength: 5,
                                  onSubmitted: () =>
                                      _cvcFocusNode.requestFocus(),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildCustomTextField(
                                  controller: _cvcController,
                                  focusNode: _cvcFocusNode,
                                  label: 'CVC',
                                  hint: _cardBrand == 'amex' ? '1234' : '123',
                                  errorText: _cvcError,
                                  isValid: _isCvcValid,
                                  suffix: Tooltip(
                                    message:
                                        'The 3 or 4 digit code on the back of your card',
                                    child: Icon(Icons.help_outline,
                                        color: Colors.grey.shade400, size: 20),
                                  ),
                                  formatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(4),
                                  ],
                                  keyboardType: TextInputType.number,
                                  maxLength: 4,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Security info
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade100),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.security,
                                    color: Colors.blue.shade600, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Your payment information is encrypted and secure',
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Submit Button
                          PrimaryButton(
                            onTap: _isFormValid && !_isLoading
                                ? _handlePayPress
                                : null,
                            text: _isLoading
                                ? 'Processing...'
                                : context.l10n.addPaymentMethod,
                            isLoading: context.read<PaymentMethodBloc>().state
                                is PaymentMethodLoading,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handlePayPress() async {
    // Validate form one more time
    _validateName();
    _validateCardNumber();
    _validateExpiry();
    _validateCvc();

    if (!_isFormValid) {
      Toast.showError('Please fix the errors above');
      return;
    }

    // Check for unsupported cards
    if (_cardBrand == 'amex') {
      Toast.showError('American Express cards are not supported at this time.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Validate network connection
      // You might want to add network connectivity check here

      final billingDetails = BillingDetails(
        email: context.userProfile?.email ?? '',
        name: _nameController.text.trim(),
      );

      // Additional validation
      if (billingDetails.email!.isEmpty) {
        throw Exception('User email is required');
      }

      // Create payment method with custom card details
      final cardNumber = _cardNumberController.text.replaceAll(' ', '');
      final expiryParts = _expiryController.text.split('/');
      final expMonth = int.parse(expiryParts[0]);
      final expYear = int.parse('20${expiryParts[1]}');

      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: billingDetails,
          ),
        ),
      );

      print('Payment Method Created: ${paymentMethod.toJson()}');

      // Validate payment method creation
      if (paymentMethod.id.isEmpty) {
        throw Exception('Failed to create payment method');
      }

      context.read<PaymentMethodBloc>().add(
            RegisterPaymentMethod(
              AddPaymentMethodDTO(
                paymentMethodId: paymentMethod.id,
                holderName: billingDetails.name ?? 'Unknown',
                last4: cardNumber.substring(cardNumber.length - 4),
                expirationDate:
                    '${expYear}/${expMonth.toString().padLeft(2, '0')}',
                brand: _cardBrand,
                isDefault: true,
              ),
            ),
          );
    } on StripeException catch (e) {
      print('Stripe Error: ${e.error}');
      String errorMessage = 'Payment setup failed';

      switch (e.error.code) {
        case FailureCode.CardDeclined:
          errorMessage = 'Your card was declined. Please try a different card.';
          break;
        case FailureCode.ExpiredCard:
          errorMessage = 'Your card has expired. Please use a different card.';
          break;
        case FailureCode.IncorrectCvc:
          errorMessage = 'Your card\'s security code is incorrect.';
          break;
        case FailureCode.ProcessingError:
          errorMessage =
              'An error occurred processing your card. Try again in a moment.';
          break;
        case FailureCode.IncorrectNumber:
          errorMessage = 'Your card number is incorrect.';
          break;
        default:
          errorMessage = e.error.localizedMessage ?? 'Payment setup failed';
      }

      Toast.showError(errorMessage);
      setState(() => _isLoading = false);
    } catch (e) {
      print('Error creating payment method: $e');

      String errorMessage = 'An unexpected error occurred';
      if (e.toString().contains('network')) {
        errorMessage =
            'Network error. Please check your connection and try again.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Request timed out. Please try again.';
      }

      Toast.showError(errorMessage);
      setState(() => _isLoading = false);
    }
  }
}

// Enhanced input formatters
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    // Limit to 19 digits
    final limitedText = text.length > 19 ? text.substring(0, 19) : text;

    for (int i = 0; i < limitedText.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(limitedText[i]);
    }

    final newSelection = TextSelection.collapsed(
      offset: buffer.length,
    );

    return TextEditingValue(
      text: buffer.toString(),
      selection: newSelection,
    );
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length && i < 4; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }

    final newSelection = TextSelection.collapsed(
      offset: buffer.length,
    );

    return TextEditingValue(
      text: buffer.toString(),
      selection: newSelection,
    );
  }
}
