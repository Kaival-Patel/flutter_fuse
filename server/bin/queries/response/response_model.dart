import 'package:shelf/shelf.dart';

class ServerRes<T> {
  ServerRes({
    this.s = 0,
    this.m = "",
    this.r,
  });
  int s;
  String m;
  T? r;

  Map<String, dynamic> toJson() => {'s': s, 'm': m, 'r': r};

  ServerRes get errorRes => ServerRes(m: 'Error', s: 0);
  Map<String, dynamic> toErrorJson() => {'s': 0, 'm': 'Error', 'r': r};
}
