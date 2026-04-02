import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ParticipationService {
  static const String historyKey = "participation_history";
  static const String pointsKey = "total_points";

  /// Task 4: Record participation including name, points, timestamp, and address
  static Future<void> recordParticipation(String fairName, int points, String address) async {
    final prefs = await SharedPreferences.getInstance();
    
    List<String> history = prefs.getStringList(historyKey) ?? [];
    String timestamp = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());
    
    final entry = jsonEncode({
      "name": fairName,
      "points": points,
      "time": timestamp,
      "address": address, // This field is now correctly handled
    });
    
    history.add(entry);
    await prefs.setStringList(historyKey, history);

    // Update cumulative total points
    int currentTotal = prefs.getInt(pointsKey) ?? 0;
    await prefs.setInt(pointsKey, currentTotal + points);
  }

  static Future<int> getTotalPoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(pointsKey) ?? 0;
  }

  static Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(historyKey) ?? [];
    return history.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
  }
}