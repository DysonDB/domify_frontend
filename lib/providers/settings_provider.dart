import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _propertyUpdatesKey = 'settings_property_updates';
  static const String _appointmentRemindersKey =
      'settings_appointment_reminders';
  static const String _priceChangesKey = 'settings_price_changes';
  static const String _languageKey = 'settings_language';
  static const String _currencyKey = 'settings_currency';
  static const String _profileNameKey = 'settings_profile_name';
  static const String _profilePhoneKey = 'settings_profile_phone';
  static const String _profileEmailKey = 'settings_profile_email';
  static const String _signedInKey = 'settings_signed_in';

  static const List<String> languages = <String>[
    'English',
    'Luganda',
    'Swahili',
    'French',
  ];

  static const Map<String, String> currencies = <String, String>{
    'UGX': 'Ugandan Shilling',
    'USD': 'US Dollar',
    'EUR': 'Euro',
    'GBP': 'British Pound',
  };

  SharedPreferences? _prefs;
  bool _propertyUpdatesEnabled = true;
  bool _appointmentRemindersEnabled = true;
  bool _priceChangesEnabled = false;
  bool _isSignedIn = true;
  String _language = languages.first;
  String _currency = 'UGX';
  String _profileName = 'Douglas Bagambe';
  String _profilePhone = '+256';
  String _profileEmail = 'douglasbagambe4@gmail.com';

  bool get propertyUpdatesEnabled => _propertyUpdatesEnabled;
  bool get appointmentRemindersEnabled => _appointmentRemindersEnabled;
  bool get priceChangesEnabled => _priceChangesEnabled;
  bool get isSignedIn => _isSignedIn;
  String get language => _language;
  String get currency => _currency;
  String get currencyName => currencies[_currency] ?? _currency;
  String get profileName => _profileName;
  String get profilePhone => _profilePhone;
  String get profileEmail => _profileEmail;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final SharedPreferences prefs = await _preferences();
    _propertyUpdatesEnabled = prefs.getBool(_propertyUpdatesKey) ?? true;
    _appointmentRemindersEnabled =
        prefs.getBool(_appointmentRemindersKey) ?? true;
    _priceChangesEnabled = prefs.getBool(_priceChangesKey) ?? false;
    _language = prefs.getString(_languageKey) ?? languages.first;
    _currency = prefs.getString(_currencyKey) ?? 'UGX';
    _profileName = prefs.getString(_profileNameKey) ?? _profileName;
    _profilePhone = prefs.getString(_profilePhoneKey) ?? _profilePhone;
    _profileEmail = prefs.getString(_profileEmailKey) ?? _profileEmail;
    _isSignedIn = prefs.getBool(_signedInKey) ?? true;
    notifyListeners();
  }

  Future<void> setPropertyUpdatesEnabled(bool value) async {
    final SharedPreferences prefs = await _preferences();
    _propertyUpdatesEnabled = value;
    await prefs.setBool(_propertyUpdatesKey, value);
    notifyListeners();
  }

  Future<void> setAppointmentRemindersEnabled(bool value) async {
    final SharedPreferences prefs = await _preferences();
    _appointmentRemindersEnabled = value;
    await prefs.setBool(_appointmentRemindersKey, value);
    notifyListeners();
  }

  Future<void> setPriceChangesEnabled(bool value) async {
    final SharedPreferences prefs = await _preferences();
    _priceChangesEnabled = value;
    await prefs.setBool(_priceChangesKey, value);
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    if (!languages.contains(language)) return;
    final SharedPreferences prefs = await _preferences();
    _language = language;
    await prefs.setString(_languageKey, language);
    notifyListeners();
  }

  Future<void> setCurrency(String currency) async {
    if (!currencies.containsKey(currency)) return;
    final SharedPreferences prefs = await _preferences();
    _currency = currency;
    await prefs.setString(_currencyKey, currency);
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    required String email,
  }) async {
    final SharedPreferences prefs = await _preferences();
    _profileName = name.trim();
    _profilePhone = phone.trim();
    _profileEmail = email.trim();
    await prefs.setString(_profileNameKey, _profileName);
    await prefs.setString(_profilePhoneKey, _profilePhone);
    await prefs.setString(_profileEmailKey, _profileEmail);
    notifyListeners();
  }

  Future<void> clearCachePreferences() async {
    final SharedPreferences prefs = await _preferences();
    await prefs.remove('recent_searches');
  }

  Future<void> signOut() async {
    final SharedPreferences prefs = await _preferences();
    _isSignedIn = false;
    await prefs.setBool(_signedInKey, false);
    notifyListeners();
  }

  Future<SharedPreferences> _preferences() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }
}
