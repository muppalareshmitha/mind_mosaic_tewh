import 'dart:io';
import 'package:flutter/material.dart';

class SimonMemoryPage extends StatefulWidget {
  @override
  _SimonMemoryPageState createState() => _SimonMemoryPageState();
}

class _SimonMemoryPageState extends State<SimonMemoryPage> {
  late File serialPort;
  late IOSink serialSink;
  String receivedData = 'No data received';

  @override
  void initState() {
    super.initState();
    initSerialCommunication();
  }

  void initSerialCommunication() async {
    serialPort = File('/dev/ttyUSB0'); // Replace with serial port of USB-to-Serial adapter
    serialSink = serialPort.openWrite();
    receivedData = 'No data received';

    // Set up a listener for receiving data
    serialPort.openRead().listen(
      (List<int> data) {
        String message = String.fromCharCodes(data);
        setState(() {
          receivedData = message;
        });

        // Echo the received data back to the Raspberry Pi Pico
        sendData(message);
      },
      onDone: () {
        print('Serial port closed');
      },
      onError: (error) {
        print('Error: $error');
      },
      cancelOnError: true,
    );
  }

  void sendData(String data) {
    serialSink.write(data);
    serialSink.flush();
  }

  @override
  void dispose() {
    serialSink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pico Communication Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Received Data:',
            ),
            Text(
              receivedData,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Send a sample command to the Pico
                sendData('Hello, Pico!');
              },
              child: Text('Send Data to Pico'),
            ),
          ],
        ),
      ),
    );
  }
}