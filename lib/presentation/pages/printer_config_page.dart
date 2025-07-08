import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/printer_provider.dart';
import '../widgets/printer_widgets.dart';
import '../../core/component_app/buttons.dart';
import '../../core/component_app/cards.dart';

/// Página principal para la configuración y prueba de impresoras térmicas
class PrinterConfigPage extends StatelessWidget {
  const PrinterConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Impresora'),
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        elevation: 0,
      ),
      body: Consumer<PrinterProvider>(
        builder: (context, printerProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado con estado actual
                _buildHeader(context, printerProvider),
                const SizedBox(height: 24),
                
                // Controles principales
                _buildMainControls(context, printerProvider),
                const SizedBox(height: 24),
                
                // Estado de la impresora seleccionada
                PrinterStatusWidget(
                  printer: printerProvider.selectedPrinter,
                  isConnecting: printerProvider.isConnecting,
                ),
                const SizedBox(height: 24),
                
                // Lista de impresoras
                _buildPrintersList(context, printerProvider),
                const SizedBox(height: 24),
                
                // Información adicional
                const ConnectionTypesInfo(),
                
                // Mostrar errores si los hay
                if (printerProvider.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _buildErrorMessage(context, printerProvider),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, PrinterProvider provider) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.print,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Impresoras Térmicas',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'Configura y prueba tu impresora térmica',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainControls(BuildContext context, PrinterProvider provider) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Controles principales',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          
          // Fila de botones principales
          Row(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: PrimaryButton(
                    text: provider.isScanning ? 'Buscando...' : 'Buscar Impresoras',
                    icon: provider.isScanning ? null : Icons.search,
                    isLoading: provider.isScanning,
                    onPressed: provider.isScanning ? null : () => provider.scanForPrinters(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SecondaryButton(
                  text: 'Detener Búsqueda',
                  icon: Icons.stop,
                  onPressed: provider.isScanning ? () => provider.stopScan() : null,
                ),
              ),
            ],
          ),
          
          // Mensaje informativo durante la búsqueda con animación
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: provider.isScanning 
                ? Container(
                    key: const ValueKey('scanning'),
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Búsqueda en progreso. La búsqueda se detendrá automáticamente en 15 segundos.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('not-scanning')),
          ),
          
          const SizedBox(height: 12),
          
          // Botones de conexión y prueba
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  text: provider.selectedPrinter?.isConnected == true 
                      ? 'Desconectar' 
                      : 'Conectar',
                  icon: provider.selectedPrinter?.isConnected == true 
                      ? Icons.link_off 
                      : Icons.link,
                  isLoading: provider.isConnecting,
                  onPressed: _getConnectionButtonAction(provider),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  text: 'Imprimir Prueba',
                  icon: Icons.print,
                  isLoading: provider.isPrinting,
                  onPressed: provider.hasConnectedPrinter && !provider.isPrinting
                      ? () => provider.printTestTicket()
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  VoidCallback? _getConnectionButtonAction(PrinterProvider provider) {
    if (provider.isConnecting || provider.selectedPrinter == null) {
      return null;
    }
    
    if (provider.selectedPrinter!.isConnected) {
      return () => provider.disconnectFromSelectedPrinter();
    } else {
      return () => provider.connectToSelectedPrinter();
    }
  }

  Widget _buildPrintersList(BuildContext context, PrinterProvider provider) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Impresoras encontradas',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${provider.printers.length}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (provider.printers.isEmpty) ...[
            _buildEmptyPrintersState(context, provider),
          ] else ...[
            ...provider.printers.map((printer) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: PrinterListTile(
                printer: printer,
                isSelected: provider.selectedPrinter?.address == printer.address,
                isConnecting: provider.isConnecting && 
                    provider.selectedPrinter?.address == printer.address,
                onTap: () => provider.selectPrinter(printer),
                onConnect: () async {
                  await provider.selectPrinter(printer);
                  provider.connectToSelectedPrinter();
                },
                onDisconnect: () async {
                  await provider.selectPrinter(printer);
                  provider.disconnectFromSelectedPrinter();
                },
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyPrintersState(BuildContext context, PrinterProvider provider) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            provider.isScanning ? Icons.search : Icons.print_disabled,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            provider.isScanning 
                ? 'Buscando impresoras...' 
                : 'No se encontraron impresoras',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            provider.isScanning
                ? 'Por favor espera mientras buscamos impresoras disponibles'
                : 'Presiona "Buscar Impresoras" para comenzar la búsqueda',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, PrinterProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              provider.errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
          IconButton(
            onPressed: () => provider.clearError(),
            icon: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }
}
