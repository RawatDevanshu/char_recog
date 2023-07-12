import 'package:char_recog/camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CameraViewPage extends StatelessWidget {
  const CameraViewPage({super.key, required this.recognised});
  final RecognizedText recognised;

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
          
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Center(child: Text(recognised.text)),
          ),
        ]),
      ),
    );
  }
}


