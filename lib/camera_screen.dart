import 'dart:io';
import 'package:camera/camera.dart';
import 'package:char_recog/camera_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

late List<CameraDescription> cameras;

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> camValue;
  final recognizer = TextRecognizer();

  int ct = 0;
  bool flash = false;

  loadCamera() {
    _controller = CameraController(cameras[0], ResolutionPreset.high);
    camValue = _controller.initialize();
    camValue.then((value) {
      if (!mounted) {
        return;
      } else {
        setState(() {
          _controller.startImageStream((image) async {
            ct++;
            if (ct % 20 == 0) {
              _scanStream(image, image.format.group.name);
            }
          });
        });
      }
    });
  }

  Future<void> _scanImage() async {
    final pictureFile = await _controller.takePicture();
    final file = File(pictureFile.path);
    final inputImage = InputImage.fromFile(file);
    final recognised = await recognizer.processImage(inputImage);
    await Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => CameraViewPage(
              recognised: recognised,
            )));
  }

  Future pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final file = File(image.path);
    final inputImage = InputImage.fromFile(file);
    final recognised = await recognizer.processImage(inputImage);
    await Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => CameraViewPage(
              recognised: recognised,
            )));
  }

  Future<void> _scanStream(CameraImage image, String imgformat) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size sz = Size(image.width.toDouble(), image.height.toDouble());

    final InputImageFormat? inputImageFormat =
        imgformat == "yuv420" ? InputImageFormat.yuv420 : null;
    if (inputImageFormat == null) {
      print("invalid inpformat");
      return;
    }

    var ipImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
            size: sz,
            rotation: InputImageRotation.rotation180deg,
            format: inputImageFormat,
            bytesPerRow: image.planes[0].bytesPerRow));
    final recogStream = await recognizer.processImage(ipImage);
    print("Recog------------------------\n");
    print(recogStream.text);
    print("------------------------\n");
  }

  @override
  void initState() {
    super.initState();
    loadCamera();
  }

  @override
  void dispose() {
    _controller.dispose();
    recognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        FutureBuilder(
            future: camValue,
            builder: (builder, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_controller);
              } else {
                return Container(
                  color: Colors.black,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
            }),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              color: Color.fromARGB(255, 40, 40, 40),
            ),
            height: MediaQuery.of(context).size.height * 0.18,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    color: Colors.white,
                    iconSize: 30,
                    icon: Icon(Icons.folder),
                    onPressed: () {
                      pickImage();
                    },
                  ),
                  IconButton(
                    color: Colors.white,
                    iconSize: 80,
                    icon: Icon(Icons.panorama_fish_eye),
                    onPressed: () {
                      _scanImage();
                    },
                  ),
                  IconButton(
                    color: Colors.white,
                    iconSize: 30,
                    icon: Icon(flash ? Icons.flash_on : Icons.flash_off),
                    onPressed: () {
                      setState(() {
                        flash = !flash;
                      });
                      flash
                          ? _controller.setFlashMode(FlashMode.torch)
                          : _controller.setFlashMode(FlashMode.off);
                    },
                  ),
                ]),
          ),
        )
      ],
    ));
  }
}
