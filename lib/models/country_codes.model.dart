import 'package:flag/flag_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';

class CountryCode {
  String countryName;

  // String countryNameInJapan;

  String countryCode;
  String countryPrefix;

  CountryCode(
    this.countryName,
    this.countryCode,
    this.countryPrefix,
  );

  static List<CountryCode> countryCodes = [
    CountryCode('Spain', '+34', 'es'),
    CountryCode('Afghanistan', '+93', 'af'),
    CountryCode('Albania', '+355', 'al'),
    CountryCode('Algeria', '+213', 'dz'),
    CountryCode('Andorra', '+376', 'ad'),
    CountryCode('Angola', '+244', 'ao'),
    CountryCode('Antigua and Barbuda', '+1-268', 'ag'),
    CountryCode('Argentina', '+54', 'ar'),
    CountryCode('Armenia', '+374', 'am'),
    CountryCode('Australia', '+61', 'au'),
    CountryCode('Austria', '+43', 'at'),
    CountryCode('Azerbaijan', '+994', 'az'),
    CountryCode('Bahamas', '+1-242', 'bs'),
    CountryCode('Bahrain', '+973', 'bh'),
    CountryCode('Bangladesh', '+880', 'bd'),
    CountryCode('Barbados', '+1-246', 'bb'),
    CountryCode('Belarus', '+375', 'by'),
    CountryCode('Belgium', '+32', 'be'),
    CountryCode('Belize', '+501', 'bz'),
    CountryCode('Benin', '+229', 'bj'),
    CountryCode('Bhutan', '+975', 'bt'),
    CountryCode('Bolivia', '+591', 'bo'),
    CountryCode('Bosnia and Herzegovina', '+387', 'ba'),
    CountryCode('Botswana', '+267', 'bw'),
    CountryCode('Brazil', '+55', 'br'),
    CountryCode('Brunei', '+673', 'bn'),
    CountryCode('Bulgaria', '+359', 'bg'),
    CountryCode('Burkina Faso', '+226', 'bf'),
    CountryCode('Burundi', '+257', 'bi'),
    CountryCode('Cabo Verde', '+238', 'cv'),
    CountryCode('Cambodia', '+855', 'kh'),
    CountryCode('Cameroon', '+237', 'cm'),
    CountryCode('Canada', '+1', 'ca'),
    CountryCode('Central African Republic', '+236', 'cf'),
    CountryCode('Chad', '+235', 'td'),
    CountryCode('Chile', '+56', 'cl'),
    CountryCode('China', '+86', 'cn'),
    CountryCode('Colombia', '+57', 'co'),
    CountryCode('Comoros', '+269', 'km'),
    CountryCode('Congo', '+242', 'cg'),
    CountryCode('Costa Rica', '+506', 'cr'),
    CountryCode('Croatia', '+385', 'hr'),
    CountryCode('Cuba', '+53', 'cu'),
    CountryCode('Cyprus', '+357', 'cy'),
    CountryCode('Czech Republic', '+420', 'cz'),
    CountryCode('Denmark', '+45', 'dk'),
    CountryCode('Djibouti', '+253', 'dj'),
    CountryCode('Dominica', '+1-767', 'dm'),
    CountryCode('Dominican Republic', '+1-809', 'do'),
    CountryCode('Ecuador', '+593', 'ec'),
    CountryCode('Egypt', '+20', 'eg'),
    CountryCode('El Salvador', '+503', 'sv'),
    CountryCode('Equatorial Guinea', '+240', 'gq'),
    CountryCode('Eritrea', '+291', 'er'),
    CountryCode('Estonia', '+372', 'ee'),
    CountryCode('Eswatini', '+268', 'sz'),
    CountryCode('Ethiopia', '+251', 'et'),
    CountryCode('Fiji', '+679', 'fj'),
    CountryCode('Finland', '+358', 'fi'),
    CountryCode('France', '+33', 'fr'),
    CountryCode('Gabon', '+241', 'ga'),
    CountryCode('Gambia', '+220', 'gm'),
    CountryCode('Georgia', '+995', 'ge'),
    CountryCode('Germany', '+49', 'de'),
    CountryCode('Ghana', '+233', 'gh'),
    CountryCode('Greece', '+30', 'gr'),
    CountryCode('Grenada', '+1-473', 'gd'),
    CountryCode('Guatemala', '+502', 'gt'),
    CountryCode('Guinea', '+224', 'gn'),
    CountryCode('Guinea-Bissau', '+245', 'gw'),
    CountryCode('Guyana', '+592', 'gy'),
    CountryCode('Haiti', '+509', 'ht'),
    CountryCode('Honduras', '+504', 'hn'),
    CountryCode('Hungary', '+36', 'hu'),
    CountryCode('Iceland', '+354', 'is'),
    CountryCode('India', '+91', 'in'),
    CountryCode('Indonesia', '+62', 'id'),
    CountryCode('Iran', '+98', 'ir'),
    CountryCode('Iraq', '+964', 'iq'),
    CountryCode('Ireland', '+353', 'ie'),
    CountryCode('Israel', '+972', 'il'),
    CountryCode('Italy', '+39', 'it'),
    CountryCode('Jamaica', '+1-876', 'jm'),
    CountryCode('Jordan', '+962', 'jo'),
    CountryCode('Japan', '+81', 'jp'),
    CountryCode('Kazakhstan', '+7', 'kz'),
    CountryCode('Kenya', '+254', 'ke'),
    CountryCode('Kiribati', '+686', 'ki'),
    CountryCode('Korea, North', '+850', 'kp'),
    CountryCode('Korea, South', '+82', 'kr'),
    CountryCode('Kosovo', '+383', 'xk'),
    CountryCode('Kuwait', '+965', 'kw'),
    CountryCode('Kyrgyzstan', '+996', 'kg'),
    CountryCode('Laos', '+856', 'la'),
    CountryCode('Latvia', '+371', 'lv'),
    CountryCode('Lebanon', '+961', 'lb'),
    CountryCode('Lesotho', '+266', 'ls'),
    CountryCode('Liberia', '+231', 'lr'),
    CountryCode('Libya', '+218', 'ly'),
    CountryCode('Liechtenstein', '+423', 'li'),
    CountryCode('Lithuania', '+370', 'lt'),
    CountryCode('Luxembourg', '+352', 'lu'),
    CountryCode('Madagascar', '+261', 'mg'),
    CountryCode('Malawi', '+265', 'mw'),
    CountryCode('Malaysia', '+60', 'my'),
    CountryCode('Maldives', '+960', 'mv'),
    CountryCode('Mali', '+223', 'ml'),
    CountryCode('Malta', '+356', 'mt'),
    CountryCode('Marshall Islands', '+692', 'mh'),
    CountryCode('Mauritania', '+222', 'mr'),
    CountryCode('Mauritius', '+230', 'mu'),
    CountryCode('Mexico', '+52', 'mx'),
    CountryCode('Micronesia', '+691', 'fm'),
    CountryCode('Moldova', '+373', 'md'),
    CountryCode('Monaco', '+377', 'mc'),
    CountryCode('Mongolia', '+976', 'mn'),
    CountryCode('Montenegro', '+382', 'me'),
    CountryCode('Morocco', '+212', 'ma'),
    CountryCode('Mozambique', '+258', 'mz'),
    CountryCode('Myanmar', '+95', 'mm'),
    CountryCode('Namibia', '+264', 'na'),
    CountryCode('Nauru', '+674', 'nr'),
    CountryCode('Nepal', '+977', 'np'),
    CountryCode('Netherlands', '+31', 'nl'),
    CountryCode('New Zealand', '+64', 'nz'),
    CountryCode('Nicaragua', '+505', 'ni'),
    CountryCode('Niger', '+227', 'ne'),
    CountryCode('Nigeria', '+234', 'ng'),
    CountryCode('North Macedonia', '+389', 'mk'),
    CountryCode('Norway', '+47', 'no'),
    CountryCode('Oman', '+968', 'om'),
    CountryCode('Pakistan', '+92', 'pk'),
    CountryCode('Palau', '+680', 'pw'),
    CountryCode('Panama', '+507', 'pa'),
    CountryCode('Papua New Guinea', '+675', 'pg'),
    CountryCode('Paraguay', '+595', 'py'),
    CountryCode('Peru', '+51', 'pe'),
    CountryCode('Philippines', '+63', 'ph'),
    CountryCode('Poland', '+48', 'pl'),
    CountryCode('Portugal', '+351', 'pt'),
    CountryCode('Qatar', '+974', 'qa'),
    CountryCode('Romania', '+40', 'ro'),
    CountryCode('Russia', '+7', 'ru'),
    CountryCode('Rwanda', '+250', 'rw'),
    CountryCode('Saint Kitts and Nevis', '+1-869', 'kn'),
    CountryCode('Saint Lucia', '+1-758', 'lc'),
    CountryCode('Saint Vincent and the Grenadines', '+1-784', 'vc'),
    CountryCode('Samoa', '+685', 'ws'),
    CountryCode('San Marino', '+378', 'sm'),
    CountryCode('Sao Tome and Principe', '+239', 'st'),
    CountryCode('Saudi Arabia', '+966', 'sa'),
    CountryCode('Senegal', '+221', 'sn'),
    CountryCode('Serbia', '+381', 'rs'),
    CountryCode('Seychelles', '+248', 'sc'),
    CountryCode('Sierra Leone', '+232', 'sl'),
    CountryCode('Singapore', '+65', 'sg'),
    CountryCode('Slovakia', '+421', 'sk'),
    CountryCode('Slovenia', '+386', 'si'),
    CountryCode('Solomon Islands', '+677', 'sb'),
    CountryCode('Somalia', '+252', 'so'),
    CountryCode('South Africa', '+27', 'za'),
    CountryCode('South Sudan', '+211', 'ss'),
    CountryCode('Sri Lanka', '+94', 'lk'),
    CountryCode('Sudan', '+249', 'sd'),
    CountryCode('Suriname', '+597', 'sr'),
    CountryCode('Sweden', '+46', 'se'),
    CountryCode('Switzerland', '+41', 'ch'),
    CountryCode('Syria', '+963', 'sy'),
    CountryCode('Taiwan', '+886', 'tw'),
    CountryCode('Tajikistan', '+992', 'tj'),
    CountryCode('Tanzania', '+255', 'tz'),
    CountryCode('Thailand', '+66', 'th'),
    CountryCode('Timor-Leste', '+670', 'tl'),
    CountryCode('Togo', '+228', 'tg'),
    CountryCode('Tonga', '+676', 'to'),
    CountryCode('Trinidad and Tobago', '+1-868', 'tt'),
    CountryCode('Tunisia', '+216', 'tn'),
    CountryCode('Turkey', '+90', 'tr'),
    CountryCode('Turkmenistan', '+993', 'tm'),
    CountryCode('Tuvalu', '+688', 'tv'),
    CountryCode('Uganda', '+256', 'ug'),
    CountryCode('Ukraine', '+380', 'ua'),
    CountryCode('United Arab Emirates', '+971', 'ae'),
    CountryCode('United Kingdom', '+44', 'gb'),
    CountryCode('United States', '+1', 'us'),
    CountryCode('Uruguay', '+598', 'uy'),
    CountryCode('Uzbekistan', '+998', 'uz'),
    CountryCode('Vanuatu', '+678', 'vu'),
    CountryCode('Vatican City', '+379', 'va'),
    CountryCode('Venezuela', '+58', 've'),
    CountryCode('Vietnam', '+84', 'vn'),
    CountryCode('Yemen', '+967', 'ye'),
    CountryCode('Zambia', '+260', 'zm'),
    CountryCode('Zimbabwe', '+263', 'zw'),
  ];
}

