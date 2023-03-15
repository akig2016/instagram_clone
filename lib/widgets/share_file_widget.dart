import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ShareFileWidget extends StatefulWidget {
  const ShareFileWidget({super.key});

  @override
  State<ShareFileWidget> createState() => _ShareFileWidgetState();
}

class _ShareFileWidgetState extends State<ShareFileWidget> {
  final _screenshotController = ScreenshotController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            // Screenshot(
            //   controller: _screenshotController,
            //   child: ,
            // ),
          ]),
        ),
      ),
    );
  }
}
