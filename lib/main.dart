import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await savePic();
  runApp(MyApp());
}

savePic() async {
  String path = (await getApplicationDocumentsDirectory()).path + '/1.png';
  ByteData byteData = await rootBundle.load('assets/images/1.png');
  List<int> bytes = byteData.buffer.asInt8List().toList();
  File(path).writeAsBytesSync(bytes);
}
