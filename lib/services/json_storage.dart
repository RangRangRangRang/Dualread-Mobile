import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/storable.dart';

Future<List<T>> loadList<T>(
    String key, T Function(Map<String, dynamic>) fromMap) async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(key);
  if (raw == null) return [];
  final list = jsonDecode(raw) as List;
  return list.map((e) => fromMap(Map<String, dynamic>.from(e))).toList();
}

Future<void> saveList<T extends Storable>(String key, List<T> items) async {
  final prefs = await SharedPreferences.getInstance();
  final data = items.map((e) => e.toMap()).toList();
  await prefs.setString(key, jsonEncode(data));
}