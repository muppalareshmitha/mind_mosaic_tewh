import 'package:flutter/material.dart';
import 'package:usb_serial/transaction.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:usb_serial/usb_serial.dart';

class ReactionTimeScreen extends StatefulWidget {
  final String numberSequence;
  final VoidCallback onNextPressed;

  ReactionTimeScreen({required this.numberSequence, required this.onNextPressed});

  @override
  _ReactionTimeScreenState createState() => _ReactionTimeScreenState();
}

class _ReactionTimeScreenState extends State<ReactionTimeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('Reaction Time Game'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Number Sequence:',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              widget.numberSequence,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: widget.onNextPressed,
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class ReactionTimePage extends StatefulWidget {
  @override
  _ReactionTimePageState createState() => _ReactionTimePageState();
}

class _ReactionTimePageState extends State<ReactionTimePage> {
  UsbPort? _port;
  String _status = "Idle";
  List<Widget> _serialData = [];
  List<String> _resultData = [];
  List<String> _gameResults = [];
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
    String receivedData = event; // Convert Uint8List to String
    if (receivedData.isNotEmpty) {
      completer.complete(receivedData);
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
    await _sendCommand("start");
    String numberSequence = await _waitForConfirmation();
    _showNumberSequence(numberSequence);
  }

  void _showNumberSequence(String numberSequence) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReactionTimeScreen(
          numberSequence: numberSequence,
          onNextPressed: () {
            // Handle next button press
            // Calculate reaction time and record it
          },
        ),
      ),
    );
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
  final VoidCallback onBackToGamePressed;

  ResultsPage1({required this.results, required this.onBackToGamePressed});

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

