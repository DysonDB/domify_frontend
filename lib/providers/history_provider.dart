// 📁 lib/providers/history_provider.dart — tracks recently viewed properties
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewedProperty {
  final String id;
  final String title;
  final String location;
  final String imageUrl;
  final double price;
  final String purpose; // 'rent' | 'sale'
  final DateTime viewedAt;

  ViewedProperty({
    required this.id,
    required this.title,
    required this.location,
    required this.imageUrl,
    required this.price,
    required this.purpose,
    required this.viewedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'location': location,
        'imageUrl': imageUrl,
        'price': price,
        'purpose': purpose,
        'viewedAt': viewedAt.toIso8601String(),
      };

  factory ViewedProperty.fromJson(Map<String, dynamic> j) => ViewedProperty(
        id: j['id'] as String,
        title: j['title'] as String,
        location: j['location'] as String,
        imageUrl: j['imageUrl'] as String,
        price: (j['price'] as num).toDouble(),
        purpose: j['purpose'] as String,
        viewedAt: DateTime.parse(j['viewedAt'] as String),
      );
}

class HistoryProvider with ChangeNotifier {
  static const String _key = 'viewing_history';
  static const int _maxItems = 50;

  final List<ViewedProperty> _history = [];

  List<ViewedProperty> get history =>
      List<ViewedProperty>.unmodifiable(_history);

  int get count => _history.length;

  HistoryProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final List<dynamic> parsed = json.decode(raw) as List<dynamic>;
      _history.clear();
      _history.addAll(
        parsed
            .map((e) => ViewedProperty.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      json.encode(_history.map((v) => v.toJson()).toList()),
    );
  }

  Future<void> recordView(ViewedProperty property) async {
    // Remove existing entry for same property so it rises to top
    _history.removeWhere((v) => v.id == property.id);
    _history.insert(0, property);
    // Cap at max
    if (_history.length > _maxItems) {
      _history.removeRange(_maxItems, _history.length);
    }
    notifyListeners();
    await _save();
  }

  Future<void> removeEntry(String propertyId) async {
    _history.removeWhere((v) => v.id == propertyId);
    notifyListeners();
    await _save();
  }

  Future<void> clearAll() async {
    _history.clear();
    notifyListeners();
    await _save();
  }
}
