import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/extensions/locale.dart';

enum TextFieldType { email, password, number, text }

class TextInputField extends StatefulWidget {
  final TextEditingController? controller;
  final String placeHolder;

  final bool showPasswordStrengthIndicator;
  final Function(String value)? onChanged;
  final TextFieldType inputType;
  final int? maxLines;

  final IconData? prefixIcon;
  final bool enableBorder;

  final bool mustValidate;

  final bool isEnabled;

  final String? label;

  final List<TextInputFormatter>? inputFormatters;
  final bool isLoading;

  final bool showDeleteIcon;

  final Widget? child;

  final Color? placeholderColor;

  final TextInputAction? textInputAction;

  final VoidCallback? onEditingComplete;

  const TextInputField({
    super.key,
    this.controller,
    this.placeholderColor,
    this.inputFormatters,
    required this.label,
    this.isEnabled = true,
    this.showPasswordStrengthIndicator = false,
    this.mustValidate = true,
    this.onChanged,
    required this.placeHolder,
    this.inputType = TextFieldType.text,
    this.maxLines,
    this.enableBorder = true,
    this.prefixIcon,
    this.isLoading = false,
    this.showDeleteIcon = false,
    this.child,
    this.textInputAction,
    this.onEditingComplete,
  });

  @override
  TextInputFieldState createState() => TextInputFieldState();
}

class TextInputFieldState extends State<TextInputField> {
  bool isPasswordVisible = false;

  // We'll track password strength level instead of individual criteria
  int passwordStrength = 1; // 0-4 scale for strength levels

  @override
  void initState() {
    super.initState();
  }

  // Calculate password strength based on criteria
  void _calculatePasswordStrength(String password) {
    int strength = 0;

    if (password.length >= 8) {
      strength++;
    }

    if (RegExp(r'[0-9]').hasMatch(password)) {
      strength++;
    }

    if (RegExp(r'[!@#<>?":_`~;\[\]\\|=+\)\(\*&^%\$]').hasMatch(password)) {
      strength++;
    }

    if (RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password)) {
      strength++;
    }

