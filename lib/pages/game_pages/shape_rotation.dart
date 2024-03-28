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
  Transaction<String>? _transaction;
  StreamSubscription<String>? _subscription;

  late StreamSubscription<UsbEvent> _usbEventSubscription;

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
    if (_subscription != null) {
      _subscription!.cancel();
      _subscription = null;
    }
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
              onPressed: _port == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GameScreen(_port!)),
                      );
                    },
              child: Text('Start Game'),
            ),
          ],
        ),
      ),
    );
  }
}

class ShapeContainer extends StatefulWidget {
  final Widget icon;

  ShapeContainer({required this.icon});

  @override
  _ShapeContainerState createState() => _ShapeContainerState();
}

class _ShapeContainerState extends State<ShapeContainer> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 200,
        height: 200,
        child: widget.icon,
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final UsbPort port;

  GameScreen(this.port);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<Widget> _serialData = [];
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
  UsbPort? _port;
  List<String> _gameResults = [];
  Transaction<String>? _transaction;
  StreamSubscription<String>? _subscription;
  List<String> _textData = [];
  List<String> _resultData = [];

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  Future<void> _sendCommand(String command) async {
    if (widget.port != null) {
      String data = command + "\n";
      await widget.port.write(Uint8List.fromList(data.codeUnits));
    }
  }

  Future<String> _waitForConfirmation() async {
    Completer<String> completer = Completer<String>();
    Timer? timer;
    _transaction = Transaction.stringTerminated(
        widget.port.inputStream as Stream<Uint8List>, Uint8List.fromList([13, 10]));
    _subscription = _transaction!.stream.listen((String event) {
      _textData.add(event);
      String text = _textData[0];
      if (text == "confirm") {
        timer = Timer(Duration(seconds: 1), () {
          completer.complete("confirm");
        });
      } else {
        timer = Timer(Duration(seconds: 5), () {
          completer.complete("timeout");
        });
      }
    });

    await completer.future.whenComplete(() {
      timer!.cancel();
      _subscription!.cancel();
    });

    return completer.future;
  }

  Future<String> _receiveResult() async {
    Completer<String> completer = Completer<String>();
    Timer? timer;
    String text1;
    _transaction = Transaction.stringTerminated(
        _port!.inputStream as Stream<Uint8List>, Uint8List.fromList([13, 10]));
    _subscription = _transaction!.stream.listen((String event) {
      _resultData.add(event);
      text1 = _resultData[_currentShapeIndex];
      if(text1 != "-1") {
        timer = Timer(Duration(seconds: 1), () {
         completer.complete(text1);
        });
      } else {
        timer = Timer(Duration(seconds: 5), () {
          completer.complete("-1");
        });
      }
    });
    
    await completer.future.whenComplete(() {
      timer!.cancel();
      _subscription!.cancel();
    });

    return completer.future;
}

  Future<void> _startGame() async {
    _gameResults.clear();
    await _sendCommand("rotate");
    String confirmation = await _waitForConfirmation();
    if (confirmation == "confirm") {
      _currentShapeIndex = 0;
      await _displayNextShape();
    } else {
      _showErrorDialog(confirmation);
    }
  }

  Future<void> _displayNextShape() async {
    if (_currentShapeIndex < _shapeWidgets.length) {
      await _sendCommand(_currentShapeIndex.toString());
      setState(() {
        _serialData.add(
          ShapeContainer(
            icon: _shapeWidgets[_currentShapeIndex],
          ),
        );
      });
      _currentShapeIndex++;
      String time = await _receiveResult();
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
      _serialData.clear();
    });
    _startGame();
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
            SizedBox(height: 20),
            ..._serialData,
            if (_currentShapeIndex < _shapeWidgets.length)
              ShapeContainer(
                icon: _shapeWidgets[_currentShapeIndex],
              ),
          ],
        ),
      ),
    );
  }
}

class ResultsPage extends StatelessWidget {
  final List<String> results;
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