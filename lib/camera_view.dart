import 'dart:io';

import 'package:char_recog/camera_screen.dart';
import 'package:char_recog/text_painter.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CameraViewPage extends StatelessWidget {
  const CameraViewPage(
      {super.key,
      required this.recognised,
      required this.img,
      required this.imgHeight,
      required this.imgWidth});
  final RecognizedText recognised;
  final String img;
  final int imgHeight;
  final int imgWidth;

  @override
  Widget build(BuildContext context) {
    print("....................\n\n");
    print(recognised.blocks.length);
    print("....................\n\n");
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => CameraScreen()));
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 40, 40, 40),
          title: Text("Result"),
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => CameraScreen()));
            },
            icon: Icon(Icons.arrow_back_ios),
          ),
        ),
        body: Stack(children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: CustomPaint(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height - 150,
                  child: Image.file(
                    File(img),
                    fit: BoxFit.cover,
                  ),
                ),
                foregroundPainter: TextBoxPainter(
                    recogText: recognised,
                    imgHeight: imgHeight,
                    imgWidth: imgWidth,
                    rotation: 0)),
          ),
        ]),
      ),
    );
  }
}
