import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/http_server_config.dart';
import '../../domain/entities/printer_entity.dart';
import '../../presentation/providers/printer_provider.dart';

class HttpServerService {
  static final Logger _logger = Logger();
  static HttpServer? _server;
  static HttpServerConfig _config = const HttpServerConfig();
  static PrinterProvider? _printerProvider;
  
  // Singleton
  static final HttpServerService _instance = HttpServerService._internal();
  factory HttpServerService() => _instance;
  HttpServerService._internal();

  static HttpServerConfig get config => _config;
  static bool get isRunning => _server != null;
  static String get serverUrl => 'http://${_config.host}:${_config.port}';

  /// Configura el PrinterProvider para usar en los endpoints
  static void setPrinterProvider(PrinterProvider? provider) {
    _printerProvider = provider;
  }

  /// Inicializa y carga la configuración guardada
  static Future<void> initialize() async {
    await _loadConfig();
    if (_config.isEnabled) {
      await startServer();
    }
  }

  /// Inicia el servidor HTTP
  static Future<bool> startServer() async {
    if (_server != null) {
      _logger.w('El servidor ya está ejecutándose');
      return true;
    }

    try {
      final router = Router()
        ..get('/status', _handleStatus)
        ..post('/configure-printer', _handleConfigurePrinter)
        ..post('/test-printer', _handleTestPrinter)
        ..post('/print-ticket', _handlePrintTicket)
        ..options('/<path|.*>', _handleOptions);

      final handler = Pipeline()
          .addMiddleware(corsHeaders())
          .addMiddleware(logRequests(logger: (message, isError) {
            if (isError) {
              _logger.e(message);
            } else {
              _logger.i(message);
            }
          }))
          .addHandler(router.call);

      _server = await shelf_io.serve(
        handler,
        _config.host,
        _config.port,
      );

      _logger.i('Servidor HTTP iniciado en ${serverUrl}');
      return true;
    } catch (e) {
      _logger.e('Error iniciando servidor HTTP: $e');
      return false;
    }
  }

  /// Detiene el servidor HTTP
  static Future<void> stopServer() async {
    if (_server != null) {
      await _server!.close();
      _server = null;
      _logger.i('Servidor HTTP detenido');
    }
  }

  /// Actualiza la configuración y reinicia el servidor si es necesario
  static Future<bool> updateConfig(HttpServerConfig newConfig) async {
    final wasRunning = isRunning;
    
    if (wasRunning) {
      await stopServer();
    }

    _config = newConfig;
    await _saveConfig();

    if (newConfig.isEnabled) {
      return await startServer();
    }
    
    return true;
  }

  /// Carga la configuración desde SharedPreferences
  static Future<void> _loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString('http_server_config');
      
