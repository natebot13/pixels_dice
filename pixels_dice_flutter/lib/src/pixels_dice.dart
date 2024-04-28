import 'dart:async';
import 'dart:io';
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
      print(state);
      if (state == BluetoothAdapterState.on) {
        _scanResultSubscription = FlutterBluePlus.scanResults.listen((results) {
          if (results.isNotEmpty) {
            _diceStreamController.add(
              results
                  .map((result) => PixelsDie._fromScanResult(result))
                  .toList(),
            );
          }
        });
        FlutterBluePlus.startScan(withServices: [_serviceId]);
      } else {
        FlutterBluePlus.turnOn();
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
  DieType get dieType => DieType.fromValue(_bytes.getUint8(1) >> 4);
  Colorway get colorway => Colorway.fromValue(_bytes.getUint8(1) & 0x0F);
  RollState get rollState => RollState.fromValue(_bytes.getUint8(2));
  int get currentFace => _bytes.getUint8(3);
  bool get charging => (_bytes.getUint8(4) & 0x80) == 0x80;
  int get batteryLevel => _bytes.getUint8(4) & 0x7F;

  @override
  String toString() =>
      "leds: $ledCount, dieType: $dieType, color: $colorway, rollState: $rollState, "
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
    print(serviceData);
    if (!serviceData.containsKey(Guid("180a"))) throw ArgumentError();
    return PixelsServiceData._fromList(serviceData[Guid("180a")]!);
  }

  int get pixelId => _bytes.getUint32(0);
  int get buildTimestampUnix => _bytes.getUint32(4);

  @override
  String toString() => "pixelId: $pixelId, buildTimestamp: $buildTimestampUnix";
}

class PixelsDie {
  PixelsDie._fromScanResult(ScanResult scanResult)
      : name = scanResult.advertisementData.advName,
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
