import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'config_enums.dart';
import 'pixels_dice.dart';

class FakeManufactureData implements PixelsDieManufactureData {
  @override
  int get batteryLevel => 50;

  @override
  bool get charging => false;

  @override
  int get currentFace => 5;

  @override
  DieType get dieType => DieType.d20;

  @override
  Colorway get colorway => Colorway.custom;

  @override
  int get ledCount => 20;

  @override
  RollState get rollState => RollState.onFace;

  @override
  ByteData _bytes = ByteData(0);

  @override
  String toString() =>
      "leds: $ledCount, color: $colorway, rollState: $rollState, "
      "face: $currentFace, charging: $charging, batteryLevel: $batteryLevel";
}

class FakeServiceData implements PixelsServiceData {
  @override
  ByteData _bytes = ByteData(0);

  @override
  int get buildTimestampUnix => DateTime(2023, 10, 24).millisecondsSinceEpoch;

  @override
  int get pixelId => 0xDEADBEEF;
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
