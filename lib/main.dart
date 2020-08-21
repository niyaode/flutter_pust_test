import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:huawei_push/push.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyPushApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Picker Example'),
      ),
      body: Center(
        child: _image == null
            ? Text('No image selected.')
            : Image.file(_image),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}

class MyPushApp extends StatefulWidget {
  @override
  _MyPushAppState createState() => _MyPushAppState();
}

class _MyPushAppState extends State<MyPushApp> {
  TextEditingController logTextController;
  TextEditingController topicTextController;

  String _token = '';
  static const EventChannel TokenEventChannel =
  EventChannel('com.huawei.flutter.push/token');
  static const EventChannel DataMessageEventChannel =
  EventChannel('com.huawei.flutter.push/data_message');

  void _onTokenEvent(Object event) {
    setState(() {
      _token = event;
    });
    showResult("TokenEvent", event);
  }

  void _onTokenError(Object error) {
    setState(() {
      _token = error;
    });
    showResult("TokenEvent", error);
  }

  void _onDataMessageEvent(Object event) {
    print("---Message----------");
    showResult("DataMessageEvent", event);
    Map dataMessageMap = json.decode(event);
    showResult("DataMessageEvent", dataMessageMap["key"]);
  }

  void _onDataMessageError(Object error) {
    print("---Error----------");
    showResult("DataMessageEvent", error);
  }

  final padding = EdgeInsets.symmetric(vertical: 1.0, horizontal: 16);

  @override
  void initState() {
    super.initState();
    logTextController = new TextEditingController();
    topicTextController = new TextEditingController();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;
    TokenEventChannel.receiveBroadcastStream()
        .listen(_onTokenEvent, onError: _onTokenError);
    DataMessageEventChannel.receiveBroadcastStream()
        .listen(_onDataMessageEvent, onError: _onDataMessageError);
  }

  @override
  void dispose() {
    logTextController?.dispose();
    topicTextController?.dispose();
    super.dispose();
  }

  void turnOnPush() async {
    dynamic result = await Push.turnOnPush();
    showResult("turnOnPush", result);
  }

  void turnOffPush() async {
    dynamic result = await Push.turnOffPush();
    showResult("turnOffPush", result);
  }

  void getId() async {
    dynamic result = await Push.getId();
    showResult("getId", result);
  }

  void getAAID() async {
    dynamic result = await Push.getAAID();
    showResult("getAAID", result);
  }

  void getAppId() async {
    dynamic result = await Push.getAppId();
    showResult("getAppId", result);
  }

  void getToken() async {
    dynamic result = await Push.getToken();
    showResult("getToken", result);
  }

  void getCreationTime() async {
    dynamic result = await Push.getCreationTime();
    showResult("getCreationTime", result);
  }

  void deleteAAID() async {
    dynamic result = await Push.deleteAAID();
    showResult("deleteAAID", result);
  }

  void deleteToken() async {
    dynamic result = await Push.deleteToken();
    showResult("deleteToken", result);
  }

  void subscribe() async {
    String topic = topicTextController.text;
    dynamic result = await Push.subscribe(topic);
    showResult("subscribe", result);
  }

  void unsubscribe() async {
    String topic = topicTextController.text;
    dynamic result = await Push.unsubscribe(topic);
    showResult("unsubscribe", result);
  }

  void enableAutoInit() async {
    dynamic result = await Push.setAutoInitEnabled(true).then((value) {
      print("$value");
    }).catchError((e){

    });
//    showResult("enableAutoInit", result);
  }

  void disableAutoInit() async {
    dynamic result = await Push.setAutoInitEnabled(false);
    showResult("disableAutoInit", result);
  }

  void isAutoInitEnabled() async {
    dynamic result = await Push.isAutoInitEnabled();
    showResult("isAutoInitEnabled", result ? "Enabled" : "Disabled");
  }

  void getAgConnectValues() async {
    dynamic result = await Push.getAgConnectValues();
    showResult("getAgConnectValues", result);
  }

  void clearLog() {
    setState(() {
      logTextController.text = "";
    });
  }

  void showResult(String name, [String msg = "Button pressed."]) {
    appendLog(name + ": " + msg);
    Push.showToast(msg);
  }

