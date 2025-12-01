// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.100.12:3000/api';

  // Get stored token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Save token after login
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Clear token on logout
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Generic GET request
  Future<dynamic> get(String endpoint) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'client': 'not-browser',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      // Log details for debugging
      try {
        // ignore: avoid_print
        print('API GET $uri -> ${response.statusCode}');
        // ignore: avoid_print
        print('Response body: ${response.body}');
      } catch (_) {}
      throw Exception('Failed to load data: ${response.body}');
    }
  }

  // Generic POST request
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'client': 'not-browser',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.post(
      uri,
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      try {
        // ignore: avoid_print
        print('API POST $uri -> ${response.statusCode}');
        // ignore: avoid_print
        print('Request body: ${json.encode(body)}');
        // ignore: avoid_print
        print('Response body: ${response.body}');
      } catch (_) {}
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Request failed');
    }
  }

  // Generic PATCH request
  Future<dynamic> patch(String endpoint, Map<String, dynamic> body) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'client': 'not-browser',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.patch(
      uri,
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      try {
        // ignore: avoid_print
        print('API PATCH $uri -> ${response.statusCode}');
        // ignore: avoid_print
        print('Request body: ${json.encode(body)}');
        // ignore: avoid_print
        print('Response body: ${response.body}');
      } catch (_) {}
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Request failed');
    }
  }

  // Generic DELETE request
  Future<dynamic> delete(String endpoint) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'client': 'not-browser',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.delete(uri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      try {
        // ignore: avoid_print
        print('API DELETE $uri -> ${response.statusCode}');
        // ignore: avoid_print
        print('Response body: ${response.body}');
      } catch (_) {}
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Request failed');
    }
  }

  // --- AUTH ENDPOINTS ---

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await post('/auth/signin', {
      'email': email,
      'password': password,
    });

    if (response['success'] == true) {
      await saveToken(response['token']);
    }

    return response;
  }

  Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String password,
  ) async {
    return await post('/auth/signup', {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> getProfile() async {
    return await get('/auth/profile');
  }

  // --- FORGOT PASSWORD ENDPOINTS ---
  Future<Map<String, dynamic>> sendForgotPasswordCode(String email) async {
    return await patch('/auth/send-forgot-password-code', {'email': email});
  }

  Future<Map<String, dynamic>> verifyForgotPasswordCode(
    String email,
    String providedCode,
    String newPassword,
  ) async {
    return await patch('/auth/verify-forgot-password-code', {
      'email': email,
      'providedCode': providedCode,
      'newPassword': newPassword,
    });
  }

  // --- USER ENDPOINTS ---

  Future<List<dynamic>> searchUsers(String query) async {
    final response = await get('/users/search?query=$query');
    return response['users'];
  }

  Future<List<dynamic>> getMyFriends() async {
    final response = await get('/users/friends');
    return response['friends'];
  }

  Future<Map<String, dynamic>> sendFriendRequest(String friendId) async {
    return await post('/users/friend-request/$friendId', {});
  }

  Future<List<dynamic>> getFriendRequests() async {
    final response = await get('/users/friend-requests');
    return response['requests'];
  }

  Future<Map<String, dynamic>> respondToFriendRequest(
    String requestId,
    String action,
  ) async {
    return await patch('/users/friend-request/$requestId', {'action': action});
  }

  // --- ROOM ENDPOINTS ---

  Future<Map<String, dynamic>> createRoom({
    required String name,
    required String description,
    required List<String> memberIds,
    String? color,
    String? icon,
  }) async {
    return await post('/rooms/create', {
      'name': name,
      'description': description,
      'memberIds': memberIds,
      'color': color ?? '#3B82F6',
      'icon': icon ?? '👥',
    });
  }

  //getMyPaymentMethods()
  Future<List<dynamic>> getMyPaymentMethods() async {
    final response = await get('/users/payment-methods');
    // backend returns payment methods under a key; try common keys
    if (response is Map && response.containsKey('paymentMethods')) {
      return response['paymentMethods'];
    }
    if (response is Map && response.containsKey('methods')) {
      return response['methods'];
    }
    // fallback: if the endpoint returns a list directly
    if (response is List) return response;
    return [];
  }

  Future<List<dynamic>> getMyRooms() async {
    final response = await get('/rooms/my-rooms');
    
    // Debug print to see what the backend returns
    print('Rooms response: $response');
    
    if (response is Map && response.containsKey('rooms')) {
      return response['rooms']; // This returns List<dynamic>
    } else if (response is Map && response.containsKey('success') && response['success'] == true) {
      // Alternative: check for success field
      return response['rooms'] ?? [];
    } else if (response is List) {
      return response;
    } else {
      throw Exception('Invalid response format from server: $response');
    }
  }

  Future<Map<String, dynamic>> getRoomDetails(String roomId) async {
    final response = await get('/rooms/$roomId');
    return response['room'];
  }

  Future<Map<String, dynamic>> addMembersToRoom(
    String roomId,
    List<String> memberIds,
  ) async {
    return await patch('/rooms/$roomId/add-members', {'memberIds': memberIds});
  }

  Future<Map<String, dynamic>> removeMemberFromRoom(
    String roomId,
    String memberId,
  ) async {
    return await delete('/rooms/$roomId/members/$memberId');
  }

  Future<Map<String, dynamic>> deleteRoom(String roomId) async {
    return await delete('/rooms/$roomId');
  }

  // --- GROUP ENDPOINTS ---

  Future<Map<String, dynamic>> createGroup({
    required String name,
    required String description,
    required double goalAmount,
    required List<String> memberIds,
    required String splitMethod,
    List<double>? customShares,
    String? deadline,
    String? sourceRoomId,
  }) async {
    return await post('/groups/create', {
      'name': name,
      'description': description,
      'goalAmount': goalAmount,
      'memberIds': memberIds,
      'splitMethod': splitMethod,
      if (customShares != null) 'customShares': customShares,
      if (deadline != null) 'deadline': deadline,
      if (sourceRoomId != null) 'sourceRoomId': sourceRoomId,
    });
  }

  Future<Map<String, dynamic>> getMyGroups() async {
    return await get('/groups/my-groups');
  }

  Future<Map<String, dynamic>> getGroupDetails(String groupId) async {
    final response = await get('/groups/$groupId');
    return response['group'];
  }

  Future<Map<String, dynamic>> markPayment(
    String groupId,
    String memberId,
    double amount,
  ) async {
    return await patch('/groups/$groupId/members/$memberId/mark-paid', {
      'amount': amount,
    });
  }

  Future<Map<String, dynamic>> addPaymentMethod(
    String groupId,
    Map<String, dynamic> paymentMethod,
  ) async {
    return await post('/groups/$groupId/payment-methods', paymentMethod);
  }

  Future<Map<String, dynamic>> deleteGroup(String groupId) async {
    return await delete('/groups/$groupId');
  }
}
