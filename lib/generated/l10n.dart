// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Sign in`
  String get signIn {
    return Intl.message(
      'Sign in',
      name: 'signIn',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `SIGN IN`
  String get signInButton {
    return Intl.message(
      'SIGN IN',
      name: 'signInButton',
      desc: '',
      args: [],
    );
  }

  /// `Don't have an account? `
  String get noAccount {
    return Intl.message(
      'Don\'t have an account? ',
      name: 'noAccount',
      desc: '',
      args: [],
    );
  }

  /// `SIGN UP`
  String get signUp {
    return Intl.message(
      'SIGN UP',
      name: 'signUp',
      desc: '',
      args: [],
    );
  }

  /// `Create your account`
  String get createAccount {
    return Intl.message(
      'Create your account',
      name: 'createAccount',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get confirmPassword {
    return Intl.message(
      'Confirm Password',
      name: 'confirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `CONTINUE`
  String get continueButton {
    return Intl.message(
      'CONTINUE',
      name: 'continueButton',
      desc: '',
      args: [],
    );
  }

  /// `Biometric Profile`
  String get biometricProfile {
    return Intl.message(
      'Biometric Profile',
      name: 'biometricProfile',
      desc: '',
      args: [],
    );
  }

  /// `Weight`
  String get weight {
    return Intl.message(
      'Weight',
      name: 'weight',
      desc: '',
      args: [],
    );
  }

  /// `Height`
  String get height {
    return Intl.message(
      'Height',
      name: 'height',
      desc: '',
      args: [],
    );
  }

  /// `Gender`
  String get gender {
    return Intl.message(
      'Gender',
      name: 'gender',
      desc: '',
      args: [],
    );
  }

  /// `Year of Birth`
  String get yearOfBirth {
    return Intl.message(
      'Year of Birth',
      name: 'yearOfBirth',
      desc: '',
      args: [],
    );
  }

  /// `CONFIRM`
  String get confirmButton {
    return Intl.message(
      'CONFIRM',
      name: 'confirmButton',
      desc: '',
      args: [],
    );
  }

  /// `Have an account? `
  String get haveAccount {
    return Intl.message(
      'Have an account? ',
      name: 'haveAccount',
      desc: '',
      args: [],
    );
  }

  /// `SKIP`
  String get skipButton {
    return Intl.message(
      'SKIP',
      name: 'skipButton',
      desc: '',
      args: [],
    );
  }

  /// `This field is required`
  String get fieldRequired {
    return Intl.message(
      'This field is required',
      name: 'fieldRequired',
      desc: '',
      args: [],
    );
  }

  /// `Invalid email address`
  String get invalidEmail {
    return Intl.message(
      'Invalid email address',
      name: 'invalidEmail',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 6 characters`
  String get passwordTooShort {
    return Intl.message(
      'Password must be at least 6 characters',
      name: 'passwordTooShort',
      desc: '',
      args: [],
    );
  }

  /// `Passwords do not match`
  String get passwordMismatch {
    return Intl.message(
      'Passwords do not match',
      name: 'passwordMismatch',
      desc: '',
      args: [],
    );
  }

  /// `Welcome back`
  String get welcomeBack {
    return Intl.message(
      'Welcome back',
      name: 'welcomeBack',
      desc: '',
      args: [],
    );
  }

  /// `My Activities`
  String get myActivities {
    return Intl.message(
      'My Activities',
      name: 'myActivities',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message(
      'Home',
      name: 'home',
      desc: '',
      args: [],
    );
  }

  /// `Statistics`
  String get statistics {
    return Intl.message(
      'Statistics',
      name: 'statistics',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: '',
      args: [],
    );
  }

  /// `START NEW`
  String get startNew {
    return Intl.message(
      'START NEW',
      name: 'startNew',
      desc: '',
      args: [],
    );
  }

  /// `My Profile`
  String get myProfile {
    return Intl.message(
      'My Profile',
      name: 'myProfile',
      desc: '',
      args: [],
    );
  }

  /// `Email:`
  String get email_profile {
    return Intl.message(
      'Email:',
      name: 'email_profile',
      desc: '',
      args: [],
    );
  }

  /// `Current Language:`
  String get currentLanguage {
    return Intl.message(
      'Current Language:',
      name: 'currentLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Weight:`
  String get weight_profile {
    return Intl.message(
      'Weight:',
      name: 'weight_profile',
      desc: '',
      args: [],
    );
  }

  /// `Height:`
  String get height_profile {
    return Intl.message(
      'Height:',
      name: 'height_profile',
      desc: '',
      args: [],
    );
  }

  /// `Year of Birth:`
  String get yearOfBirth_profile {
    return Intl.message(
      'Year of Birth:',
      name: 'yearOfBirth_profile',
      desc: '',
      args: [],
    );
  }

  /// `Gender:`
  String get gender_profile {
    return Intl.message(
      'Gender:',
      name: 'gender_profile',
      desc: '',
      args: [],
    );
  }

  /// `Log Out`
  String get logout {
    return Intl.message(
      'Log Out',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `Delete Account`
  String get deleteAccount {
    return Intl.message(
      'Delete Account',
      name: 'deleteAccount',
      desc: '',
      args: [],
    );
  }

  /// `Male`
  String get male {
    return Intl.message(
      'Male',
      name: 'male',
      desc: '',
      args: [],
    );
  }

  /// `Female`
  String get female {
    return Intl.message(
      'Female',
      name: 'female',
      desc: '',
      args: [],
    );
  }

  /// `My Training Stats`
  String get myTrainingStats {
    return Intl.message(
      'My Training Stats',
      name: 'myTrainingStats',
      desc: '',
      args: [],
    );
  }

  /// `All Trainings`
  String get allTrainings {
    return Intl.message(
      'All Trainings',
      name: 'allTrainings',
      desc: '',
      args: [],
    );
  }

  /// `Running`
  String get running {
    return Intl.message(
      'Running',
      name: 'running',
      desc: '',
      args: [],
    );
  }

  /// `Cycling`
  String get cycling {
    return Intl.message(
      'Cycling',
      name: 'cycling',
      desc: '',
      args: [],
    );
  }

  /// `Number of Trainings`
  String get numberOfTrainings {
    return Intl.message(
      'Number of Trainings',
      name: 'numberOfTrainings',
      desc: '',
      args: [],
    );
  }

  /// `Total Time Spent`
  String get totalTimeSpent {
    return Intl.message(
      'Total Time Spent',
      name: 'totalTimeSpent',
      desc: '',
      args: [],
    );
  }

  /// `Total Distance Covered`
  String get totalDistanceCovered {
    return Intl.message(
      'Total Distance Covered',
      name: 'totalDistanceCovered',
      desc: '',
      args: [],
    );
  }

  /// `Total Calories Burned`
  String get totalCaloriesBurned {
    return Intl.message(
      'Total Calories Burned',
      name: 'totalCaloriesBurned',
      desc: '',
      args: [],
    );
  }

  /// `Top Speed`
  String get topSpeed {
    return Intl.message(
      'Top Speed',
      name: 'topSpeed',
      desc: '',
      args: [],
    );
  }

  /// `Longest Session`
  String get longestSession {
    return Intl.message(
      'Longest Session',
      name: 'longestSession',
      desc: '',
      args: [],
    );
  }

  /// `Longest Route Covered`
  String get longestRouteCovered {
    return Intl.message(
      'Longest Route Covered',
      name: 'longestRouteCovered',
      desc: '',
      args: [],
    );
  }

  /// `Average Time Between Sessions`
  String get avgTimeBetweenSessions {
    return Intl.message(
      'Average Time Between Sessions',
      name: 'avgTimeBetweenSessions',
      desc: '',
      args: [],
    );
  }

  /// `START`
  String get start {
    return Intl.message(
      'START',
      name: 'start',
      desc: '',
      args: [],
    );
  }

  /// `STOP`
  String get stop {
    return Intl.message(
      'STOP',
      name: 'stop',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'bs'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
