import 'dart:async';
import 'package:flutter/foundation.dart';
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
      // Genera un ticket de prueba profesional usando ESC/POS commands
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      
      List<int> bytes = [];
      
      // Logo/Encabezado principal con diseño ASCII
      bytes += generator.text(
        '================================',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.text(
        'SUPER MARKET DEMO',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      
      bytes += generator.text(
        '================================',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.text(
        'Av. Tecnologia 123, Local 456',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
        ),
      );
      
      bytes += generator.text(
        'Tel: (555) 123-4567',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.text(
        'RFC: SMD123456789',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.text(
        '================================',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      // Información del ticket
      final now = DateTime.now();
      bytes += generator.text(
        'TICKET DE VENTA',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
      );
      
      bytes += generator.text('');
      
      bytes += generator.row([
        PosColumn(text: 'FOLIO:', width: 4, styles: const PosStyles(bold: true)),
        PosColumn(text: '#${now.millisecondsSinceEpoch.toString().substring(7)}', width: 8, styles: const PosStyles(align: PosAlign.right)),
      ]);
      
      bytes += generator.row([
        PosColumn(text: 'FECHA:', width: 4, styles: const PosStyles(bold: true)),
        PosColumn(text: '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}', width: 8, styles: const PosStyles(align: PosAlign.right)),
      ]);
      
      bytes += generator.row([
        PosColumn(text: 'HORA:', width: 4, styles: const PosStyles(bold: true)),
        PosColumn(text: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}', width: 8, styles: const PosStyles(align: PosAlign.right)),
      ]);
      
      bytes += generator.row([
        PosColumn(text: 'CAJERO:', width: 4, styles: const PosStyles(bold: true)),
        PosColumn(text: 'Maria Rodriguez', width: 8, styles: const PosStyles(align: PosAlign.right)),
      ]);
      
      bytes += generator.row([
        PosColumn(text: 'CAJA:', width: 4, styles: const PosStyles(bold: true)),
        PosColumn(text: 'POS-001', width: 8, styles: const PosStyles(align: PosAlign.right)),
      ]);
      
      bytes += generator.text(
        '--------------------------------',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      // Productos
      bytes += generator.text(
        'PRODUCTOS',
        styles: const PosStyles(
          bold: true,
          align: PosAlign.center,
          underline: true,
        ),
      );
      
      bytes += generator.text('');
      
      // Encabezados de columnas
      bytes += generator.row([
        PosColumn(text: 'DESC.', width: 5, styles: const PosStyles(bold: true)),
        PosColumn(text: 'QTY', width: 2, styles: const PosStyles(bold: true, align: PosAlign.center)),
        PosColumn(text: 'PRECIO', width: 3, styles: const PosStyles(bold: true, align: PosAlign.right)),
        PosColumn(text: 'TOTAL', width: 2, styles: const PosStyles(bold: true, align: PosAlign.right)),
      ]);
      
      bytes += generator.text(
        '------------------------------------------------',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      // Lista de productos
      double subtotal = 0;
      
      // Producto 1
      bytes += generator.row([
        PosColumn(text: 'Coca Cola 600ml', width: 5),
        PosColumn(text: '2', width: 2, styles: const PosStyles(align: PosAlign.center)),
        PosColumn(text: '\$25.00', width: 3, styles: const PosStyles(align: PosAlign.right)),
        PosColumn(text: '\$50.00', width: 2, styles: const PosStyles(align: PosAlign.right)),
      ]);
      bytes += generator.text('  Cod: 7501234567890');
      subtotal += 50.00;
      
      // Producto 2
      bytes += generator.row([
        PosColumn(text: 'Pan Bimbo Grande', width: 5),
        PosColumn(text: '1', width: 2, styles: const PosStyles(align: PosAlign.center)),
        PosColumn(text: '\$32.50', width: 3, styles: const PosStyles(align: PosAlign.right)),
        PosColumn(text: '\$32.50', width: 2, styles: const PosStyles(align: PosAlign.right)),
      ]);
      bytes += generator.text('  Cod: 7501055360031');
      subtotal += 32.50;
      
      // Producto 3
      bytes += generator.row([
        PosColumn(text: 'Leche Lala 1L', width: 5),
        PosColumn(text: '3', width: 2, styles: const PosStyles(align: PosAlign.center)),
        PosColumn(text: '\$28.90', width: 3, styles: const PosStyles(align: PosAlign.right)),
        PosColumn(text: '\$86.70', width: 2, styles: const PosStyles(align: PosAlign.right)),
      ]);
      bytes += generator.text('  Cod: 7501234567891');
      subtotal += 86.70;
      
      // Producto 4
      bytes += generator.row([
        PosColumn(text: 'Arroz Verde Valle', width: 5),
        PosColumn(text: '1', width: 2, styles: const PosStyles(align: PosAlign.center)),
        PosColumn(text: '\$45.00', width: 3, styles: const PosStyles(align: PosAlign.right)),
        PosColumn(text: '\$45.00', width: 2, styles: const PosStyles(align: PosAlign.right)),
      ]);
      bytes += generator.text('  Cod: 7501055360032');
      subtotal += 45.00;
      
      bytes += generator.text(
        '------------------------------------------------',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      // Totales
      final tax = subtotal * 0.16; // IVA 16%
      final total = subtotal + tax;
      
      bytes += generator.row([
        PosColumn(text: 'SUBTOTAL:', width: 8, styles: const PosStyles(bold: true)),
        PosColumn(text: '\$${subtotal.toStringAsFixed(2)}', width: 4, styles: const PosStyles(align: PosAlign.right, bold: true)),
      ]);
      
      bytes += generator.row([
        PosColumn(text: 'IVA (16%):', width: 8, styles: const PosStyles(bold: true)),
        PosColumn(text: '\$${tax.toStringAsFixed(2)}', width: 4, styles: const PosStyles(align: PosAlign.right, bold: true)),
      ]);
      
      bytes += generator.text(
        '================================================',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.row([
        PosColumn(
          text: 'TOTAL:', 
          width: 8, 
          styles: const PosStyles(
            bold: true, 
            height: PosTextSize.size2,
            width: PosTextSize.size1,
          )
        ),
        PosColumn(
          text: '\$${total.toStringAsFixed(2)}', 
          width: 4, 
          styles: const PosStyles(
            align: PosAlign.right, 
            bold: true,
            height: PosTextSize.size2,
            width: PosTextSize.size1,
          )
        ),
      ]);
      
      bytes += generator.text(
        '================================================',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      // Información de pago
      bytes += generator.text('');
      bytes += generator.text(
        'FORMA DE PAGO',
        styles: const PosStyles(bold: true, align: PosAlign.center),
      );
      
      bytes += generator.row([
        PosColumn(text: 'EFECTIVO:', width: 8, styles: const PosStyles(bold: true)),
        PosColumn(text: '\$${(total + 50).toStringAsFixed(2)}', width: 4, styles: const PosStyles(align: PosAlign.right)),
      ]);
      
      bytes += generator.row([
        PosColumn(text: 'CAMBIO:', width: 8, styles: const PosStyles(bold: true)),
        PosColumn(text: '\$50.00', width: 4, styles: const PosStyles(align: PosAlign.right)),
      ]);
      
      bytes += generator.text('');
      bytes += generator.text(
        '--------------------------------',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      // Pie del ticket
      bytes += generator.text(
        'ARTICULOS VENDIDOS: 7',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
      
      bytes += generator.text('');
      bytes += generator.text(
        'GRACIAS POR SU COMPRA!',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
      );
      
      bytes += generator.text(
        'Conserve su ticket para',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.text(
        'aclaraciones o devoluciones',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.text('');
      bytes += generator.text(
        'www.supermarketdemo.com',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.text(
        'Siguenos: @SuperMarketDemo',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.text('');
      bytes += generator.text(
        'Sistema: SellPOS v1.0',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.text(
        'Ticket generado automaticamente',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      // QR Code simulado (solo texto por ahora)
      bytes += generator.text('');
      bytes += generator.text(
        '[QR: Validacion Digital]',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      // Corte final
      bytes += generator.feed(3);
      bytes += generator.cut();
      
      return bytes;
    } catch (e) {
      debugPrint('Error generando ticket de prueba: $e');
      throw Exception('Error al generar ticket de prueba: $e');
    }
  }

  @override
  Future<List<int>> generateConfigurationTicket() async {
    try {
      // Genera un ticket de configuración estilo SELL
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      
      List<int> bytes = [];
      final now = DateTime.now();
      
      // Encabezado principal con logo
      bytes += generator.text(
        '================================',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.text(
        'SELLPOS CONFIGURACION',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      
      bytes += generator.text(
        '================================',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.text('');
      bytes += generator.text(
        'CONFIGURACION DE IMPRESORA',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          underline: true,
        ),
      );
      
      bytes += generator.text('');
      bytes += generator.text(
        '--------------------------------',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      // Información de la configuración
      bytes += generator.row([
        PosColumn(text: 'FECHA:', width: 4, styles: const PosStyles(bold: true)),
        PosColumn(text: '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}', width: 8, styles: const PosStyles(align: PosAlign.right)),
      ]);
      
      bytes += generator.row([
        PosColumn(text: 'HORA:', width: 4, styles: const PosStyles(bold: true)),
        PosColumn(text: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}', width: 8, styles: const PosStyles(align: PosAlign.right)),
      ]);
      
      bytes += generator.row([
        PosColumn(text: 'VERSION:', width: 4, styles: const PosStyles(bold: true)),
        PosColumn(text: 'SellPOS v1.0', width: 8, styles: const PosStyles(align: PosAlign.right)),
      ]);
      
      bytes += generator.text('');
      bytes += generator.text(
        'ESTADO DE CONEXION',
        styles: const PosStyles(
          bold: true,
          align: PosAlign.center,
          underline: true,
        ),
      );
      
      bytes += generator.text('');
      bytes += generator.text('- Impresora conectada correctamente');
      bytes += generator.text('- Puerto de comunicacion activo');
      bytes += generator.text('- Drivers instalados');
      bytes += generator.text('- Sistema de punto de venta listo');
      
      bytes += generator.text('');
      bytes += generator.text(
        '--------------------------------',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      // Información de configuración de la app
      bytes += generator.text(
        'CONFIGURACION DISPONIBLE',
        styles: const PosStyles(
          bold: true,
          align: PosAlign.center,
          underline: true,
        ),
      );
      
      bytes += generator.text('');
      bytes += generator.text('DESDE LA APP MOVIL:');
      bytes += generator.text('   * Configurar productos');
      bytes += generator.text('   * Gestionar inventario');
      bytes += generator.text('   * Reportes de ventas');
      bytes += generator.text('   * Control de usuarios');
      
      bytes += generator.text('');
      bytes += generator.text('DESDE LA WEB:');
      bytes += generator.text('   * Panel administrativo');
      bytes += generator.text('   * Configuracion avanzada');
      bytes += generator.text('   * Respaldos de datos');
      bytes += generator.text('   * Actualizaciones del sistema');
      
      bytes += generator.text('');
      bytes += generator.text(
        '--------------------------------',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      // Instrucciones de conexión
      bytes += generator.text(
        'COMO CONECTAR',
        styles: const PosStyles(
          bold: true,
          align: PosAlign.center,
          underline: true,
        ),
      );
      
      bytes += generator.text('');
      bytes += generator.text(
        'DESDE DISPOSITIVO MOVIL:',
        styles: const PosStyles(bold: true),
      );
      bytes += generator.text('1. Abrir app SellPOS');
      bytes += generator.text('2. Ir a Configuracion');
      bytes += generator.text('3. Seleccionar "Impresoras"');
      bytes += generator.text('4. Buscar dispositivos');
      bytes += generator.text('5. Conectar y probar');
      
      bytes += generator.text('');
      bytes += generator.text(
        'DESDE LA WEB:',
        styles: const PosStyles(bold: true),
      );
      bytes += generator.text('1. Acceder al panel web');
      bytes += generator.text('2. Menu -> Dispositivos');
      bytes += generator.text('3. Agregar nueva impresora');
      bytes += generator.text('4. Configurar parametros');
      bytes += generator.text('5. Guardar configuracion');
      
      bytes += generator.text('');
      bytes += generator.text(
        '--------------------------------',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      // Información de soporte
      bytes += generator.text(
        'SOPORTE TECNICO',
        styles: const PosStyles(
          bold: true,
          align: PosAlign.center,
          underline: true,
        ),
      );
      
      bytes += generator.text('');
      bytes += generator.text('Email: soporte@sellpos.com');
      bytes += generator.text('Tel: +52 (55) 1234-5678');
      bytes += generator.text('Web: www.sellpos.com');
      bytes += generator.text('Chat: Disponible 24/7');
      
      bytes += generator.text('');
      bytes += generator.text(
        '================================',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      // QR Code simulado para configuración
      bytes += generator.text(
        '[CODIGO QR PARA CONFIGURACION]',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.text('');
      bytes += generator.text(
        'Escanea para configuracion rapida',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.text('');
      bytes += generator.text(
        'Impresora configurada y lista',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
        ),
      );
      
      bytes += generator.text(
        'para punto de venta',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
        ),
      );
      
      bytes += generator.text('');
      bytes += generator.text(
        '================================',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      // Pie del ticket
      bytes += generator.text('');
      bytes += generator.text(
        'SELLPOS - Gestiona Tus Ventas',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
        ),
      );
      
      bytes += generator.text(
        'Powered by Logica Booleana',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.text('');
      bytes += generator.text(
        'Ticket generado: ${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      // Corte final
      bytes += generator.feed(3);
      bytes += generator.cut();
      
      return bytes;
    } catch (e) {
      debugPrint('Error generando ticket de configuración: $e');
      throw Exception('Error al generar ticket de configuración: $e');
    }
  }

  @override
  Future<List<int>> generateCustomTicket({
    required String businessName,
    required List<Map<String, dynamic>> products,
    required double total,
    required String paymentMethod,
    String? customerName,
    double? cashReceived,
    double? change,
  }) async {
    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      
      List<int> bytes = [];
      
      // Encabezado del negocio
      bytes += generator.text(
        '================================',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.text(
        businessName.toUpperCase(),
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size1,
        ),
      );
      
      bytes += generator.text(
        '================================',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.text('');
      
      // Fecha y hora
      final now = DateTime.now();
      bytes += generator.row([
        PosColumn(text: 'FECHA:', width: 4, styles: const PosStyles(bold: true)),
        PosColumn(text: '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}', width: 8, styles: const PosStyles(align: PosAlign.right)),
      ]);
      
      bytes += generator.row([
        PosColumn(text: 'HORA:', width: 4, styles: const PosStyles(bold: true)),
        PosColumn(text: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}', width: 8, styles: const PosStyles(align: PosAlign.right)),
      ]);
      
      // Cliente (si se proporciona)
      if (customerName != null && customerName.isNotEmpty) {
        bytes += generator.row([
          PosColumn(text: 'CLIENTE:', width: 4, styles: const PosStyles(bold: true)),
          PosColumn(text: customerName, width: 8, styles: const PosStyles(align: PosAlign.right)),
        ]);
      }
      
      bytes += generator.text(
        '--------------------------------',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      // Encabezado de productos
      bytes += generator.row([
        PosColumn(text: 'CANT', width: 2, styles: const PosStyles(bold: true)),
        PosColumn(text: 'DESCRIPCION', width: 6, styles: const PosStyles(bold: true)),
        PosColumn(text: 'PRECIO', width: 4, styles: const PosStyles(bold: true, align: PosAlign.right)),
      ]);
      
      bytes += generator.text(
        '--------------------------------',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      // Lista de productos
      for (final product in products) {
        final quantity = product['quantity']?.toString() ?? '1';
        final description = product['description']?.toString() ?? 'Producto';
        final price = (product['price'] as num?)?.toDouble() ?? 0.0;
        
        bytes += generator.row([
          PosColumn(text: quantity, width: 2),
          PosColumn(text: description, width: 6),
          PosColumn(text: '\$${price.toStringAsFixed(2)}', width: 4, styles: const PosStyles(align: PosAlign.right)),
        ]);
      }
      
      bytes += generator.text(
        '--------------------------------',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      // Total
      bytes += generator.row([
        PosColumn(text: '', width: 8),
        PosColumn(text: 'TOTAL:', width: 2, styles: const PosStyles(bold: true)),
        PosColumn(text: '\$${total.toStringAsFixed(2)}', width: 2, styles: const PosStyles(bold: true, align: PosAlign.right)),
      ]);
      
      bytes += generator.text('');
      
      // Método de pago
      bytes += generator.text(
        'Metodo de pago: $paymentMethod',
        styles: const PosStyles(align: PosAlign.left),
      );
      
      // Efectivo recibido y cambio (si aplica)
      if (cashReceived != null && cashReceived > 0) {
        bytes += generator.text(
          'Efectivo recibido: \$${cashReceived.toStringAsFixed(2)}',
          styles: const PosStyles(align: PosAlign.left),
        );
        
        if (change != null && change > 0) {
          bytes += generator.text(
            'Cambio: \$${change.toStringAsFixed(2)}',
            styles: const PosStyles(
              align: PosAlign.left,
              bold: true,
            ),
          );
        }
      }
      
      bytes += generator.text('');
      bytes += generator.text('');
      
      // Pie de página
      bytes += generator.text(
        '¡Gracias por su compra!',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
        ),
      );
      
      bytes += generator.text(
        'Vuelva pronto',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.text(
        '================================',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      // Corte final
      bytes += generator.feed(3);
      bytes += generator.cut();
      
      return bytes;
    } catch (e) {
      debugPrint('Error generando ticket personalizado: $e');
      throw Exception('Error al generar ticket personalizado: $e');
    }
  }

  void dispose() {
    _scanTimeout?.cancel();
    _printersSubscription?.cancel();
    _printersController.close();
  }
}
