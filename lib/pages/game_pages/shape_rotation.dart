// ignore_for_file: prefer_const_constructors, prefer_final_fields, use_key_in_widget_constructors, library_private_types_in_public_api, unrelated_type_equality_checks

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';

class ShapeRotationPage extends StatefulWidget {
  @override
  _ShapeRotationPageState createState() => _ShapeRotationPageState();
}

class _ShapeRotationPageState extends State<ShapeRotationPage> {
  UsbPort? _port;
  String _status = "Idle";
  List<Widget> _serialData = [];
  List<Widget> _ports = [];
  List<int> _gameResults = [];

  UsbDevice? _device;
  StreamSubscription<String>? _subscription;
  Transaction<String>? _transaction;

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

    UsbSerial.usbEventStream!.listen((UsbEvent event) {
      _getPorts();
    });

    _getPorts();
  }

  @override
  void dispose() {
    super.dispose();
    _connectTo(null);
  }

  Future<bool> _connectTo(device) async {
    _serialData.clear();

    if (_subscription != null) {
      _subscription!.cancel();
      _subscription = null;
    }

    if (_transaction != null) {
      _transaction!.dispose();
      _transaction = null;
    }

    if (_port != null) {
      _port!.close();
      _port = null;
    }

    if (device == null) {
      _device = null;
      setState(() {
        _status = "Disconnected";
      });
      return true;
    }

    _port = await device.create();
    if (await (_port!.open()) != true) {
      setState(() {
        _status = "Failed to open port";
      });
      return false;
    }
    _device = device;

    await _port!.setDTR(true);
    await _port!.setRTS(true);
    await _port!.setPortParameters(
        115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    _transaction = Transaction.stringTerminated(
        _port!.inputStream as Stream<Uint8List>, Uint8List.fromList([13, 10]));

    _subscription = _transaction!.stream.listen((String line) {
      setState(() {
        _serialData.add(Text(line));
        if (_serialData.length > 20) {
          _serialData.removeAt(0);
        }
      });
    });

    setState(() {
      _status = "Connected";
    });
    return true;
  }

  void _getPorts() async {
    _ports = [];
    List<UsbDevice> devices = await UsbSerial.listDevices();
    if (!devices.contains(_device)) {
      _connectTo(null);
    }
    print(devices);

    devices.forEach((device) {
      _ports.add(ListTile(
          leading: Icon(Icons.usb),
          title: Text(device.productName!),
          subtitle: Text(device.manufacturerName!),
          trailing: ElevatedButton(
            child: Text(_device == device ? "Disconnect" : "Connect"),
            onPressed: () {
              _connectTo(_device == device ? null : device).then((res) {
                _getPorts();
              });
            },
          )));
    });

    setState(() {
      print(_ports);
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
    subscription = (_port!.inputStream! as Stream<String>).listen((event) {
      if (event.trim() == "confirm\n") {
        completer.complete("confirm");
      }
    });
    timer = Timer(Duration(seconds: 5), () {
      completer.complete("timeout");
    });
    await completer.future.whenComplete(() {
      timer!.cancel();
      subscription.cancel();
    });
    return completer.future;
  }

  Future<int> _receiveResult() async {
    Completer<int> completer = Completer<int>();
    late StreamSubscription<String> subscription;
    Timer? timer;
    subscription = (_port!.inputStream! as Stream<String>).listen((event) {
      String trimmedEvent = event.trim();
      if (trimmedEvent.endsWith("\n")) {
        trimmedEvent = trimmedEvent.substring(0, trimmedEvent.length - 1);
      }
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
      await _displayNextShape();
    } else {
      _showErrorDialog('Failed to confirm start. Please try again.');
    }
  }

  Future<void> _displayNextShape() async {
    if (_currentShapeIndex < _shapeWidgets.length) {
      setState(() {
        _currentShapeIndex++;
      });
      await _sendCommand(_currentShapeIndex.toString());
      int time = await _receiveResult();
      _gameResults.add(time);
      if (_currentShapeIndex < _shapeWidgets.length) {
        await Future.delayed(Duration(seconds: 1));
        await _displayNextShape();
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
            SizedBox(height: 20),
            if (_currentShapeIndex < _shapeWidgets.length)
              _shapeWidgets[_currentShapeIndex],
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