    setState(() {
      passwordStrength = strength < 1 ? 1 : strength.clamp(1, 4);
    });
  }

  @override
  Widget build(BuildContext context) {
    TextInputType? getKeyboardType() {
      switch (widget.inputType) {
        case TextFieldType.email:
          return TextInputType.emailAddress;
        case TextFieldType.number:
          return TextInputType.numberWithOptions(signed: false, decimal: true);
        default:
          return TextInputType.multiline;
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimens.baseSize / 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: widget.label == null
                ? []
                : [
                    Text(
                      widget.label!,
                      style: Typo.mediumBody.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),
                    Dimens.space(1),
                  ],
          ),
          TextFormField(
              enabled: widget.isEnabled,
              onEditingComplete: widget.onEditingComplete,
              onChanged: widget.showPasswordStrengthIndicator
                  ? (value) {
                      _calculatePasswordStrength(value);
                      if (widget.onChanged != null) {
                        widget.onChanged!(value);
                      }
                    }
                  : widget.onChanged,
              validator: (value) {
                if (!widget.mustValidate) {
                  return null;
                }
                if (value == null || value.isEmpty) {
                  return '${context.l10n.pleaseEnter}${widget.label?.toLowerCase().replaceAll("enter", "")}';
                }
                if (widget.inputType == TextFieldType.password &&
                    value.length < 8) {
                  return context.l10n.passwordMinLength;
                }
                if (widget.inputType == TextFieldType.password &&
                    !RegExp(r'[0-9]').hasMatch(value)) {
                  return context.l10n.passwordRequireNumber;
                }
                if (widget.inputType == TextFieldType.password &&
                    !RegExp(r'[!@#<>?":_`~;\[\]\\|=+\)\(\*&^%\$]')
                        .hasMatch(value)) {
                  return context.l10n.passwordRequireSpecial;
                }
                if (widget.inputType == TextFieldType.password &&
                    !RegExp(r'[A-Z]').hasMatch(value)) {
                  return context.l10n.passwordRequireUppercase;
                }

                if (widget.inputType == TextFieldType.email &&
                    !value.isValidEmail()) {
                  return context.l10n.pleaseEnterValidEmail;
                }
                return null;
              },
              maxLines: widget.maxLines ?? 1,
              controller: widget.controller,
              onTapOutside: (PointerDownEvent event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              inputFormatters: widget.inputFormatters ??
                  (widget.inputType == TextFieldType.number
                      ? [FilteringTextInputFormatter.digitsOnly]
                      : []),
              textInputAction: widget.textInputAction ?? TextInputAction.newline,
              obscureText: widget.inputType == TextFieldType.password
                  ? !isPasswordVisible
                  : false,
              keyboardType: getKeyboardType(),
              decoration: InputDecoration(
                  disabledBorder: !widget.enableBorder
                      ? InputBorder.none
                      : OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10000),
                          borderSide: const BorderSide(
                              // color: AppColors.gray,
                              ), // Border color when not focused
                        ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 20),
                  prefixIcon: widget.isLoading
                      ? CupertinoActivityIndicator(
                          color: AppColors.primary400,
                        )
                      : widget.prefixIcon == null
                          ? null
                          : Icon(
                              widget.prefixIcon,
                              size: 18,
                              color: AppColors.neutral300,
                            ),
                  hintText: widget.placeHolder,
                  hintStyle: Typo.largeBody.copyWith(
                    color: widget.placeholderColor ?? AppColors.neutral300,
                    fontWeight: FontWeight.w500,
                  ),
                  errorStyle: Typo.smallBody.copyWith(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w500,
                  ),
                  focusedErrorBorder: !widget.enableBorder
                      ? InputBorder.none
                      : OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10000),
                          borderSide: const BorderSide(
                            color: Colors.redAccent,
                          ),
                        ),
                  enabledBorder: !widget.enableBorder
                      ? InputBorder.none
                      : OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10000),
                          borderSide: BorderSide(
                            color: AppColors.neutral100.withOpacity(0.8),
                          ), // Border color when not focused
                        ),
                  errorBorder: !widget.enableBorder
                      ? InputBorder.none
                      : OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10000),
                          borderSide: const BorderSide(
                            color: Colors.redAccent,
                          ), // Border color when focused
                        ),
                  focusedBorder: !widget.enableBorder
                      ? InputBorder.none
                      : OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10000),
                          borderSide: BorderSide(
                              color: AppColors
                                  .primary400), // Border color when focused
                        ),
                  suffixIcon: widget.child ??
                      (widget.showDeleteIcon
                          ? widget.controller!.text.isNotEmpty
                              ? InkWell(
                                  splashColor: Colors
                                      .transparent, // Remove ripple effect
                                  highlightColor: Colors
                                      .transparent, // Remove highlight effect
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 5),
                                    child: GestureDetector(
                                      child: Icon(
                                        Iconsax.close_circle5,
                                        size: 22,
                                        color: AppColors.neutral100,
                                        // color: AppColors.gray,
                                      ),
                                      onTap: () {
                                        widget.controller!.clear();
                                        setState(() {
                                          passwordStrength = 0;
                                        });
                                      },
                                    ),
                                  ),
                                )
                              : null
                          : widget.inputType == TextFieldType.password
                              ? InkWell(
                                  splashColor: Colors
                                      .transparent, // Remove ripple effect
                                  highlightColor: Colors
                                      .transparent, // Remove highlight effect
                                  child: GestureDetector(
                                    child: Icon(
                                      isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      size: 18,
                                      color: AppColors.neutral300,
                                      // color: AppColors.gray,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        isPasswordVisible = !isPasswordVisible;
                                      });
                                    },
                                  ),
                                )
                              : null))),
          if (widget.showPasswordStrengthIndicator &&
              widget.controller != null &&
              widget.controller!.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(4, (index) {
                  final isActive = index < passwordStrength;

                  Color segmentColor = Colors.grey.withOpacity(0.2);

                  if (isActive) {
                    if (passwordStrength <= 1) {
                      segmentColor = Colors.red;
                    } else if (passwordStrength <= 3) {
                      segmentColor = Colors.amber; // Yellow
                    } else {
                      segmentColor = Colors.green;
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Container(
                      width: 22,
                      height: 6,
                      decoration: BoxDecoration(
                        color: segmentColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}
