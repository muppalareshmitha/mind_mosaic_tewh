import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:usb_serial/usb_serial.dart';

class FingerTappingPage extends StatefulWidget {
  const FingerTappingPage({Key key}) : super(key: key);

  @override
  State<FingerTappingPage> createState() => FingerTappingPageState();
}

class FingerTappingPageState extends State<FingerTappingPage> {
  UsbPort _port;
  StreamSubscription<String> _subscription;
  List<String> results = [];
  Random _random = Random();
  int randomFinger;

  @override
  void initState() {
    super.initState();
    initCommunication();
  }

  Future<void> initCommunication() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    if (devices.isNotEmpty) {
      UsbDevice device = devices[0];
      _port = await device.create();
      if (_port != null) {
        await _port.open();
        _subscription = _port.inputStream.listen((String data) {
          processResponse(data);
        });
      }
    }
  }

  void processResponse(String data) {
    // Process response from hardware device
    if (data.trim() == "confirm") {
      // Pico confirmed
      // Generate random finger index (1-5)
      randomFinger = _random.nextInt(5) + 1;
      // Send lift finger command
      sendCommand("lift finger $randomFinger");
    } else if (data.trim() == "success") {
      // Pico returned success
      results.add("Success"); // Store result
      // Move to the next finger
      // Send start command for the next finger
      sendCommand("touch"); // Send command to start the next round
    } else if (data.trim() == "failure") {
      // Pico returned failure
      results.add("Failure"); // Store result
      // Move to the next finger
      // Send start command for the next finger
      sendCommand("touch"); // Send command to start the next round
    }
    setState(() {}); // Update UI to display random finger number
  }

  void sendCommand(String command) async {
    if (_port != null) {
      _port.write(Uint8List.fromList(utf8.encode(command + "\n")));
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    _port.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finger Tapping Game'),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            iconSize: 30,
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Results:"),
            Column(
              children: results.map((result) => Text(result)).toList(),
            ),
            SizedBox(height: 20),
            Text(
              "Lift Finger: ${randomFinger != null ? randomFinger.toString() : ''}",
              style: TextStyle(fontSize: 20),
            ),
            ElevatedButton(
              onPressed: () {
                sendCommand("touch");
              },
              child: Text("Start Button"),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to results display screen
              },
              child: Text("Results"),
            ),
          ],
        ),
      ),
    );
  }
}