class PhoneField extends StatefulWidget {
  final String? label;
  final String? prefixText;
  final String? countryPrefix;
  final bool enableBorder;

  final String hint;
  final bool isRequired;
  final bool enabledBorder;
  final String? initialValue;

  final IconData? icon;

  final Function(String text, String countryCode)? onChanged;

  const PhoneField({
    super.key,
    this.isRequired = true,
    this.label,
    this.enableBorder = true,
    this.prefixText,
    this.hint = "",
    this.countryPrefix,
    this.icon,
    required this.onChanged,
    this.enabledBorder = true,
    required this.initialValue,
  });

  @override
  State<PhoneField> createState() => _TSLFieldState();
}

class _TSLFieldState extends State<PhoneField> {
  late FocusNode focusNode;
  late CountryCode selectedCode;

  @override
  void initState() {
    focusNode = FocusNode();
    getCountryCode();
    super.initState();
  }

  String? updatedInitialValue;

  getCountryCode() {
    if (widget.initialValue == null) {
      setState(() {
        selectedCode = CountryCode.countryCodes.first;
      });
    } else {
      if (widget.initialValue!.contains("-")) {
        setState(() {
          selectedCode = CountryCode.countryCodes
                  .where((element) =>
                      element.countryCode == widget.initialValue!.split("-")[0])
                  .firstOrNull ??
              CountryCode.countryCodes.first;
          updatedInitialValue = widget.initialValue!.split("-")[1];
        });
      } else {
        setState(() {
          selectedCode = CountryCode.countryCodes.first;
          updatedInitialValue = widget.initialValue!;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimens.baseSize / 2),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(focusNode);
        },
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
              initialValue: updatedInitialValue,
              onChanged: (e) {
                if (widget.onChanged != null) {
                  if (e.isEmpty) {
                    widget.onChanged!("", "");

                    return;
                  }
                  widget.onChanged!(e, "${selectedCode.countryCode}-");
                  setState(() {
                    updatedInitialValue = e;
                  });
                }
              },
              validator: (value) {
                if (!widget.isRequired) {
                  return null;
                }
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              keyboardType: TextInputType.phone,
              focusNode: focusNode,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
                filled: false,
                prefixIcon: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: EdgeInsets.only(left: Dimens.defaultMargin),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {
                          showMenu(
                            context: context,
                            position: const RelativeRect.fromLTRB(0, 0, 0, 0),
                            items: CountryCode.countryCodes
                                .map(
                                  (e) => PopupMenuItem<CountryCode>(
                                    value: e,
                                    child: Row(
                                      children: [
                                        Flag.fromString(
                                            widget.countryPrefix ??
                                                e.countryPrefix.toUpperCase(),
                                            height: 17,
                                            width: 17,
                                            borderRadius: 1000,
                                            fit: BoxFit.fill),
                                        Dimens.space(1),
                                        Flexible(
                                          child: Text(e.countryName),
                                        ),
                                        // Flexible(
                                        //   child: Text(currentLocale == "ja"
                                        //       ? e.countryNameInJapan
                                        //       : e.countryName),
                                        // ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ).then((CountryCode? value) {
                            if (value != null) {
                              setState(() {
                                selectedCode = value;
                              });
                              if (widget.onChanged != null &&
                                  updatedInitialValue != null &&
                                  updatedInitialValue!.isNotEmpty) {
                                if (updatedInitialValue!.length == 1) {
                                  widget.onChanged!("", "");
                                  return;
                                }
                                widget.onChanged!(
                                    updatedInitialValue!,
                                    value.countryCode == "+81"
                                        ? ""
                                        : "${value.countryCode}-");
                              }
                            }
                          });
                        },
                        child: Row(
                          children: [
                            Flag.fromString(selectedCode.countryPrefix,
                                height: 17,
                                width: 17,
                                borderRadius: 1000,
                                fit: BoxFit.fill),
                            const Icon(
                              Icons.arrow_drop_down_rounded,
                              color: Colors.black,
                            ),
                            Container(
                              width: 1,
                              color: AppColors.neutral100,
                              height: 20,
                            ),
                            Dimens.space(1),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                hintStyle: TextStyle(color: AppColors.neutral100),
                hintText: "XXX-XXXX-XXXX",
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String formatPhoneNumber(String phoneNumber, CountryCode selectedCountryCode) {
  String cleanedNumber = phoneNumber;
  if (phoneNumber.startsWith('0')) {
    cleanedNumber.substring(1, cleanedNumber.length).split(" ").join("");
  }

  String formattedNumber = '${selectedCountryCode.countryCode}$cleanedNumber';
  return formattedNumber;
}
