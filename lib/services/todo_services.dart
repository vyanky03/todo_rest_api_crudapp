import 'dart:convert';

import 'package:http/http.dart' as http;

class TodoService {
  static Future<bool> deteletById(String id) async {
    //delete the item
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final resp = await http.delete(uri);
    return resp.statusCode == 200;
  }

  static Future<List?> fetchTodo() async {
    const url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final json = jsonDecode(resp.body) as Map;
      final result = json['items'] as List;
      return result;
    } else {
      return null;
    }
  }
}
