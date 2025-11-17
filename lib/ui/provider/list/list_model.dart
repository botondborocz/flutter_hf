import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../../../network/user_item.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListException extends Equatable implements Exception {
  final String message;

  const ListException(this.message);

  @override
  List<Object?> get props => [message];
}

class ListModel extends ChangeNotifier{
  var isLoading = false;
  var users = <UserItem>[];
  final Dio _dio = GetIt.I<Dio>();
  final SharedPreferences _prefs = GetIt.I<SharedPreferences>();

  void _setState({bool loading = false, List<UserItem>? usersList}) {
    isLoading = loading;
    if (usersList != null) {
      users = usersList;
    }
    notifyListeners();
  }

  Future loadUsers() async {
    if (isLoading) return;
    print('Notifier: Felhasználók letöltése elindult.');
    _setState(loading: true);
    try {
      final response = await _dio.get(
          '/users'
      );

      final List<dynamic> userListJson = response.data;
      final List<UserItem> userList = userListJson.map((userJson) {
        return UserItem(
          userJson['name'],
          userJson['avatarUrl'],
        );
      }).toList();
      
      print('Notifier: Felhasználók letöltve a szerverről.');

      _setState(loading: false, usersList: userList);

      print('Notifier: Felhasználók sikeresen letöltve: ${userList.length} felhasználó.');
      print(userList.map((u) => u.name).toList());

    } on DioError catch (e) {
      String error = 'Hiba a felhasználók letöltésekor.';
      if (e.response != null && e.response?.data is Map) {
        error = e.response?.data['message'] ?? 'Szerver hiba.';
      }
      _setState(loading: false);
      throw ListException(error);

    } catch (e) {
      _setState(loading: false);
      return false;
    }
  }

  Future<void> logout() async {;
    await _prefs.remove('token');

    print('Notifier: Felhasználó kijelentkeztetve, token törölve.');
  }
}