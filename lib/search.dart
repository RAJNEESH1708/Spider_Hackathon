import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_file_utils/flutter_file_utils.dart';
import 'package:path_provider/path_provider.dart';


class Search extends StatefulWidget {
  _FilesSearchStateApp createState() => _FilesSearchStateApp();
}

class _FilesSearchStateApp extends State<Search> {
  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(

          backgroundColor:Color(0xff383985),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
          title: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                  Radius.circular(20)),
              color: Colors.white,
            ),
            child : Container(
              height: 30,

              child: TextField(
                autofocus: true,
                onChanged: (text) {
                  setState(() {});
                },
                controller: myController,
              ),
            ),
          ),
        ),
        body: FutureBuilder(
            future: getfiles("/"+myController.text),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data != null) {
                  return ListView.builder(
                    primary: false,
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                          title: Container(
                              decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide())),
                              child: Text(snapshot.data[index])));
                    },
                  );
                } else
                  return Center(child: Text("Nothing yet!"));
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: Text("Loading..."));
              } else if (snapshot.connectionState == ConnectionState.none) {
                return Center(child: Text("Nothing was found"));
              }
              return Container();
            }),
      );

  }

  Future getfiles(String searchString) async {


    var root = await getExternalStorageDirectory();
    var fm = FileManager(root: root);
    return await fm.search(searchString).toList();
  }
}