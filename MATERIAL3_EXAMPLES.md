# Ejemplos de Material Design 3 - SellPOS

## 🎨 Componentes Implementados

### 1. Configuración del Tema

```dart
// main.dart
MaterialApp(
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    fontFamily: 'Segoe UI',
    // Configuraciones específicas
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      elevation: 1,
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
      ),
    ),
  ),
  themeMode: ThemeMode.system, // Soporte automático claro/oscuro
)
```

### 2. AppBar Material 3

```dart
// main_page.dart
AppBar(
  title: const Text('SellPOS'),
  actions: [
    // Badge con contador
    Badge(
      isLabelVisible: provider.printers.isNotEmpty,
      label: Text('${provider.printers.length}'),
      child: FilledButton.icon(
        onPressed: () => _showPrinterSelectionDialog(context, provider),
        icon: const Icon(Icons.print),
        label: const Text('Impresoras'),
      ),
    ),
  ],
)
```

### 3. Card con Estado Visual

```dart
// main_page.dart
Card(
  child: Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        // Icono con color semántico
        Icon(
          statusIcon,
          size: 64,
          color: iconColor, // Del ColorScheme
        ),
        // Texto con tipografía del tema
        Text(
          statusText,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  ),
)
```

### 4. AlertDialog Material 3

```dart
// printer_selection_dialog.dart
AlertDialog(
  icon: const Icon(Icons.print),
  title: const Text('Seleccionar Impresora'),
  content: SizedBox(/* ... */),
  actions: [
    TextButton.icon(/* ... */),
    FilledButton.tonal( // Botón secundario
      onPressed: () => Navigator.of(context).pop(),
      child: const Text('Cerrar'),
    ),
  ],
)
```

### 5. Lista con Cards Interactivas

```dart
// printer_selection_dialog.dart
Card(
  elevation: isSelected ? 3 : 1,
  color: isSelected 
      ? Theme.of(context).colorScheme.primaryContainer 
      : null,
  child: InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: () {/* ... */},
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Badge para estado
          Badge(
            isLabelVisible: printer.isConnected,
            label: Icon(Icons.check, size: 12),
            child: CircleAvatar(/* ... */),
          ),
          // Información con colores semánticos
          Expanded(
            child: Column(
              children: [
                Text(
                  printer.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
)
```

## 🎯 Colores Semánticos Utilizados

### Estados Primarios
```dart
Theme.of(context).colorScheme.primary              // Azul principal
Theme.of(context).colorScheme.onPrimary            // Blanco sobre azul
Theme.of(context).colorScheme.primaryContainer     // Azul claro de fondo
Theme.of(context).colorScheme.onPrimaryContainer   // Texto sobre azul claro
```

### Estados Secundarios
```dart
Theme.of(context).colorScheme.secondaryContainer   // Fondo alternativo
Theme.of(context).colorScheme.onSecondaryContainer // Texto sobre alternativo
```

### Estados de Superficie
```dart
Theme.of(context).colorScheme.surface              // Fondo base
Theme.of(context).colorScheme.onSurface            // Texto sobre fondo
Theme.of(context).colorScheme.surfaceVariant       // Fondo variante
Theme.of(context).colorScheme.onSurfaceVariant     // Texto sobre variante
Theme.of(context).colorScheme.outline              // Bordes y elementos inactivos
```

### Estados de Error
```dart
Theme.of(context).colorScheme.error                // Error principal
Theme.of(context).colorScheme.errorContainer       // Fondo de error
Theme.of(context).colorScheme.onErrorContainer     // Texto sobre error
```

## 🔧 Tipografía Material 3

### Jerarquía de Texto
```dart
Theme.of(context).textTheme.headlineSmall    // Títulos principales (24px)
Theme.of(context).textTheme.titleLarge       // Títulos de sección (22px)
Theme.of(context).textTheme.titleMedium      // Subtítulos (16px)
Theme.of(context).textTheme.titleSmall       // Títulos pequeños (14px)
Theme.of(context).textTheme.bodyLarge        // Texto principal (16px)
Theme.of(context).textTheme.bodyMedium       // Texto secundario (14px)
Theme.of(context).textTheme.bodySmall        // Texto auxiliar (12px)
```

### Uso en la App
```dart
// Título principal de cards
Text(
  'Impresora Conectada',
  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
    fontWeight: FontWeight.w600,
  ),
)

// Subtítulos informativos
Text(
  printer.name,
  style: Theme.of(context).textTheme.titleMedium?.copyWith(
    fontWeight: FontWeight.w600,
    color: isSelected 
        ? Theme.of(context).colorScheme.onPrimaryContainer
        : null,
  ),
)

// Texto descriptivo
Text(
  'Asegúrate de que la impresora esté encendida',
  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  ),
)
```

## 🚀 Componentes de Botones

### Jerarquía de Botones
```dart
// 1. Acción principal más importante
FilledButton.icon(
  onPressed: () {},
  icon: const Icon(Icons.print),
  label: const Text('Imprimir'),
)

// 2. Acción secundaria importante
FilledButton.tonal(
  onPressed: () {},
  child: const Text('Cerrar'),
)

// 3. Acción secundaria normal
OutlinedButton.icon(
  onPressed: () {},
  icon: const Icon(Icons.link),
  label: const Text('Conectar'),
)

// 4. Acción terciaria o menos importante
TextButton.icon(
  onPressed: () {},
  icon: const Icon(Icons.refresh),
  label: const Text('Actualizar'),
)
```

## 📱 Estados Interactivos

### Indicadores de Carga
```dart
// En botones
FilledButton.icon(
  onPressed: isLoading ? null : () {},
  icon: isLoading
      ? SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        )
      : const Icon(Icons.print),
  label: Text(isLoading ? 'Imprimiendo...' : 'Imprimir'),
)

// En áreas de contenido
AnimatedSwitcher(
  duration: const Duration(milliseconds: 300),
  child: isLoading
      ? CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        )
      : Icon(statusIcon, color: iconColor),
)
```

### Feedback Visual
```dart
// Cards seleccionables
Card(
  elevation: isSelected ? 3 : 1,
  color: isSelected 
      ? Theme.of(context).colorScheme.primaryContainer 
      : null,
  child: InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: () {},
    child: /* contenido */,
  ),
)

// Estados con chips
if (printer.isConnected)
  Chip(
    label: const Text('Conectado'),
    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
    side: BorderSide.none,
    labelStyle: TextStyle(
      color: Theme.of(context).colorScheme.onSecondaryContainer,
    ),
  )
```

## ✨ Beneficios Obtenidos

### 1. **Consistencia Visual**
- Todos los componentes siguen el mismo sistema de diseño
- Colores automáticamente coherentes
- Espaciado estandarizado

### 2. **Accesibilidad**
- Contraste automático según el modo (claro/oscuro)
- Tamaños de toque apropiados (mínimo 48px)
- Navegación por teclado mejorada
- Soporte para screen readers

### 3. **Adaptabilidad**
- Modo oscuro automático
- Responsive design
- Colores que se adaptan al sistema

### 4. **Mantenibilidad**
- Menos código personalizado
- Actualizaciones automáticas con Flutter
- Estándares de la industria

### 5. **Experiencia de Usuario**
- Animaciones suaves integradas
- Feedback visual inmediato
- Navegación intuitiva
- Consistencia con otras apps del sistema
