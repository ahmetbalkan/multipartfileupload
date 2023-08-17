import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  _pickAndUploadFile(context);
                },
                child: Text(
                  "Tek Yükle",
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _pickAndUploadMultipleFiles(context);
                },
                child: Text(
                  "Bİrden Fazla Yükle",
                ),
              ),
            ]),
      ),
    );
  }

  Future<bool> uploadImage(File imageFile, String uriString) async {
    try {
      // Dosya boyutunu kontrol et (1MB = 1024 * 1024 bytes)
      if (imageFile.lengthSync() > 1024 * 1024) {
        print('File is larger than 1MB');
        return false;
      }

      // Sadece resim dosyalarını kabul edelim
      if (!['.jpg', '.jpeg', '.png']
          .contains(extension(imageFile.path).toLowerCase())) {
        return false;
      }

      var uri = Uri.parse(uriString);

      var request = http.MultipartRequest('POST', uri);
      request.files
          .add(await http.MultipartFile.fromPath('myfile', imageFile.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        print('Upload successful!');
        return true;
      } else {
        print('Upload failed with status: ${response.statusCode}.');
        return false;
      }
    } catch (e) {
      print('An error occurred: $e');
      return false;
    }
  }

  Future<void> _pickAndUploadFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: true);

    if (result != null) {
      File file = File(result.files.single.path!);

      // Desteklenen uzantıları kontrol edelim
      if (!['.jpg', '.jpeg', '.png']
          .contains(extension(file.path).toLowerCase())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('This file type is not supported.')),
        );
        return; // Desteklenmeyen bir dosya tipiyse geri dön
      }

      bool success = await uploadImage(file, 'https://postman-echo.com/post');

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File uploaded successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File upload failed.')),
        );
      }
    } else {
      // Kullanıcı dosya seçme işlemi iptal ederse
      print('User canceled the picker');
    }
  }

  Future<void> _pickAndUploadMultipleFiles(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      for (var pickedFile in result.files) {
        File file = File(pickedFile.path!);

        if (!['.jpg', '.jpeg', '.png']
            .contains(extension(file.path).toLowerCase())) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('This file type is not supported: ${file.path}')),
          );
          continue;
        }

        bool success = await uploadImage(file, 'https://postman-echo.com/post');

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File uploaded successfully: ${file.path}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File upload failed: ${file.path}')),
          );
        }
      }
    } else {
      print('User canceled the picker');
    }
  }
}
