import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';

class DarkModeSwitch extends StatelessWidget {
  const DarkModeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final themeOfContext = Theme.of(context);
    final providerOfContext = Provider.of<ThemeProvider>(
      context,
      listen: false,
    );
    return SwitchListTile(
      title: const Text(
        'Dark Mode',
        style: TextStyle(
          fontSize: 20.0,
        ),
      ),
      value: themeOfContext.brightness == Brightness.dark,
      selected: themeOfContext.brightness == Brightness.dark,
      onChanged: (newValue) {
        final newThemeMode =
            newValue ? ThemeModeType.dark : ThemeModeType.light;
        providerOfContext.setThemeMode(newThemeMode);
      },
      secondary: const Icon(Icons.dark_mode_rounded),
    );
  }
}
