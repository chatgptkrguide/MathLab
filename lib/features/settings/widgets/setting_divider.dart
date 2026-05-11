// Setting divider — thin horizontal divider used between setting tiles
// inside the settings cards.
import 'package:flutter/material.dart';

import '../../../shared/constants/constants.dart';

class SettingDivider extends StatelessWidget {
  const SettingDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: AppColors.borderLight,
    );
  }
}
