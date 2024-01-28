// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_print

import 'dart:io';
import 'package:flutter/material.dart';

class SimonMemoryPage extends StatefulWidget {
  const SimonMemoryPage({super.key});

  @override
  State<SimonMemoryPage> createState() => SimonMemoryPageState();
}

class SimonMemoryPageState extends State<SimonMemoryPage> {
  ServerSocket? serverSocket;
  Socket? socket;
  String receivedData = 'No data received';

  @override
  void initState() {
    super.initState();
    initServer();
  }

  void initServer() async {
    serverSocket = await ServerSocket.bind('192.168.1.100', 12345); // Need to replace with Pico's IP and Port
    serverSocket?.listen((Socket client) {
      socket = client;
      socket?.listen(
        (List<int> data) {
          // Handle received data
          String message = String.fromCharCodes(data);
          setState(() {
            receivedData = message;
          });
        },
        onError: (error) {
          print('Error: $error');
        },
        onDone: () {
          print('Connection closed');
        },
      );
    });
  }

  @override
  void dispose() {
    serverSocket?.close();
    socket?.close();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Simon Memory Page"),
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
            Text(
              'Received Data:',
            ),
            Text(
              receivedData,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}