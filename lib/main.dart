import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // バックグラウンドサービスの初期化
  await initializeService();

  runApp(MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onBackgroundServiceStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'my_background_service',
      initialNotificationTitle: 'Bluetoothスキャン中',
      initialNotificationContent: 'バックグラウンドでスキャンを実行しています',
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onBackgroundServiceStart,
      autoStart: true,
    ),
  );
}

void onBackgroundServiceStart(ServiceInstance service) {
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // バックグラウンドタスク例 (Bluetoothスキャンやデータ送信)
  service.on('backgroundTask').listen((event) async {
    // 例: サーバーにデバイス情報を送信
    await sendDataToServer("Background Device", "00:11:22:33:44:55");
  });

  service.invoke('backgroundTask');
}

Future<void> sendDataToServer(String deviceName, String deviceId) async {
  final url = Uri.parse("https://example.com/receive_data.php");
  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        "device_name": deviceName,
        "device_id": deviceId,
        "status": "connected",
      },
    );

    if (response.statusCode == 200) {
      print("データ送信成功: ${response.body}");
    } else {
      print("データ送信失敗: ステータスコード ${response.statusCode}");
    }
  } catch (e) {
    print("データ送信エラー: $e");
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BluetoothScanPage(),
    );
  }
}

class BluetoothScanPage extends StatefulWidget {
  @override
  _BluetoothScanPageState createState() => _BluetoothScanPageState();
}

class _BluetoothScanPageState extends State<BluetoothScanPage> {
  List<ScanResult> scanResults = [];
  String targetMacAddress = "B8:27:EB:F7:D4:26";
  String serverUrl = "https://example.com/receive_data.php";

  @override
  void initState() {
    super.initState();
    startBluetoothScan();
  }

void startBluetoothScan() async {
  // スキャンを開始
  await FlutterBluePlus.startScan(timeout: Duration(seconds: 10));

  // スキャン結果をリッスン
  FlutterBluePlus.scanResults.listen((results) {
    setState(() {
      scanResults = results;
    });
  });
}

  void connectToDevice(BluetoothDevice device) async {
    print("Connecting to ${device.name.isEmpty ? "名前なしデバイス" : device.name}");
    try {
      await device.connect();
      print("接続成功: ${device.id}");

      if (device.id.toString() == targetMacAddress) {
        print("正しいデバイスに接続しました！");
        await sendDataToServer(device.name, device.id.toString());
      } else {
        print("ターゲットデバイスではありません");
      }
    } catch (e) {
      print("接続失敗: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetoothデバイス検出'),
      ),
      body: ListView.builder(
        itemCount: scanResults.length,
        itemBuilder: (context, index) {
          final device = scanResults[index].device;
          return ListTile(
            title: Text(device.name.isNotEmpty ? device.name : '名前なしデバイス'),
            subtitle: Text("MACアドレス: ${device.id}"),
            onTap: () => connectToDevice(device),
          );
        },
      ),
    );
  }
}