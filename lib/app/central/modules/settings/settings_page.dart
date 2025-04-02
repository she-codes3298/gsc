import 'package:flutter/material.dart';
import 'package:gsc/app/central/common/translatable_text.dart';


class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TranslatableText("Settings", style: TextStyle(color: Colors.white)),
    );
  }
}
