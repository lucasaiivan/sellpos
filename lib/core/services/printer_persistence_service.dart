import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/printer_entity.dart';

/// Servicio para persistir la configuración de impresoras
class PrinterPersistenceService {
  static const String _selectedPrinterKey = 'selected_printer';
  static const String _addressKey = 'address';
  static const String _nameKey = 'name';
  static const String _connectionTypeKey = 'connection_type';
  static const String _vendorIdKey = 'vendor_id';
  static const String _productIdKey = 'product_id';

  /// Guarda la impresora seleccionada
  static Future<void> saveSelectedPrinter(PrinterEntity printer) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('${_selectedPrinterKey}_$_addressKey', printer.address ?? '');
    await prefs.setString('${_selectedPrinterKey}_$_nameKey', printer.name ?? '');
    await prefs.setString('${_selectedPrinterKey}_$_connectionTypeKey', printer.connectionType.name);
    await prefs.setString('${_selectedPrinterKey}_$_vendorIdKey', printer.vendorId ?? '');
    await prefs.setString('${_selectedPrinterKey}_$_productIdKey', printer.productId ?? '');
  }

  /// Carga la impresora seleccionada guardada
  static Future<PrinterEntity?> loadSelectedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    
    final address = prefs.getString('${_selectedPrinterKey}_$_addressKey');
    final name = prefs.getString('${_selectedPrinterKey}_$_nameKey');
    final connectionTypeStr = prefs.getString('${_selectedPrinterKey}_$_connectionTypeKey');
    final vendorId = prefs.getString('${_selectedPrinterKey}_$_vendorIdKey');
    final productId = prefs.getString('${_selectedPrinterKey}_$_productIdKey');

    // Si no hay datos guardados, retorna null
    if (address == null || name == null || connectionTypeStr == null) {
      return null;
    }

    // Convierte el string a enum
    PrinterConnectionType connectionType;
    switch (connectionTypeStr) {
      case 'USB':
        connectionType = PrinterConnectionType.usb;
        break;
      case 'Bluetooth':
        connectionType = PrinterConnectionType.bluetooth;
        break;
      case 'Network':
        connectionType = PrinterConnectionType.network;
        break;
      default:
        connectionType = PrinterConnectionType.usb;
    }

    return PrinterEntity(
      address: address.isEmpty ? null : address,
      name: name.isEmpty ? null : name,
      connectionType: connectionType,
      isConnected: false, // Siempre inicia desconectada
      vendorId: vendorId?.isEmpty == true ? null : vendorId,
      productId: productId?.isEmpty == true ? null : productId,
    );
  }

  /// Elimina la impresora seleccionada guardada
  static Future<void> clearSelectedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove('${_selectedPrinterKey}_$_addressKey');
    await prefs.remove('${_selectedPrinterKey}_$_nameKey');
    await prefs.remove('${_selectedPrinterKey}_$_connectionTypeKey');
    await prefs.remove('${_selectedPrinterKey}_$_vendorIdKey');
    await prefs.remove('${_selectedPrinterKey}_$_productIdKey');
  }
}
