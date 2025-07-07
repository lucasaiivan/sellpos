# Detección de Impresoras USB Térmicas

## Descripción General

Se ha implementado un sistema completo de detección de impresoras USB térmicas para la aplicación de punto de venta. El sistema utiliza múltiples métodos de detección para maximizar la compatibilidad con diferentes marcas y modelos de impresoras térmicas.

## Funcionalidades Implementadas

### 1. Detección USB Multicapa

- **Método Principal**: Windows Management Instrumentation (WMI) via PowerShell
- **Método Fallback**: Windows SetupAPI con ffi/win32
- **Servicio Unificado**: Combina ambos métodos para máxima compatibilidad

### 2. Filtrado Específico para Impresoras Térmicas

#### Fabricantes Soportados:
- Epson (VID: 04B8)
- Star Micronics (VID: 0519) 
- Citizen (VID: 2730)
- Bixolon (VID: 0BDA)
- Custom/Samsung (VID: 04E8)
- Sewoo (VID: 0471)
- Partner Tech (VID: 20D1)
- SNBC (VID: 0DD4, 28E9)
- Xprinter (VID: 2909)
- Goojprt (VID: 4348)
- Y otros fabricantes comunes

#### Palabras Clave de Detección:
- thermal, receipt, pos, ticket
- Modelos específicos: TM-, TSP, CT-, SRP, RP, ZJ
- thermal printer, receipt printer, pos printer

### 3. Interfaz de Usuario Mejorada

#### Página de Configuración con Pestañas:
- **Pestaña Red**: Configuración de impresoras de red
- **Pestaña USB**: Detección y configuración de impresoras USB

#### Funcionalidades USB:
- Búsqueda automática de dispositivos
- Lista visual de impresoras detectadas
- Selección fácil con información detallada
- Configuración con un clic

### 4. Información Detallada de Dispositivos

Para cada impresora detectada se muestra:
- Nombre amigable del dispositivo
- Fabricante
- Vendor ID (VID) y Product ID (PID)
- Ruta del dispositivo
- Estado de conexión

## Archivos Creados/Modificados

### Nuevos Servicios:
1. `lib/core/services/enhanced_usb_detector.dart`
   - Detección usando WMI y PowerShell
   - Fallback a SetupAPI

2. `lib/core/services/thermal_printer_detection_service.dart`
   - Servicio unificado que combina todos los métodos
   - Eliminación de duplicados
   - Scoring de completitud de información

### Servicios Modificados:
1. `lib/core/services/usb_device_detector.dart`
   - Mejorado con más VIDs de fabricantes
   - Palabras clave más específicas
   - Correcciones de bugs

### UI Actualizada:
1. `lib/presentation/pages/printer_configuration_page.dart`
   - Interfaz con pestañas (Red/USB)
   - Lista interactiva de dispositivos USB
   - Botón de reporte de debug
   - Selección visual de impresoras

2. `lib/presentation/providers/thermal_printer_provider.dart`
   - Métodos adicionales para búsqueda específica
   - Reporte de detección para debug
   - Gestión de estado USB mejorada

### Repositorio:
1. `lib/data/repositories/thermal_printer_repository_impl.dart`
   - Integración con el servicio unificado
   - Mejor manejo de errores

## Uso de la Funcionalidad

### Para el Usuario:
1. Abrir "Configurar Impresora"
2. Ir a la pestaña "USB"
3. Presionar "Buscar Impresoras USB"
4. Seleccionar la impresora deseada de la lista
5. Presionar "Configurar Impresora USB Seleccionada"

### Para Desarrollo/Debug:
- En modo debug, usar "Ver Reporte de Detección" para información detallada
- Los logs incluyen VID/PID, rutas de dispositivo y puntajes de completitud

## Compatibilidad

### Sistema Operativo:
- Windows 7/8/10/11 (x64)
- Requiere PowerShell para detección avanzada

### Impresoras Soportadas:
- Impresoras térmicas USB estándar
- Dispositivos con controladores genéricos USB
- Impresoras con chips USB-Serie (FTDI, CH340, etc.)

## Tecnologías Utilizadas

- **Flutter**: Framework principal
- **win32**: API de Windows nativa
- **ffi**: Foreign Function Interface para APIs de sistema
- **PowerShell**: WMI queries para detección avanzada
- **SetupAPI**: API nativa de Windows para dispositivos

## Notas Técnicas

- La detección WMI requiere permisos estándar de usuario
- SetupAPI funciona como fallback sin permisos adicionales
- El sistema combina resultados para máxima compatibilidad
- Filtrado inteligente reduce falsos positivos

## Próximos Pasos Sugeridos

1. **Pruebas Reales**: Probar con diferentes modelos de impresoras térmicas
2. **Optimización**: Cachear resultados de detección
3. **Conectividad**: Implementar comunicación directa por USB
4. **Feedback**: Mejorar mensajes de error y guías de usuario
