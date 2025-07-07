import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/printer_provider.dart';
import '../widgets/printer_selection_dialog.dart';

/// Página principal con UI minimalista para mostrar el estado de la impresora
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    // Búsqueda automática al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrinterProvider>().scanForPrinters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('SellPOS'),
      actions: [
        Consumer<PrinterProvider>(
          builder: (context, provider, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Botón de refresh
                IconButton(
                  onPressed: provider.isScanning 
                      ? null 
                      : () => provider.scanForPrinters(),
                  icon: provider.isScanning
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.refresh),
                  tooltip: 'Buscar impresoras',
                ),
                // Botón contador de impresoras
                FilledButton.icon(
                  onPressed: () => _showPrinterSelectionDialog(context, provider),
                  icon: const Icon(Icons.print),
                  label: Text('${provider.printers.length}'),
                ),
                const SizedBox(width: 16),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Consumer<PrinterProvider>(
      builder: (context, provider, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Estado principal de la impresora
              _buildPrinterStatus(provider),
              const SizedBox(height: 32),
              // Información adicional si hay errores
              if (provider.errorMessage != null)
                _buildErrorMessage(provider.errorMessage!),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrinterStatus(PrinterProvider provider) {
    final bool isConnected = provider.selectedPrinter?.isConnected ?? false;
    final bool hasSelectedPrinter = provider.selectedPrinter != null;
    final bool isConnecting = provider.isConnecting;

    IconData statusIcon;
    String statusText;
    String? statusSubtitle;

    if (isConnecting) {
      statusIcon = Icons.sync;
      statusText = 'Conectando...';
      statusSubtitle = provider.selectedPrinter?.name;
    } else if (isConnected) {
      statusIcon = Icons.check_circle;
      statusText = 'Impresora Conectada';
      statusSubtitle = provider.selectedPrinter?.name;
    } else if (hasSelectedPrinter) {
      statusIcon = Icons.error;
      statusText = 'Impresora Desconectada';
      statusSubtitle = provider.selectedPrinter?.name;
    } else {
      statusIcon = Icons.print_disabled;
      statusText = 'Sin Impresora Seleccionada';
      statusSubtitle = provider.printers.isEmpty 
          ? 'No se encontraron impresoras'
          : 'Toca el contador para seleccionar';
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono principal
              isConnecting
                  ? const CircularProgressIndicator()
                  : Icon(
                      statusIcon,
                      size: 64,
                    ),
              const SizedBox(height: 16),
              // Texto principal
              Text(
                statusText,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              // Subtítulo si existe
              if (statusSubtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  statusSubtitle,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              // Botones de acción rápida
              if (hasSelectedPrinter && !isConnecting) ...[
                const SizedBox(height: 24),
                // Botón de imprimir prueba
                if (isConnected) ...[
                  FilledButton.icon(
                    onPressed: provider.isPrinting 
                        ? null 
                        : () => provider.printTestTicket(),
                    icon: provider.isPrinting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.receipt),
                    label: Text(provider.isPrinting ? 'Imprimiendo...' : 'Imprimir Prueba'),
                  ),
                  const SizedBox(height: 12),
                ],
                // Botón de conectar/desconectar
                OutlinedButton.icon(
                  onPressed: isConnected
                      ? () => provider.disconnectFromSelectedPrinter()
                      : () => provider.connectToSelectedPrinter(),
                  icon: Icon(isConnected ? Icons.link_off : Icons.link),
                  label: Text(isConnected ? 'Desconectar' : 'Conectar'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.error_outline, 
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  error,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPrinterSelectionDialog(BuildContext context, PrinterProvider provider) {
    showDialog(
      context: context,
      builder: (context) => PrinterSelectionDialog(provider: provider),
    );
  }
}
