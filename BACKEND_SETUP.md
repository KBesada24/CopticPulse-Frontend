# Backend Connection Setup Guide

This guide explains how to connect your Flutter Coptic Pulse app to your separate backend server.

## Quick Setup

### 1. Update Backend URL

Edit `lib/config/environment.dart` and update the development URL:

```dart
static String get apiBaseUrl {
  switch (_currentEnvironment) {
    case Environment.development:
      return 'http://YOUR_BACKEND_URL:PORT/api/v1'; // Update this line
    case Environment.staging:
      return 'https://staging-api.copticpulse.com/api/v1';
    case Environment.production:
      return 'https://api.copticpulse.com/api/v1';
  }
}
```

### 2. Common Backend URLs

- **Local development**: `http://localhost:3000/api/v1`
- **Local with specific IP**: `http://192.168.1.100:3000/api/v1`
- **Docker container**: `http://host.docker.internal:3000/api/v1`
- **Remote server**: `https://your-domain.com/api/v1`

## Backend API Requirements

Your backend server should provide these endpoints:

### Health Check
```
GET /api/v1/health
Response: {
  "status": "ok",
  "version": "1.0.0",
  "environment": "development",
  "timestamp": "2024-01-01T00:00:00Z",
  "database": "connected"
}
```

### Authentication
```
POST /api/v1/auth/login
POST /api/v1/auth/refresh
POST /api/v1/auth/logout
```

### Data Endpoints
```
GET /api/v1/posts
GET /api/v1/liturgy-events
GET /api/v1/sermons
GET /api/v1/users
POST /api/v1/upload
```

## Testing Connection

### 1. Using the Connection Widget

Add this to any screen to test your connection:

```dart
import 'package:coptic_pulse/widgets/connection_status_widget.dart';

// In your widget build method:
ConnectionStatusWidget()
```

### 2. Using Connection Service Directly

```dart
import 'package:coptic_pulse/services/connection_service.dart';

final connectionService = ConnectionService();
final result = await connectionService.testConnection();

if (result.isConnected) {
  print('Connected to backend!');
  print('Server info: ${result.serverInfo}');
} else {
  print('Connection failed: ${result.message}');
}
```

## Environment Configuration

### Development Environment
- Longer timeouts (60 seconds)
- API logging enabled
- Frequent cache refresh (5 minutes)
- Separate database file

### Production Environment
- Standard timeouts (30 seconds)
- API logging disabled
- Standard cache refresh (1 hour)
- Production database file

## Common Issues & Solutions

### 1. Connection Refused
**Problem**: `Connection refused` or `Network error`
**Solutions**:
- Check if your backend server is running
- Verify the URL and port number
- Check firewall settings
- For mobile testing, use your computer's IP address instead of `localhost`

### 2. CORS Issues
**Problem**: Cross-Origin Request Blocked
**Solutions**:
- Configure CORS in your backend to allow Flutter app origin
- For development, allow `*` origin temporarily

### 3. SSL/HTTPS Issues
**Problem**: SSL certificate errors
**Solutions**:
- Use HTTP for local development
- Configure proper SSL certificates for production
- Add certificate exceptions for testing

### 4. Timeout Issues
**Problem**: Requests timing out
**Solutions**:
- Increase timeout in `environment.dart`
- Check network connectivity
- Optimize backend response times

## Backend Server Examples

### Node.js/Express Example
```javascript
const express = require('express');
const cors = require('cors');
const app = express();

app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/api/v1/health', (req, res) => {
  res.json({
    status: 'ok',
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'development',
    timestamp: new Date().toISOString(),
    database: 'connected'
  });
});

// Your other API endpoints here...

app.listen(3000, () => {
  console.log('Backend server running on port 3000');
});
```

### Python/FastAPI Example
```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure properly for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/api/v1/health")
async def health_check():
    return {
        "status": "ok",
        "version": "1.0.0",
        "environment": "development",
        "timestamp": datetime.now().isoformat(),
        "database": "connected"
    }

# Your other API endpoints here...

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=3000)
```

## Mobile Testing

When testing on a physical device or emulator:

1. **Find your computer's IP address**:
   - Windows: `ipconfig`
   - Mac/Linux: `ifconfig` or `ip addr`

2. **Update the backend URL**:
   ```dart
   return 'http://192.168.1.100:3000/api/v1'; // Use your actual IP
   ```

3. **Ensure your backend accepts connections from all interfaces**:
   - Bind to `0.0.0.0` instead of `localhost` or `127.0.0.1`

## Security Considerations

### Development
- Use HTTP for local development
- Enable CORS for all origins temporarily
- Use simple authentication

### Production
- Always use HTTPS
- Configure CORS properly
- Implement proper authentication and authorization
- Use environment variables for sensitive configuration

## Next Steps

1. Update the backend URL in `environment.dart`
2. Start your backend server
3. Test the connection using the ConnectionStatusWidget
4. Implement your specific API endpoints
5. Test offline functionality with the caching system

For more help, check the connection logs in your Flutter app's debug console.