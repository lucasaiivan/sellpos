# 🖨️ SellPOS - Sistema de Impresión Térmica con API HTTP

Sistema de impresión térmica para Windows con servidor HTTP integrado que permite recibir solicitudes de impresión desde aplicaciones web externas.

## ✅ Estado de Implementación

### Conexión HTTP ✅ IMPLEMENTADO
- **Servidor HTTP**: Funciona en `http://localhost:8080`
- **CORS**: Habilitado para conexiones desde aplicaciones web
- **Estado**: Servidor activo y respondiendo correctamente

### Recepción de Datos ✅ IMPLEMENTADO
- **Endpoint principal**: `POST/print-ticket`
- **Formato JSON**: Completamente implementado
- **Validación**: Datos validados antes de procesar

### Impresión Automática ✅ IMPLEMENTADO
- **Generación de tickets**: Sistema completo de formateo
- **Impresión térmica**: Compatible con impresoras ESC/POS
- **Estado**: Impresión automática funcionando

### Respuesta de Éxito ✅ IMPLEMENTADO
- **Respuestas JSON**: Estado de éxito/error detallado
- **Logs**: Sistema de logging completo
- **Confirmación**: Respuesta inmediata del estado de impresión

## 🚀 Endpoints de la API

### 1. Estado del Servidor
```http
GET http://localhost:8080/status
```
**Respuesta:**
```json
{
  "status": "ok",
  "message": "Servidor de impresión activo",
  "timestamp": "2025-07-08T00:59:47.156809",
  "printer": "Impresora conectada: PosTermical",
  "serverVersion": "1.0.0"
}
```

### 2. Configurar Impresora
```http
POST http://localhost:8080/configure-printer
Content-Type: application/json

{}
```
**Nota**: Ya no requiere parámetro `printerName`. Usa automáticamente la impresora configurada en la aplicación.
```

### 3. Ticket de Prueba
```http
POST http://localhost:8080/test-printer
Content-Type: application/json

{}
```

### 4. Imprimir Ticket Personalizado ⭐ PRINCIPAL
```http
POST http://localhost:8080/print-ticket
Content-Type: application/json

{
  "businessName": "Mi Tienda",
  "products": [
    {
      "quantity": "2",
      "description": "Producto A",
      "price": 15.50
    },
    {
      "quantity": "1",
      "description": "Producto B", 
      "price": 25.00
    }
  ],
  "total": 56.00,
  "paymentMethod": "Efectivo",
  "customerName": "Cliente Ejemplo",     // Opcional
  "cashReceived": 60.00,                 // Opcional
  "change": 4.00                         // Opcional
}
```

**Respuesta de Éxito:**
```json
{
  "status": "ok",
  "message": "Ticket impreso correctamente en: PosTermical"
}
```

**Respuesta de Error:**
```json
{
  "status": "error",
  "message": "Descripción del error"
}
```

## 🔧 Uso desde Aplicación Web

### JavaScript/Fetch API
```javascript
async function imprimirTicket(datosTicket) {
  try {
    const response = await fetch('http://localhost:8080/print-ticket', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(datosTicket)
    });
    
    const resultado = await response.json();
    
    if (response.ok) {
      console.log('✅ Ticket impreso:', resultado.message);
      return true;
    } else {
      console.error('❌ Error:', resultado.message);
      return false;
    }
  } catch (error) {
    console.error('❌ Error de conexión:', error);
    return false;
  }
}

// Ejemplo de uso
const ticket = {
  businessName: "Mi Tienda Online",
  products: [
    { quantity: "2", description: "Camiseta", price: 19.99 },
    { quantity: "1", description: "Pantalón", price: 49.99 }
  ],
  total: 89.97,
  paymentMethod: "Tarjeta",
  customerName: "Juan Pérez"
};

