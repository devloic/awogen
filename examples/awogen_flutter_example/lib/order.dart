// ignore_for_file: unused_element
import 'awogen/env.awogen.dart';
import "package:awogen/AwIncludes.dart";

part 'order.g.dart';

enum myenum { dd, green, yellow }

@awogen(["myexcludedfield", "myexcludedfield2"])
class _Order {
  String? name = "dd";
  bool? myboolean;
  DateTime? mydatetime;
  double? amount;
  int? myint;
  static const List<String> blabla = ["gssssigi", "gaga", "gugu"];
  AwEmail? email;
  AwUrl? url;
  AwIp? ip;
  String? myexcludedfield;
  String? myexcludedfield2;
  _Order();

  test() {
    blabla[0];
    myenum.values.indexOf(myenum.dd);
  }
}
