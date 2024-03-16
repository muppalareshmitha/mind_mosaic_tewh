// ignore_for_file: prefer_const_constructors, prefer_final_fields, use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:usb_serial/transaction.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:usb_serial/usb_serial.dart';

class ShapeRotationPage extends StatefulWidget {
  @override
  _ShapeRotationPageState createState() => _ShapeRotationPageState();
}

class _ShapeRotationPageState extends State<ShapeRotationPage> {
  UsbPort? _port;
  String _status = "Idle";
  List<Widget> _serialData = [];
  List<int> _gameResults = [];
  Transaction<String>? _transaction;

  late StreamSubscription<UsbEvent> _usbEventSubscription;

  int _currentShapeIndex = 0;
  List<Widget> _shapeWidgets = [
    Icon(Icons.crop_square),
    Icon(Icons.pentagon),
    Icon(Icons.favorite),
    Icon(CupertinoIcons.triangle),
    Icon(Icons.rectangle),
    Icon(Icons.star),
    Icon(Icons.local_hospital_sharp),
    Icon(Icons.circle),
  ];

  @override
  void initState() {
    super.initState();
    _usbEventSubscription = UsbSerial.usbEventStream!.listen((event) {
      _getPorts();
    });
    _getPorts();
  }

  @override
  void dispose() {
    _usbEventSubscription.cancel();
    _connectTo(null);
    super.dispose();
  }

  Future<bool> _connectTo(UsbDevice? device) async {
    _serialData.clear();
    if (_port != null) {
      _port!.close();
      _port = null;
    }
    if (device == null) {
      setState(() {
        _status = "Disconnected";
      });
      return true;
    }
    if (_transaction != null) {
      _transaction!.dispose();
      _transaction = null;
    }
    _port = await device.create();
    if (await (_port!.open()) != true) {
      setState(() {
        _status = "Failed to open port";
      });
      return false;
    }
    await _port!.setDTR(true);
    await _port!.setRTS(true);
    await _port!.setPortParameters(
      115200,
      UsbPort.DATABITS_8,
      UsbPort.STOPBITS_1,
      UsbPort.PARITY_NONE,
    );
    setState(() {
      _status = "Connected";
    });
    return true;
  }

  void _getPorts() async {
    List<Widget> ports = [];
    List<UsbDevice> devices = await UsbSerial.listDevices();
    devices.forEach((device) {
      ports.add(ListTile(
        title: Text(device.productName!),
        subtitle: Text(device.manufacturerName!),
        trailing: ElevatedButton(
          onPressed: () {
            _connectTo(_port == device ? null : device);
          },
          child: Text(_port == device ? "Disconnect" : "Connect"),
        ),
      ));
    });
    setState(() {
      _serialData = ports;
    });
  }

  Future<void> _sendCommand(String command) async {
    if (_port != null) {
      String data = command + "\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
    }
  }

  Future<String> _waitForConfirmation() async {
    Completer<String> completer = Completer<String>();
    late StreamSubscription<String> subscription;
    Timer? timer;
    _transaction = Transaction.stringTerminated(
        _port!.inputStream as Stream<Uint8List>, Uint8List.fromList([13, 10]));
    // subscription = _transaction!.stream.listen((String event) {
    _transaction!.stream.listen((String event) {
      print(event);
      print(event);
      print(event);
      print("HEllo");
      print("HEllo");
      print("HEllo");
      // if (event == "confirm") {
      //   completer.complete("confirm");
      // } else {
      //   timer = Timer(Duration(seconds: 5), () {
      //     completer.complete("timeout");
      //   });
      // }
    });
    
    await completer.future.whenComplete(() {
      timer!.cancel();
      // subscription.cancel();
    });
    return completer.future;
  }

  Future<int> _receiveResult() async {
    Completer<int> completer = Completer<int>();
    late StreamSubscription<String> subscription;
    Timer? timer;
    subscription = (_port!.inputStream! as Stream<String>).listen((event) {
      int? time = int.tryParse(event.trim());
      if (time != null) {
        completer.complete(time);
      }
    });
    timer = Timer(Duration(seconds: 5), () {
      completer.complete(-1);
    });
    await completer.future.whenComplete(() {
      timer!.cancel();
      subscription.cancel();
    });
    return completer.future;
  }

  /*
  Future<void> _connectToDevice(UsbDevice? device) async {
    bool isConnected = await _connectTo(device);
    if (isConnected) {
      await _startGame();
    }
  } 
  */

  Future<void> _startGame() async {
    _gameResults.clear();
    await _sendCommand("rotate");
    String confirmation = await _waitForConfirmation();
    if (confirmation == "confirm") {
      print("test");
      _currentShapeIndex = 0; // Reset the shape index to 0
      await _displayNextShape(); // Start displaying shapes
    } else {
      _showErrorDialog(confirmation);
    }
  }

  Future<void> _displayNextShape() async {
  if (_currentShapeIndex < _shapeWidgets.length) {
    setState(() {
      _currentShapeIndex++; // Increment the index to move to the next shape
    });
    await _sendCommand(_currentShapeIndex.toString());
    int time = await _receiveResult();
    _gameResults.add(time);
    if (_currentShapeIndex < _shapeWidgets.length) {
      await Future.delayed(Duration(seconds: 1));
      await _displayNextShape(); // Recursively call _displayNextShape to show the next shape
    } else {
      _navigateToResultsPage();
    }
  }
}

  void _navigateToResultsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsPage(
          results: _gameResults,
          onBackToGamePressed: _resetGame,
        ),
      ),
    );
  }

  void _resetGame() {
    setState(() {
      _currentShapeIndex = 0;
      _gameResults.clear();
    });
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shape Rotation Game'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _serialData.isNotEmpty
                  ? "Available Serial Ports"
                  : "No serial devices available",
              style: Theme.of(context).textTheme.headline5,
            ),
            ..._serialData,
            SizedBox(height: 20),
            Text('Status: $_status'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _port == null ? null : _startGame,
              child: Text('Start Game'),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultsPage extends StatelessWidget {
  final List<int> results;
  final VoidCallback onBackToGamePressed;

  ResultsPage({required this.results, required this.onBackToGamePressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Results'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Game Results', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 20),
            Text('Results: $results'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: onBackToGamePressed,
              child: Text('Back to Game'),
            ),
          ],
        ),
      ),
    );
  }
}