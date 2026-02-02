# PK Servizi - Flutter Backend Integration

Complete boilerplate for connecting Flutter with backend services.

## Features

- ✅ HTTP API Client with Dio
- ✅ Authentication (Login/Register/Logout)
- ✅ State Management with Riverpod
- ✅ Secure Token Storage
- ✅ Auto-retry & Logging
- ✅ Form Validation
- ✅ Navigation with GoRouter
- ✅ Error Handling

## Setup Instructions

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Generate JSON Serialization Code
```bash
flutter packages pub run build_runner build
```

### 3. Configure Backend URL
Update the `baseUrl` in `lib/core/network/api_client.dart`:
```dart
static const String baseUrl = 'https://your-backend-url.com/api';
```

### 4. Run the App
```bash
flutter run
```

## Backend API Endpoints

Your backend should implement these endpoints:

### Authentication
- `POST /auth/login` - User login
- `POST /auth/register` - User registration  
- `POST /auth/logout` - User logout
- `GET /auth/me` - Get current user

### Expected Request/Response Format

#### Login Request
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

#### Register Request
```json
{
  "name": "John Doe",
  "email": "user@example.com", 
  "password": "password123",
  "phone": "+1234567890"
}
```

#### Success Response
```json
{
  "success": true,
  "message": "Operation successful",
  "data": {
    "token": "jwt_token_here",
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "user@example.com",
      "phone": "+1234567890",
      "avatar": null,
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-01T00:00:00Z"
    }
  }
}
```

#### Error Response
```json
{
  "success": false,
  "message": "Invalid credentials",
  "code": 401,
  "errors": ["Email or password is incorrect"]
}
```

## Project Structure

```
lib/
├── core/
│   ├── models/          # Data models
│   └── network/         # API client
├── providers/           # State management
├── screens/            # UI screens
├── services/           # Business logic
├── main.dart          # App entry point
└── router.dart        # Navigation config
```

## Usage Examples

### Making API Calls
```dart
// In your service
final response = await _apiClient.get('/users');
final users = response.data.map((json) => User.fromJson(json)).toList();
```

### Using Authentication
```dart
// Login
await ref.read(authStateProvider.notifier).login(email, password);

// Check auth status
final isAuthenticated = ref.watch(authStateProvider).isAuthenticated;

// Logout
await ref.read(authStateProvider.notifier).logout();
```

## Customization

1. **Add new models**: Create in `lib/core/models/`
2. **Add new services**: Create in `lib/services/`
3. **Add new screens**: Create in `lib/screens/`
4. **Update API endpoints**: Modify services or create new ones

## Backend Examples

### Node.js/Express
```javascript
app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;
  // Validate credentials
  const user = await User.findOne({ email });
  if (user && bcrypt.compareSync(password, user.password)) {
    const token = jwt.sign({ userId: user.id }, JWT_SECRET);
    res.json({
      success: true,
      message: 'Login successful',
      data: { token, user }
    });
  } else {
    res.status(401).json({
      success: false,
      message: 'Invalid credentials',
      code: 401
    });
  }
});
```

### Laravel/PHP
```php
Route::post('/auth/login', function (Request $request) {
    $credentials = $request->only('email', 'password');
    
    if (Auth::attempt($credentials)) {
        $user = Auth::user();
        $token = $user->createToken('auth_token')->plainTextToken;
        
        return response()->json([
            'success' => true,
            'message' => 'Login successful',
            'data' => [
                'token' => $token,
                'user' => $user
            ]
        ]);
    }
    
    return response()->json([
        'success' => false,
        'message' => 'Invalid credentials',
        'code' => 401
    ], 401);
});
```

## Security Notes

- Tokens are stored securely using FlutterSecureStorage
- API client automatically adds Bearer token to requests
- Passwords are never stored locally
- Network requests include retry logic and timeout handling