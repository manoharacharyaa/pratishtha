import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageServices {
  Future<File> pickImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile pickedFile;

    pickedFile = (await imagePicker.pickImage(source: ImageSource.gallery))!;
    return File(pickedFile.path);
  }

  Future<String> uploadImage(String fileName, File file) async {
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    await reference.putFile(file);
    return reference.getDownloadURL();
  }

  Future<String> uploadFestImage(String fileName, File file) async {
    Reference reference = FirebaseStorage.instance.ref("Fests").child(fileName);
    await reference.putFile(file);
    return reference.getDownloadURL();
  }

  Future<String> uploadEventImage(String fileName, File file) async {
    Reference reference =
        FirebaseStorage.instance.ref("Events").child(fileName);
    await reference.putFile(file);
    return reference.getDownloadURL();
  }

  Future<String> uploadSponsorImage(
      String fileName, File file, bool isLogo) async {
    Reference reference = FirebaseStorage.instance
        .ref("Sponsorship/${isLogo ? "Logo" : "Image"}")
        .child(fileName);
    await reference.putFile(file);
    return reference.getDownloadURL();
  }

  Future<void> deleteImage(String url) {
    return FirebaseStorage.instance.refFromURL(url).delete();
  }
}
