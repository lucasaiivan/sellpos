import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const String baseUrl = 'http://localhost:8080';
  
  print('=== Debug Test Printer Endpoint ===\n');
  
  try {
    print('🔄 Enviando GET a /test-printer...');
    final getResponse = await http.get(
      Uri.parse('$baseUrl/test-printer'),
    ).timeout(Duration(seconds: 10));
    
    print('✅ GET Status: ${getResponse.statusCode}');
    print('📄 GET Respuesta: ${getResponse.body}\n');
  } catch (e) {
    print('❌ GET Error: $e\n');
  }
  
  try {
    print('🔄 Enviando POST a /test-printer...');
    final postResponse = await http.post(
      Uri.parse('$baseUrl/test-printer'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({}),
    ).timeout(Duration(seconds: 10));
    
    print('✅ POST Status: ${postResponse.statusCode}');
    print('📄 POST Respuesta: ${postResponse.body}\n');
  } catch (e) {
    print('❌ POST Error: $e\n');
  }
  
  // Lista de todos los endpoints para verificar
  final endpoints = ['/status', '/configure-printer', '/print-ticket', '/test-printer'];
  
  print('=== Verificando todos los endpoints ===');
  for (final endpoint in endpoints) {
    try {
      if (endpoint == '/status') {
        final response = await http.get(Uri.parse('$baseUrl$endpoint'));
        print('$endpoint: ${response.statusCode}');
      } else {
        final response = await http.post(
          Uri.parse('$baseUrl$endpoint'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({}),
        );
        print('$endpoint: ${response.statusCode}');
      }
    } catch (e) {
      print('$endpoint: ERROR - $e');
    }
  }
}
