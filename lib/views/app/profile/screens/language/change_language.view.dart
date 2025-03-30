import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/extenstions/user.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/global/widgets/appbar.dart';
import 'package:letdem/global/widgets/body.dart';
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/views/app/profile/widgets/settings_container.widget.dart';
import 'package:letdem/views/app/profile/widgets/settings_row.widget.dart';

class Language {
  final String name;
  final String code;
  final String flag;

  Language(this.name, this.code, this.flag);
}

class ChangeLanguageView extends StatefulWidget {
  const ChangeLanguageView({super.key});

  @override
  State<ChangeLanguageView> createState() => _ChangeLanguageViewState();
}

class _ChangeLanguageViewState extends State<ChangeLanguageView> {
  String _selectedLanguage = 'en'; // Default language

  final List<Language> _languages = [
    Language('English', 'en', '🇺🇸'),
    Language('Español', 'es', '🇪🇸'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding:  EdgeInsets.all(Dimens.defaultMargin),
        child: SafeArea(
          child: PrimaryButton(
            text: 'Save',
            onTap: () {
              // Here you would update the app's language using your UserBloc
              NavigatorHelper.pop();
            },
          ),
        ),
      ),
      body: StyledBody(
        children: [
          StyledAppBar(
            title: 'Language',
            onTap: () {
              NavigatorHelper.pop();
            },
            icon: Icons.close,
          ),
          Dimens.space(3),
          Expanded(
            child: ListView(
              children: [
                Column(
                    children: _languages.map((language) {
                      return LanguageOption(
                        flag: language.flag,
                        name: language.name,
                        isSelected: _selectedLanguage == language.code,
                        onTap: () {
                          setState(() {
                            _selectedLanguage = language.code;
                          });
                          // Here you would update the app's language using your UserBloc
                        },
                      );
                    }).toList(),
                  ),


              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LanguageOption extends StatelessWidget {
  final String flag;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageOption({
    Key? key,
    required this.flag,
    required this.name,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: isSelected
              ? AppColors.primary500.withOpacity(0.05)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? AppColors.primary500
                : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey.withOpacity(0.1),
                ),
                child: Text(
                  flag,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? AppColors.primary500
                        : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: AppColors.primary500
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}