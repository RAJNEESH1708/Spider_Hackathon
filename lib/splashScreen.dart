import 'package:filemanager/file_manager.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';



class SplashScreen extends StatefulWidget {
  static const id = 'splash_screen';
  @override
  Splash createState() => Splash();
}

class Splash extends State<SplashScreen>  {


  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Timer(
        Duration(seconds: 3),
            () =>
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => FileManager())));


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                Expanded(
                  child: Image.asset("assets/images/folder1.png",
                    fit: BoxFit.scaleDown,
                    // height: double.infinity,
                    // width: double.infinity,
                    alignment: Alignment.center,),
                ),
                Expanded(
                  child: Text("File Manager",style: TextStyle(
                      fontSize: 30,
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                  ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}