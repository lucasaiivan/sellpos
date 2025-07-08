import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';

class TicketGenerator {
  /// Genera un ticket personalizado basado en los datos del request
  static Future<List<int>> generateCustomTicket({
    required String businessName,
    required List<Map<String, dynamic>> products,
    required double total,
    required String paymentMethod,
    String? customerName,
    double? cashReceived,
    double? change,
    String? timestamp,
  }) async {
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
    
    bytes += generator.emptyLines(1);
    
    // Fecha y hora
    final dateTime = timestamp != null 
        ? DateTime.tryParse(timestamp) ?? DateTime.now()
        : DateTime.now();
    
    bytes += generator.text(
      'Fecha: ${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}',
      styles: const PosStyles(align: PosAlign.left),
    );
    
    bytes += generator.text(
      'Hora: ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
      styles: const PosStyles(align: PosAlign.left),
    );
    
    // Cliente (si se proporciona)
    if (customerName != null && customerName.isNotEmpty) {
      bytes += generator.text(
        'Cliente: $customerName',
        styles: const PosStyles(align: PosAlign.left),
      );
    }
    
    bytes += generator.emptyLines(1);
    bytes += generator.text(
      '--------------------------------',
      styles: const PosStyles(align: PosAlign.center),
    );
    
    // Encabezado de productos
    bytes += generator.text(
      'CANT  DESCRIPCION        PRECIO',
      styles: const PosStyles(
        align: PosAlign.left,
        bold: true,
      ),
    );
    
    bytes += generator.text(
      '--------------------------------',
      styles: const PosStyles(align: PosAlign.center),
    );
    
    // Lista de productos
    for (final product in products) {
      final quantity = product['quantity']?.toString() ?? '1';
      final description = product['description']?.toString() ?? 'Producto';
      final price = (product['price'] as num?)?.toDouble() ?? 0.0;
      
      // Formatear línea del producto
      final quantityStr = quantity.padRight(5);
      final priceStr = '\$${price.toStringAsFixed(2)}';
      
      // Calcular espacio disponible para descripción
      final maxDescLength = 32 - quantityStr.length - priceStr.length - 1;
      final truncatedDesc = description.length > maxDescLength 
          ? description.substring(0, maxDescLength - 3) + '...'
          : description;
      
      final line = '$quantityStr$truncatedDesc${' ' * (32 - quantityStr.length - truncatedDesc.length - priceStr.length)}$priceStr';
      
      bytes += generator.text(
        line,
        styles: const PosStyles(align: PosAlign.left),
      );
    }
    
    bytes += generator.text(
      '--------------------------------',
      styles: const PosStyles(align: PosAlign.center),
    );
    
    // Total
    bytes += generator.text(
      'TOTAL: \$${total.toStringAsFixed(2)}',
      styles: const PosStyles(
        align: PosAlign.right,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size1,
      ),
    );
    
    bytes += generator.emptyLines(1);
    
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
    
    bytes += generator.emptyLines(2);
    
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
    
    bytes += generator.emptyLines(2);
    
    // Línea de separación final
    bytes += generator.text(
      '================================',
      styles: const PosStyles(align: PosAlign.center),
    );
    
    bytes += generator.emptyLines(3);
    
    // Comando de corte de papel (si es compatible)
    bytes += generator.cut();
    
    return bytes;
  }
}
