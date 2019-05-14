import 'dart:async';
import 'dart:io';
import 'dart:io' as Io;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_app/firestore_ds.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';

import 'firebase_auth.dart';
import 'user_utils.dart';
//import 'package:flutter/widgets.dart';

class DrawerMenuPresenter {

  FirestoreDatasource api = new FirestoreDatasource();
  FirebaseAuthentication authenticationApi = new FirebaseAuthentication();
  DrawerMenuPresenter();

  getUserPhotoUrl(String userId) async {
    String photoUrl= await api.getUserPhotoUrl(userId);
    return photoUrl;
  }

  Future<String>setUserPhoto(File file) async {
    final userId = await new UserUtils().get('userId');
    print('UserId: $userId');

    var bytes = file.readAsBytesSync();
    Image image = decodeImage(bytes);
    print('read');

    //Image thumbnailImage = copyResize(image, 240);
    //Image image = Image.file(file);


    List<int> jpg = encodeJpg(image);
    final tempDirectory = await getTemporaryDirectory();
    final localImagePath = tempDirectory.path + userId + '.jpg';

    File localFile = new Io.File(localImagePath)
      ..writeAsBytesSync(jpg);


    print("end setUserPhoto");

    /*
    final StorageReference ref = FirebaseStorage.instance.ref().child(userId);
    final StorageUploadTask uploadTask = ref.put(localFile);
    final Uri downloadUrl = (await uploadTask).downloadUrl;
    final http.Response downloadData = await http.get(downloadUrl);
    api.setUserPhotoUrl(userId, downloadUrl.toString());
    return downloadUrl.toString();
    */

  }

}