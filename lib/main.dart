import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Firebase Storage"),
      ),
      body: Column(children: <Widget>[
        (imageUrl != null)
            ? Container(
                height: 400,
                width: 400,
                child: Image.network(imageUrl!),
              )
            : const SizedBox(height: 400, width: 400),
        const SizedBox(
          height: 20,
        ),
        MaterialButton(
            onPressed: () => uploadImage(), child: const Text("Upload Image"),color: Colors.redAccent,)
      ]),
    );
  }

  uploadImage() async {
    //Upload Image to Firebase Storage
    final storage = FirebaseStorage.instance;
    final picker = ImagePicker();
    PickedFile? image;
    await Permission.photos.request();
    var permissionStatus = await Permission.photos.status;
    if (permissionStatus.isGranted) {
      image = await picker.getImage(source: ImageSource.gallery);
      var file = File(image!.path);
      if (image != null) {
        var snapshot = await storage
            .ref()
            .child('folderName/imageName' + file.path.split('picker').last)
            .putFile(file);
        var downloadUrl = await snapshot.ref.getDownloadURL();
        print("Download URL: $downloadUrl");

        setState(() {
          imageUrl = downloadUrl;
          print(downloadUrl.toString());
        });
      } else {
        print('No Path Received');
      }
    } else {
      print('Grant Permissions and try again');
    }
  }
}
