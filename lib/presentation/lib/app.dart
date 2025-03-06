import 'package:domain_ui/values/parcel_info_local_keys.dart';
import 'package:domain_ui/values/parcel_info_theme.dart';
import 'package:flutter/material.dart';
import 'package:presentation/router/parcel_info_router.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  Locale? _locale;
  ThemeMode? _themeMode;
  RouterConfig<Object>? routerConfig;

  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  void initState() {
    routerConfig = ParcelInfoRouter(
      onLanguageChange: _changeLanguage,
      onThemeToggle: _toggleTheme,
    ).getRouter();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: routerConfig,
      localizationsDelegates: ParcelInfoLocalKeys.localizationsDelegates,
      supportedLocales: ParcelInfoLocalKeys.supportedLocales,
      title: ParcelInfoLocalKeys.title,
      theme: ParcelInfoTheme.lightTheme,
      darkTheme: ParcelInfoTheme.darkTheme,
      locale: _locale,
      themeMode: _themeMode,
    );
  }
}