imprimirTicket(ticket);
```

### jQuery
```javascript
function imprimirTicket(datosTicket) {
  $.ajax({
    url: 'http://localhost:8080/print-ticket',
    method: 'POST',
    contentType: 'application/json',
    data: JSON.stringify(datosTicket),
    success: function(response) {
      console.log('✅ Ticket impreso:', response.message);
    },
    error: function(xhr) {
      const error = JSON.parse(xhr.responseText);
      console.error('❌ Error:', error.message);
    }
  });
}
```

### PHP (cURL)
```php
function imprimirTicket($datosTicket) {
  $ch = curl_init();
  
  curl_setopt($ch, CURLOPT_URL, 'http://localhost:8080/print-ticket');
  curl_setopt($ch, CURLOPT_POST, true);
  curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($datosTicket));
  curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json'
  ]);
  curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
  
  $response = curl_exec($ch);
  $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
  curl_close($ch);
  
  $resultado = json_decode($response, true);
  
  if ($httpCode == 200) {
    echo "✅ Ticket impreso: " . $resultado['message'];
    return true;
  } else {
    echo "❌ Error: " . $resultado['message'];
    return false;
  }
}
```

## 🛠️ Configuración del Sistema

### Requisitos
- Windows 10/11
- Impresora térmica compatible con ESC/POS
- Puerto disponible 8080

### Instalación
1. Ejecutar la aplicación Flutter: `flutter run -d windows`
2. El servidor HTTP se inicia automáticamente en `http://localhost:8080`
3. Configurar la impresora desde la interfaz de la aplicación

### Configuración de Red
El servidor acepta conexiones desde:
- `localhost` (127.0.0.1)
- IP local de la máquina
- CORS habilitado para aplicaciones web

## 📊 Estados de Respuesta HTTP

| Código | Estado | Descripción |
|--------|--------|-------------|
| 200 | ✅ OK | Operación exitosa |
| 400 | ❌ Bad Request | Datos inválidos o impresora no conectada |
| 404 | ❌ Not Found | Endpoint no encontrado |
| 503 | ❌ Service Unavailable | Sistema de impresión no disponible |

## 🧪 Herramientas de Prueba

### Scripts Incluidos
1. **`test_http_connection.dart`** - Prueba completa de todos los endpoints
2. **`test_web_api.html`** - Interfaz web interactiva para pruebas
3. **`debug_test_printer.dart`** - Debug específico de endpoints

### Ejecutar Pruebas
```bash
# Prueba completa
dart run test_http_connection.dart

# Debug específico
dart run debug_test_printer.dart
```

## 🔍 Troubleshooting

### Problemas Comunes

**1. "Route not found" en /test-printer**
- ✅ **Solución**: Usar POST en lugar de GET

**2. "Impresora no conectada"**
- ✅ **Solución**: Configurar impresora desde la aplicación primero

**3. "CORS Error" desde aplicación web**
- ✅ **Solución**: CORS ya está habilitado, verificar que la aplicación esté ejecutándose

**4. Puerto 8080 ocupado**
- ✅ **Solución**: Cambiar puerto en la configuración de la aplicación

## 📝 Logs del Sistema

El sistema genera logs detallados para debugging:
- Solicitudes HTTP recibidas
- Estado de impresión
- Errores de conexión
- Respuestas enviadas

## 🎯 Casos de Uso

### E-commerce
```javascript
// Al completar una compra online
fetch('http://localhost:8080/print-ticket', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(datosVenta)
});
```

### Punto de Venta Web
```javascript
// Al procesar una venta en POS web
async function procesarVenta(venta) {
  const impreso = await imprimirTicket(venta);
  if (impreso) {
    mostrarMensaje("Ticket impreso correctamente");
  }
}
```

### Sistema de Restaurante
```javascript
// Al confirmar un pedido
function confirmarPedido(pedido) {
  const ticket = formatearTicketRestaurante(pedido);
  imprimirTicket(ticket);
}
```

## ✅ Verificación Final

### Lista de Verificación ✅ COMPLETADA

- [x] **Conexión HTTP**: Servidor funcionando en puerto 8080
- [x] **Recepción de Datos**: Endpoint `/print-ticket` operativo  
- [x] **Impresión Automática**: Tickets se imprimen automáticamente
- [x] **Respuesta de Éxito**: Confirmación JSON de estado
- [x] **Manejo de Errores**: Respuestas de error detalladas
- [x] **CORS**: Habilitado para aplicaciones web
- [x] **Documentación**: Completa con ejemplos
- [x] **Pruebas**: Scripts de verificación funcionando

## 🎉 Resumen

**✅ SISTEMA COMPLETAMENTE FUNCIONAL**

El sistema SellPOS está **completamente implementado** y **funcionando correctamente**:

1. **Servidor HTTP activo** en `http://localhost:8080`
2. **Recepción de datos** vía POST a `/print-ticket`
3. **Impresión automática** de tickets térmicos
4. **Respuesta inmediata** del estado de impresión
5. **Compatible** con aplicaciones web externas
6. **Probado** y verificado funcionando

**¡Listo para usar en producción!** 🚀
