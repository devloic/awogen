import 'package:envied/envied.dart';

part 'env.awogen.g.dart';

@Envied(path: ".env.awogen")
abstract class Env {
  @EnviedField(varName: 'PROJECTID', obfuscate: true)
  static final String PROJECTID = _Env.PROJECTID;
  @EnviedField(varName: 'DATABASEID', obfuscate: true)
  static final String DATABASEID = _Env.DATABASEID;
  @EnviedField(varName: 'ENDPOINT', obfuscate: true)
  static final String ENDPOINT = _Env.ENDPOINT;
  @EnviedField(varName: 'FLAVOR', obfuscate: false)
  static final String FLAVOR = _Env.FLAVOR;
  @EnviedField(varName: 'APIKEY', obfuscate: true)
  static final String APIKEY = _Env.APIKEY ;
   
  }
   