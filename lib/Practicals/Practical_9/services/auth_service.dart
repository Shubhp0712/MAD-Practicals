import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import '../models/user_model.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _sessionKey = 'session_data';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _jwtSecret = 'your_secret_key_here';

  static final List<Map<String, dynamic>> _registeredUsers = [];

  static String _hashPassword(String password) {
    return base64Encode(utf8.encode('${password}_salt_${password.length}'));
  }

  static bool _verifyPassword(String password, String hash) {
    return _hashPassword(password) == hash;
  }

  static Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      final existingUser = _registeredUsers.firstWhere(
        (user) => user['email'] == email,
        orElse: () => {},
      );

      if (existingUser.isNotEmpty) {
        return AuthResponse(
          success: false,
          message: 'Email already registered',
        );
      }

      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      final username = email.split('@')[0];

      final userData = {
        'id': userId,
        'username': username,
        'email': email,
        'password': _hashPassword(password),
        'role': 'user',
        'name': name,
        'avatar':
            'https://images.unsplash.com/photo-1494790108755-2616b612b5bc?w=100&h=100&fit=crop&crop=face',
        'twoFactorEnabled': false,
      };

      _registeredUsers.add(userData);

      final user = User.fromJson(userData);
      final token = _generateToken(user);

      return AuthResponse(
        success: true,
        message: 'Registration successful',
        token: token,
        user: user,
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Registration failed: ${e.toString()}',
      );
    }
  }

  static Future<AuthResponse> login(String email, String password) async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      if (Random().nextInt(20) == 0) {
        throw Exception('Network timeout. Please try again.');
      }

      final userData = _registeredUsers.firstWhere(
        (user) =>
            user['email'] == email &&
            _verifyPassword(password, user['password']),
        orElse: () => {},
      );

      if (userData.isEmpty) {
        return AuthResponse(
          success: false,
          message: 'Invalid email or password',
        );
      }

      final user = User.fromJson(userData);

      if (user.twoFactorEnabled) {
        final tempToken = _generateTempToken();
        return AuthResponse(
          success: true,
          message: 'Two-factor authentication required',
          requiresTwoFactor: true,
          tempToken: tempToken,
          user: user,
        );
      }

      final token = _generateToken(user);

      return AuthResponse(
        success: true,
        message: 'Login successful',
        token: token,
        user: user,
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Login failed: ${e.toString()}',
      );
    }
  }

  static Future<AuthResponse> verifyTwoFactor(
    String tempToken,
    String code,
  ) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      if (code != '123456' && code != '000000') {
        return AuthResponse(
          success: false,
          message: 'Invalid verification code',
        );
      }

      final userData = _registeredUsers.firstWhere(
        (user) => tempToken.contains(user['id']),
        orElse: () => {},
      );

      if (userData.isEmpty) {
        return AuthResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      }

      final user = User.fromJson(userData);
      final token = _generateToken(user);

      return AuthResponse(
        success: true,
        message: 'Two-factor authentication successful',
        token: token,
        user: user,
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Verification failed: ${e.toString()}',
      );
    }
  }

  static String _generateToken(User user) {
    final header = base64Encode(utf8.encode('{"alg":"HS256","typ":"JWT"}'));
    final now = DateTime.now();
    final payload = base64Encode(
      utf8.encode(
        jsonEncode({
          'userId': user.id,
          'username': user.username,
          'role': user.role,
          'email': user.email,
          'exp': now.add(const Duration(hours: 24)).millisecondsSinceEpoch,
          'iat': now.millisecondsSinceEpoch,
          'jti': _generateTokenId(),
        }),
      ),
    );

    final signatureData = '$header.$payload$_jwtSecret';
    final signature = base64Encode(
      utf8.encode(signatureData.hashCode.toString()),
    );

    return '$header.$payload.$signature';
  }

  static String _generateRefreshToken(User user) {
    final now = DateTime.now();
    final payload = jsonEncode({
      'userId': user.id,
      'type': 'refresh',
      'exp': now.add(const Duration(days: 30)).millisecondsSinceEpoch,
      'iat': now.millisecondsSinceEpoch,
    });

    return base64Encode(utf8.encode('${payload}_$_jwtSecret'));
  }

  static String _generateTokenId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return '${timestamp}_$random';
  }

  static String _generateTempToken() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return 'temp_${timestamp}_$random';
  }

  static Future<void> storeSession(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();

    final refreshToken = _generateRefreshToken(user);

    await prefs.setString(_tokenKey, token);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));

    final sessionData = {
      'loginTime': DateTime.now().toIso8601String(),
      'deviceInfo': 'Flutter App',
      'lastActivity': DateTime.now().toIso8601String(),
      'tokenVersion': '1.0',
    };
    await prefs.setString(_sessionKey, jsonEncode(sessionData));
  }

  static Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      final token = prefs.getString(_tokenKey);
      final refreshToken = prefs.getString(_refreshTokenKey);

      if (userJson == null || token == null) return null;

      if (_isTokenExpired(token)) {
        if (refreshToken != null && !_isRefreshTokenExpired(refreshToken)) {
          final user = User.fromJson(jsonDecode(userJson));
          final newToken = _generateToken(user);
          await prefs.setString(_tokenKey, newToken);
          return user;
        } else {
          await logout();
          return null;
        }
      }

      return User.fromJson(jsonDecode(userJson));
    } catch (e) {
      return null;
    }
  }

  static bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = jsonDecode(utf8.decode(base64Decode(parts[1])));
      final exp = payload['exp'] as int;

      return DateTime.now().millisecondsSinceEpoch > exp;
    } catch (e) {
      return true;
    }
  }

  static bool _isRefreshTokenExpired(String refreshToken) {
    try {
      final decoded = utf8.decode(base64Decode(refreshToken));
      final parts = decoded.split('_$_jwtSecret');
      if (parts.isEmpty) return true;

      final payload = jsonDecode(parts[0]);
      final exp = payload['exp'] as int;

      return DateTime.now().millisecondsSinceEpoch > exp;
    } catch (e) {
      return true;
    }
  }
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_sessionKey);
  }

  static Future<Map<String, dynamic>?> getSessionInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString(_sessionKey);

      if (sessionJson == null) return null;

      return jsonDecode(sessionJson);
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateLastActivity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString(_sessionKey);

      if (sessionJson != null) {
        final sessionData = jsonDecode(sessionJson);
        sessionData['lastActivity'] = DateTime.now().toIso8601String();
        await prefs.setString(_sessionKey, jsonEncode(sessionData));
      }
    } catch (e) {
      
    }
  }
}
