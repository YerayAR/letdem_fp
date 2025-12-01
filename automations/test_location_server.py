#!/usr/bin/env python3
"""
WebSocket server that simulates real-time location tracking for testing.
Sends random location updates mimicking a person moving around.

Usage:
    pip install websockets
    python test_location_server.py

Then update your Flutter app to connect to ws://localhost:8765
"""

import asyncio
import json
import random
import math
from datetime import datetime
from websockets.server import serve

# Starting location (you can change this to any city)
# Default: San Francisco
BASE_LAT = 37.7749
BASE_LNG = -122.4194

# Movement parameters
MOVEMENT_SPEED = 0.0001  # degrees per update (~11 meters)
UPDATE_INTERVAL = 1.0     # seconds between updates

class LocationSimulator:
    def __init__(self, base_lat, base_lng):
        self.lat = base_lat
        self.lng = base_lng
        self.direction = random.uniform(0, 2 * math.pi)  # Random initial direction

    def move(self):
        """Simulate realistic movement with occasional direction changes"""
        # 20% chance to change direction
        if random.random() < 0.2:
            self.direction += random.uniform(-math.pi/4, math.pi/4)

        # Move in current direction
        self.lat += MOVEMENT_SPEED * math.cos(self.direction)
        self.lng += MOVEMENT_SPEED * math.sin(self.direction)

        # Add slight randomness
        self.lat += random.uniform(-MOVEMENT_SPEED/10, MOVEMENT_SPEED/10)
        self.lng += random.uniform(-MOVEMENT_SPEED/10, MOVEMENT_SPEED/10)

        return self.lat, self.lng


async def location_handler(websocket, path):
    """Handle WebSocket connections and send location updates"""
    print(f"🟢 New connection from {websocket.remote_address}")

    # Parse query parameters (token and reservation_id are ignored in test mode)
    print(f"📍 Path: {path}")

    simulator = LocationSimulator(BASE_LAT, BASE_LNG)

    try:
        while True:
            # Simulate movement
            lat, lng = simulator.move()

            # Create message in the expected format
            message = {
                "event_type": "track_location",
                "data": {
                    "lat": round(lat, 6),
                    "lng": round(lng, 6)
                }
            }

            # Send location update
            await websocket.send(json.dumps(message))

            # Log to console
            timestamp = datetime.now().strftime("%H:%M:%S")
            print(f"📡 [{timestamp}] Sent: lat={lat:.6f}, lng={lng:.6f}")

            # Wait before next update
            await asyncio.sleep(UPDATE_INTERVAL)

    except Exception as e:
        print(f"🔴 Connection closed: {e}")


async def main():
    """Start the WebSocket server"""
    print("=" * 60)
    print("🚀 Location Tracking Test Server")
    print("=" * 60)
    print(f"📍 Starting location: ({BASE_LAT}, {BASE_LNG})")
    print(f"⏱️  Update interval: {UPDATE_INTERVAL}s")
    print(f"🏃 Movement speed: ~{MOVEMENT_SPEED * 111000:.1f}m per update")
    print("=" * 60)
    print("🌐 Server running on ws://localhost:8765")
    print("💡 Update your Flutter app to use this URL for testing")
    print("=" * 60)
    print()

    async with serve(location_handler, "localhost", 8765):
        await asyncio.Future()  # run forever


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\n\n👋 Server stopped")
