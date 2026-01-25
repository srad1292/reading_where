import 'dart:convert';

class DecodeHelper {

  static List<String> decodeListString(dynamic value) {
    if (value == null) return [];
    try {
      return List<String>.from(jsonDecode(value));
    } catch (_) {
      return [];
    }
  }
}