import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:filemanager/general.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';
import 'package:filemanager/search.dart';

class FileManager extends StatefulWidget {
  @override
  _FileManagerState createState() => _FileManagerState();
}

class _FileManagerState extends State<FileManager> {
  List<FileSystemEntity> files = [];
  Directory parentDir;
  ScrollController controller = ScrollController();
  List<double> position = [];
  bool toMoveFile = false;
  bool toCopyFile = false;
  FileSystemEntity sourceFilePath;



  @override
  void initState() {
    super.initState();
    parentDir = Directory(General().sDCardDir);
    toMoveFile = false;
    initPathFiles(General().sDCardDir);
  }


  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<bool> onWillPop() async {
    if (parentDir.path != General().sDCardDir) {
      initPathFiles(parentDir.parent.path);
      jumpToPosition(false);
    } else {
      SystemNavigator.pop();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(

        appBar: AppBar(
        backgroundColor:Color(0xff383985),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),


          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  parentDir?.path == General().sDCardDir
                      ? 'File Manager'
                      : p.basename(parentDir.path),
                  style: TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,

                ),
              ),
              !toMoveFile
                  ? Container()
                  : GestureDetector(
                onLongPress: () {
                  askConfirmation();
                },
                child: IconButton(
                    icon: Icon(Icons.forward, color: Colors.white),
                    onPressed: () {
                      String destinationPath = parentDir.path;
                      moveFileConfirmation(destinationPath);
                    }),
              ),
             ! toCopyFile
                  ? Container()
                  : GestureDetector(
                onLongPress: () {
                  askConfirmation();
                },

                child: IconButton(
                    icon: Icon(Icons.content_copy, color: Colors.white),
                    onPressed: () {

                      String destinationPath = parentDir.path;
                      copyFileConfirmation(destinationPath);
                    }),
              ),


            ],

          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search, color: Colors.white),
              tooltip: 'Search',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Search()),
                );
              },
            ),

          ],

          centerTitle: true,
          elevation: 30.0,

          leading: parentDir?.path == General().sDCardDir
              ? Container()
              : IconButton(
              icon: Icon(Icons.chevron_left, color: Colors.black),
              onPressed: onWillPop),

        ),
        body: files.length == 0
            ? Center(child: Text('The folder is empty',
        style: TextStyle(
          fontSize: 30,
        ),
        ))
            : Scrollbar(
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            controller: controller,
            itemCount: files.length,
            itemBuilder: (BuildContext context, int index) {
              if (FileSystemEntity.isFileSync(files[index].path))
                return _buildFileItem(files[index]);
              else
                return _buildFolderItem(files[index]);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFileItem(FileSystemEntity file) {
    String modifiedTime = DateFormat('yyyy-MM-dd HH:mm:ss', 'en-UN')
        .format(file.statSync().modified.toLocal());

    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          border:
          Border(bottom: BorderSide(width: 0.5, color: Color(0xffe5e5e5))),
        ),
        child: ListTile(
          leading: Image.asset(General().selectIcon(p.extension(file.path))),
          title: Padding(
            padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
            // child: Text(file.path.substring(file.parent.path.length + 1)),
            child: AutoSizeText(
              file.path.substring(file.parent.path.length + 1),
              maxLines: 2,
            ),
          ),
          subtitle: Text(
              '$modifiedTime  ${General().getFileSize(file.statSync().size)}',
              style: TextStyle(fontSize: 12.0)),
        ),
      ),
      onTap: () {
        OpenFile.open(file.path);
      },
      onLongPress: () {
        showModalBottomSheet(

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
          ),
          context: context,
          builder: (BuildContext context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CupertinoButton(
                  pressedOpacity: 0.6,
                  child:
                  Text('Move', style: TextStyle(color: Colors.blue[300])),
                  onPressed: () {
                    Navigator.pop(context);
                    moveFile(file);
                  },
                ),


                CupertinoButton(
                  pressedOpacity: 0.6,
                  child:
                  Text('Copy', style: TextStyle(color: Colors.blue[300])),
                  onPressed: () {
                    Navigator.pop(context);
                    copyFile(file);
                  },
                ),
                CupertinoButton(
                  pressedOpacity: 0.6,
                  child:
                  Text('Rename', style: TextStyle(color: Colors.blue[600])),
                  onPressed: () {
                    Navigator.pop(context);
                    renameFile(file);
                  },
                ),
                CupertinoButton(
                  pressedOpacity: 0.6,
                  child: Text('Delete',
                      style: TextStyle(
                          color: Colors.red[400], fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.pop(context);
                    deleteFile(file);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFolderItem(FileSystemEntity file) {
    String modifiedTime = DateFormat('yyyy-MM-dd HH:mm:ss', 'en-UN')
        .format(file.statSync().modified.toLocal());

    return InkWell(

      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(

          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment(1, 1), // 10% of the width, so there are ten blinds.
            colors: [Color(0xff6EE2F5), Color(0xff6454F0)], // whitish to gray
            tileMode: TileMode.repeated, // repeats the gradient over the canvas
          ),
      border:
        Border.all(
              color: Colors.white,
            ),
          borderRadius: BorderRadius.all(Radius.circular(10)),

        ),
        child: ListTile(
          leading: Image.asset('assets/images/folder.png'),
          title: Padding(
            padding: const EdgeInsets.only(bottom: 5.0, top: 5.0),
            // child: Text(file.path.substring(file.parent.path.length + 1)),
            child: AutoSizeText(

              file.path.substring(file.parent.path.length + 1),
              maxLines: 2,
              style: TextStyle(fontSize: 18,
              color: Colors.white),
            ),
          ),
          subtitle: Row(
            children: [
              Text('$modifiedTime', style: TextStyle(fontSize: 15.0,
              color: Colors.white,
              )),
              Text(
                  _calculateFilesCountByFolder(file) == 1
                      ? ' Item ${_calculateFilesCountByFolder(file)}'
                      : ' Items ${_calculateFilesCountByFolder(file)}',
                  style:
                  TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold,
                    color: Colors.white,)),
            ],
          ),
          trailing: Icon(Icons.chevron_right,color: Colors.white,),
        ),
      ),
      onTap: () {
        // Click into a folder and record the offset before entering
        //Return to the previous layer and jump back to the offset, then clear the offset
        position.add(controller.offset);
        initPathFiles(file.path);
        jumpToPosition(true);
      },
      onLongPress: () {
        showModalBottomSheet(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
          ),
          context: context,
          builder: (BuildContext context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CupertinoButton(
                  pressedOpacity: 0.6,
                  child:
                  Text('Move', style: TextStyle(color: Colors.blue[300])),
                  onPressed: () {
                    Navigator.pop(context);
                    moveFile(file);

                  },
                ),
                CupertinoButton(
                  pressedOpacity: 0.6,
                  child:
                  Text('Rename', style: TextStyle(color: Colors.blue[600])),
                  onPressed: () {
                    Navigator.pop(context);
                    renameFile(file);
                  },
                ),
                CupertinoButton(
                  pressedOpacity: 0.6,
                  child: Text('Delete',
                      style: TextStyle(
                          color: Colors.red[400], fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.pop(context);
                    deleteFile(file);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Count the total number of files and folders starting with.
  int _calculatePointBegin(List<FileSystemEntity> fileList) {
    int count = 0;
    for (var v in fileList) {
      if (p.basename(v.path).substring(0, 1) == '.') count++;
    }

    return count;
  }

  // Count the number of files and folders in the folder, except those beginning with.
  int _calculateFilesCountByFolder(Directory path) {
    var dir = path.listSync();
    int count = dir.length - _calculatePointBegin(dir);

    return count;
  }

  void jumpToPosition(bool isEnter) async {
    if (isEnter)
      controller.jumpTo(0.0);
    else {
      try {
        await Future.delayed(Duration(milliseconds: 1));
        controller?.jumpTo(position[position.length - 1]);
      } catch (e) {}
      position.removeLast();
    }
  }

  //Initialize the files and folders under this path
  void initPathFiles(String path) {
    try {
      setState(() {
        parentDir = Directory(path);
        sortFiles();
      });
    } catch (e) {
      print(e);
      print("Directory does not exist！");
    }
  }

  void deleteFile(FileSystemEntity file) {
    showCupertinoDialog(

      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Delete File'),
          content: Text('Are you sure you want to proceed?'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Cancel', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              child: Text('Yes', style: TextStyle(color: Colors.red[400])),
              onPressed: () {
                if (file.statSync().type == FileSystemEntityType.directory) {
                  Directory directory = Directory(file.path);
                  directory.deleteSync(recursive: true);
                } else if (file.statSync().type == FileSystemEntityType.file) {
                  file.deleteSync();
                }

                initPathFiles(file.parent.path);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void askConfirmation() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Move File'),
          content: Text('Do you want to cancel the move operation?'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('No', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              child: Text('Yes', style: TextStyle(color: Colors.red[400])),
              onPressed: () {
                setState(() {
                  toMoveFile = false;
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void moveFileConfirmation(String destinationPath) {
    try {
      String finalDestinationPath =
          destinationPath + '/' + p.basename(sourceFilePath.path);
      final newFile = sourceFilePath.renameSync(finalDestinationPath);
      sourceFilePath.delete();
      print('new file is $newFile');
      initPathFiles(newFile.parent.path);
    } on FileSystemException catch (e) {
      print(e);
    } finally {
      setState(() {
        toMoveFile = false;
      });
    }

    Fluttertoast.showToast(
        backgroundColor: Colors.grey,
        textColor: Colors.black,
        msg: sourceFilePath.path,
        gravity: ToastGravity.CENTER);
  }

  void moveFile(FileSystemEntity sourceFile) {
    setState(() {
      toMoveFile = true;
      sourceFilePath = sourceFile;
    });
  }

  void copyFileConfirmation(String destinationPath) {
    try {
      String finalDestinationPath =
          destinationPath + '/' + p.basename(sourceFilePath.path);
      final newFile = sourceFilePath.renameSync(finalDestinationPath);
      //sourceFilePath.delete();
      print('new file is $newFile');
      initPathFiles(newFile.parent.path);
    } on FileSystemException catch (e) {
      print(e);
    } finally {
      setState(() {
        toCopyFile = false;
      });
    }

    Fluttertoast.showToast(
        backgroundColor: Colors.grey,
        textColor: Colors.black,
        msg: sourceFilePath.path,
        gravity: ToastGravity.CENTER);
  }

  void copyFile(FileSystemEntity sourceFile) {
    setState(() {
      toCopyFile = true;
      sourceFilePath = sourceFile;
    });
  }


  // rename file
  void renameFile(FileSystemEntity file) {
    TextEditingController _controller = TextEditingController();
    _controller.text = p.basename(file.path);

    bool isFile = file is File;

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: CupertinoAlertDialog(
              title: Text('Rename'),
              content: Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2.0)),
                    hintText: isFile? 'File Name': 'Folder Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.0)),
                    contentPadding: EdgeInsets.all(10.0),
                  ),
                ),
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text('Cancel', style: TextStyle(color: Colors.blue)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                CupertinoDialogAction(
                  child: Text('Rename',
                      style: TextStyle(
                          color: Colors.blue[600],
                          fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    String newName = _controller.text;
                    if (newName.trim().length == 0) {
                      Fluttertoast.showToast(
                          msg: 'Name cannot be empty',
                          gravity: ToastGravity.CENTER);
                      return;
                    }

                    String newPath = file.parent.path +
                        '/' +
                        newName +
                        (isFile?p.extension(file.path):'');

                    file.renameSync(newPath);
                    initPathFiles(file.parent.path);

                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  void sortFiles() {
    // print('at sort files ${parentDir.listSync()}');
    List<FileSystemEntity> _files = [];
    List<FileSystemEntity> _folder = [];

    for (var v in parentDir.listSync()) {
      // Remove files / folders starting with.
      if (p.basename(v.path).substring(0, 1) == '.') {
        continue;
      }
      if (FileSystemEntity.isFileSync(v.path))
        _files.add(v);
      else
        _folder.add(v);
    }

    _files.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    _folder
        .sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    files.clear();
    files.addAll(_folder);
    files.addAll(_files);
  }
}