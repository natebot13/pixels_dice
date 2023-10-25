import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:pixels_dice_flutter/src/config_enums.dart';
import 'package:pixels_dice_flutter/src/pixels_die_messages.dart';

const int manufacturerId = 0xFFFF;
final Guid _serviceId = Guid("6E400001B5A3F393E0A9E50E24DCCA9E");

class RollEvent {
  DateTime instant;
  int value;
  RollEvent({required this.instant, required this.value});
}

class PixelsDiceScanner {
  static StreamSubscription<BluetoothAdapterState>? _adapterStreamSubscription;
  static StreamSubscription<List<ScanResult>>? _scanResultSubscription;
  static searchAndConnect() {
    _adapterStreamSubscription?.cancel();
    _adapterStreamSubscription = FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.on) {
        // _diceStreamController.add([FakePixelsDie()]);
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

class PixelsDieManufactureData {
  ByteData _bytes;
  PixelsDieManufactureData._(this._bytes);
  factory PixelsDieManufactureData._fromList(List<int> data) {
    final byteList = Uint8List.fromList(data);
    return PixelsDieManufactureData._(ByteData.view(byteList.buffer));
  }

  factory PixelsDieManufactureData._fromScanResult(ScanResult result) {
    final manufactureData = result.advertisementData.manufacturerData;
    if (!manufactureData.containsKey(manufacturerId)) throw ArgumentError();
    return PixelsDieManufactureData._fromList(manufactureData[manufacturerId]!);
  }

  int get ledCount => _bytes.getUint8(0);
  Colorway get designAndColor => Colorway.fromValue(_bytes.getUint8(1));
  RollState get rollState => RollState.fromValue(_bytes.getUint8(2));
  int get currentFace => _bytes.getUint8(3);
  bool get charging => (_bytes.getUint8(4) & 0x80) == 0x80;
  int get batteryLevel => _bytes.getUint8(4) & 0x7F;

  @override
  String toString() =>
      "leds: $ledCount, color: $designAndColor, rollState: $rollState, "
      "face: $currentFace, charging: $charging, batteryLevel: $batteryLevel";
}

class FakeManufactureData implements PixelsDieManufactureData {
  @override
  int get batteryLevel => 50;

  @override
  bool get charging => false;

  @override
  int get currentFace => 5;

  @override
  Colorway get designAndColor => Colorway.custom;

  @override
  int get ledCount => 20;

  @override
  RollState get rollState => RollState.onFace;

  @override
  ByteData _bytes = ByteData(0);

  @override
  String toString() =>
      "leds: $ledCount, color: $designAndColor, rollState: $rollState, "
      "face: $currentFace, charging: $charging, batteryLevel: $batteryLevel";
}

class PixelsServiceData {
  ByteData _bytes;
  PixelsServiceData._(this._bytes) : assert(_bytes.lengthInBytes == 8);

  factory PixelsServiceData._fromList(List<int> data) {
    final byteList = Uint8List.fromList(data);
    return PixelsServiceData._(ByteData.view(byteList.buffer));
  }

  factory PixelsServiceData._fromScanResult(ScanResult result) {
    final serviceData = result.advertisementData.serviceData;
    if (!serviceData.containsKey(0x180A)) throw ArgumentError();
    return PixelsServiceData._fromList(serviceData[0x180A]!);
  }

  int get pixelId => _bytes.getUint32(0);
  int get buildTimestampUnix => _bytes.getUint32(4);

  @override
  String toString() => "pixelId: $pixelId, buildTimestamp: $buildTimestampUnix";
}

class FakeServiceData implements PixelsServiceData {
  @override
  ByteData _bytes = ByteData(0);

  @override
  int get buildTimestampUnix => DateTime(2023, 10, 24).millisecondsSinceEpoch;

  @override
  int get pixelId => 0xDEADBEEF;
}

class PixelsDie {
  PixelsDie._fromScanResult(ScanResult scanResult)
      : name = scanResult.advertisementData.localName,
        manufactureData = PixelsDieManufactureData._fromScanResult(scanResult),
        serviceData = PixelsServiceData._fromScanResult(scanResult),
        _device = scanResult.device;

  final String name;
  final PixelsDieManufactureData manufactureData;
  final PixelsServiceData serviceData;
  final BluetoothDevice _device;

  Stream<PixelsDieConnectionState> get connectionState =>
      _device.connectionState.map((state) => state.toPixelsConnectionState());
  StreamSubscription<List<int>>? _notifySubscription;

  RollState previousRollState = RollState.unknown;

  Future<void> connect() async {
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
        notifyCharacteristic.onValueReceived.listen(_receiveEvent);
    await notifyCharacteristic.setNotifyValue(true);
  }

  void disconnect() {
    _notifySubscription?.cancel();
    _device.disconnect();
  }

  void _receiveEvent(List<int> data) {
    Uint8List byteList = Uint8List.fromList(data);
    final bytes = ByteData.view(byteList.buffer);
    final message = bytes.parsePixelsMessage();
    if (message is RollStateMessage) {
      if (previousRollState == RollState.rolling &&
          message.rollState == RollState.onFace) {
        _rollController.add(
          RollEvent(instant: DateTime.now(), value: message.currentFace),
        );
      }
      previousRollState = message.rollState;
    }
  }

  final _rollController = StreamController<RollEvent>();
  Stream<RollEvent> get rollEvents => _rollController.stream;
}

class FakePixelsDie implements PixelsDie {
  final _connectionController = StreamController<PixelsDieConnectionState>();

  @override
  final _rollController = StreamController<RollEvent>();

  final _random = Random();

  FakePixelsDie() {
    Stream.periodic(const Duration(seconds: 3), (_) {
      final rollStateIndex = _random.nextInt(RollState.values.length);
      final newRollState = RollState.values[rollStateIndex];
      if (previousRollState == RollState.rolling &&
          newRollState == RollState.onFace) {
        _rollController.sink.add(
          RollEvent(
            instant: DateTime.now(),
            value: _random.nextInt(20) + 1,
          ),
        );
      }
    });
  }

  @override
  RollState previousRollState = RollState.unknown;

  @override
  Future<void> connect() {
    return Future.delayed(
      const Duration(milliseconds: 10),
      () => _connectionController.sink.add(PixelsDieConnectionState.connected),
    );
  }

  @override
  Stream<PixelsDieConnectionState> get connectionState =>
      _connectionController.stream;

  @override
  void disconnect() {
    Future.delayed(
      const Duration(milliseconds: 10),
      () =>
          _connectionController.sink.add(PixelsDieConnectionState.disconnected),
    );
  }

  @override
  String get name => 'FakeDie';

  @override
  PixelsDieManufactureData get manufactureData => FakeManufactureData();

  @override
  PixelsServiceData get serviceData => FakeServiceData();

  @override
  Stream<RollEvent> get rollEvents => _rollController.stream;

  @override
  void _receiveEvent(List<int> data) => throw UnimplementedError();
  @override
  StreamSubscription<List<int>>? _notifySubscription;
  @override
  BluetoothDevice get _device => throw UnimplementedError();
}
