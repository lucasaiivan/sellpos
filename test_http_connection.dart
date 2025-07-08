import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const String baseUrl = 'http://localhost:8080';
  
  print('=== Prueba de Conexión HTTP SellPOS ===\n');
  
  // Función auxiliar para hacer peticiones con manejo de errores
  Future<void> makeRequest(String endpoint, String description, {Map<String, dynamic>? body}) async {
    try {
      print('🔄 $description...');
      
      http.Response response;
      if (body != null) {
        response = await http.post(
          Uri.parse('$baseUrl$endpoint'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        ).timeout(Duration(seconds: 10));
      } else {
        response = await http.get(
          Uri.parse('$baseUrl$endpoint'),
        ).timeout(Duration(seconds: 10));
      }
      
      print('✅ Status: ${response.statusCode}');
      
      if (response.headers['content-type']?.contains('application/json') == true) {
        final data = jsonDecode(response.body);
        print('📄 Respuesta: ${jsonEncode(data)}');
      } else {
        print('📄 Respuesta: ${response.body}');
      }
      
      print('');
    } catch (e) {
      print('❌ Error: $e\n');
    }
  }
  
  // 1. Verificar estado del servidor
  await makeRequest('/status', 'Verificando estado del servidor');
  
  // 2. Configurar impresora (usar nombre genérico para pruebas)
  await makeRequest('/configure-printer', 'Configurando impresora de prueba', body: {
    'printerName': 'prueba'
  });
  
  // 3. Probar impresión de ticket de prueba (con POST)
  await makeRequest('/test-printer', 'Enviando ticket de prueba', body: {});
  
  // 4. Imprimir ticket personalizado
  await makeRequest('/print-ticket', 'Imprimiendo ticket personalizado', body: {
    'businessName': 'Mi Tienda de Prueba',
    'products': [
      {
        'quantity': '2',
        'description': 'Producto A',
        'price': 15.50
      },
      {
        'quantity': '1', 
        'description': 'Producto B',
        'price': 25.00
      }
    ],
    'total': 56.00,
    'paymentMethod': 'Efectivo',
    'customerName': 'Cliente de Prueba',
    'cashReceived': 60.00,
    'change': 4.00
  });
  
  print('=== Prueba Completada ===');
  print('');
  print('📋 Endpoints disponibles:');
  print('  GET  $baseUrl/status - Estado del servidor');
  print('  POST $baseUrl/configure-printer - Configurar impresora');
  print('  POST $baseUrl/test-printer - Ticket de prueba');
  print('  POST $baseUrl/print-ticket - Imprimir ticket personalizado');
  print('');
  print('💡 Para usar desde aplicación web, envía peticiones POST a:');
  print('   $baseUrl/print-ticket');
  print('');
  print('📝 Formato del JSON para imprimir tickets:');
  print('''
{
  "businessName": "Nombre del Negocio",
  "products": [
    {
      "quantity": "2",
      "description": "Producto 1",
      "price": 10.50
    }
  ],
  "total": 21.00,
  "paymentMethod": "Efectivo",
  "customerName": "Nombre Cliente", // opcional
  "cashReceived": 25.00,           // opcional
  "change": 4.00                   // opcional
}
''');
}
