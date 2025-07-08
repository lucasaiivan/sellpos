/// Entidad que representa una impresora térmica
class PrinterEntity {
  final String? address;
  final String? name;
  final PrinterConnectionType connectionType;
  final bool isConnected;
  final String? vendorId;
  final String? productId;

  const PrinterEntity({
    this.address,
    this.name,
    required this.connectionType,
    this.isConnected = false,
    this.vendorId,
    this.productId,
  });

  /// Crea una copia de la entidad con los campos especificados modificados
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

  @override
  String toString() {
    return 'PrinterEntity(name: $name, address: $address, connectionType: $connectionType, isConnected: $isConnected)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is PrinterEntity &&
        other.address == address &&
        other.name == name &&
        other.connectionType == connectionType &&
        other.isConnected == isConnected &&
        other.vendorId == vendorId &&
        other.productId == productId;
  }

  @override
  int get hashCode {
    return address.hashCode ^
        name.hashCode ^
        connectionType.hashCode ^
        isConnected.hashCode ^
        vendorId.hashCode ^
        productId.hashCode;
  }
}

/// Tipos de conexión para impresoras térmicas
enum PrinterConnectionType {
  usb,
  bluetooth,
  network,
}

extension PrinterConnectionTypeExtension on PrinterConnectionType {
  String get name {
    switch (this) {
      case PrinterConnectionType.usb:
        return 'USB';
      case PrinterConnectionType.bluetooth:
        return 'Bluetooth';
      case PrinterConnectionType.network:
        return 'Network';
    }
  }
}
