import '../entities/printer_entity.dart';

/// Repositorio abstrato para el manejo de impresoras térmicas
abstract class PrinterRepository {
  /// Obtiene el stream de impresoras disponibles
  Stream<List<PrinterEntity>> get printersStream;

  /// Busca impresoras disponibles
  Future<void> scanForPrinters();

  /// Detiene la búsqueda de impresoras
  Future<void> stopScan();

  /// Conecta a una impresora específica
  Future<bool> connectToPrinter(PrinterEntity printer);

  /// Desconecta de una impresora
  Future<void> disconnectFromPrinter(PrinterEntity printer);

  /// Verifica si una impresora está conectada
  Future<bool> isPrinterConnected(PrinterEntity printer);

  /// Imprime datos en la impresora
  Future<void> printData(PrinterEntity printer, List<int> data);

  /// Genera un ticket de prueba
  Future<List<int>> generateTestTicket();
}
