// 📁 lib/providers/appointments_provider.dart — stores booked appointments locally
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppointmentStatus { pending, confirmed, cancelled, completed }

class Appointment {
  final String id;
  final String propertyId;
  final String propertyTitle;
  final String propertyLocation;
  final String propertyImageUrl;
  final String name;
  final String phone;
  final String email;
  final DateTime appointmentTime;
  final String duration;
  final String purpose;
  final String? notes;
  final AppointmentStatus status;
  final DateTime bookedAt;

  Appointment({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.propertyLocation,
    required this.propertyImageUrl,
    required this.name,
    required this.phone,
    required this.email,
    required this.appointmentTime,
    required this.duration,
    required this.purpose,
    this.notes,
    this.status = AppointmentStatus.pending,
    required this.bookedAt,
  });

  Appointment copyWith({AppointmentStatus? status}) => Appointment(
        id: id,
        propertyId: propertyId,
        propertyTitle: propertyTitle,
        propertyLocation: propertyLocation,
        propertyImageUrl: propertyImageUrl,
        name: name,
        phone: phone,
        email: email,
        appointmentTime: appointmentTime,
        duration: duration,
        purpose: purpose,
        notes: notes,
        status: status ?? this.status,
        bookedAt: bookedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'propertyId': propertyId,
        'propertyTitle': propertyTitle,
        'propertyLocation': propertyLocation,
        'propertyImageUrl': propertyImageUrl,
        'name': name,
        'phone': phone,
        'email': email,
        'appointmentTime': appointmentTime.toIso8601String(),
        'duration': duration,
        'purpose': purpose,
        'notes': notes,
        'status': status.name,
        'bookedAt': bookedAt.toIso8601String(),
      };

  factory Appointment.fromJson(Map<String, dynamic> j) => Appointment(
        id: j['id'] as String,
        propertyId: j['propertyId'] as String,
        propertyTitle: j['propertyTitle'] as String,
        propertyLocation: j['propertyLocation'] as String,
        propertyImageUrl: j['propertyImageUrl'] as String,
        name: j['name'] as String,
        phone: j['phone'] as String,
        email: j['email'] as String,
        appointmentTime: DateTime.parse(j['appointmentTime'] as String),
        duration: j['duration'] as String,
        purpose: j['purpose'] as String,
        notes: j['notes'] as String?,
        status: AppointmentStatus.values.firstWhere(
          (s) => s.name == j['status'],
          orElse: () => AppointmentStatus.pending,
        ),
        bookedAt: DateTime.parse(j['bookedAt'] as String),
      );
}

class AppointmentsProvider with ChangeNotifier {
  static const String _key = 'appointments_v2';

  final List<Appointment> _appointments = [];

  List<Appointment> get appointments =>
      List<Appointment>.unmodifiable(_appointments);

  List<Appointment> get upcoming => _appointments
      .where((a) =>
          a.appointmentTime.isAfter(DateTime.now()) &&
          a.status != AppointmentStatus.cancelled)
      .toList()
    ..sort((a, b) => a.appointmentTime.compareTo(b.appointmentTime));

  List<Appointment> get past => _appointments
      .where((a) =>
          a.appointmentTime.isBefore(DateTime.now()) ||
          a.status == AppointmentStatus.cancelled)
      .toList()
    ..sort((a, b) => b.appointmentTime.compareTo(a.appointmentTime));

  int get pendingCount =>
      _appointments.where((a) => a.status == AppointmentStatus.pending).length;

  AppointmentsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final List<dynamic> parsed = json.decode(raw) as List<dynamic>;
      _appointments.clear();
      _appointments.addAll(
        parsed.map((e) => Appointment.fromJson(e as Map<String, dynamic>)),
      );
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      json.encode(_appointments.map((a) => a.toJson()).toList()),
    );
  }

  Future<void> addAppointment(Appointment appointment) async {
    _appointments.insert(0, appointment);
    notifyListeners();
    await _save();
  }

  Future<void> cancelAppointment(String id) async {
    final index = _appointments.indexWhere((a) => a.id == id);
    if (index != -1) {
      _appointments[index] = _appointments[index].copyWith(
        status: AppointmentStatus.cancelled,
      );
      notifyListeners();
      await _save();
    }
  }

  Future<void> removeAppointment(String id) async {
    _appointments.removeWhere((a) => a.id == id);
    notifyListeners();
    await _save();
  }

  Future<void> clearAll() async {
    _appointments.clear();
    notifyListeners();
    await _save();
  }

  bool hasAppointmentForProperty(String propertyId) =>
      _appointments.any((a) =>
          a.propertyId == propertyId &&
          a.status != AppointmentStatus.cancelled &&
          a.appointmentTime.isAfter(DateTime.now()));
}
