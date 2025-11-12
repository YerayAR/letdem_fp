# Marketplace Feature - Architecture Documentation

## Overview
The marketplace feature follows **Clean Architecture** principles with clear separation between domain, data, and presentation layers.

## Folder Structure

```
lib/features/marketplace/
├── domain/                         # Business Logic Layer
│   ├── entities/                   # Pure business objects (future use)
│   ├── repositories/              # Repository interfaces (contracts)
│   │   └── marketplace_repository.dart
│   ├── usecases/                  # Business use cases (future implementation)
│   │   ├── cart/
│   │   ├── catalog/
│   │   ├── orders/
│   │   └── vouchers/
│   └── marketplace_domain.dart    # Domain layer barrel export
│
├── data/                          # Data Layer
│   ├── datasources/              # Remote/Local data sources (future)
│   ├── models/                   # Data models with JSON serialization
│   │   ├── cart_item.model.dart
│   │   ├── order.model.dart
│   │   ├── product.model.dart
│   │   ├── store.model.dart
│   │   └── voucher.model.dart
│   ├── repositories/             # Repository implementations
│   │   └── marketplace_repository_impl.dart
│   └── marketplace_data.dart     # Data layer barrel export
│
├── presentation/                  # Presentation Layer
│   ├── bloc/                     # State Management (BLoC/Cubit)
│   │   ├── cart/                # Cart management BLoC
│   │   ├── store_catalog/       # Store catalog BLoC
│   │   ├── store_products/      # Store products BLoC
│   │   ├── order_history/       # Order history Cubit
│   │   ├── pending_vouchers/    # Pending vouchers Cubit
│   │   └── marketplace_blocs.dart
│   │
│   ├── pages/                    # UI Pages (renamed from views)
│   │   ├── start/               # Landing/start page
│   │   ├── catalog/             # Store & product browsing
│   │   ├── cart/                # Shopping cart & checkout
│   │   ├── purchases/           # Purchase flow & order history
│   │   ├── redeems/             # Voucher redemption flows
│   │   └── marketplace_pages.dart
│   │
│   └── widgets/                  # Reusable UI components
│       ├── common/              # Shared widgets
│       │   ├── category_filter.widget.dart
│       │   ├── product_card.widget.dart
│       │   └── store_card.widget.dart
│       └── marketplace_widgets.dart
│
└── marketplace.dart               # Main feature barrel export

```

## Architecture Layers

### 1. Domain Layer (`domain/`)
**Purpose:** Contains business logic and abstractions

- **Repositories:** Abstract interfaces defining contracts for data operations
- **Entities:** Pure business objects (to be implemented as needed)
- **Use Cases:** Single-responsibility business operations (future implementation)

**Key Files:**
- `marketplace_repository.dart` - Abstract repository interface

### 2. Data Layer (`data/`)
**Purpose:** Handles data operations and external communications

- **Models:** Data Transfer Objects with JSON serialization
- **Repositories:** Concrete implementations of domain repository interfaces
- **Data Sources:** HTTP clients, local storage, etc. (future organization)

**Key Files:**
- `marketplace_repository_impl.dart` - Repository implementation with HTTP calls
- Models: `store`, `product`, `voucher`, `order`, `cart_item`

### 3. Presentation Layer (`presentation/`)
**Purpose:** UI and state management

