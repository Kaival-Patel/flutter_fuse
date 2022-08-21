import 'dart:math';

import 'package:shelf/shelf.dart';

import '../../models/users/user_model.dart';
import '../../network/mysql_connection.dart';
import '../response/response_model.dart';

class UsersQueries {
  String userDb = 'users';
  Future<ServerRes> registerUser({required User user}) async {
    var r = await Database()
        .connection
        .query('SELECT * FROM $userDb WHERE email = ?', [user.email]);
    if (r.isEmpty) {
      //INSERT
      var rng = Random();
      var code = rng.nextInt(900000) + 100000;
      var result = await Database().connection.query(
          'INSERT INTO $userDb (code,name,email,password,photo) VALUES (?,?,?,?,?)',
          [code, user.name, user.email, user.password, user.photo]);
      if (result.affectedRows != null && result.affectedRows! > 0) {
        return ServerRes(m: 'User registered successfully', s: 1);
      } else {
        return ServerRes(m: 'Error registering user');
      }
    } else {
      //EXISTS
      return ServerRes(m: 'User already registered');
    }
  }

  Future<ServerRes> loginUser({required User user}) async {
    var r = await Database().connection.query(
        'SELECT * FROM $userDb WHERE email = ? AND password = ? LIMIT 1',
        [user.email, user.password]);
    if (r.isEmpty) {
      //INCORRECT CREDS
      return ServerRes(m: 'Invalid Credentials');
    } else {
      //EXISTS
      var loggedInUser = User.fromJson(r.first.fields);
      return ServerRes(
          m: 'Logged in successfully', s: 1, r: loggedInUser.toJson());
    }
  }
}
