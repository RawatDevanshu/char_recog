import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextBoxPainter extends CustomPainter {
  TextBoxPainter(
      {required this.recogText,
      required this.imgHeight,
      required this.imgWidth,
      required this.rotation});
  RecognizedText recogText;
  late List<TextBlock> blks = [];
  int imgHeight;
  int imgWidth;
  int rotation;

  @override
  void paint(Canvas canvas, Size size) {
    List<TextBlock> blks = recogText.blocks;

    Paint paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final Paint background = Paint()..color = Color(0x99000000);

    for (var i = 0; i < blks.length; i++) {
      double left = blks[i].boundingBox.left *
          size.width /
          (rotation == 0 ? imgWidth : imgHeight);
      double right = blks[i].boundingBox.right *
          size.width /
          (rotation == 0 ? imgWidth : imgHeight);
      double top = blks[i].boundingBox.top *
          size.height /
          (rotation == 0 ? imgHeight : imgWidth);
      double bottom = blks[i].boundingBox.bottom *
          size.height /
          (rotation == 0 ? imgHeight : imgWidth);

      final ParagraphBuilder builder = ParagraphBuilder(
        ParagraphStyle(
            textAlign: TextAlign.left,
            fontSize: 16,
            textDirection: TextDirection.ltr),
      );
      builder
          .pushStyle(ui.TextStyle(color: Colors.black, background: background));
      builder.addText(blks[i].text);
      builder.pop();

      canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), paint);
      canvas.drawParagraph(
        builder.build()
          ..layout(ParagraphConstraints(width: (right - left).abs())),
        Offset(left, top),
      );
      // box created without caliberated values
      // Paint paint = Paint()
      // ..color = Colors.yellow
      // ..strokeWidth = 2
      // ..style = PaintingStyle.stroke;
      // canvas.drawRect(blks[i].boundingBox, paint);
    }
  }

  @override
  bool shouldRepaint(TextBoxPainter oldDelegate) {
    return oldDelegate.blks != blks || oldDelegate.recogText != recogText;
  }
}
