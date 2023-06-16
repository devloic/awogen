import 'dart:io';

import 'src/AwServerHelper.dart';
import 'package:dart_appwrite/models.dart' as sm;
import 'package:appwrite/models.dart' as cm;

import 'package:email_validator/email_validator.dart';
import 'src/AwClientHelperStub.dart' // Stub implementation
    if (dart.library.ui) './src/AwClientHelper.dart'; // dart:io implementation

abstract class AwEnv {
  late String ENDPOINT;

  late String PROJECTID;

  late String APIKEY;

  late String DATABASEID;
}

class AwogenEnv {
  AwogenEnv(
      {required this.DATABASEID,
      required this.ENDPOINT,
      required this.PROJECTID,
      this.APIKEY = "",
      this.FLAVOR = ""});
  String DATABASEID;

  String ENDPOINT;

  String PROJECTID;

  String APIKEY;

  String FLAVOR;
}

class Msg {
  static final String SERVER_SDK_UNAVAILABLE =
      "awServerHelper not available. Check if APPWRITE_USE_SERVERSDK=true in .env.awogen";
}

abstract class AwObject {
  String collectionId = "";
  AwServerHelper? get awServerHelper => null;
  AwClientHelper? get awClientHelper => null;

  AwObject toObject(dynamic doc);

  String documentId = "";

  static Map<String, List<String>> enum_values = {};

  Map<String, List<String>> get enum_values2 => enum_values;

  Future<sm.Document> createGetDocumentServerSdk() async {
    if (awServerHelper == null) {
      print("awServerHelper not available, check if your apikey is set");
    }
    sm.Document? doc = await awServerHelper?.createDocument(this);
    return Future.value(doc);
  }

  Future<dynamic> createObjectServerSdk() async {
    if (awServerHelper == null) {
      print("awServerHelper not available, check if your apikey is set");
    }

    AwObject? object = await awServerHelper?.createAwObjectDocument(this);
    return Future.value(object);
  }

  Future<dynamic> updateObjectServerSdk() async {
    if (awServerHelper == null) {
      print("awServerHelper not available, check if your apikey is set");
    }
    AwObject? object = await awServerHelper?.updateAwObjectDocument(this);
    return Future.value(object);
  }

  Future<sm.Document> updateGetDocumentServerSdk() async {
    if (awServerHelper == null) {
      print("awServerHelper not available, check if your apikey is set");
    }
    sm.Document? doc = await awServerHelper?.updateDocument(this);
    return Future.value(doc);
  }

  Future<cm.Document> createGetDocumentClientSdk(
      {List<String>? permissions}) async {
    if (awClientHelper == null) {
      print(
          "awClientHelper not available, maybe your platform doesn t support flutter");
    }
    cm.Document? doc =
        await awClientHelper?.createDocument(this, permissions: permissions);
    return Future.value(doc);
  }

  Future<dynamic> createObjectClientSdk({List<String>? permissions}) async {
    if (awClientHelper == null) {
      print(
          "awClientHelper not available, maybe your platform doesn t support flutter");
    }

    AwObject? object = await awClientHelper?.createAwObjectDocument(this,
        permissions: permissions);
    return Future.value(object);
  }

  Future<dynamic> updateObjectClientSdk({List<String>? permissions}) async {
    if (awClientHelper == null) {
      print(
          "awClientHelper not available, maybe your platform doesn t support flutter");
    }
    AwObject? object = await awClientHelper?.updateAwObjectDocument(this,
        permissions: permissions);
    return Future.value(object);
  }

//TODO
//add permissions
  Future<cm.Document> updateGetDocumentClientSdk(
      {List<String>? permissions}) async {
    if (awClientHelper == null) {
      print(
          "awClientHelper not available, maybe your platform doesn t support flutter");
    }
    cm.Document? doc =
        await awClientHelper?.updateDocument(this, permissions: permissions);
    return Future.value(doc);
  }

  Map<String, dynamic> toJSON();
}

class AwEmail {
  AwEmail(this.email) {
    isvalid = EmailValidator.validate(email);
  }
  bool isvalid = false;
  bool isValid() {
    return isvalid;
  }

  String email;
}

class AwIp {
  AwIp(this.ip) {
    isvalid = InternetAddress.tryParse(ip) != null;
  }
  bool isvalid = false;
  bool isValid() {
    return isvalid;
  }

  String ip;
}

class AwUrl {
  AwUrl(this.url) {
    try {
      Uri myuri = Uri.parse(url);
      if (myuri.host != "" &&
          (myuri.isScheme('https') || myuri.isScheme('http'))) {
        isvalid = true;
      }
    } on Exception {
      isvalid = false;
    }
  }
  bool isvalid = false;
  String url;
  bool isValid() {
    return isvalid;
  }
}

class AwException implements Exception {
  String cause;
  AwException(this.cause);
}
