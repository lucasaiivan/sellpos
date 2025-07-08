import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../../core/services/http_server_service.dart';
import '../../data/models/http_server_config.dart';
import 'printer_provider.dart';

class HttpServerProvider extends ChangeNotifier {
  final Logger _logger = Logger();
  
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get isServerRunning => HttpServerService.isRunning;
  String? get errorMessage => _errorMessage;
  HttpServerConfig get config => HttpServerService.config;
  String get serverUrl => HttpServerService.serverUrl;

  /// Inicializa el servicio del servidor HTTP
  Future<void> initialize() async {
    if (_isInitialized) return;

    _setLoading(true);
    try {
      await HttpServerService.initialize();
      _isInitialized = true;
      _clearError();
      _logger.i('HttpServerProvider inicializado');
    } catch (e) {
      _setError('Error inicializando servidor HTTP: $e');
      _logger.e('Error en HttpServerProvider.initialize(): $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Configura el PrinterProvider para usar en el servidor HTTP
  void configurePrinterProvider(PrinterProvider printerProvider) {
    HttpServerService.setPrinterProvider(printerProvider);
  }

  /// Inicia el servidor HTTP
  Future<bool> startServer() async {
    _setLoading(true);
    try {
      final success = await HttpServerService.startServer();
      if (success) {
        _clearError();
        _logger.i('Servidor HTTP iniciado exitosamente');
      } else {
        _setError('No se pudo iniciar el servidor HTTP');
      }
      return success;
    } catch (e) {
      _setError('Error iniciando servidor: $e');
      _logger.e('Error en startServer(): $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Detiene el servidor HTTP
  Future<void> stopServer() async {
    _setLoading(true);
    try {
      await HttpServerService.stopServer();
      _clearError();
      _logger.i('Servidor HTTP detenido');
    } catch (e) {
      _setError('Error deteniendo servidor: $e');
      _logger.e('Error en stopServer(): $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Actualiza la configuración del servidor
  Future<bool> updateConfiguration(HttpServerConfig newConfig) async {
    _setLoading(true);
    try {
      final success = await HttpServerService.updateConfig(newConfig);
      if (success) {
        _clearError();
        _logger.i('Configuración del servidor actualizada');
      } else {
        _setError('No se pudo actualizar la configuración');
      }
      return success;
    } catch (e) {
      _setError('Error actualizando configuración: $e');
      _logger.e('Error en updateConfiguration(): $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Alterna el estado del servidor (iniciar/detener)
  Future<void> toggleServer() async {
    if (isServerRunning) {
      await stopServer();
    } else {
      await startServer();
    }
  }

  // Métodos privados para manejar el estado

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // Detener el servidor al cerrar la aplicación
    if (isServerRunning) {
      HttpServerService.stopServer();
    }
    super.dispose();
  }
}