#### BLoC/Cubit Structure
- **cart/** - Shopping cart state management
- **store_catalog/** - Store listing and filtering
- **store_products/** - Product browsing per store
- **order_history/** - Purchase history
- **pending_vouchers/** - Active vouchers management

#### Pages Organization
- **start/** - Marketplace entry point
- **catalog/** - Browse stores and products
- **cart/** - Shopping cart and checkout
- **purchases/** - Purchase flows and history
- **redeems/** - Voucher creation and redemption

#### Widgets
- **common/** - Reusable components across marketplace

## Import Conventions

### Barrel Exports
The feature provides convenient barrel exports:

```dart
// Import entire feature
import 'package:letdem/features/marketplace/marketplace.dart';

// Or import specific layers
import 'package:letdem/features/marketplace/domain/marketplace_domain.dart';
import 'package:letdem/features/marketplace/data/marketplace_data.dart';
import 'package:letdem/features/marketplace/presentation/bloc/marketplace_blocs.dart';
import 'package:letdem/features/marketplace/presentation/pages/marketplace_pages.dart';
```

### Relative Imports Within Feature
Use relative imports within the feature:

```dart
// From BLoC to domain
import '../../../domain/repositories/marketplace_repository.dart';

// From BLoC to data models
import '../../../data/models/product.model.dart';

// From page to BLoC
import '../../bloc/cart/cart_bloc.dart';
```

## Dependencies Between Layers

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (BLoCs, Pages, Widgets)                │
│  - Depends on Domain                    │
└─────────────┬───────────────────────────┘
              │
              ↓
┌─────────────────────────────────────────┐
│           Domain Layer                  │
│  (Repositories, Entities, Use Cases)    │
│  - No dependencies on other layers      │
└─────────────┬───────────────────────────┘
              ↑
              │
┌─────────────────────────────────────────┐
│            Data Layer                   │
│  (Repository Impl, Models, Data Sources)│
│  - Depends on Domain                    │
└─────────────────────────────────────────┘
```

## Naming Conventions

- **Pages:** `*.page.dart` (e.g., `store_catalog.page.dart`)
- **Widgets:** `*.widget.dart` (e.g., `product_card.widget.dart`)
- **Models:** `*.model.dart` (e.g., `product.model.dart`)
- **BLoCs:** `*_bloc.dart`, `*_event.dart`, `*_state.dart`
- **Cubits:** `*_cubit.dart`, `*_state.dart`

## State Management Patterns

### BLoC Pattern
Used for complex state with multiple events:
- `store_catalog_bloc` - Multiple filters and searches
- `store_products_bloc` - Product filtering and sorting
- `cart_bloc` - Multiple cart operations

### Cubit Pattern
Used for simpler state transitions:
- `order_history_cubit` - Load and display orders
- `pending_vouchers_cubit` - Load and manage vouchers

## Future Enhancements

### 1. Use Cases Implementation
Create single-responsibility use cases:
```
usecases/
├── catalog/
│   ├── fetch_stores_usecase.dart
│   └── fetch_products_usecase.dart
├── cart/
│   └── checkout_cart_usecase.dart
└── vouchers/
    └── redeem_voucher_usecase.dart
```

### 2. Entity Separation
Create domain entities separate from data models:
```
entities/
├── store_entity.dart
├── product_entity.dart
└── voucher_entity.dart
```

### 3. Data Source Abstraction
```
datasources/
├── marketplace_remote_datasource.dart (interface)
└── marketplace_remote_datasource_impl.dart
```

## Migration Notes

### Changes Made
1. ✅ Moved models from `models/` to `data/models/`
2. ✅ Created domain layer with repository interface
3. ✅ Moved repository implementation to `data/repositories/`
4. ✅ Organized BLoCs into subdirectories
5. ✅ Renamed `views/` to `pages/` and `.view.dart` to `.page.dart`
6. ✅ Organized widgets into `common/` subdirectory
7. ✅ Updated all import paths
8. ✅ Created barrel exports for each layer
9. ✅ Removed duplicate repository files

### Breaking Changes
- Import paths have changed - update external references
- Repository interface renamed from `IMarketplaceRepository` to `MarketplaceRepository`
- Implementation renamed to `MarketplaceRepositoryImpl`

## Testing Structure (Future)
```
test/features/marketplace/
├── domain/
│   ├── usecases/
│   └── repositories/
├── data/
│   ├── models/
│   └── repositories/
└── presentation/
    ├── bloc/
    └── pages/
```

## Best Practices

1. **Dependency Rule:** Outer layers depend on inner layers, never the reverse
2. **Single Responsibility:** Each BLoC/Cubit handles one feature
3. **Immutability:** Use `const` constructors where possible
4. **Error Handling:** Consistent error states in BLoCs
5. **Barrel Exports:** Use for cleaner imports outside the feature

## Questions or Issues?

For architecture questions or refactoring suggestions, consult the team or review Clean Architecture principles.
