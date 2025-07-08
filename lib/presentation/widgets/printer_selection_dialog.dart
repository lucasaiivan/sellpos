import 'package:flutter/material.dart';
import '../providers/printer_provider.dart';

/// Diálogo para seleccionar una impresora de la lista disponible
class PrinterSelectionDialog extends StatelessWidget {
  final PrinterProvider provider;

  const PrinterSelectionDialog({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog( 
      title: Row(
        children: [
          const Icon(Icons.print),
          const SizedBox(width: 8),
          const Text('Seleccionar Impresora'),
        ],
      ),
      content: SizedBox(
        width: 600,
        height: 500,
        child: Column(
          children: [
            // Información del header con mejor diseño
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${provider.printers.length} impresora${provider.printers.length != 1 ? 's' : ''} encontrada${provider.printers.length != 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (provider.isScanning)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Lista de impresoras
            Expanded(child: _buildPrintersList(context)),
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: provider.isScanning 
              ? null 
              : () => provider.scanForPrinters(),
          icon: provider.isScanning
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              : const Icon(Icons.refresh),
          label: Text(provider.isScanning ? 'Buscando...' : 'Actualizar'),
        ),
        FilledButton.tonal(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }

  Widget _buildPrintersList(BuildContext context) {
    if (provider.printers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off, 
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              'No se encontraron impresoras',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Asegúrate de que la impresora esté encendida\ny conectada al sistema',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: provider.isScanning 
                  ? null 
                  : () => provider.scanForPrinters(),
              icon: provider.isScanning
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.refresh),
              label: Text(provider.isScanning ? 'Buscando...' : 'Buscar de nuevo'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: provider.printers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final printer = provider.printers[index];
        final isSelected = provider.selectedPrinter?.address == printer.address;
        
        return Card(
          elevation: isSelected ? 2 : 0,
          color: isSelected 
              ? Theme.of(context).colorScheme.primaryContainer 
              : null,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              await provider.selectPrinter(printer);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Avatar compacto
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: printer.isConnected 
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    foregroundColor: printer.isConnected 
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    child: Icon(
                      printer.isConnected ? Icons.print : Icons.print_disabled,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Información de la impresora compacta
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          (printer.name?.isNotEmpty == true) 
                              ? printer.name! 
                              : 'Impresora sin nombre',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected 
                                ? Theme.of(context).colorScheme.onPrimaryContainer
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              _getConnectionIcon(printer.connectionType),
                              size: 14,
                              color: isSelected 
                                  ? Theme.of(context).colorScheme.onPrimaryContainer
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${printer.connectionType.name} • ${printer.address ?? 'Sin dirección'}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isSelected 
                                      ? Theme.of(context).colorScheme.onPrimaryContainer
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Indicador unificado - solo para seleccionados
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check,
                            size: 16,
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Conectado',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getConnectionIcon(dynamic connectionType) {
    switch (connectionType.toString()) {
      case 'PrinterConnectionType.usb':
        return Icons.usb;
      case 'PrinterConnectionType.bluetooth':
        return Icons.bluetooth;
      case 'PrinterConnectionType.network':
        return Icons.wifi;
      default:
        return Icons.cable;
    }
  }
}
