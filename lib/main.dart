import 'package:activity_tracker/generated/l10n.dart';
import 'package:activity_tracker/pages/home_screen.dart';
import 'package:activity_tracker/pages/login_screen.dart';
import 'package:activity_tracker/pages/registration_screen.dart';
import 'package:activity_tracker/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  final locale = await _getLocaleFromCache();
  runApp(ActivityTrackerApp(locale: locale));
}

Future<Locale> _getLocaleFromCache() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? localeString = prefs.getString('locale');

  if (localeString != null && localeString == 'bs_BA') {
    return Locale('bs', 'BA');
  }
  return Locale('en', 'US');
}

class ActivityTrackerApp extends StatefulWidget {
  final Locale locale;

  ActivityTrackerApp({required this.locale});

  static void setLocale(BuildContext context, Locale newLocale) {
    _ActivityTrackerAppState state =
        context.findAncestorStateOfType<_ActivityTrackerAppState>()!;
    state.setLocale(newLocale);
  }

  @override
  _ActivityTrackerAppState createState() => _ActivityTrackerAppState();
}

class _ActivityTrackerAppState extends State<ActivityTrackerApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.locale;
  }

  void setLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Activity Tracker',
      locale: _locale,
      supportedLocales: [
        Locale('en', 'US'),
        Locale('bs', 'BA'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        S.delegate
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode &&
              supportedLocale.countryCode == locale?.countryCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegistrationScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
