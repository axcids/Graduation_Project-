import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';

class APIHelper {
  static String apiBase = '192.168.1.3:5000';
  static String apiURL = 'http://' + apiBase;
  static FlutterSecureStorage storage = const FlutterSecureStorage();

  static Future<void> _saveToken(String token) async {
    await storage.write(key: 'token', value: token);
  }

  static Future<String?> _loadToken() async {
    return await storage.read(key: 'token');
  }

  static Future<Map<String, dynamic>> makePostRequest(
    String endpoint,
    String requestType,
    Map<String, dynamic> body,
    Map<String, dynamic> query,
  ) async {
    String? token = await _loadToken();
    if (requestType == 'post') {
      final response = await http.post(
        Uri.parse(apiURL + endpoint + "?token=$token"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(body),
      );
      return jsonDecode(response.body);
    } else {
      Map<String, dynamic> newQuery = query;
      newQuery.putIfAbsent('token', () => token);
      final response = await http.get(
        Uri.http(apiBase, endpoint, newQuery),
      );
      return jsonDecode(response.body);
    }
  }

  static Future<void> updatePassportImage(XFile? img) async {
    if (img != null) {
      String? token = await _loadToken();
      var request = http.MultipartRequest(
          'POST', Uri.parse("$apiURL/client/upload?token=$token"));
      request.files.add(http.MultipartFile.fromBytes(
          'img', await img.readAsBytes(),
          filename: 'img.jpg'));
      await request.send();
    }
  }

  static Future<bool> login(username, password) async {
    final resp = await makePostRequest(
      '/client/signin',
      'post',
      {'username': username, 'password': password},
      {},
    );
    if (resp['status']) {
      await _saveToken(resp['token']);
      return true;
    }
    return false;
  }

  static Future<Map> signup(
      fname, lname, email, passportId, phone, username, password) async {
    final resp = await makePostRequest(
      '/client/signup',
      'post',
      {
        'fname': fname,
        'lname': lname,
        'email': email,
        'passport_id': passportId,
        'phone': phone,
        'username': username,
        'password': password,
      },
      {},
    );
    return resp;
  }

  static Future<Map> editProfile(fname, lname, email, passportId) async {
    final resp = await makePostRequest(
      '/client/update',
      'post',
      {
        'fname': fname,
        'lname': lname,
        'email': email,
        'passport_id': passportId,
      },
      {},
    );
    return resp;
  }

  static Future<Map> getProfile() async {
    final resp = await makePostRequest('/client/profile', 'get', {}, {});
    if (resp['status']) {
      return resp['profile'];
    }
    return {};
  }

  static Future<List<Map>> getReservations() async {
    final resp = await makePostRequest('/client/reservations', 'get', {}, {});
    if (resp['status']) {
      return List<Map>.from(resp['reservations']);
    }
    return [];
  }

  static Future<bool> checkIn(int id) async {
    final resp =
        await makePostRequest('/client/check_in', 'post', {'id': id}, {});
    return resp['status'];
  }

  static Future<bool> checkOut(int id) async {
    final resp =
        await makePostRequest('/client/check_out', 'post', {'id': id}, {});
    return resp['status'];
  }
}
