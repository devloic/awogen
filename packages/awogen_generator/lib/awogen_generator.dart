import 'package:build/build.dart';
import 'src/aw_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder awogenBuilder(BuilderOptions options) => SharedPartBuilder(
      [AwGenerator()],
      'awg',
    );
