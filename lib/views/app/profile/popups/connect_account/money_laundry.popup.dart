import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/views/auth/views/onboard/register.view.dart';

class MoneyLaundryPopup extends StatefulWidget {
  final VoidCallback onContinue;
  final bool initialChecked;

  const MoneyLaundryPopup({
    super.key,
    required this.onContinue,
    this.initialChecked = true,
  });

  @override
  State<MoneyLaundryPopup> createState() => _MoneyLaundryPopupState();
}

class _MoneyLaundryPopupState extends State<MoneyLaundryPopup> {
  bool _isChecked = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Container(
        padding: EdgeInsets.all(Dimens.defaultMargin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Alert icon in purple circle
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.primary500.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(22),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.primary500,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.priority_high,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Important Notice text
            Text(
              'Important Notice',
              style: Typo.heading4.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Description text
            Text(
              'The Anti-money Laundering Directive forces us to verify your identity in order to receive payment for your online sales. You will only need to verify yourself once.',
              textAlign: TextAlign.center,
              style: Typo.mediumBody.copyWith(
                color: AppColors.neutral500,
              ),
            ),
            const SizedBox(height: 32),

            // Continue button
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                onTap: widget.onContinue,
                text: 'Continue',
              ),
            ),
            const SizedBox(height: 16),

            // Agreement checkbox text with links
            Row(
              children: [
                CustomCheckbox(
                  value: _isChecked,
                  onChanged: (value) {
                    setState(() {
                      _isChecked = value;
                    });
                  },
                  activeColor: AppColors.primary500,
                  size: 21.0,
                  borderRadius: 7.0,
                ),
                Dimens.space(1),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'By continuing, I agree to LetDem ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                        TextSpan(
                          text: 'Terms & Conditions',
                          style: TextStyle(
                            color: AppColors.primary500,
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // handle tap here (e.g. open a web page or navigate to terms screen)
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Bottom handle indicator
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgreementText extends StatefulWidget {
  @override
  _AgreementTextState createState() => _AgreementTextState();
}

class _AgreementTextState extends State<_AgreementText> {
  bool isChecked = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: isChecked,
            onChanged: (value) {
              setState(() {
                isChecked = value ?? false;
              });
            },
            activeColor: Colors.purple.shade500,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
              children: [
                const TextSpan(text: 'By continuing, I agree to the '),
                TextSpan(
                  text: 'Stripe Connected Account Agreement',
                  style: TextStyle(
                    color: Colors.purple.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Stripe Terms of Service',
                  style: TextStyle(
                    color: Colors.purple.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
