import '../entities/printer_entity.dart';
import '../repositories/printer_repository.dart';

/// Caso de uso para el manejo de impresoras térmicas
class PrinterUseCase {
  final PrinterRepository _repository;

  PrinterUseCase(this._repository);

  /// Stream de impresoras disponibles
  Stream<List<PrinterEntity>> get printersStream => _repository.printersStream;

  /// Busca impresoras disponibles
  Future<void> scanForPrinters() async {
    await _repository.scanForPrinters();
  }

  /// Detiene la búsqueda de impresoras
  Future<void> stopScan() async {
    await _repository.stopScan();
  }

  /// Conecta a una impresora
  Future<bool> connectToPrinter(PrinterEntity printer) async {
    try {
      return await _repository.connectToPrinter(printer);
    } catch (e) {
      throw Exception('Error al conectar con la impresora: $e');
    }
  }

  /// Desconecta de una impresora
  Future<void> disconnectFromPrinter(PrinterEntity printer) async {
    try {
      await _repository.disconnectFromPrinter(printer);
    } catch (e) {
      throw Exception('Error al desconectar de la impresora: $e');
    }
  }

  /// Verifica si una impresora está conectada
  Future<bool> isPrinterConnected(PrinterEntity printer) async {
    try {
      return await _repository.isPrinterConnected(printer);
    } catch (e) {
      return false;
    }
  }

  /// Imprime un ticket de prueba
  Future<void> printTestTicket(PrinterEntity printer) async {
    try {
      final data = await _repository.generateTestTicket();
      await _repository.printData(printer, data);
    } catch (e) {
      throw Exception('Error al imprimir ticket de prueba: $e');
    }
  }

  /// Imprime datos personalizados
  Future<void> printCustomData(PrinterEntity printer, List<int> data) async {
    try {
      await _repository.printData(printer, data);
    } catch (e) {
      throw Exception('Error al imprimir datos: $e');
    }
  }
}
