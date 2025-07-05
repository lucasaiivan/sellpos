 
---
applyTo: '**'
---
# Guía de Desarrollo

## Arquitectura y Patrones
- El desarrollo está orientado a aplicaciones desktop (windows) con Flutter
- Aplica siempre el patrón Clean Architecture para mantener una estructura clara y escalable
- Utiliza Provider para la gestión de dependencias y el manejo de estados, siguiendo estrictamente Clean Architecture
- Organiza el código en capas: domain, data, presentation, core

## Diseño y UX
- Implementa Material 3 como guía de diseño y buenas prácticas de UX
- Asegura compatibilidad con el cambio dinámico de brillo (tema claro/oscuro)
- Prioriza la responsividad y accesibilidad en todos los componentes

## Convenciones de Código
- Sigue convención de nombres en inglés clara y consistente para archivos, carpetas, clases y variables
- Utiliza snake_case para archivos y carpetas
- Utiliza PascalCase para clases
- Utiliza camelCase para variables y métodos

## Documentación y Comentarios
- Documenta las funciones clave, limitando la documentación a 1-2 líneas por función únicamente cuando el código no sea autoexplicativo (en español)
- Utiliza comentarios en el código para explicar secciones complejas o no evidentes (en español)
- Evita comentarios redundantes o innecesarios

## Reutilización de Código
- Utiliza `core/` para la creación de widgets reutilizables, evitando duplicación de código y mejorando la mantenibilidad
- Utiliza `core/component_app.dart/` para la creación de componentes reutilizables (buttons, textButtons, inputs, etc.), evitando duplicación de código y mejorando la mantenibilidad
- Crea abstracciones cuando identifiques patrones repetitivos

## Estructura de Directorios
```
lib/
├── core/
│   ├── ComponentApp/     # Componentes reutilizables
│   ├── services/         # Servicios globales
│   ├── widgets/          # Widgets comunes
│   ├── utils/           # Utilidades
│   └── constants/       # Constantes
├── domain/
│   ├── entities/        # Entidades de negocio
│   ├── repositories/    # Interfaces de repositorios
│   └── usecases/        # Casos de uso
├── data/
│   └── repositories/    # Implementaciones de repositorios
└── presentation/
    ├── pages/           # Páginas de la aplicación
    ├── providers/       # Providers de estado
    └── widgets/         # Widgets específicos de páginas
```

## Calidad de Código
- Ejecuta `flutter analyze` regularmente para mantener el código libre de warnings
- Implementa manejo robusto de errores con try-catch apropiados
- Utiliza async/await correctamente para operaciones asíncronas
- Implementa loading states y feedback visual para el usuario
```
