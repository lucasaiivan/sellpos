import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/printer_entity.dart';
import '../../domain/usecases/printer_usecase.dart';

/// Provider para el manejo del estado de las impresoras térmicas
class PrinterProvider extends ChangeNotifier {
  final PrinterUseCase _printerUseCase;
  
  StreamSubscription? _printersSubscription;
  List<PrinterEntity> _printers = [];
  PrinterEntity? _selectedPrinter;
  bool _isScanning = false;
  String? _errorMessage;
  bool _isConnecting = false;
  bool _isPrinting = false;
  Timer? _debounceTimer;

  PrinterProvider(this._printerUseCase) {
    _initPrintersStream();
  }

  // Getters
  List<PrinterEntity> get printers => _printers;
  PrinterEntity? get selectedPrinter => _selectedPrinter;
  bool get isScanning => _isScanning;
  String? get errorMessage => _errorMessage;
  bool get isConnecting => _isConnecting;
  bool get isPrinting => _isPrinting;
  bool get hasConnectedPrinter => _selectedPrinter?.isConnected ?? false;

  void _initPrintersStream() {
    _printersSubscription = _printerUseCase.printersStream.listen(
      (printers) {
        // Implementar debounce para evitar actualizaciones excesivas
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 300), () {
          _printers = printers;
          _updateSelectedPrinterStatus();
          notifyListeners();
        });
      },
      onError: (error) {
        _setError('Error al obtener impresoras: $error');
      },
    );
  }

  void _updateSelectedPrinterStatus() {
    if (_selectedPrinter != null) {
      final updatedPrinter = _printers.firstWhere(
        (printer) => printer.address == _selectedPrinter!.address,
        orElse: () => _selectedPrinter!,
      );
      _selectedPrinter = updatedPrinter;
    }
  }

  /// Busca impresoras disponibles
  Future<void> scanForPrinters() async {
    // Prevenir múltiples búsquedas simultáneas
    if (_isScanning) {
      return;
    }
    
    try {
      _isScanning = true;
      _clearError();
      notifyListeners();
      
      await _printerUseCase.scanForPrinters();
    } catch (e) {
      _setError('Error al buscar impresoras: $e');
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  /// Detiene la búsqueda de impresoras
  Future<void> stopScan() async {
    try {
      await _printerUseCase.stopScan();
      _isScanning = false;
      notifyListeners();
    } catch (e) {
      _setError('Error al detener búsqueda: $e');
    }
  }

  /// Selecciona una impresora
  void selectPrinter(PrinterEntity printer) {
    _selectedPrinter = printer;
    _clearError();
    notifyListeners();
  }

  /// Conecta a la impresora seleccionada
  Future<bool> connectToSelectedPrinter() async {
    if (_selectedPrinter == null) {
      _setError('No hay una impresora seleccionada');
      return false;
    }

    try {
      _isConnecting = true;
      _clearError();
      notifyListeners();

      final isConnected = await _printerUseCase.connectToPrinter(_selectedPrinter!);
      
      if (isConnected) {
        _selectedPrinter = _selectedPrinter!.copyWith(isConnected: true);
      } else {
        _setError('No se pudo conectar a la impresora');
      }
      
      return isConnected;
    } catch (e) {
      _setError('Error al conectar: $e');
      return false;
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  /// Desconecta de la impresora seleccionada
  Future<void> disconnectFromSelectedPrinter() async {
    if (_selectedPrinter == null) return;

    try {
      _clearError();
      await _printerUseCase.disconnectFromPrinter(_selectedPrinter!);
      _selectedPrinter = _selectedPrinter!.copyWith(isConnected: false);
      notifyListeners();
    } catch (e) {
      _setError('Error al desconectar: $e');
    }
  }

  /// Imprime un ticket de prueba
  Future<void> printTestTicket() async {
    if (_selectedPrinter == null) {
      _setError('No hay una impresora seleccionada');
      return;
    }

    if (!_selectedPrinter!.isConnected) {
      _setError('La impresora no está conectada');
      return;
    }

    try {
      _isPrinting = true;
      _clearError();
      notifyListeners();

      await _printerUseCase.printTestTicket(_selectedPrinter!);
    } catch (e) {
      _setError('Error al imprimir: $e');
    } finally {
      _isPrinting = false;
      notifyListeners();
    }
  }

  /// Imprime datos personalizados
  Future<void> printCustomData(List<int> data) async {
    if (_selectedPrinter == null) {
      _setError('No hay una impresora seleccionada');
      return;
    }

    if (!_selectedPrinter!.isConnected) {
      _setError('La impresora no está conectada');
      return;
    }

    try {
      _isPrinting = true;
      _clearError();
      notifyListeners();

      await _printerUseCase.printCustomData(_selectedPrinter!, data);
    } catch (e) {
      _setError('Error al imprimir: $e');
    } finally {
      _isPrinting = false;
      notifyListeners();
    }
  }

  /// Obtiene información detallada del estado de búsqueda
  String getScanStatusMessage() {
    if (_isScanning) {
      return 'Buscando impresoras disponibles...';
    } else if (_printers.isEmpty) {
      return 'No se han encontrado impresoras. Presiona "Buscar Impresoras" para comenzar.';
    } else {
      return 'Búsqueda completada. ${_printers.length} impresora(s) encontrada(s).';
    }
  }

  /// Reinicia la búsqueda de impresoras
  Future<void> refreshPrinters() async {
    if (_isScanning) {
      await stopScan();
      // Esperar un poco antes de iniciar nueva búsqueda
      await Future.delayed(const Duration(milliseconds: 500));
    }
    await scanForPrinters();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Limpia el error manualmente
  void clearError() {
    _clearError();
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _printersSubscription?.cancel();
    super.dispose();
  }
}

extension on PrinterEntity {
  PrinterEntity copyWith({
    String? address,
    String? name,
    PrinterConnectionType? connectionType,
    bool? isConnected,
    String? vendorId,
    String? productId,
  }) {
    return PrinterEntity(
      address: address ?? this.address,
      name: name ?? this.name,
      connectionType: connectionType ?? this.connectionType,
      isConnected: isConnected ?? this.isConnected,
      vendorId: vendorId ?? this.vendorId,
      productId: productId ?? this.productId,
    );
  }
}
