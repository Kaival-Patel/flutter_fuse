import 'dart:io';

import 'package:mysql1/mysql1.dart';

class Database {
  static final Database _database = Database._internal();

  late MySqlConnection _connection;

  set connection(MySqlConnection connection) => _connection = connection;

  MySqlConnection get connection => _connection;

  factory Database() {
    return _database;
  }

  Database._internal();

  Future<void> init() async {
    //Change host to Redis Google console address
    try {
      var settings = ConnectionSettings(
        host: 'localhost',
        port: 3306,
        user: 'root',
        db: 'flutter_fuse',
      );
      _connection = await MySqlConnection.connect(settings);
      print('SQL CONNECTION SUCCESS');
      return;
    } catch (err) {
      print(err);
      throw Exception('Error connecting to SQL Db');
    }
  }
}
