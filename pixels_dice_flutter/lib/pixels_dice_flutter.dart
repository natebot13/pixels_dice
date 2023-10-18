library pixels_dice_flutter;

import 'dart:async';
import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

//final Guid _characteristic = Guid("9ECADC240EE5A9E093F3A3B50000406E");
//final Guid _characteristic = Guid("0x6E400002-B5A3-F393-E0A9-E50E24DCCA9E");
final Guid _service_id = Guid("6E400001B5A3F393E0A9E50E24DCCA9E");
//final Guid _other_service_id = Guid("0000FE5900001000800000805F9B34FB");

class PixelsDice {
  List<int> _manufactureData;
  ScanResult _scanResult;
  String get name => _scanResult.advertisementData.localName;
  int get ledCount => _manufactureData[0];
  int get designAndColor => _manufactureData[1];
  int get rollState => _manufactureData[2];
  int get currentFace => _manufactureData[3];
  bool get charging => (_manufactureData[4] & 0x80) == 0x80;
  int get batteryLevel => _manufactureData[4] & 0x7F;

  PixelsDice._fromScanResult(this._scanResult)
      : _manufactureData =
            _scanResult.advertisementData.manufacturerData.values.first;

  static StreamSubscription<BluetoothAdapterState>? _adapterStreamSubscription;
  static StreamSubscription<List<ScanResult>>? _scanResultSubscription;
  static searchAndConnect() {
    _adapterStreamSubscription?.cancel();
    _adapterStreamSubscription = FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.on) {
        _scanResultSubscription = FlutterBluePlus.scanResults.listen(
            (results) => _diceStreamController.add(results
                .map((result) => PixelsDice._fromScanResult(result))
                .toList()));
        FlutterBluePlus.startScan(
          withServices: [_service_id],
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

  static final _diceStreamController = StreamController<List<PixelsDice>>();
  static Stream<List<PixelsDice>> get dice => _diceStreamController.stream;

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
