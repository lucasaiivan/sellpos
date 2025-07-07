# SellPOS - Sistema de Gestión de Impresoras

Aplicación de escritorio para Windows desarrollada en Flutter que permite gestionar y controlar impresoras térmicas de forma sencilla y eficiente.

## 🌟 Características

- **UI Minimalista**: Interfaz limpia y moderna con Material Design 3
- **Detección Automática**: Búsqueda automática de impresoras al iniciar la aplicación
- **Gestión Simple**: Estado centralizado de conexión de impresoras
- **Selector Intuitivo**: Diálogo elegante para seleccionar entre múltiples impresoras
- **Indicadores Visuales**: Estados claros de conexión (Conectado/Desconectado/Sin seleccionar)
- **Soporte Multiplataforma**: Compatible con conexiones USB, Bluetooth y red

## 🎨 Interfaz de Usuario

### Pantalla Principal
- **AppBar**: Incluye el nombre de la aplicación, botón de actualización y contador de impresoras disponibles
- **Cuerpo Central**: Muestra el estado actual de la impresora con iconografía intuitiva
- **Controles**: Botones de acción rápida para conectar/desconectar

### Diálogo de Selección
- Lista completa de impresoras detectadas
- Información detallada de cada dispositivo (nombre, dirección, tipo de conexión)
- Estados visuales de conexión
- Actualización en tiempo real

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
