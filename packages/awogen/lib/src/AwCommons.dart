import '../AwIncludes.dart';

Map<String, dynamic> removeColDoc(AwObject awobject) {
  //map enums value to String value
  Map<String, dynamic> obJson = awobject.toJSON();
  obJson.forEach((key, value) {
    if (awobject.enum_values2.keys.contains("${key}_awEnum")) {
      obJson[key] = awobject.enum_values2["${key}_awEnum"]![value];
    }
  });
  obJson.remove('collectionId');
  obJson.remove('documentId');
  return obJson;
}
