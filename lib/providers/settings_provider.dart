import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_cache.dart';

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
    // 1. Clear search history
    await prefs.remove('recent_searches');
    // 2. Clear API response cache
    await ApiCache.clear();
    notifyListeners();
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

  // ── Currency Converter Helper ──────────────────────────────────────────────
  double convertFromUgx(double ugxAmount) {
    switch (_currency) {
      case 'USD':
        return ugxAmount / 3700.0;
      case 'EUR':
        return ugxAmount / 4000.0;
      case 'GBP':
        return ugxAmount / 4700.0;
      case 'UGX':
      default:
        return ugxAmount;
    }
  }

  String formatPrice(double priceInUgx, {bool compact = false, bool appendPeriod = false}) {
    final double converted = convertFromUgx(priceInUgx);
    final String symbol = _currency;
    String symbolPrefix = '$symbol ';
    
    if (_currency == 'USD') symbolPrefix = '\$';
    else if (_currency == 'EUR') symbolPrefix = '€';
    else if (_currency == 'GBP') symbolPrefix = '£';
    
    String formattedAmount;
    if (compact) {
      if (converted >= 1000000000) {
        formattedAmount = '$symbolPrefix${(converted / 1000000000.0).toStringAsFixed(1)}B';
      } else if (converted >= 1000000) {
        formattedAmount = '$symbolPrefix${(converted / 1000000.0).toStringAsFixed(1)}M';
      } else if (converted >= 1000) {
        formattedAmount = '$symbolPrefix${(converted / 1000.0).toStringAsFixed(0)}K';
      } else {
        formattedAmount = '$symbolPrefix${converted.toStringAsFixed(0)}';
      }
    } else {
      final String raw = converted.toStringAsFixed(0);
      final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
      formattedAmount = '$symbolPrefix${raw.replaceAllMapped(reg, (Match m) => '${m[1]},')}';
    }
    
    return appendPeriod ? formattedAmount : formattedAmount;
  }

  // ── Translation lookup mapping ─────────────────────────────────────────────
  static const Map<String, Map<String, String>> _localizedValues = {
    'English': {
      'welcome_subtitle': 'Find your next home with confidence.',
      'explore': 'Explore',
      'saved': 'Saved',
      'compare': 'Compare',
      'new_listings': 'New Listings',
      'quick_actions': 'Quick Actions',
      'filter': 'Filter',
      'featured_properties': 'Featured Properties',
      'recent_properties': 'Recent Properties',
      'all_properties': 'All Properties',
      'buy': 'Buy',
      'rent': 'Rent',
      'stay': 'Stay',
      'land': 'Land',
      'settings': 'Settings',
      'dark_mode': 'Dark Mode',
      'light_mode': 'Light Mode',
      'system_mode': 'System Default',
      'safety_first': 'Safety First',
      'search_placeholder': 'Search properties...',
      'currency_txt': 'Currency',
      'language_txt': 'Language',
      'appearance_txt': 'Appearance',
      'clear_cache_txt': 'Clear Cache',
      'cache_cleared_msg': 'Cache has been cleared successfully',
      'viewing_history': 'Viewing History',
      'appointments': 'Appointments',
      'property_updates': 'Property Updates',
      'appointment_reminders': 'Appointment Reminders',
      'price_changes': 'Price Changes',
    },
    'Luganda': {
      'welcome_subtitle': 'Noonya enju yo eddako n’obwesige.',
      'explore': 'Noonya',
      'saved': 'Ebiterekedwa',
      'compare': 'Geraageranya',
      'new_listings': 'Ebyakateesebwa',
      'quick_actions': 'Ebyangu',
      'filter': 'Sunsula',
      'featured_properties': 'Ebizimbe Ebirondeddwa',
      'recent_properties': 'Ebyakabaawo',
      'all_properties': 'Ebizimbe Byonna',
      'buy': 'Gula',
      'rent': 'Pangisa',
      'stay': 'Sula',
      'land': 'Ettaka',
      'settings': 'Ebiragiro',
      'dark_mode': 'Kizikiza',
      'light_mode': 'Kitangaala',
      'system_mode': 'Enkyukakyuka ya Wansi',
      'safety_first': 'Okwerinda Okusooka',
      'search_placeholder': 'Noonya ebizimbe...',
      'currency_txt': 'Ekirabo',
      'language_txt': 'Olulimi',
      'appearance_txt': 'Endabika',
      'clear_cache_txt': 'Siimuula Okutereka',
      'cache_cleared_msg': 'Okutereka kusiimuliddwa bulungi',
      'viewing_history': 'Ebyalambuddwa',
      'appointments': 'Okulaga okulaba',
      'property_updates': 'Ebizimbe ebyakateesebwa',
      'appointment_reminders': 'Okujjukiza okulaba',
      'price_changes': 'Enkyukakyuka y’ebisale',
    },
    'Swahili': {
      'welcome_subtitle': 'Tafuta nyumba yako ijayo kwa ujasiri.',
      'explore': 'Vumbua',
      'saved': 'Zilizohifadhiwa',
      'compare': 'Linganisha',
      'new_listings': 'Orodha Mpya',
      'quick_actions': 'Hatua za Haraka',
      'filter': 'Chuja',
      'featured_properties': 'Majengo Yaliyoangaziwa',
      'recent_properties': 'Majengo ya Hivi Karibuni',
      'all_properties': 'Majengo Yote',
      'buy': 'Nunua',
      'rent': 'Kodi',
      'stay': 'Lala',
      'land': 'Kiwanja',
      'settings': 'Mipangilio',
      'dark_mode': 'Hali ya Giza',
      'light_mode': 'Hali ya Mwanga',
      'system_mode': 'Mfumo wa Kawaida',
      'safety_first': 'Usalama Kwanza',
      'search_placeholder': 'Tafuta majengo...',
      'currency_txt': 'Sarafu',
      'language_txt': 'Lugha',
      'appearance_txt': 'Mwonekano',
      'clear_cache_txt': 'Futa Akiba',
      'cache_cleared_msg': 'Akiba imefutwa kikamilifu',
      'viewing_history': 'Historia ya Kutazama',
      'appointments': 'Miadi ya Vikao',
      'property_updates': 'Sasisho za Majengo',
      'appointment_reminders': 'Vikumbusho vya Miadi',
      'price_changes': 'Mabadiliko ya Bei',
    },
    'French': {
      'welcome_subtitle': 'Trouvez votre prochaine maison en toute confiance.',
      'explore': 'Explorer',
      'saved': 'Enregistré',
      'compare': 'Comparer',
      'new_listings': 'Nouvelles Annonces',
      'quick_actions': 'Actions Rapides',
      'filter': 'Filtrer',
      'featured_properties': 'Propriétés en Vedette',
      'recent_properties': 'Propriétés Récentes',
      'all_properties': 'Toutes les Propriétés',
      'buy': 'Acheter',
      'rent': 'Louer',
      'stay': 'Séjourner',
      'land': 'Terrain',
      'settings': 'Paramètres',
      'dark_mode': 'Mode Sombre',
      'light_mode': 'Mode Clair',
      'system_mode': 'Défaut Système',
      'safety_first': 'Sécurité d\'abord',
      'search_placeholder': 'Rechercher des propriétés...',
      'currency_txt': 'Devise',
      'language_txt': 'Langue',
      'appearance_txt': 'Apparence',
      'clear_cache_txt': 'Vider le Cache',
      'cache_cleared_msg': 'Le cache a été vidé avec succès',
      'viewing_history': 'Historique des Vues',
      'appointments': 'Rendez-vous',
      'property_updates': 'Mises à jour Propriété',
      'appointment_reminders': 'Rappels de Rendez-vous',
      'price_changes': 'Changements de Prix',
    }
  };

  String translate(String key) {
    return _localizedValues[_language]?[key] ?? _localizedValues['English']?[key] ?? key;
  }
}
