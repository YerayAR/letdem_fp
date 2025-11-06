# LetDem Mobile - Marketplace

Aplicación móvil Flutter para LetDem con integración completa del sistema de Marketplace.

## Características del Marketplace

- **Catálogo de Tiendas**: Exploración de tiendas por categorías (Ropa, Alimentación, Moda, Gasolineras, Farmacias, Restaurantes)
- **Productos**: Visualización detallada de productos con imágenes, precios, descuentos y stock
- **Sistema de Puntos LetDem**: Gestión de puntos y balance monetario
- **Búsqueda y Filtros**: Búsqueda por nombre y filtrado por categorías
- **Arquitectura BLoC**: Gestión de estado con patrón BLoC
- **Integración con API**: Conexión al backend Django para datos en tiempo real

## Estructura del Marketplace

```
lib/features/marketplace/
├── data/
│   └── marketplace_repository.dart
├── models/
│   ├── product.model.dart
│   └── store.model.dart
├── presentation/
│   ├── bloc/
│   │   ├── store_catalog_bloc.dart
│   │   └── store_products_bloc.dart
│   ├── views/
│   │   ├── marketplace_start.view.dart
│   │   ├── store_catalog.view.dart
│   │   ├── store_products.view.dart
│   │   └── product_detail.view.dart
│   └── widgets/
│       ├── store_card.widget.dart
│       ├── product_card.widget.dart
│       └── category_filter.widget.dart
```

## Acceso

El marketplace se accede desde la pestaña **Profile** en el BottomNavigationBar de la aplicación.

## Getting Started

Este proyecto usa Flutter. Para ejecutarlo:

```bash
flutter pub get
flutter run
```

## Recursos

- [Documentación Flutter](https://docs.flutter.dev/)
- [Flutter BLoC](https://bloclibrary.dev/)
