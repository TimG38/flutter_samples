import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

// 1. tap FlutterLogo to create Image file
// 2. tap FAB to run _getImage -> imglib.Image.fromBytes()
class _MyHomePageState extends State<MyHomePage> {
  GlobalKey _globalKey = new GlobalKey();
  ui.Image image1;
  imglib.Image image2;
  Uint8List byteList;
  String state = "ready";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RepaintBoundary(
              key: _globalKey,
              child: IconButton(
                iconSize: 400,
                icon: FlutterLogo(size: 400),
                onPressed: () async {
                  if (image1 == null) {
                    image1 = await _capturePng();
                    byteList = await _bytePng(image1);
                    setState(() {
                      state = "image captured=" + image1.width.toString() + "x" + image1.height.toString()
                          + "\nimage byted=" + byteList.lengthInBytes.toString();
                    });
                  }
                },
              ),
            ),
            Text(state.toString())
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          image2 = await compute(_getImage, [image1.width, image1.height, byteList]);
//          image2 = await getImage(image1);
          setState(() => state = image2.length.toString());
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<ui.Image> _capturePng() async {
    RenderRepaintBoundary boundary = _globalKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    setState(() {});
    return image;
  }

  Future<Uint8List> _bytePng(ui.Image image) async {
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    Uint8List byteList = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
    return byteList;
  }
}

Future<imglib.Image> _getImage(List<dynamic> values) async {
  var temp = imglib.Image.fromBytes(values[0], values[1], values[2], format: imglib.Format.bgra);

  var rng = new Random().nextInt(50);
  imglib.Image cropped = imglib.copyCrop(temp, 0, 0, temp.width - rng, temp.height - rng);

  return cropped;
}
