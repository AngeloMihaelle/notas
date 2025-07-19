# Notas de Ajuste - App de Costura

Una aplicación móvil desarrollada en Flutter para gestionar notas de servicio y ajustes de costura, diseñada específicamente para el negocio "Andrea Gomez: Alta Costura".

## 📱 Características

### Funcionalidades Principales
- **Gestión de Notas de Servicio**: Crear, editar, eliminar y visualizar notas de ajuste
- **Búsqueda Inteligente**: Buscar por cliente, número de factura o descripción de servicios
- **Generación de PDF**: Crear y compartir documentos profesionales de las notas
- **Cálculo Automático**: Subtotales, anticipos (a cuenta) y saldos pendientes
- **Base de Datos Local**: Almacenamiento offline usando SQLite

### Información de Cliente
- Nombre del cliente (requerido)
- Dirección
- Teléfono
- Observaciones adicionales

### Gestión de Servicios
- **Ajustes Detallados**: Cantidad, descripción, valor unitario e importe
- **Cálculo Flexible**: Automático o manual de importes
- **Múltiples Servicios**: Agregar varios ajustes por nota

### Aspectos Financieros
- Subtotal automático
- Manejo de anticipos (a cuenta)
- Cálculo de saldo pendiente
- Indicadores visuales para montos pendientes/pagados

## 🚀 Instalación

### Requisitos Previos
- Flutter SDK (versión 3.0 o superior)
- Dart SDK
- Android Studio / VS Code
- Dispositivo Android o iOS / Emulador

### Dependencias
```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0
  intl: ^0.19.0
  path_provider: ^2.1.1
  pdf: ^3.10.7
  share_plus: ^7.2.1
```

### Pasos de Instalación

1. **Clonar el repositorio**
```bash
git clone https://github.com/AngeloMihaelle/notas 
cd notas_de_ajuste
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Ejecutar la aplicación**
```bash
flutter run
```

## 🏗️ Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── models/
│   └── nota.dart            # Modelos de datos (Nota y Ajuste)
├── screens/
│   ├── home_screen.dart     # Pantalla principal con lista de notas
│   ├── nota_form_screen.dart # Formulario para crear/editar notas
│   └── nota_detail_screen.dart # Vista detallada de nota
└── services/
    ├── database_service.dart # Servicio de base de datos SQLite
    └── pdf_service.dart     # Servicio de generación de PDF
```

## 💾 Base de Datos

La aplicación utiliza SQLite para almacenamiento local con las siguientes tablas:

### Tabla `notas`
- `id` (PRIMARY KEY)
- `factura_no` (TEXT UNIQUE)
- `fecha` (TEXT)
- `cliente` (TEXT)
- `ajustes` (TEXT JSON)
- `subtotal` (REAL)
- `a_cuenta` (REAL)
- `saldo` (REAL)
- `observaciones` (TEXT)
- `direccion` (TEXT)
- `telefono` (TEXT)
- `incluir_terminos` (INTEGER)

## 📋 Uso de la Aplicación

### Crear una Nueva Nota
1. Presionar el botón flotante (+) en la pantalla principal
2. Completar la información del cliente
3. Agregar los ajustes/servicios necesarios
4. Especificar el monto a cuenta (anticipo)
5. Guardar la nota

### Buscar Notas
- Utilizar la barra de búsqueda en la pantalla principal
- Buscar por nombre de cliente, número de factura o descripción de servicios

### Generar PDF
- Abrir el detalle de una nota
- Presionar el ícono de PDF en la barra superior
- El documento se genera y se puede compartir

### Gestión de Servicios
- **Cálculo Automático**: Los importes se calculan automáticamente (cantidad × valor unitario)
- **Edición Manual**: Alternar al modo manual para importes específicos
- **Múltiples Ajustes**: Agregar tantos servicios como sea necesario

## 🎨 Diseño y Tema

- **Tema Principal**: Rosa (#E91E63)
- **Tipografía**: Roboto
- **Idioma**: Español (es_ES)
- **Formato de Fecha**: dd/MM/yyyy

## 📄 Términos y Condiciones Predeterminados

La aplicación incluye términos y condiciones estándar:
- Plazo de entrega: 3 a 5 días hábiles
- Anticipo requerido: 50%
- Modificaciones adicionales con costo extra
- Política de responsabilidad para prendas deterioradas
- Importancia de conservar el recibo

## 🔧 Personalización

### Modificar Información del Negocio
Editar en `nota_detail_screen.dart`:
```dart
Text('Andrea Gomez: Alta Costura')
```

### Cambiar Términos y Condiciones
Modificar el texto en `nota_detail_screen.dart` en la sección de términos.

### Ajustar Colores del Tema
En `main.dart`:
```dart
theme: ThemeData(
  primarySwatch: Colors.pink, // Cambiar color principal
  // ...
),
```

## 🚨 Consideraciones de Desarrollo

- **Numeración Automática**: Las facturas se numeran automáticamente
- **Validaciones**: Campos requeridos y validación de datos
- **Persistencia**: Todos los datos se guardan localmente
- **Responsive**: Adaptado para diferentes tamaños de pantalla

## 🤝 Contribuciones

Para contribuir al proyecto:
1. Fork el repositorio
2. Crear una rama feature (`git checkout -b feature/AmazingFeature`)
3. Commit los cambios (`git commit -m 'Add AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir un Pull Request

## 📝 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 📞 Soporte

Para soporte técnico o consultas sobre la aplicación, contactar al desarrollador.

---

**Desarrollado para Andrea Gomez: Alta Costura** 🪡✨