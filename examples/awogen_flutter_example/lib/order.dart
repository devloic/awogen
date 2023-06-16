// ignore_for_file: unused_element
import 'awogen/env.awogen.dart';
import "package:awogen/AwIncludes.dart";

part 'order.g.dart';

enum myenum { red, green, yellow }

@awogen(["myexcludedfield", "myexcludedfield2"])
class _Order {
  String? name = "somename";
  bool? myboolean;
  DateTime? mydatetime;
  double? amount;
  int? myint;
  static const List<String> blabla = ["gogo", "gaga", "gugu"];
  AwEmail? email;
  AwUrl? url;
  AwIp? ip;
  String? myexcludedfield;
  String? myexcludedfield2;
  _Order();
}
