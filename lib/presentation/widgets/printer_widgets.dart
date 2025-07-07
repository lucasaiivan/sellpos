import 'package:flutter/material.dart';
import '../../domain/entities/printer_entity.dart';
import '../../core/component_app/cards.dart';

/// Widget que muestra una impresora en una lista
class PrinterListTile extends StatelessWidget {
  final PrinterEntity printer;
  final VoidCallback? onTap;
  final VoidCallback? onConnect;
  final VoidCallback? onDisconnect;
  final bool isConnecting;
  final bool isSelected;

  const PrinterListTile({
    super.key,
    required this.printer,
    this.onTap,
    this.onConnect,
    this.onDisconnect,
    this.isConnecting = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        border: isSelected 
            ? Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              )
            : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InfoCard(
        title: printer.name ?? 'Impresora sin nombre',
        subtitle: _getSubtitleText(),
        icon: _getConnectionIcon(),
        iconColor: _getConnectionColor(context),
        onTap: onTap,
        trailing: _buildTrailingWidget(context),
      ),
    );
  }

  String _getSubtitleText() {
    final parts = <String>[];
    
    if (printer.address != null) {
      parts.add('${printer.connectionType.name}: ${printer.address}');
    } else {
      parts.add(printer.connectionType.name);
    }
    
    if (printer.vendorId != null && printer.productId != null) {
      parts.add('VID:${printer.vendorId} PID:${printer.productId}');
    }
    
    return parts.join(' • ');
  }

  IconData _getConnectionIcon() {
    switch (printer.connectionType) {
      case PrinterConnectionType.usb:
        return Icons.usb;
      case PrinterConnectionType.bluetooth:
        return Icons.bluetooth;
      case PrinterConnectionType.network:
        return Icons.wifi;
    }
  }

  Color _getConnectionColor(BuildContext context) {
    if (printer.isConnected) {
      return Colors.green;
    }
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  Widget _buildTrailingWidget(BuildContext context) {
    if (isConnecting) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    // Solo mostrar botones de acción si la impresora está seleccionada
    if (!isSelected) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (printer.isConnected) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Conectado',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Desconectado',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ],
          const SizedBox(width: 8),
          Icon(
            Icons.touch_app,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      );
    }

    if (printer.isConnected) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Conectado',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onDisconnect,
            icon: const Icon(Icons.close, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.1),
              foregroundColor: Colors.red,
            ),
            tooltip: 'Desconectar',
          ),
        ],
      );
    }

    return IconButton(
      onPressed: onConnect,
      icon: const Icon(Icons.link, size: 20),
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      tooltip: 'Conectar',
    );
  }
}

/// Widget que muestra el estado actual de la impresora seleccionada
class PrinterStatusWidget extends StatelessWidget {
  final PrinterEntity? printer;
  final bool isConnecting;

  const PrinterStatusWidget({
    super.key,
    this.printer,
    this.isConnecting = false,
  });

  @override
  Widget build(BuildContext context) {
    if (printer == null) {
      return StatusCard(
        title: 'Estado de la impresora',
        status: 'No seleccionada',
        statusColor: Colors.grey,
        icon: Icons.print_disabled,
      );
    }

    if (isConnecting) {
      return StatusCard(
        title: printer!.name ?? 'Impresora',
        status: 'Conectando...',
        statusColor: Colors.orange,
        icon: Icons.sync,
      );
    }

    return StatusCard(
      title: printer!.name ?? 'Impresora',
      status: printer!.isConnected ? 'Conectada' : 'Desconectada',
      statusColor: printer!.isConnected ? Colors.green : Colors.red,
      icon: printer!.isConnected ? Icons.print : Icons.print_disabled,
    );
  }
}

/// Widget que muestra información sobre los tipos de conexión soportados
class ConnectionTypesInfo extends StatelessWidget {
  const ConnectionTypesInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tipos de conexión soportados',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          _buildConnectionTypeItem(
            context,
            Icons.usb,
            'USB',
            'Conexión directa por cable USB',
          ),
          const SizedBox(height: 8),
          _buildConnectionTypeItem(
            context,
            Icons.bluetooth,
            'Bluetooth',
            'Conexión inalámbrica Bluetooth',
          ),
          const SizedBox(height: 8),
          _buildConnectionTypeItem(
            context,
            Icons.wifi,
            'Red (WiFi)',
            'Conexión a través de red WiFi',
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionTypeItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
