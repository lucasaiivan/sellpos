import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/printer_provider.dart';
import '../providers/http_server_provider.dart';
import '../widgets/printer_selection_dialog.dart';
import '../widgets/http_server_config_dialog.dart';

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
      title: const Text('Sell - POS'),
      actions: [
        Consumer<PrinterProvider>(
          builder: (context, provider, child) {
            return Padding(
              padding: const EdgeInsets.only(right: 8, top: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botón de configuración del servidor HTTP
                  Consumer<HttpServerProvider>(
                    builder: (context, httpProvider, child) {
                      return IconButton(
                        onPressed: () => _showHttpServerConfigDialog(context),
                        icon: Icon(
                          httpProvider.isServerRunning 
                              ? Icons.cloud_done 
                              : Icons.cloud_off,
                          color: httpProvider.isServerRunning
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                        ),
                        tooltip: httpProvider.isServerRunning
                            ? 'Servidor HTTP activo - Configurar'
                            : 'Servidor HTTP inactivo - Configurar',
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  // Botón de refresh con mejores estados visuales y animación
                  AnimatedRotation(
                    turns: provider.isScanning ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 800),
                    child: IconButton(
                      onPressed: provider.isScanning 
                          ? null 
                          : () => provider.scanForPrinters(),
                      icon: provider.isScanning
                          ? AnimatedBuilder(
                              animation: AlwaysStoppedAnimation(0),
                              builder: (context, child) {
                                return TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(seconds: 2),
                                  builder: (context, value, child) {
                                    return Transform.rotate(
                                      angle: value * 6.28318, // 2π radianes
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Icon(
                                            Icons.refresh,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                          SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            )
                          : Icon(
                              Icons.refresh_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      tooltip: 'Buscar impresoras',
                    ),
                  ),
                  //  button : Impresoras con mejor diseño y animación
                  Badge(
                    isLabelVisible: provider.printers.isNotEmpty,
                    label: Text(provider.printers.length.toString()),
                    child: IconButton(
                    onPressed: provider.printers.isEmpty 
                      ? null 
                      : () => _showPrinterSelectionDialog(context, provider),
                    icon: Icon(
                      provider.printers.isEmpty 
                        ? Icons.print_disabled_outlined
                        : provider.selectedPrinter?.isConnected == true
                          ? Icons.print_rounded
                          : Icons.print_outlined,
                      color: provider.printers.isEmpty 
                        ? Theme.of(context).colorScheme.outline
                        : provider.selectedPrinter?.isConnected == true
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.secondary,
                    ),
                    tooltip: provider.printers.isEmpty 
                      ? 'No hay impresoras disponibles'
                      : 'Seleccionar Impresora (${provider.printers.length} encontradas)',
                    ),
                  ),
                    
                ],
              ),
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
    Color? iconColor;

    if (isConnecting) {
      statusIcon = Icons.sync;
      statusText = 'Conectando...';
      statusSubtitle = provider.selectedPrinter?.name;
      iconColor = Theme.of(context).colorScheme.primary;
    } else if (isConnected) {
      statusIcon = Icons.check_circle;
      statusText = 'Impresora Conectada';
      statusSubtitle = provider.selectedPrinter?.name;
      iconColor = Theme.of(context).colorScheme.primary;
    } else if (hasSelectedPrinter) {
      statusIcon = Icons.error;
      statusText = 'Impresora Desconectada';
      statusSubtitle = provider.selectedPrinter?.name;
      iconColor = Theme.of(context).colorScheme.error;
    } else {
      statusIcon = Icons.print_disabled;
      statusText = 'Sin Impresora Seleccionada';
      statusSubtitle = provider.printers.isEmpty 
          ? 'No se encontraron impresoras'
          : 'Toca el botón "Impresoras" para seleccionar';
      iconColor = Theme.of(context).colorScheme.outline;
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono principal con animación
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isConnecting
                    ? SizedBox(
                        key: const ValueKey('progress'),
                        width: 64,
                        height: 64,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : Icon(
                        key: ValueKey(statusIcon),
                        statusIcon,
                        size: 64,
                        color: iconColor,
                      ),
              ),
              const SizedBox(height: 16),
              // Texto principal
              Text(
                statusText,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              // Subtítulo si existe
              if (statusSubtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  statusSubtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
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
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.receipt_long),
                    label: Text(provider.isPrinting ? 'Imprimiendo...' : 'Ticket de Compra (test)'),
                  ),
                  const SizedBox(height: 8),
                  // Botón de configuración
                  FilledButton.icon(
                    onPressed: provider.isPrinting 
                        ? null 
                        : () => provider.printConfigurationTicket(),
                    icon: const Icon(Icons.receipt_long),
                    label: const Text( 'Ticket de Configuración'),
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

  void _showHttpServerConfigDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const HttpServerConfigDialog(),
    );
  }

  void _showPrinterSelectionDialog(BuildContext context, PrinterProvider provider) {
    showDialog(
      context: context,
      builder: (context) => PrinterSelectionDialog(provider: provider),
    );
  }
}
