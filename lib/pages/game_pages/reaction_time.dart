// ignore_for_file: prefer_const_constructors, prefer_final_fields, use_key_in_widget_constructors, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:usb_serial/transaction.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:usb_serial/usb_serial.dart';

class ButtonDisplayScreen extends StatelessWidget {
  final Widget button;
  final VoidCallback onNextPressed;

  ButtonDisplayScreen({required this.button, required this.onNextPressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('Button Display'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            button,
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: onNextPressed,
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class ReactionTimeScreen extends StatefulWidget {
  @override
  _ReactionTimeScreenState createState() => _ReactionTimeScreenState();
}

class _ReactionTimeScreenState extends State<ReactionTimeScreen> {
  UsbPort? _port;
  String _status = "Idle";
  List<Widget> _serialData = [];
  List<String> _resultData = [];
  List<String> _textData = [];
  List<String> _gameResults = [];
  Transaction<String>? _transaction;
  StreamSubscription<String>? _subscription;

  late StreamSubscription<UsbEvent> _usbEventSubscription;

  int _currentButtonIndex = 0;
  List<Widget> _buttonWidgets = List.generate(
    8,
    (index) => ElevatedButton(
      onPressed: null,
      child: Text('Button $index'),
    ),
  );

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
    _textData.clear();
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

  Future<void> _sendCommand(String command) async {
    if (_port != null) {
      String data = command + "\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
    }
  }

  Future<String> _waitForConfirmation() async {
    Completer<String> completer = Completer<String>();
    Timer? timer;
    _transaction = Transaction.stringTerminated(
        _port!.inputStream as Stream<Uint8List>, Uint8List.fromList([13, 10]));
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
      text1 = _resultData[_currentButtonIndex];
      if (text1 != "-1") {
        timer = Timer(Duration(seconds: 1), () {
          completer.complete(text1);
        });
      } else {
        timer = Timer(Duration(seconds: 1), () {
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
    await _sendCommand("reaction");
    String confirmation = await _waitForConfirmation();
    if (confirmation == "confirm") {
      _currentButtonIndex = 0; // Reset the button index to 0
      _showNextButton(); // Start displaying buttons
    } else {
      _showErrorDialog(confirmation);
    }
  }

  Future<void> _showNextButton() async {
    if (_currentButtonIndex < _buttonWidgets.length) {
      await _sendCommand(_currentButtonIndex.toString());
      _currentButtonIndex++; // Increment the index to move to the next button

      // Navigate to the ButtonDisplayScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ButtonDisplayScreen(
            button: _buttonWidgets[_currentButtonIndex - 1],
            onNextPressed:
                _currentButtonIndex < _buttonWidgets.length ? _showNextButton : _navigateToResultsPage,
          ),
        ),
      );

      String time = await _receiveResult();
      _gameResults.add(time);
    }
  }

  void _navigateToResultsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsPage1(
          results: _gameResults,
          onBackToHomePressed: _resetGame,
        ),
      ),
    );
  }

  void _resetGame() {
    setState(() {
      _currentButtonIndex = 0;
      _gameResults.clear();
      _serialData.clear();
      _status = "Idle";
    });
    Navigator.of(context).popUntil((route) => route.isFirst);
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
       title: Text('Reaction Time Game'),
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

class ResultsPage1 extends StatelessWidget {
 final List<String> results;
 final VoidCallback onBackToHomePressed;

 ResultsPage1({required this.results, required this.onBackToHomePressed});

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
             onPressed: onBackToHomePressed,
             child: Text('Back to Home'),
           ),
         ],
       ),
     ),
   );
 }
}