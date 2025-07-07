import 'dart:async';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import '../../domain/entities/printer_entity.dart';
import '../../domain/repositories/printer_repository.dart';

/// Implementación del repositorio de impresoras usando flutter_thermal_printer
class PrinterRepositoryImpl implements PrinterRepository {
  final FlutterThermalPrinter _thermalPrinter = FlutterThermalPrinter.instance;
  late StreamController<List<PrinterEntity>> _printersController;
  StreamSubscription? _printersSubscription;
  bool _isScanning = false;
  Timer? _scanTimeout;

  PrinterRepositoryImpl() {
    _printersController = StreamController<List<PrinterEntity>>.broadcast();
    _initPrintersStream();
  }

  void _initPrintersStream() {
    _printersSubscription = _thermalPrinter.devicesStream.listen((printers) {
      final entities = printers.map((printer) => _convertToEntity(printer)).toList();
      _printersController.add(entities);
    });
  }

  PrinterEntity _convertToEntity(Printer printer) {
    return PrinterEntity(
      address: printer.address,
      name: printer.name ?? 'Impresora desconocida',
      connectionType: _convertConnectionType(printer.connectionType),
      isConnected: printer.isConnected ?? false,
      vendorId: printer.vendorId,
      productId: printer.productId,
    );
  }

  PrinterConnectionType _convertConnectionType(ConnectionType? type) {
    switch (type) {
      case ConnectionType.USB:
        return PrinterConnectionType.usb;
      case ConnectionType.BLE:
        return PrinterConnectionType.bluetooth;
      case ConnectionType.NETWORK:
        return PrinterConnectionType.network;
      default:
        return PrinterConnectionType.usb;
    }
  }

  ConnectionType _convertToPackageConnectionType(PrinterConnectionType type) {
    switch (type) {
      case PrinterConnectionType.usb:
        return ConnectionType.USB;
      case PrinterConnectionType.bluetooth:
        return ConnectionType.BLE;
      case PrinterConnectionType.network:
        return ConnectionType.NETWORK;
    }
  }

  Printer _convertToPrinter(PrinterEntity entity) {
    return Printer(
      address: entity.address,
      name: entity.name,
      connectionType: _convertToPackageConnectionType(entity.connectionType),
      isConnected: entity.isConnected,
      vendorId: entity.vendorId,
      productId: entity.productId,
    );
  }

  @override
  Stream<List<PrinterEntity>> get printersStream => _printersController.stream;

  @override
  Future<void> scanForPrinters() async {
    // Prevenir múltiples búsquedas simultáneas
    if (_isScanning) {
      return;
    }
    
    try {
      _isScanning = true;
      
      // Cancelar timeout anterior si existe
      _scanTimeout?.cancel();
      
      await _thermalPrinter.getPrinters(
        connectionTypes: [
          ConnectionType.USB,
          ConnectionType.BLE,
        ],
      );
      
      // Establecer un timeout para detener automáticamente la búsqueda
      _scanTimeout = Timer(const Duration(seconds: 15), () {
        if (_isScanning) {
          stopScan();
        }
      });
      
    } catch (e) {
      _isScanning = false;
      throw Exception('Error al buscar impresoras: $e');
    }
  }

  @override
  Future<void> stopScan() async {
    try {
      _isScanning = false;
      _scanTimeout?.cancel();
      _scanTimeout = null;
      await _thermalPrinter.stopScan();
    } catch (e) {
      throw Exception('Error al detener búsqueda: $e');
    }
  }

  @override
  Future<bool> connectToPrinter(PrinterEntity printer) async {
    try {
      final thermalPrinter = _convertToPrinter(printer);
      return await _thermalPrinter.connect(thermalPrinter);
    } catch (e) {
      throw Exception('Error al conectar impresora: $e');
    }
  }

  @override
  Future<void> disconnectFromPrinter(PrinterEntity printer) async {
    try {
      final thermalPrinter = _convertToPrinter(printer);
      await _thermalPrinter.disconnect(thermalPrinter);
    } catch (e) {
      throw Exception('Error al desconectar impresora: $e');
    }
  }

