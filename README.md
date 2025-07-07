# SellPOS - Sistema de Gestión de Impresoras

Aplicación de escritorio para Windows desarrollada en Flutter que permite gestionar y controlar impresoras térmicas de forma sencilla y eficiente.

## 🌟 Características

- **UI Material Design 3**: Interfaz moderna que sigue las últimas guías de Google
- **Modo Claro/Oscuro**: Soporte automático según la preferencia del sistema
- **Accesibilidad**: Contraste automático y navegación optimizada
- **Colores Semánticos**: Paleta de colores coherente y adaptativa
- **Detección Automática**: Búsqueda automática de impresoras al iniciar la aplicación
- **Gestión Simple**: Estado centralizado de conexión de impresoras
- **Selector Intuitivo**: Diálogo elegante para seleccionar entre múltiples impresoras
- **Indicadores Visuales**: Estados claros de conexión con feedback inmediato
- **Soporte Multiplataforma**: Compatible con conexiones USB, Bluetooth y red
- **Animaciones Suaves**: Transiciones nativas de Material 3

## 🎨 Diseño Material 3

### Implementación Completa
- ✅ **ColorScheme.fromSeed()**: Paleta generada automáticamente
- ✅ **Tipografía Semántica**: Jerarquía textual estándar
- ✅ **Componentes Nativos**: AlertDialog, Card, FilledButton, Badge, Chip
- ✅ **Estados Visuales**: Feedback táctil y visual mejorado
- ✅ **Espaciado Consistente**: Padding y margin estandarizados

### Componentes Utilizados
- **FilledButton.icon**: Acciones primarias importantes
- **OutlinedButton.icon**: Acciones secundarias
- **Card**: Contenedores de información
- **Badge**: Indicadores numéricos
- **Chip**: Estados y etiquetas
- **CircularProgressIndicator**: Estados de carga

## 🚀 Ejecución

### Requisitos
- Flutter SDK
- Windows 10 o superior
- Visual Studio Build Tools

### Comandos
```bash
# Instalar dependencias
flutter pub get

# Ejecutar en Windows
flutter run -d windows

# Compilar para Windows
flutter build windows
```

## 🏗️ Arquitectura

El proyecto sigue una arquitectura limpia con separación de responsabilidades:

- **Presentation**: UI components, páginas y providers
- **Domain**: Entidades y casos de uso
- **Data**: Repositorios e implementaciones

### Dependencias Principales
- `flutter_thermal_printer`: Control de impresoras térmicas
- `provider`: Gestión de estado
- `material`: Componentes de Material Design 3

## 📱 Pantallas

1. **MainPage**: Pantalla principal con estado de impresora
2. **PrinterSelectionDialog**: Diálogo de selección de impresoras
