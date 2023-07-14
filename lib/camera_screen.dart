import 'dart:io';
import 'package:camera/camera.dart';
import 'package:char_recog/camera_view.dart';
import 'package:char_recog/text_painter.dart';
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
  RecognizedText recogStream = RecognizedText(text: "", blocks: []);
  double imgHeight = 0.0;
  double imgWidth = 0.0;

  int ct = 0;
  bool flash = false;

  loadCamera() {
    _controller = CameraController(cameras[0], ResolutionPreset.high);
    camValue = _controller.initialize();
    camValue.then((value) {
      if (!mounted) {
        return;
      } else {
        _controller.startImageStream((image) async {
          ct++;
          if (ct % 20 == 0) {
            _scanStream(image, image.format.group.name);
            print(ct);
          }
        });
      }
    });
  }

  Future<void> _scanImage() async {
    final pictureFile = await _controller.takePicture();
    final file = File(pictureFile.path);
    final imgSize = await decodeImageFromList(file.readAsBytesSync());
    final inputImage = InputImage.fromFile(file);
    final recognised = await recognizer.processImage(inputImage);
    await Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => CameraViewPage(
              recognised: recognised,
              img: pictureFile.path,
              imgHeight: imgSize.height,
              imgWidth: imgSize.width,
            )));
  }

  Future pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final file = File(image.path);
    final imgSize = await decodeImageFromList(file.readAsBytesSync());
    final inputImage = InputImage.fromFile(file);
    final recognised = await recognizer.processImage(inputImage);
    await Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => CameraViewPage(
              recognised: recognised,
              img: image.path,
              imgHeight: imgSize.height,
              imgWidth: imgSize.width,
            )));
  }

  Future<void> _scanStream(CameraImage image, String imgformat) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    imgHeight = image.height.toDouble();
    imgWidth = image.width.toDouble();

    final Size sz = Size(imgWidth, imgHeight);

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
            rotation: InputImageRotation.rotation90deg,
            format: inputImageFormat,
            bytesPerRow: image.planes[0].bytesPerRow));
    recogStream = await recognizer.processImage(ipImage);
    setState(() {});
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
                return CameraPreview(
                  _controller,
                  child: CustomPaint(
                      painter: TextBoxPainter(
                          recogText: recogStream,
                          imgHeight: imgHeight.toInt(),
                          imgWidth: imgWidth.toInt(),
                          rotation: 90)),
                );
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
