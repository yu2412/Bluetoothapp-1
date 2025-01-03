import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PhpSenderPage extends StatefulWidget {
  @override
  _PhpSenderPageState createState() => _PhpSenderPageState();
}

class _PhpSenderPageState extends State<PhpSenderPage> {
  static const String serverUrl = 'https://your-server.com/api.php';
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedValues();
  }

  Future<void> _loadSavedValues() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      idController.text = prefs.getString('saved_id') ?? "";
      passwordController.text = prefs.getString('saved_password') ?? "";
    });
  }

  Future<bool> sendDataToServer(String deviceName, String deviceId) async {
    try {
      final response = await http.post(
        Uri.parse(serverUrl),
        body: {
          'device_name': deviceName,
          'device_id': deviceId,
          'id': idController.text,
          'password': passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('サーバーレスポンス: $data');
        return true;
      } else {
        print('サーバーエラー: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('通信エラー: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PHPサーバー送信'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: idController,
              decoration: InputDecoration(labelText: "ID"),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                bool result = await sendDataToServer('TestDevice', 'TestID123');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result ? 'データ送信成功' : 'データ送信失敗')),
                );
              },
              child: Text('データを送信'),
            ),
          ],
        ),
      ),
    );
  }
}
