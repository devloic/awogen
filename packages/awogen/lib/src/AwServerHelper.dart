library awogen;

import 'dart:async';
import 'dart:io';

import '../AwBaseTypes.dart';
import '../AwMisc.dart';
import 'AwCommons.dart';
import 'package:dart_appwrite/dart_appwrite.dart';

import 'package:dart_appwrite/models.dart';
import 'package:awogen_generator/src/model_visitor.dart';

class AwServerHelper {
  Client client = Client();
  late Databases databases;
  AwogenEnv config;
  AwServerHelper({required this.config}) {
    databases = _init();
  }
  Databases _init() {
    client
        .setEndpoint(config.ENDPOINT)
        .setProject(config.PROJECTID)
        .setSelfSigned(status: true)
        .setKey(config.APIKEY);

    Databases databases = Databases(client);

    return databases;
  }

  Future<Document?> createDocument(AwObject awobject) async {
    try {
      Map<String, dynamic> obJson = removeColDoc(awobject);

      Future<Document> result = databases.createDocument(
        databaseId: config.DATABASEID,
        collectionId: awobject.collectionId,
        documentId:
            awobject.documentId != "" ? awobject.documentId : ID.unique(),
        data: obJson,
      );
      return result;
    } on AppwriteException catch (e) {
      print(e.toString());
      return Future.value(null);
    }
  }

  Future<AwObject?> createAwObjectDocument(AwObject awobject) async {
    Document? result = await createDocument(awobject);
    AwObject? awobject2;
    if (result != null) {
      awobject2 = awobject.toObject(result);
      awobject2.documentId = result.$id;
    }
    return Future.value(awobject2);
  }

  Future<dynamic> deleteDocument(AwObject awobject) async {
    try {
      Future<dynamic> result = databases.deleteDocument(
          databaseId: config.DATABASEID,
          collectionId: awobject.collectionId,
          documentId: awobject.documentId);

      return result;
    } on AppwriteException catch (e) {
      print(e.toString());
      return Future.value(null);
    }
  }

  Future<Document?> updateDocument(AwObject awobject,
      {List<String>? permissions}) async {
    try {
      Map<String, dynamic> obJson = removeColDoc(awobject);
      Future<Document> result = databases.updateDocument(
          databaseId: config.DATABASEID,
          collectionId: awobject.collectionId,
          documentId: awobject.documentId,
          data: obJson,
          permissions: permissions);

      return result;
    } on AppwriteException catch (e) {
      print(e.toString());
      return Future.value(null);
    }
  }

  Future<AwObject?> updateAwObjectDocument(AwObject awobject) async {
    Document? result = await updateDocument(awobject);
    AwObject? awobject2;
    if (result != null) {
      awobject2 = awobject.toObject(result);
    }
    return Future.value(awobject2);
  }

  Future<dynamic> deleteCollection(String collectionId) {
    try {
      Future<dynamic> result = databases.deleteCollection(
          collectionId: collectionId, databaseId: config.DATABASEID);
      return result;
    } on AppwriteException catch (e) {
      print(e.toString());
      return Future.value(null);
    }
  }

  Future<Collection?> updateCollection(String collectionId, String newname,
      List<String>? newpermissions, bool? documentSecurity, bool? enabled) {
    try {
      Future<Collection> result = databases.updateCollection(
          databaseId: config.DATABASEID,
          collectionId: collectionId,
          name: newname,
          permissions: newpermissions,
          documentSecurity: documentSecurity,
          enabled: enabled);
      return result;
    } on AppwriteException catch (e) {
      print(e.toString());
      return Future.value(null);
    }
  }

  Future<Collection?> createCollection({
    required String collectionId,
    required String name,
    List<String>? permissions,
    bool? documentSecurity,
  }) {
    try {
      Future<Collection> result = databases.createCollection(
          databaseId: config.DATABASEID,
          collectionId: ID.unique(),
          name: name,
          permissions: permissions,
          documentSecurity: documentSecurity);
      return result;
    } on AppwriteException catch (e) {
      print(e.toString());
      return Future.value(null);
    }
  }

