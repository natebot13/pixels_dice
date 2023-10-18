import 'dart:async';
import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

const int manufacturerId = 0xFE59;
final Guid _serviceId = Guid("6E400001B5A3F393E0A9E50E24DCCA9E");

class PixelsDiceScanner {
  static StreamSubscription<BluetoothAdapterState>? _adapterStreamSubscription;
  static StreamSubscription<List<ScanResult>>? _scanResultSubscription;
  static searchAndConnect() {
    _adapterStreamSubscription?.cancel();
    _adapterStreamSubscription = FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.on) {
        _scanResultSubscription = FlutterBluePlus.scanResults.listen(
          (results) => _diceStreamController.add(
            results.map((result) => PixelsDie._fromScanResult(result)).toList(),
          ),
        );
        FlutterBluePlus.startScan(
          withServices: [_serviceId],
        );
      }
    });
  }

  static stopSearching() {
    _scanResultSubscription?.cancel();
    _scanResultSubscription = null;
    _adapterStreamSubscription?.cancel();
    _adapterStreamSubscription = null;
  }

  static final _diceStreamController = StreamController<List<PixelsDie>>();
  static Stream<List<PixelsDie>> get dice => _diceStreamController.stream;

  static connectToDice() {
    _adapterStreamSubscription = FlutterBluePlus.adapterState
        .listen((BluetoothAdapterState state) async {
      if (state == BluetoothAdapterState.on) {
        FlutterBluePlus.startScan();
      } else {
        // turn on bluetooth ourself if we can
        // for iOS, the user controls bluetooth enable/disable
        if (Platform.isAndroid) {
          await FlutterBluePlus.turnOn();
        } else {}
        // show an error to the user, etc
      }
    });
  }
}

enum PixelsDieConnectionState {
  connected,
  disconnected,
}

extension on BluetoothConnectionState {
  PixelsDieConnectionState toPixelsConnectionState() {
    switch (this) {
      case BluetoothConnectionState.disconnected:
        return PixelsDieConnectionState.disconnected;
      case BluetoothConnectionState.connected:
        return PixelsDieConnectionState.connected;
      default:
        throw UnimplementedError();
    }
  }
}

class PixelsDie {
  PixelsDie._fromScanResult(this._scanResult);

  AdvertisementData get _advertisementData => _scanResult.advertisementData;
  List<int> get _manufactureData =>
      _advertisementData.manufacturerData[manufacturerId]!;
  List<int> get _serviceData => _advertisementData.serviceData[_serviceId]!;
  final ScanResult _scanResult;
  String get name => _advertisementData.localName;
  int get ledCount => _manufactureData[0];
  int get designAndColor => _manufactureData[1];
  int get rollState => _manufactureData[2];
  int get currentFace => _manufactureData[3];
  bool get charging => (_manufactureData[4] & 0x80) == 0x80;
  int get batteryLevel => _manufactureData[4] & 0x7F;
  BluetoothDevice get _device => _scanResult.device;
  Stream<PixelsDieConnectionState> get connectionState =>
      _device.connectionState.map((state) => state.toPixelsConnectionState());
  StreamSubscription<List<int>>? _notifySubscription;

  void connect() async {
    await _device.connect();
    final services = await _device.discoverServices();
    BluetoothService dieService =
        services.where((service) => service.uuid == _serviceId).first;
    final notifyCharacteristic = dieService.characteristics
        .where((c) => c.uuid == Guid("6e400001-b5a3-f393-e0a9-e50e24dcca9e"))
        .first;
    final writeCharacteristic = dieService.characteristics
        .where((c) => c.uuid == Guid("6e400002-b5a3-f393-e0a9-e50e24dcca9e"))
        .first;
    _notifySubscription =
        notifyCharacteristic.onValueReceived.listen(receiveEvent);
    await notifyCharacteristic.setNotifyValue(true);
  }

  void disconnect() {
    _notifySubscription?.cancel();
    _device.disconnect();
  }

  void receiveEvent(List<int> data) {
    // TODO: receive cool data
  }

  final _rollController = StreamController<int>();
  Stream get rollEvents => _rollController.stream;
}
