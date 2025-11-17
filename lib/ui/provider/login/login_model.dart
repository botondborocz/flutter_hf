import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginException extends Equatable implements Exception{
  final String message;

  const LoginException(this.message);

  @override
  List<Object?> get props => [message];
}

class LoginModel extends ChangeNotifier{

  final SharedPreferences _prefs;
  LoginModel() : _prefs = GetIt.I<SharedPreferences>();


  var isLoading = false;
  Dio get _dio => GetIt.I<Dio>();

  void _setState({bool loading = false}) {
    isLoading = loading;
    notifyListeners();
  }

  Future login(String email, String password, bool rememberMe) async {
    if (isLoading) return;
    _setState(loading: true);
    try {
      final Map<String, dynamic> loginData = {
        'email': email,
        'password': password,
      };

      final response = await _dio.post(
        '/login',
        data: loginData,
      );

      final token = response.data['token'];

      _dio.options.headers['Authorization'] = 'Bearer $token';

      if (rememberMe) {
        await _prefs.setString('token', token);
      }

      _setState(loading: false);
      return true;

    } on DioError catch (e) {
      String error = 'Ismeretlen hálózati hiba.';
      if (e.response != null && e.response?.data is Map) {
        error = e.response?.data['message'] ?? 'Szerver hiba (nincs üzenet).';
      }

      _setState(loading: false);
      throw LoginException(error);

    } catch (e) {
      _setState(loading: false);
      return false;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = GetIt.I<SharedPreferences>();
    final savedToken = prefs.getString('token');
    if (savedToken != null && savedToken.isNotEmpty) {
      print('Notifier: Elmentett token megtalálva: $savedToken');
      _dio.options.headers['Authorization'] = 'Bearer $savedToken';
      return true;
    } else {
      print('Notifier: Nincs elmentett token.');
      return false;
    }
  }
}