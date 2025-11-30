# Automations

Python automation scripts for testing and development.

## Setup

### 1. Create virtual environment
```bash
cd automations
python3 -m venv venv
```

### 2. Activate virtual environment

**macOS/Linux:**
```bash
source venv/bin/activate
```

**Windows:**
```bash
venv\Scripts\activate
```

### 3. Install dependencies
```bash
pip install -r requirements.txt
```

## Scripts

### `test_location_server.py`
WebSocket server that simulates real-time location tracking.

**Usage:**
```bash
source venv/bin/activate  # Activate venv first
python test_location_server.py
```

See `../TESTING_LOCATION_TRACKING.md` for full documentation.

## Deactivate

When done, deactivate the virtual environment:
```bash
deactivate
```
