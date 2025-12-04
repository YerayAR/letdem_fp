import 'package:letdem/core/enums/PublishSpaceType.dart';
import 'package:letdem/features/activities/activities_state.dart';
import 'package:letdem/features/auth/models/nearby_payload.model.dart';

/// Mock data for testing TrackLocationView without making real API calls
class MockTrackLocationData {
  /// Creates a dummy ReservedSpacePayload for testing
  /// Location: San Francisco (matches test server default location)
  static ReservedSpacePayload createDummyPayload() {
    return ReservedSpacePayload(
      id: 'test-reservation-123',
      price: 15.99,
      space: Space(
        id: 'test-space-456',
        type: PublishSpaceType.free,
        image: 'https://via.placeholder.com/300',
        location: Location(
          streetName: 'Market Street',
          address: 'San Francisco, CA 94103',
          point: Point(lat: 37.7749, lng: -122.4194),
        ),
        created: DateTime.now().subtract(const Duration(days: 1)),
        resourceType: 'FreeSpace',
        price: '15.99',
        isPremium: false,
        expirationDate: DateTime.now().add(const Duration(hours: 2)),
      ),
      expireAt: DateTime.now().add(const Duration(hours: 2)),
      canceledAt: DateTime.now(),
      status: 'CONFIRMED',
      isOwner: false,
      phone: '+1234567890',
      confirmationCode: 'ABC123',
      carPlateNumber: 'TEST-001',
    );
  }

  /// Creates a dummy payload with custom coordinates
  static ReservedSpacePayload createDummyPayloadWithLocation({
    required double lat,
    required double lng,
    String? streetName,
    String? address,
  }) {
    return ReservedSpacePayload(
      id: 'test-reservation-custom',
      price: 20.00,
      space: Space(
        id: 'test-space-custom',
        type: PublishSpaceType.disabled,
        image: 'https://via.placeholder.com/300',
        location: Location(
          streetName: streetName ?? 'Custom Street',
          address: address ?? 'Custom Address',
          point: Point(lat: lat, lng: lng),
        ),
        created: DateTime.now(),
        resourceType: 'PaidSpace',
        price: '20.00',
        isPremium: true,
        expirationDate: DateTime.now().add(const Duration(hours: 3)),
      ),
      expireAt: DateTime.now().add(const Duration(hours: 3)),
      canceledAt: DateTime.now(),
      status: 'RESERVED',
      isOwner: true,
      phone: '+1234567890',
      confirmationCode: 'XYZ789',
      carPlateNumber: 'CUSTOM-002',
    );
  }

  /// Common test locations
  static const Map<String, Map<String, dynamic>> testLocations = {
    'san_francisco': {
      'lat': 37.7749,
      'lng': -122.4194,
      'name': 'San Francisco, CA',
    },
    'new_york': {'lat': 40.7128, 'lng': -74.0060, 'name': 'New York, NY'},
    'london': {'lat': 51.5074, 'lng': -0.1278, 'name': 'London, UK'},
    'tokyo': {'lat': 35.6762, 'lng': 139.6503, 'name': 'Tokyo, Japan'},
  };

  /// Get dummy space ID (can be anything in test mode)
  static String get dummySpaceId => 'test-space-id-123';
}
