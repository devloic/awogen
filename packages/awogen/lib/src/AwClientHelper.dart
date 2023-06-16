import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import '../AwBaseTypes.dart';
import 'AwCommons.dart';

class AwClientHelper {
  Client client = Client();
  late Databases databases;
  AwogenEnv config;
  AwClientHelper({required this.config}) {
    databases = _init();
  }

  Databases _init() {
    client
        .setEndpoint(config.ENDPOINT)
        .setProject(config.PROJECTID)
        .setSelfSigned(status: true);

    Databases databases = Databases(client);

    return databases;
  }

  Future<Document?> createDocument(AwObject awobject,
      {List<String>? permissions}) async {
    try {
      Future<Document> result = databases.createDocument(
          databaseId: config.DATABASEID,
          collectionId: awobject.collectionId,
          documentId:
              awobject.documentId != "" ? awobject.documentId : ID.unique(),
          data: awobject.toJSON(),
          permissions: permissions);

      return result;
    } on AppwriteException catch (e) {
      print(e.toString());
      return Future.value(null);
    }
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

  Future<Document?> updateDocument(AwObject awObject,
      {List<String>? permissions}) async {
    try {
      Map<String, dynamic> obJson = removeColDoc(awObject);

      Future<Document> result = databases.updateDocument(
          databaseId: config.DATABASEID,
          collectionId: awObject.collectionId,
          documentId: awObject.documentId,
          data: obJson,
          permissions: permissions);

      return result;
    } on AppwriteException catch (e) {
      print(e.toString());
      return Future.value(null);
    }
  }

  Future<Document?> getDocument(String collectionId, String documentId) async {
    try {
      Future<Document> result = databases.getDocument(
        databaseId: config.DATABASEID,
        collectionId: collectionId,
        documentId: documentId,
      );

      return result;
    } on AppwriteException catch (e) {
      print(e.toString());
      return Future.value(null);
    }
  }

  Future<DocumentList> listDocuments({
    required String collectionId,
    List<String>? queries,
  }) {
    return databases.listDocuments(
        databaseId: config.DATABASEID,
        collectionId: collectionId,
        queries: queries);
  }

  Future<AwObject> updateAwObjectDocument(AwObject awObject,
      {List<String>? permissions}) async {
    Document? result = await updateDocument(awObject);
    AwObject? awobject2;
    if (result != null) {
      awobject2 = awObject.toObject(result);
    }
    return Future.value(awobject2);
  }

  Future<AwObject?> createAwObjectDocument(AwObject awObject,
      {List<String>? permissions}) async {
    Map<String, dynamic> obJson = removeColDoc(awObject);
    try {
      Document? result = await databases.createDocument(
          databaseId: config.DATABASEID,
          collectionId: awObject.collectionId,
          documentId:
              awObject.documentId != "" ? awObject.documentId : ID.unique(),
          data: obJson,
          permissions: permissions);
      AwObject? awobject2;

      awobject2 = awObject.toObject(result);

      return Future.value(awobject2);
    } on AppwriteException catch (e) {
      print(e.toString());
      return Future.value(null);
    }
  }
}
