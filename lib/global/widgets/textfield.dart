import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';

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

  const TextInputField({
    super.key,
    this.controller,
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
  });

  @override
  TextInputFieldState createState() => TextInputFieldState();
}

class TextInputFieldState extends State<TextInputField> {
  bool isPasswordVisible = false;

  Map<String, bool> passwordValid = {
    'isLength': false,
    'isSpecial': false,
    'isNumber': false,
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextInputType? getKeyboardType() {
      switch (widget.inputType) {
        case TextFieldType.email:
          return TextInputType.emailAddress;
        case TextFieldType.number:
          return TextInputType.number;
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
              onChanged: widget.showPasswordStrengthIndicator
                  ? (e) {
                      if (e.length >= 8) {
                        setState(() {
                          passwordValid['isLength'] = true;
                        });
                      } else {
                        setState(() {
                          passwordValid['isLength'] = false;
                        });
                      }
                      if (RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%]').hasMatch(e)) {
                        setState(() {
                          passwordValid['isSpecial'] = true;
                        });
                      } else {
                        setState(() {
                          passwordValid['isSpecial'] = false;
                        });
                      }
                      if (RegExp(r'[0-9]').hasMatch(e)) {
                        setState(() {
                          passwordValid['isNumber'] = true;
                        });
                      } else {
                        setState(() {
                          passwordValid['isNumber'] = false;
                        });
                      }
                    }
                  : widget.onChanged,
              validator: (value) {
                if (!widget.mustValidate) {
                  return null;
                }
                if (value == null || value.isEmpty) {
                  return 'Please enter${widget.placeHolder.toLowerCase().replaceAll("enter", "")}';
                }
                if (widget.inputType == TextFieldType.email &&
                    !value.isValidEmail()) {
                  return 'Please enter valid email';
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
              textInputAction: TextInputAction.newline,
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
                    color: AppColors.neutral300,
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
                  suffixIcon: widget.inputType == TextFieldType.password
                      ? InkWell(
                          splashColor:
                              Colors.transparent, // Remove ripple effect
                          highlightColor:
                              Colors.transparent, // Remove highlight effect
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
                      : null)),
          Column(
            children: widget.showPasswordStrengthIndicator &&
                    widget.controller != null &&
                    widget.controller!.text.isNotEmpty
                ? <Widget>[
                    Dimens.space(2),
                    Row(
                      children: [
                        Text(
                          "Password Strength",
                          style: Typo.mediumBody.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: passwordValid.keys.map((key) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: AnimatedContainer(
                                height: 7,
                                duration: const Duration(milliseconds: 600),
                                width: 24,
                                decoration: BoxDecoration(
                                  color: passwordValid[key] == true
                                      ? AppColors.green500
                                      : AppColors.neutral50,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ]
                : [],
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
