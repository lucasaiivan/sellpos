import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../data/models/http_server_config.dart';
import '../providers/http_server_provider.dart';
import '../providers/printer_provider.dart';

class HttpServerConfigDialog extends StatefulWidget {
  const HttpServerConfigDialog({super.key});

  @override
  State<HttpServerConfigDialog> createState() => _HttpServerConfigDialogState();
}

class _HttpServerConfigDialogState extends State<HttpServerConfigDialog> {
  late final TextEditingController _hostController;
  late final TextEditingController _portController;
  late final TextEditingController _originsController;
  
  late bool _isEnabled;
  late bool _corsEnabled;
  
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    final config = context.read<HttpServerProvider>().config;
    
    _hostController = TextEditingController(text: config.host);
    _portController = TextEditingController(text: config.port.toString());
    _originsController = TextEditingController(
      text: config.allowedOrigins.join(', '),
    );
    
    _isEnabled = config.isEnabled;
    _corsEnabled = config.corsEnabled;
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _originsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.settings_ethernet,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          const Text('Configuración del Servidor HTTP'),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Estado del servidor
              _buildServerStatus(),
              const SizedBox(height: 24),
              
              // Switch para habilitar/deshabilitar
              _buildEnableSwitch(),
              const SizedBox(height: 16),
              
              // Configuraciones cuando está habilitado
              if (_isEnabled) ...[
                _buildHostField(),
                const SizedBox(height: 16),
                _buildPortField(),
                const SizedBox(height: 16),
                _buildCorsSwitch(),
                if (_corsEnabled) ...[
                  const SizedBox(height: 16),
                  _buildOriginsField(),
                ],
                const SizedBox(height: 24),
                _buildTestSection(),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _saveConfiguration,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }

