// Import the implementation class for typedef
import '../data/repositories/marketplace_repository_impl.dart';

// Export both the interface and implementation
export '../domain/repositories/marketplace_repository.dart';
export '../data/repositories/marketplace_repository_impl.dart';

// Provide a concrete implementation for dependency injection
typedef MarketplaceRepository = MarketplaceRepositoryImpl;
