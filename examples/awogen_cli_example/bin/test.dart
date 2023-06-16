import 'dart:io';

import 'package:awogen/AwBaseTypes.dart';
import '../lib/order.dart';

Future<void> main(List<String> arguments) async {
  Order order = Order(
      name: "somename",
      email: AwEmail("test@test.com"),
      amount: 4,
      myboolean: false,
      mydatetime: DateTime.now(),
      myint: 5,
      url: AwUrl("http://www.appwrite.io"),
      blabla: blabla_awEnum.gaga,
      ip: AwIp("10.0.0.11"));
  Order order2 = await order.createObjectServerSdk();

  print(order2.documentId);
  print(order2.name);
  order2.name = "newname";
  order2.blabla = blabla_awEnum.gugu;
  order2 = await order2.updateObjectServerSdk();
  print(order2.toJSON());
  print(order2.documentId);
  print(order2.name);
  print(order2.amount);
  print(order2.getblablaValue());
  exit(1);
}
