import 'package:domain_ui/values/parcel_info_local_keys.dart';
import 'package:domain_ui/widgets/button/parcel_info_text_button.dart';
import 'package:domain_ui/widgets/text/parcel_info_text.dart';
import 'package:flutter/material.dart';

class SplashBody extends StatelessWidget {
  final VoidCallback onThemeToggle;

  const SplashBody({super.key, required this.onThemeToggle});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ParcelInfoText(ParcelInfoLocalKeys.of(context)!.splashTitle),
          ParcelInfoTextButton(
            ParcelInfoLocalKeys.of(context)!.splashButton,
            onPressed: onThemeToggle,
          ),
        ],
      ),
    );
  }
}
