import 'package:apivideolivestream/Apivideolivestream.dart';
import 'package:apivideolivestream_example/Model/Resolution.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Constants.dart';
import 'Model/Params.dart';
import 'SettingsScreen.dart';

class LivestreamViewWidget extends StatefulWidget {
  @override
  _LivestreamViewWidget createState() => _LivestreamViewWidget();
}

class _LivestreamViewWidget extends State<LivestreamViewWidget> {
  final ButtonStyle style =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

  Apivideolivestream? controller;
  bool _isStreaming = false;
  String _title = "Start";
  String text = '';
  late Params params;

  @override
  void initState() {
    print("initState");
    setState(() {
      params = Params(streamKey: "");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter livestream'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (choice) => _onMenuSelected(choice, context),
            itemBuilder: (BuildContext context) {
              return Constants.choices.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Center(
              child: _cameraPreviewWidget(),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  style: style,
                  onPressed: () {
                    Apivideolivestream.switchCamera();
                  },
                  child: const Text('switch'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  style: style,
                  onPressed: _toggleStream,
                  child: Text('$_title'),
                ),
              ],
            ),
            Center(
              child: Text('$text'),
            )
          ],
        ),
      ),
    );
  }

  void _toggleStream() {
    setState(() {
      if (_isStreaming) {
        print("Stop Stream");
        _title = "Start";
        _isStreaming = false;
        Apivideolivestream.stopStream();
      } else {
        print("Start Stream");
        _title = "Stop";
        _isStreaming = true;
        Apivideolivestream.startStream();
      }
    });
  }

  void _onMenuSelected(String choice, BuildContext context) {
    if (choice == Constants.Settings) {
      print(choice);
      _awaitResultFromSettingsFinal(context);
    }
  }

  void _awaitResultFromSettingsFinal(BuildContext context) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SettingsScreen(params: params)));
    setState(() {
      text = params.streamKey;
    });
  }

  Widget _cameraPreviewWidget() {
    final plugin = Apivideolivestream();

    return Container(
        color: Colors.lightBlueAccent,
        child: LiveStreamPreview(
          controller: plugin,
          liveStreamKey: params.streamKey,
          videoResolution: Resolution.RESOLUTION_240.getSimpleResolutionToString(params.resolution),
          videoFps: int.parse(params.fps.toString()),
          videoBitrate: int.parse(params.bitrate.toString()),
          onConnectionSuccess: () {
            print("onConnectionSuccess");
          },
          onConnectionError: (error) {
            print("onConnectionError : $error");
          },
          onDeconnection: () {
            print("onDeconnection");
          },
        ));
  }
}