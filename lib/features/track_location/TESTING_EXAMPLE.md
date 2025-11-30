# Testing TrackLocationView

## Quick Example

Here's how to test the location tracking feature using the mock server:

```dart
import 'package:flutter/material.dart';
import 'package:letdem/features/track_location/view/track_location_view.dart';
import 'package:letdem/features/track_location/mock/mock_data.dart';

// Example: Navigate to the tracking view for testing
void openTrackLocationForTesting(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TrackLocationView(
        payload: MockTrackLocationData.createDummyPayload(),
        spaceId: MockTrackLocationData.dummySpaceId,
        useTestServer: true, // 🧪 Use test server
      ),
    ),
  );
}
```

## Step-by-Step Testing

### 1. Start the Python test server
```bash
./automations/run_test_server.sh
```

### 2. Use TrackLocationView with test mode

**Option A: Hardcode for testing**
```dart
TrackLocationView(
  payload: MockTrackLocationData.createDummyPayload(),
  spaceId: 'any-id-works-in-test-mode',
  useTestServer: true, // 🧪 Connect to localhost:8765
)
```

**Option B: Toggle based on build mode**
```dart
import 'package:flutter/foundation.dart';

TrackLocationView(
  payload: realPayload,
  spaceId: realSpaceId,
  useTestServer: kDebugMode, // Auto-enable in debug builds
)
```

**Option C: Use a debug flag**
```dart
// In your app config or constants
class AppConfig {
  static const bool useMockLocationServer = true; // Toggle this
}

// In your code
TrackLocationView(
  payload: MockTrackLocationData.createDummyPayload(),
  spaceId: MockTrackLocationData.dummySpaceId,
  useTestServer: AppConfig.useMockLocationServer,
)
```

## Mock Data Options

### Default San Francisco Location
```dart
final payload = MockTrackLocationData.createDummyPayload();
// Lat: 37.7749, Lng: -122.4194
```

### Custom Location
```dart
final payload = MockTrackLocationData.createDummyPayloadWithLocation(
  lat: 40.7128,
  lng: -74.0060,
  streetName: 'Broadway',
  address: 'New York, NY',
);
```

### Use Predefined Test Locations
```dart
// Available: san_francisco, new_york, london, tokyo
final nyc = MockTrackLocationData.testLocations['new_york']!;
final payload = MockTrackLocationData.createDummyPayloadWithLocation(
  lat: nyc['lat'],
  lng: nyc['lng'],
  streetName: nyc['name'],
);
```

## What Happens in Test Mode

When `useTestServer: true`:

✅ Connects to `ws://localhost:8765` instead of production
✅ The `spaceId` parameter is ignored (can be any string)
✅ No authentication token required
✅ Python server sends simulated location updates
✅ Console logs show `🧪 [TEST MODE]` messages

When `useTestServer: false` (default):

🌐 Connects to production server (`ws://api-staging.letdem.org`)
🔐 Requires valid auth token
📍 Requires valid `reservationId`
🚀 Uses real GPS data

## Console Output

### Test Mode
```
🧪 [TEST MODE] Connecting to local test server: ws://localhost:8765/test
🧪 [TEST MODE] Reservation ID: any-id (ignored in test mode)
```

### Production Mode
```
🌐 [PRODUCTION] Connecting to: ws://api-staging.letdem.org/ws/reservations/track-location?token=...
```

## Full Testing Flow Example

```dart
// In your test screen or debug menu
import 'package:flutter/material.dart';
import 'package:letdem/features/track_location/view/track_location_view.dart';
import 'package:letdem/features/track_location/mock/mock_data.dart';

class DebugTrackingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Location Tracking')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TrackLocationView(
                      payload: MockTrackLocationData.createDummyPayload(),
                      spaceId: 'test-123',
                      useTestServer: true, // 🧪 Test mode
                    ),
                  ),
                );
              },
              child: Text('Test: San Francisco'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final nyc = MockTrackLocationData.testLocations['new_york']!;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TrackLocationView(
                      payload: MockTrackLocationData.createDummyPayloadWithLocation(
                        lat: nyc['lat'],
                        lng: nyc['lng'],
                        streetName: nyc['name'],
                      ),
                      spaceId: 'test-456',
                      useTestServer: true, // 🧪 Test mode
                    ),
                  ),
                );
              },
              child: Text('Test: New York'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Tips

1. **Always start the Python server first** before setting `useTestServer: true`
2. **Use dummy data** from `MockTrackLocationData` when testing
3. **Check console logs** to verify which mode you're in
4. **Don't commit** with `useTestServer: true` enabled in production code
5. **Android Emulator**: Change `localhost` to `10.0.2.2` in the cubit if needed

---

Happy testing! 🧪