  Future<Collection?> genCollection(String collectionName) async {
    String finalName = "${collectionName.toLowerCase()}s";
    try {
      CollectionList clist =
          await databases.listCollections(databaseId: config.DATABASEID);

      for (final element in clist.collections) {
        //clist.collections.forEach((element) async {
        if (element.name == finalName) {
          String? yesno = "";
          String collectionId = element.$id;
          while (yesno != "y" && yesno != "n") {
            printAwogenMessage(
                "found collection with name '$finalName'. Delete ? y/n \n");

            yesno = stdin.readLineSync();
          }
          if (yesno?.toLowerCase() == "y") {
            await databases.deleteCollection(
                databaseId: config.DATABASEID, collectionId: collectionId);
            printAwogenMessage("collection with name $finalName deleted.\n");
          } else {
            String newname = "${element.name}_$collectionId";
            printAwogenMessage("renaming collection to $newname\n");

            await databases.updateCollection(
                databaseId: config.DATABASEID,
                collectionId: collectionId,
                name: newname);
            printAwogenMessage("renamed collection to $newname\n");
          }
        }
      }

      Future<Collection> result = databases.createCollection(
        databaseId: config.DATABASEID,
        collectionId: ID.unique(),
        name: finalName,
      );

      return result;
    } on AppwriteException catch (e) {
      print(e.toString());
      return null;
    }
  }

  genAttributes(
      ModelVisitor visitor, String collectionId, List<String?> ignoreFields) {
    Map<String, dynamic> fields = visitor.fields;
    Map<String, dynamic> initializers = visitor.initializers;
    int defaultStringSize = 1024;

    fields.forEach((key, value) {
      if (ignoreFields.contains(key)) {
        return;
      }
      if (value.endsWith("?")) {
        value = value.replaceAll('?', '');
      }
      switch (value) {
        case "String":
          databases.createStringAttribute(
              databaseId: config.DATABASEID,
              collectionId: collectionId,
              key: key,
              size: defaultStringSize,
              xrequired: false);
          break;
        case "bool":
          databases.createBooleanAttribute(
              databaseId: config.DATABASEID,
              collectionId: collectionId,
              key: key,
              xrequired: false);
          break;
        case "DateTime":
          databases.createDatetimeAttribute(
              databaseId: config.DATABASEID,
              collectionId: collectionId,
              key: key,
              xrequired: false);
          break;
        case "double":
          databases.createFloatAttribute(
              databaseId: config.DATABASEID,
              collectionId: collectionId,
              key: key,
              xrequired: false);
          break;
        case "int":
          databases.createIntegerAttribute(
              databaseId: config.DATABASEID,
              collectionId: collectionId,
              key: key,
              xrequired: false);
          break;
        case "List<String>":
          List<String> initializer = initializers[key];

          databases.createEnumAttribute(
              elements: initializer,
              databaseId: config.DATABASEID,
              collectionId: collectionId,
              key: key,
              xrequired: false);
          break;
        case "AwEmail":
          databases.createEmailAttribute(
              databaseId: config.DATABASEID,
              collectionId: collectionId,
              key: key,
              xrequired: false);
          break;
        case "AwUrl":
          databases.createUrlAttribute(
              databaseId: config.DATABASEID,
              collectionId: collectionId,
              key: key,
              xrequired: false);
          break;
        case "AwIp":
          databases.createIpAttribute(
              databaseId: config.DATABASEID,
              collectionId: collectionId,
              key: key,
              xrequired: false);
          break;
        case "Relation-fix":
          databases.createRelationshipAttribute(
              relatedCollectionId: "",
              type: "",
              databaseId: config.DATABASEID,
              collectionId: collectionId,
              key: key);
          break;
        default:
      }
    });
  }
}
