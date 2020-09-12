import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:filemanager/general.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'splashScreen.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Future<void> getSDCardDir() async {
    General().sDCardDir = (await getExternalStorageDirectory()).path;
  }

  // Permission check
  Future<void> getPermission() async {
    if (Platform.isAndroid) {
      PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
      if (permission != PermissionStatus.granted) {
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);
      }
      await getSDCardDir();
    } else if (Platform.isIOS) {
      await getSDCardDir();
    }
  }


  Future.wait([initializeDateFormatting("en-US", null), getPermission()]).then((result) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter File Manager',
      theme: ThemeData(
//        platform: TargetPlatform.iOS,
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}