  Widget _buildServerStatus() {
    return Consumer<HttpServerProvider>(
      builder: (context, provider, child) {
        final isRunning = provider.isServerRunning;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isRunning 
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isRunning 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isRunning ? Icons.cloud_done : Icons.cloud_off,
                color: isRunning 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRunning ? 'Servidor Activo' : 'Servidor Inactivo',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: isRunning 
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (isRunning)
                      Text(
                        provider.serverUrl,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnableSwitch() {
    return SwitchListTile(
      title: const Text('Habilitar Servidor HTTP'),
      subtitle: const Text('Permite que otras aplicaciones se conecten vía HTTP'),
      value: _isEnabled,
      onChanged: (value) {
        setState(() {
          _isEnabled = value;
        });
      },
    );
  }

  Widget _buildHostField() {
    return TextFormField(
      controller: _hostController,
      decoration: const InputDecoration(
        labelText: 'Host/Dirección',
        hintText: 'localhost o 127.0.0.1',
        prefixIcon: Icon(Icons.computer),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Ingrese una dirección válida';
        }
        return null;
      },
    );
  }

  Widget _buildPortField() {
    return TextFormField(
      controller: _portController,
      decoration: const InputDecoration(
        labelText: 'Puerto',
        hintText: '8080',
        prefixIcon: Icon(Icons.numbers),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(5),
      ],
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Ingrese un puerto válido';
        }
        final port = int.tryParse(value);
        if (port == null || port < 1 || port > 65535) {
          return 'Puerto debe estar entre 1 y 65535';
        }
        return null;
      },
    );
  }

  Widget _buildCorsSwitch() {
    return SwitchListTile(
      title: const Text('Habilitar CORS'),
      subtitle: const Text('Permite solicitudes desde otras aplicaciones web'),
      value: _corsEnabled,
      onChanged: (value) {
        setState(() {
          _corsEnabled = value;
        });
      },
    );
  }

  Widget _buildOriginsField() {
    return TextFormField(
      controller: _originsController,
      decoration: const InputDecoration(
        labelText: 'Orígenes Permitidos',
        hintText: '*, http://localhost:3000, https://miapp.com',
        prefixIcon: Icon(Icons.public),
        border: OutlineInputBorder(),
        helperText: 'Separe múltiples orígenes con comas. Use * para permitir todos.',
      ),
      maxLines: 2,
    );
  }

  Widget _buildTestSection() {
    return Consumer<HttpServerProvider>(
      builder: (context, provider, child) {
        final isServerRunning = provider.isServerRunning;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bug_report,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Probar Servidor',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Usa estos botones para verificar que el servidor responde correctamente',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: isServerRunning ? _testServerStatus : null,
                    icon: const Icon(Icons.health_and_safety, size: 18),
                    label: const Text('Probar Status'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(120, 36),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: isServerRunning ? _testPrinterConfig : null,
                    icon: const Icon(Icons.settings_applications, size: 18),
                    label: const Text('Probar Config'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(120, 36),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: isServerRunning ? _testPrintTicket : null,
                    icon: const Icon(Icons.print, size: 18),
                    label: const Text('Prueba Impresión'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(140, 36),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _testServerStatus() async {
    final provider = context.read<HttpServerProvider>();
    await _performTest(
      'Status del Servidor',
      () async {
        final response = await http.get(
          Uri.parse('${provider.serverUrl}/status'),
        ).timeout(const Duration(seconds: 5));
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return 'Servidor activo: ${data['message']}';
        } else {
          throw Exception('HTTP ${response.statusCode}');
        }
      },
    );
  }

  Future<void> _testPrinterConfig() async {
    final provider = context.read<HttpServerProvider>();
    final printerProvider = context.read<PrinterProvider>();
    
    // Verificar que hay impresoras disponibles antes de la prueba
    if (printerProvider.printers.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(child: Text('No hay impresoras disponibles. Primero busque impresoras usando el botón de actualizar en la pantalla principal.')),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    await _performTest(
      'Configuración de Impresora',
      () async {
        final response = await http.post(
          Uri.parse('${provider.serverUrl}/configure-printer'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({}), // Ya no necesita parámetros específicos
        ).timeout(const Duration(seconds: 5));
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return 'Configuración exitosa: ${data['message']}';
        } else {
          final data = jsonDecode(response.body);
          throw Exception('${data['message']}');
        }
      },
    );
  }

  Future<void> _testPrintTicket() async {
    final provider = context.read<HttpServerProvider>();
    await _performTest(
      'Impresión de Ticket',
      () async {
        final response = await http.post(
          Uri.parse('${provider.serverUrl}/print-ticket'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'businessName': 'Tienda de Prueba',
            'products': [
              {
                'quantity': 1,
                'description': 'Producto de Prueba',
                'price': 10.50
              }
            ],
            'total': 10.50,
            'paymentMethod': 'Efectivo',
            'timestamp': DateTime.now().toIso8601String(),
          }),
        ).timeout(const Duration(seconds: 5));
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return 'Impresión exitosa: ${data['message']}';
        } else {
          throw Exception('HTTP ${response.statusCode}');
        }
      },
    );
  }

  Future<void> _performTest(String testName, Future<String> Function() testFunction) async {
    try {
      // Mostrar loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text('Probando $testName...'),
              ],
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }

      // Ejecutar prueba
      final result = await testFunction();
      
      // Mostrar resultado exitoso
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(result)),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Mostrar error
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text('Error en $testName: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _saveConfiguration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final origins = _originsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (origins.isEmpty) {
        origins.add('*');
      }

      final newConfig = HttpServerConfig(
        isEnabled: _isEnabled,
        host: _hostController.text.trim(),
        port: int.parse(_portController.text.trim()),
        corsEnabled: _corsEnabled,
        allowedOrigins: origins,
      );

      final provider = context.read<HttpServerProvider>();
      final success = await provider.updateConfiguration(newConfig);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Configuración guardada exitosamente')),
                ],
              ),
              backgroundColor: Colors.green,
              action: newConfig.isEnabled ? SnackBarAction(
                label: 'Probar',
                textColor: Colors.white,
                onPressed: () => _testServerStatus(),
              ) : null,
            ),
          );
          // No cerrar el diálogo inmediatamente para permitir pruebas
          // Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? 'Error guardando configuración'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