  @override
  Future<bool> isPrinterConnected(PrinterEntity printer) async {
    try {
      // En flutter_thermal_printer no hay un método directo para verificar conexión
      // Por ahora retornamos el estado almacenado en la entidad
      return printer.isConnected;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> printData(PrinterEntity printer, List<int> data) async {
    try {
      final thermalPrinter = _convertToPrinter(printer);
      await _thermalPrinter.printData(thermalPrinter, data);
    } catch (e) {
      throw Exception('Error al imprimir: $e');
    }
  }

  @override
  Future<List<int>> generateTestTicket() async {
    try {
      // Genera un ticket de prueba usando ESC/POS commands
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      
      List<int> bytes = [];
      
      // Encabezado
      bytes += generator.text(
        'TICKET DE PRUEBA',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      
      bytes += generator.text(
        'SellPOS - Sistema de Ventas',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
        ),
      );
      
      bytes += generator.text(
        'Tienda Demo #001',
        styles: const PosStyles(
          align: PosAlign.center,
        ),
      );
      
      bytes += generator.hr();
      
      // Información del ticket
      final now = DateTime.now();
      bytes += generator.text('Fecha: ${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}');
      bytes += generator.text('Hora: ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}');
      bytes += generator.text('Ticket: #${now.millisecondsSinceEpoch.toString().substring(8)}');
      bytes += generator.text('Cajero: Demo User');
      
      bytes += generator.hr();
      
      // Productos de ejemplo
      bytes += generator.text(
        'PRODUCTOS:',
        styles: const PosStyles(bold: true),
      );
      
      bytes += generator.text(''); // Línea en blanco
      
      // Encabezados de columnas
      bytes += generator.row([
        PosColumn(text: 'ITEM', width: 5, styles: const PosStyles(bold: true)),
        PosColumn(text: 'QTY', width: 2, styles: const PosStyles(bold: true, align: PosAlign.center)),
        PosColumn(text: 'PRECIO', width: 3, styles: const PosStyles(bold: true, align: PosAlign.right)),
        PosColumn(text: 'TOTAL', width: 2, styles: const PosStyles(bold: true, align: PosAlign.right)),
      ]);
      
      bytes += generator.text('-' * 32);
      
      // Productos con más detalle
      double subtotal = 0;
      
      // Producto 1
      bytes += generator.row([
        PosColumn(text: 'Laptop Gaming', width: 5),
        PosColumn(text: '1', width: 2, styles: const PosStyles(align: PosAlign.center)),
        PosColumn(text: '\$899.99', width: 3, styles: const PosStyles(align: PosAlign.right)),
        PosColumn(text: '\$899.99', width: 2, styles: const PosStyles(align: PosAlign.right)),
      ]);
      subtotal += 899.99;
      
      // Producto 2
      bytes += generator.row([
        PosColumn(text: 'Mouse Inalambrico', width: 5),
        PosColumn(text: '2', width: 2, styles: const PosStyles(align: PosAlign.center)),
        PosColumn(text: '\$24.50', width: 3, styles: const PosStyles(align: PosAlign.right)),
        PosColumn(text: '\$49.00', width: 2, styles: const PosStyles(align: PosAlign.right)),
      ]);
      subtotal += 49.00;
      
      // Producto 3
      bytes += generator.row([
        PosColumn(text: 'Teclado Mecanico', width: 5),
        PosColumn(text: '1', width: 2, styles: const PosStyles(align: PosAlign.center)),
        PosColumn(text: '\$75.25', width: 3, styles: const PosStyles(align: PosAlign.right)),
        PosColumn(text: '\$75.25', width: 2, styles: const PosStyles(align: PosAlign.right)),
      ]);
      subtotal += 75.25;
      
      // Producto 4
      bytes += generator.row([
        PosColumn(text: 'Monitor 24" FHD', width: 5),
        PosColumn(text: '1', width: 2, styles: const PosStyles(align: PosAlign.center)),
        PosColumn(text: '\$189.99', width: 3, styles: const PosStyles(align: PosAlign.right)),
        PosColumn(text: '\$189.99', width: 2, styles: const PosStyles(align: PosAlign.right)),
      ]);
      subtotal += 189.99;
      
      // Producto 5
      bytes += generator.row([
        PosColumn(text: 'Cable HDMI 2m', width: 5),
        PosColumn(text: '3', width: 2, styles: const PosStyles(align: PosAlign.center)),
        PosColumn(text: '\$12.99', width: 3, styles: const PosStyles(align: PosAlign.right)),
        PosColumn(text: '\$38.97', width: 2, styles: const PosStyles(align: PosAlign.right)),
      ]);
      subtotal += 38.97;
      
      bytes += generator.text('-' * 32);
      
      // Cálculos de impuestos
      double taxRate = 0.08; // 8% de impuesto
      double taxAmount = subtotal * taxRate;
      double total = subtotal + taxAmount;
      
      // Subtotal
      bytes += generator.row([
        PosColumn(text: 'SUBTOTAL:', width: 8, styles: const PosStyles(bold: true)),
        PosColumn(text: '\$${subtotal.toStringAsFixed(2)}', width: 4, styles: const PosStyles(align: PosAlign.right, bold: true)),
      ]);
      
      // Impuestos
      bytes += generator.row([
        PosColumn(text: 'IMPUESTO (8%):', width: 8),
        PosColumn(text: '\$${taxAmount.toStringAsFixed(2)}', width: 4, styles: const PosStyles(align: PosAlign.right)),
      ]);
      
      bytes += generator.text('-' * 32);
      
      // Total
      bytes += generator.row([
        PosColumn(text: 'TOTAL:', width: 8, styles: const PosStyles(bold: true, height: PosTextSize.size2)),
        PosColumn(text: '\$${total.toStringAsFixed(2)}', width: 4, styles: const PosStyles(align: PosAlign.right, bold: true, height: PosTextSize.size2)),
      ]);
      
      bytes += generator.hr();
      
      // Método de pago
      bytes += generator.text(
        'METODO DE PAGO:',
        styles: const PosStyles(bold: true),
      );
      bytes += generator.text('Tarjeta de Credito ****1234');
      bytes += generator.text('Aprobado: ${now.millisecondsSinceEpoch.toString().substring(8)}');
      
      bytes += generator.text(''); // Línea en blanco
      
      // Información adicional
      bytes += generator.text(
        'RESUMEN DEL PEDIDO:',
        styles: const PosStyles(bold: true),
      );
      bytes += generator.text('Items: 8 unidades');
      bytes += generator.text('Ahorro: \$0.00');
      
      bytes += generator.hr();
      
      bytes += generator.text(
        'Gracias por su compra!',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
      
      bytes += generator.text(
        'Conserve este ticket como',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.text(
        'comprobante de compra',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.text(''); // Línea en blanco
      
      bytes += generator.text(
        'www.sellpos.com',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.text(
        'Soporte: support@sellpos.com',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.text(''); // Línea en blanco
      bytes += generator.text(''); // Línea en blanco
      
      // Corte de papel
      bytes += generator.cut();
      
      return bytes;
    } catch (e) {
      throw Exception('Error al generar ticket de prueba: $e');
    }
  }

  void dispose() {
    _scanTimeout?.cancel();
    _printersSubscription?.cancel();
    _printersController.close();
  }
}