  void appendLog([String msg = "Button pressed."]) {
    setState(() {
      logTextController.text = msg + "\n" + logTextController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('🔔 HMS Push Kit Demo'),
        ),
        body: Center(
            child: ListView(shrinkWrap: true, children: <Widget>[
              Row(children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Padding(
                      padding: padding,
                      child: RaisedButton(
                        onPressed: () => turnOnPush(),
                        child: Text('TurnOnPush', style: TextStyle(fontSize: 20)),
                      )),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                      padding: padding,
                      child: RaisedButton(
                        onPressed: () => turnOffPush(),
                        child: Text('TurnOffPush', style: TextStyle(fontSize: 20)),
                      )),
                ),
              ]),
              Row(children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Padding(
                      padding: padding,
                      child: RaisedButton(
                        onPressed: () => getId(),
                        child: Text('GetID', style: TextStyle(fontSize: 20)),
                      )),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                      padding: padding,
                      child: RaisedButton(
                        onPressed: () => getAAID(),
                        child: Text('GetAAID', style: TextStyle(fontSize: 20)),
                      )),
                ),
              ]),
              Row(children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Padding(
                      padding: padding,
                      child: RaisedButton(
                        onPressed: () => getToken(),
                        child: Text('GetToken', style: TextStyle(fontSize: 20)),
                      )),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                      padding: padding,
                      child: RaisedButton(
                        onPressed: () => deleteToken(),
                        child: Text('DeleteToken', style: TextStyle(fontSize: 20)),
                      )),
                ),
              ]),
              Row(children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Padding(
                      padding: padding,
                      child: RaisedButton(
                        onPressed: () => getCreationTime(),
                        child:
                        Text('GetCreationTime', style: TextStyle(fontSize: 20)),
                      )),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                      padding: padding,
                      child: RaisedButton(
                        onPressed: () => deleteAAID(),
                        child: Text('DeleteAAID', style: TextStyle(fontSize: 20)),
                      )),
                ),
              ]),
              Padding(
                  padding: padding,
                  child: TextField(
                    controller: topicTextController,
                    textAlign: TextAlign.center,
                    decoration: new InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.blueAccent, width: 3.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueGrey, width: 3.0),
                      ),
                      hintText: 'Topic Name',
                    ),
                  )),
              Row(children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Padding(
                      padding: padding,
                      child: RaisedButton(
                        onPressed: () => subscribe(),
                        child: Text('Subsribe', style: TextStyle(fontSize: 20)),
                      )),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                      padding: padding,
                      child: RaisedButton(
                        onPressed: () => unsubscribe(),
                        child: Text('UnSubscribe', style: TextStyle(fontSize: 20)),
                      )),
                ),
              ]),
              Row(children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Padding(
                      padding: padding,
                      child: RaisedButton(
                        onPressed: () => disableAutoInit(),
                        child: Text('Disable AutoInit',
                            style: TextStyle(fontSize: 20)),
                      )),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                      padding: padding,
                      child: RaisedButton(
                        onPressed: () => enableAutoInit(),
                        child:
                        Text('Enable AutoInit', style: TextStyle(fontSize: 20)),
                      )),
                ),
              ]),
              Row(children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Padding(
                      padding: padding,
                      child: RaisedButton(
                        onPressed: () => isAutoInitEnabled(),
                        child: Text('IsAutoInitEnabled',
                            style: TextStyle(fontSize: 20)),
                      )),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                      padding: padding,
                      child: RaisedButton(
                        onPressed: () => clearLog(),
                        child: Text('ClearLog', style: TextStyle(fontSize: 20)),
                      )),
                ),
              ]),
              Padding(
                  padding: padding,
                  child: RaisedButton(
                    onPressed: () => getAgConnectValues(),
                    child: Text('Get agconnect values',
                        style: TextStyle(fontSize: 20)),
                  )),
              Padding(
                  padding: padding,
                  child: TextField(
                    controller: logTextController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 15,
                    readOnly: true,
                    decoration: new InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.blueAccent, width: 3.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueGrey, width: 3.0),
                      ),
                    ),
                  )),
            ])),
      ),
    );
  }
}
