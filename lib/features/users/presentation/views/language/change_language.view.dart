import 'package:flutter/material.dart';
import 'package:letdem/common/widgets/appbar.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/extenstions/locale.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/l10n/locales.dart';
import 'package:letdem/notifiers/locale.notifier.dart';
import 'package:provider/provider.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(Dimens.defaultMargin),
        child: SafeArea(
          child: PrimaryButton(
            text: context.l10n.save,
            onTap: () {
              // Here you would update the app's language using your UserBloc
              NavigatorHelper.pop();
            },
          ),
        ),
      ),
      body: Consumer<LocaleProvider>(builder: (context, snapshot, _) {
        return StyledBody(
          children: [
            StyledAppBar(
              title: context.l10n.language,
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
                    children: L10n.all.map((language) {
                      return LanguageOption(
                        flag: "",
                        name: language == const Locale('en')
                            ? 'English'
                            : 'Español',
                        isSelected: snapshot.defaultLocale == language,
                        onTap: () {
                          context.read<LocaleProvider>().setLocale(language);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class LanguageOption extends StatelessWidget {
  final String flag;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageOption({
    super.key,
    required this.flag,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? AppColors.primary500
                        : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: AppColors.primary500),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
