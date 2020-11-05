import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Image convertedImage;
  Widget widgetToConvert;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(child: widgetToConvert ?? Container()),
          Positioned.fill(
            child: yourPage(),
          ),
        ],
      ),
    );
  }

  Future<Uint8List> widgetToImage(Widget widget) async {
    GlobalKey key = GlobalKey(); // 1.通过 key 来获取 BuildContext 从而获取 RenderObject
    Completer completer = Completer<Uint8List>(); // 2.因为要等待回调之后才能返回，所以需要使用到 Completer

    setState(() {
      widgetToConvert = RepaintBoundary(key: key, child: widget); // 3.将需要转换为图片的 widget 显示出来，才能获取到 BuildContext
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      // 4.此时如果立刻执行下面的代码，是获取不到 BuildContext，因为 widget 还没有完成绘制
      // 所以需要等待这一帧绘制完成后，才能开始转换图片
      if (key.currentContext?.findRenderObject() != null) {
        RenderRepaintBoundary render = key.currentContext.findRenderObject();
        ui.Image image = await render.toImage();
        ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        completer.complete(byteData.buffer.asUint8List());
      }

      setState(() {
        widgetToConvert = null; // 5.图片已经绘制完成，不需要显示该 widget 了
      });
    });

    // 6.返回数据，使用 Completer 可以实现返回和回调数据相关的 Future
    return completer.future;
  }

  Future<Widget> createWidget() async {
    /// asset
    AssetImage provider = AssetImage('assets/images/1.png');

    /// network
    // NetworkImage provider = NetworkImage('https://upload-images.jianshu.io/upload_images/1940075-56c284948fc4f9de.png');

    /// file
    // FileImage provider = FileImage(File((await getApplicationDocumentsDirectory()).path + '/1.png'));

    await precacheImage(provider, context);
    Image image = Image(image: provider);
    return Future(() {
      return Container(
        width: 160,
        height: 160,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue, width: 4),
        ),
        // child: Container(color: Colors.green),
        child: image,
      );
    });
  }

  Widget yourPage() {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlatButton(
                onPressed: () async {
                  Widget widget = await createWidget();
                  Uint8List res = await widgetToImage(widget);
                  setState(() {
                    convertedImage = Image.memory(res);
                  });
                },
                child: Text('生成'),
              ),
              FlatButton(
                onPressed: () {
                  setState(() {
                    convertedImage = null;
                  });
                },
                child: Text('清除'),
              ),
            ],
          ),
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
            ),
            child: convertedImage ?? Container(),
          ),
        ],
      ),
    );
  }
}