      if (configJson != null) {
        final Map<String, dynamic> config = jsonDecode(configJson);
        _config = HttpServerConfig.fromJson(config);
      }
    } catch (e) {
      _logger.e('Error cargando configuración HTTP: $e');
    }
  }

  /// Guarda la configuración en SharedPreferences
  static Future<void> _saveConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('http_server_config', jsonEncode(_config.toJson()));
    } catch (e) {
      _logger.e('Error guardando configuración HTTP: $e');
    }
  }

  // Manejadores de endpoints

  static Future<Response> _handleStatus(Request request) async {
    final printerStatus = _printerProvider?.selectedPrinter?.isConnected == true
        ? 'Impresora conectada: ${_printerProvider?.selectedPrinter?.name}'
        : _printerProvider?.selectedPrinter != null
            ? 'Impresora seleccionada pero no conectada: ${_printerProvider?.selectedPrinter?.name}'
            : 'Sin impresora configurada';

    return Response.ok(
      jsonEncode({
        'status': 'ok',
        'message': 'Servidor de impresión activo',
        'timestamp': DateTime.now().toIso8601String(),
        'printer': printerStatus,
        'serverVersion': '1.0.0',
      }),
      headers: {'content-type': 'application/json'},
    );
  }

  static Future<Response> _handleConfigurePrinter(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);
      
      _logger.i('Configurando impresora: ${data['printerName']}');
      
      if (_printerProvider == null) {
        return Response(503,
          body: jsonEncode({
            'status': 'error',
            'message': 'Sistema de impresión no disponible',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final availablePrinters = _printerProvider!.printers;
      
      if (availablePrinters.isEmpty) {
        return Response(404,
          body: jsonEncode({
            'status': 'error',
            'message': 'No hay impresoras disponibles. Asegúrese de que hay impresoras conectadas y ejecute una búsqueda primero.',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Si el nombre es genérico (para pruebas), usar la primera impresora disponible
      final printerName = data['printerName']?.toString() ?? '';
      PrinterEntity? matchingPrinter;
      
      if (printerName.toLowerCase().contains('prueba') || 
          printerName.toLowerCase().contains('test') || 
          printerName.isEmpty ||
          !availablePrinters.any((p) => p.name?.toLowerCase().contains(printerName.toLowerCase()) ?? false)) {
        // Para pruebas o si no se encuentra coincidencia exacta, usar la primera impresora disponible
        matchingPrinter = availablePrinters.first;
        _logger.i('Usando primera impresora disponible: ${matchingPrinter.name}');
      } else {
        // Buscar por nombre específico
        matchingPrinter = availablePrinters.where(
          (printer) => printer.name?.toLowerCase().contains(
            printerName.toLowerCase()
          ) ?? false
        ).firstOrNull;
      }
      
      if (matchingPrinter != null) {
        await _printerProvider!.selectPrinter(matchingPrinter);
        final connected = await _printerProvider!.connectToSelectedPrinter();
        
        if (connected) {
          return Response.ok(
            jsonEncode({
              'status': 'ok',
              'message': 'Impresora configurada y conectada correctamente',
              'printer': matchingPrinter.name,
              'availablePrinters': availablePrinters.length,
            }),
            headers: {'content-type': 'application/json'},
          );
        } else {
          return Response(400,
            body: jsonEncode({
              'status': 'error',
              'message': 'Impresora encontrada pero no se pudo conectar: ${matchingPrinter.name}',
            }),
            headers: {'content-type': 'application/json'},
          );
        }
      } else {
        return Response(404,
          body: jsonEncode({
            'status': 'error',
            'message': 'Impresora "$printerName" no encontrada. Impresoras disponibles: ${availablePrinters.map((p) => p.name).join(', ')}',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
    } catch (e) {
      _logger.e('Error configurando impresora: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Error interno del servidor: $e',
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  static Future<Response> _handleTestPrinter(Request request) async {
    try {
      _logger.i('Solicitando prueba de impresión');
      
      if (_printerProvider == null) {
        return Response(503,
          body: jsonEncode({
            'status': 'error',
            'message': 'Sistema de impresión no disponible',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      if (_printerProvider!.selectedPrinter == null) {
        return Response(400,
          body: jsonEncode({
            'status': 'error',
            'message': 'No hay impresora seleccionada. Primero configure una impresora.',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      if (!(_printerProvider!.selectedPrinter?.isConnected ?? false)) {
        return Response(400,
          body: jsonEncode({
            'status': 'error',
            'message': 'La impresora seleccionada no está conectada',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      // Ejecutar prueba de impresión real
      await _printerProvider!.printTestTicket();
      
      return Response.ok(
        jsonEncode({
          'status': 'ok',
          'message': 'Ticket de prueba enviado a la impresora: ${_printerProvider!.selectedPrinter!.name}',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error en prueba de impresión: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Error en la prueba de impresión: $e',
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  static Future<Response> _handlePrintTicket(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);
      
      _logger.i('Imprimiendo ticket para: ${data['businessName']}');
      
      if (_printerProvider == null) {
        return Response(503,
          body: jsonEncode({
            'status': 'error',
            'message': 'Sistema de impresión no disponible',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      if (_printerProvider!.selectedPrinter == null) {
        return Response(400,
          body: jsonEncode({
            'status': 'error',
            'message': 'No hay impresora seleccionada. Primero configure una impresora.',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      if (!(_printerProvider!.selectedPrinter?.isConnected ?? false)) {
        return Response(400,
          body: jsonEncode({
            'status': 'error',
            'message': 'La impresora seleccionada no está conectada',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      // Extraer datos del request
      final businessName = data['businessName']?.toString() ?? 'Mi Negocio';
      final products = (data['products'] as List<dynamic>?)
          ?.map((p) => p as Map<String, dynamic>)
          .toList() ?? [];
      final total = (data['total'] as num?)?.toDouble() ?? 0.0;
      final paymentMethod = data['paymentMethod']?.toString() ?? 'Efectivo';
      final customerName = data['customerName']?.toString();
      final cashReceived = (data['cashReceived'] as num?)?.toDouble();
      final change = (data['change'] as num?)?.toDouble();

      // Ejecutar impresión real del ticket
      await _printerProvider!.printCustomTicket(
        businessName: businessName,
        products: products,
        total: total,
        paymentMethod: paymentMethod,
        customerName: customerName,
        cashReceived: cashReceived,
        change: change,
      );
      
      return Response.ok(
        jsonEncode({
          'status': 'ok',
          'message': 'Ticket impreso correctamente en: ${_printerProvider!.selectedPrinter!.name}',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      _logger.e('Error imprimiendo ticket: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Error imprimiendo el ticket: $e',
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  static Future<Response> _handleOptions(Request request) async {
    return Response.ok('', headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    });
  }
}
