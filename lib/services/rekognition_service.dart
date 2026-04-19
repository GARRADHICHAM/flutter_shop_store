import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class RekognitionService {
  static const String _endpoint =
      'https://xqap76lioe.execute-api.eu-north-1.amazonaws.com/detect-category';

  static Future<String?> detectCategory(Uint8List imageBytes) async {
    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image': base64Encode(imageBytes)}),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['category'] as String?;
  }
}
