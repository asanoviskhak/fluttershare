import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {
  final User currentUser;

  Upload({this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  PickedFile ffile;
  bool isUploading = false;
  String postId = Uuid().v4();
  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();

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

  Future<File> compressImage(vFile) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(vFile.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      vFile = compressedImageFile;
    });
    return vFile;
  }

  Future<String> uploadImage(vFile) async {
    StorageUploadTask uploadTask =
        storageRef.child("post_$postId.jpg").putFile(vFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore(
      {String mediaUrl, String location, String description}) {
    postsRef
        .document(widget.currentUser.id)
        .collection("userPosts")
        .document(postId)
        .setData({
      "postId": postId,
      "ownerId": widget.currentUser.id,
      "username": widget.currentUser.username,
      "mediaUrl": mediaUrl,
      "description": description,
      "location": location,
      "timestamp": timestamp,
      "likes": {}
    });
  }

  handleSubmit() async {
    File vFile = File(ffile.path);
    setState(() {
      isUploading = true;
    });
    File imageFile = await compressImage(vFile);
    String mediaUrl = await uploadImage(imageFile);
    createPostInFirestore(
      mediaUrl: mediaUrl,
      location: locationController.text,
      description: captionController.text,
    );
    captionController.clear();
    locationController.clear();
    setState(() {
      ffile = null;
      vFile = null;
      imageFile = null;
      isUploading = false;
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
            onPressed: isUploading ? null : () => handleSubmit(),
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
          isUploading ? linearProgress(context) : Text(""),
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
              child: Expanded(
                child: TextField(
                  controller: captionController,
                  decoration: InputDecoration(
                    hintText: "Caption your post...",
                    border: InputBorder.none,
                  ),
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
                controller: locationController,
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
