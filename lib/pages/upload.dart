import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:image_picker/image_picker.dart';

class Upload extends StatefulWidget {
  final User currentUser;

  Upload({this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  PickedFile ffile;

  final picker = ImagePicker();
  handleTakePhoto() async {
    Navigator.pop(context);

    final file = await picker.getImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      this.ffile = file;
    });
  }

  handleChoosePhromGalery() async {
    Navigator.pop(context);
    final file = await picker.getImage(
      source: ImageSource.gallery,
    );
    setState(() {
      this.ffile = file;
    });
  }

  selectImage(BuildContext pContext) {
    return showDialog(
        context: pContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Create post"),
            children: <Widget>[
              new SimpleDialogOption(
                child: Text("Photo with Camera"),
                onPressed: handleTakePhoto,
              ),
              new SimpleDialogOption(
                child: Text("Image from Gallery"),
                onPressed: handleChoosePhromGalery,
              ),
              new SimpleDialogOption(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  Container buildSplashScreeen() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RaisedButton(
            padding: EdgeInsets.all(12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              "Upload image",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.0,
              ),
            ),
            color: Theme.of(context).primaryColor,
            onPressed: () => selectImage(context),
          ),
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      ffile = null;
    });
  }

  buildUploadForm() {
    File vFile = File(ffile.path);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: clearImage,
        ),
        title: Text(
          "Post captioning",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: [
          FlatButton(
            onPressed: () => print('pressed'),
            child: Text(
              "Post",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          Container(
            height: 220.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(vFile),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Caption your post...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Theme.of(context).accentColor,
              size: 35.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Location",
                  border: InputBorder.none,
                ),
              ),
            ),
            trailing: FlatButton(
              onPressed: () => print('Get location'),
              // shape: RoundedRectangleBorder(
              //   borderRadius: BorderRadius.circular(8),
              // ),
              //color: Theme.of(context).primaryColor,
              child: Icon(
                Icons.my_location,
                color: Theme.of(context).primaryColor.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ffile == null ? buildSplashScreeen() : buildUploadForm();
  }
}
