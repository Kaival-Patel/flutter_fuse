import '../../models/users/user_model.dart';
import '../../network/mysql_connection.dart';

class UsersQueries {
  Future<User> registerUser({required User user}) async {
    // var result = await Database().connection.query(
    //     'insert into users (name, email, age) values (?, ?, ?)',
    //     ['Bob', 'bob@bob.com', 25]);
    return User();
  }
}
