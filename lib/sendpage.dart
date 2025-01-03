import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothSendPage extends StatefulWidget {
  final BluetoothDevice device;

  const BluetoothSendPage({Key? key, required this.device}) : super(key: key);

  @override
  _BluetoothSendPageState createState() => _BluetoothSendPageState();
}

class _BluetoothSendPageState extends State<BluetoothSendPage> {
  late BluetoothDevice targetDevice;
  late BluetoothCharacteristic idCharacteristic;
  late BluetoothCharacteristic pwCharacteristic;
  late BluetoothCharacteristic resultCharacteristic;

  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String serverResult = "Waiting for response...";

  @override
  void initState() {
    super.initState();
    targetDevice = widget.device;
    connectToDevice(targetDevice);
  }

  void connectToDevice(BluetoothDevice device) async {
    try {
      print("Connecting to ${device.name}...");
      await device.connect();
      print("Connected to ${device.name}");

      List<BluetoothService> services = await device.discoverServices();
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString() ==
              "beb5483e-36e1-4688-b7f5-ea07361b26a8") {
            idCharacteristic = characteristic;
          } else if (characteristic.uuid.toString() ==
              "cba1d466-344c-4be3-ab3f-189f80dd7518") {
            pwCharacteristic = characteristic;
          } else if (characteristic.uuid.toString() ==
              "d13f7956-6b92-4b41-bd37-f4b04da2bdb1") {
            resultCharacteristic = characteristic;
            listenToResultCharacteristic(resultCharacteristic);
          }
        }
      }
    } catch (e) {
      print("Failed to connect: $e");
    }
  }

  void sendData() async {
    try {
      String id = idController.text;
      String password = passwordController.text;

      await idCharacteristic.write(id.codeUnits, withoutResponse: false);
      print("ID sent: $id");

      await pwCharacteristic.write(password.codeUnits, withoutResponse: false);
      print("Password sent: $password");
    } catch (e) {
      print("Error sending data: $e");
    }
  }

  void listenToResultCharacteristic(BluetoothCharacteristic characteristic) {
    characteristic.value.listen((value) {
      setState(() {
        serverResult = String.fromCharCodes(value);
        print("Received server result: $serverResult");
      });
    });

    characteristic.setNotifyValue(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Data to ESP32'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: idController,
              decoration: InputDecoration(labelText: "Enter ID"),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Enter Password"),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: sendData,
              child: Text("Send Data"),
            ),
            SizedBox(height: 32),
            Text(
              "Server Result:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(serverResult),
          ],
        ),
      ),
    );
  }
}