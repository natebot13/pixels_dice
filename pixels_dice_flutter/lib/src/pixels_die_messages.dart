import 'dart:typed_data';
import 'dart:ui';

import 'package:pixels_dice_flutter/src/config_enums.dart';

enum MessageType {
  none,
  whoAreYou,
  iAmADie,
  rollState,
  telemetry,
  bulkSetup,
  bulkSetupAck,
  bulkData,
  bulkDataAck,
  transferAnimSet,
  transferAnimSetAck,
  transferAnimSetFinished,
  transferSettings,
  transferSettingsAck,
  transferSettingsFinished,
  transferTestAnimSet,
  transferTestAnimSetAck,
  transferTestAnimSetFinished,
  debugLog,
  playAnim,
  playAnimEvent,
  stopAnim,
  remoteAction,
  requestRollState,
  requestAnimSet,
  requestSettings,
  requestTelemetry,
  programDefaultAnimSet,
  programDefaultAnimSetFinished,
  blink,
  blinkAck,
  requestDefaultAnimSetColor,
  defaultAnimSetColor,
  requestBatteryLevel,
  batteryLevel,
  requestRssi,
  rssi,
  calibrate,
  calibrateFace,
  notifyUser,
  notifyUserAck,
  testHardware,
  storeValue,
  storeValueAck,
  setTopLevelState,
  programDefaultParameters,
  programDefaultParametersFinished,
  setDesignAndColor,
  setDesignAndColorAck,
  setCurrentBehavior,
  setCurrentBehaviorAck,
  setName,
  setNameAck,
  powerOperation,
  exitValidation,
  transferInstantAnimSet,
  transferInstantAnimSetAck,
  transferInstantAnimSetFinished,
  playInstantAnim,
  stopAllAnims,
  requestTemperature,
  temperature,
  enableCharging,
  disableCharging,
  discharge,
  blinkId,
  blinkIdAck,
  transferTest,
  transferTestAck,
  transferTestFinished,
  clearSettings,
  clearSettingsAck,

  // TESTING
  testBulkSend,
  testBulkReceive,
  setAllLEDsToColor,
  attractMode,
  printNormals,
  printA2DReadings,
  lightUpFace,
  setLEDToColor,
  printAnimControllerState,

  count;

  static MessageType fromValue(int value) {
    if (value >= 0 && value < values.length) {
      return values[value];
    }
    throw ArgumentError("Invalid MessageType value");
  }
}

extension ByteDataToMessage on ByteData {
  PixelsDieMessage parsePixelsMessage() {
    final messageType = MessageType.fromValue(getUint8(0));
    return messageType.parse(this);
  }
}

extension on MessageType {
  PixelsDieMessage parse(ByteData bytes) {
    switch (this) {
      case MessageType.none:
        throw UnimplementedError();
      case MessageType.whoAreYou:
        return WhoAreYou._(bytes);
      case MessageType.iAmADie:
        return IAmADie._(bytes);
      case MessageType.rollState:
        return RollStateMessage._(bytes);
      case MessageType.telemetry:
        return PixelsDieMessage._(bytes);
      case MessageType.bulkSetup:
        return PixelsDieMessage._(bytes);
      case MessageType.bulkSetupAck:
        return PixelsDieMessage._(bytes);
      case MessageType.bulkData:
        return PixelsDieMessage._(bytes);
      case MessageType.bulkDataAck:
        return PixelsDieMessage._(bytes);
      case MessageType.transferAnimSet:
        return PixelsDieMessage._(bytes);
      case MessageType.transferAnimSetAck:
        return PixelsDieMessage._(bytes);
      case MessageType.transferAnimSetFinished:
        return PixelsDieMessage._(bytes);
      case MessageType.transferSettings:
        return PixelsDieMessage._(bytes);
      case MessageType.transferSettingsAck:
        return PixelsDieMessage._(bytes);
      case MessageType.transferSettingsFinished:
        return PixelsDieMessage._(bytes);
      case MessageType.transferTestAnimSet:
        return PixelsDieMessage._(bytes);
      case MessageType.transferTestAnimSetAck:
        return PixelsDieMessage._(bytes);
      case MessageType.transferTestAnimSetFinished:
        return PixelsDieMessage._(bytes);
      case MessageType.debugLog:
        return PixelsDieMessage._(bytes);
      case MessageType.playAnim:
        return PixelsDieMessage._(bytes);
      case MessageType.playAnimEvent:
        return PixelsDieMessage._(bytes);
      case MessageType.stopAnim:
        return PixelsDieMessage._(bytes);
      case MessageType.remoteAction:
        return PixelsDieMessage._(bytes);
      case MessageType.requestRollState:
        return PixelsDieMessage._(bytes);
      case MessageType.requestAnimSet:
        return PixelsDieMessage._(bytes);
      case MessageType.requestSettings:
        return PixelsDieMessage._(bytes);
      case MessageType.requestTelemetry:
        return PixelsDieMessage._(bytes);
      case MessageType.programDefaultAnimSet:
        return PixelsDieMessage._(bytes);
      case MessageType.programDefaultAnimSetFinished:
        return PixelsDieMessage._(bytes);
      case MessageType.blink:
        return Blink._(bytes);
      case MessageType.blinkAck:
        return PixelsDieMessage._(bytes);
      case MessageType.requestDefaultAnimSetColor:
        return PixelsDieMessage._(bytes);
      case MessageType.defaultAnimSetColor:
        return PixelsDieMessage._(bytes);
      case MessageType.requestBatteryLevel:
        return PixelsDieMessage._(bytes);
      case MessageType.batteryLevel:
        return BatteryLevel._(bytes);
      case MessageType.requestRssi:
        return PixelsDieMessage._(bytes);
      case MessageType.rssi:
        return PixelsDieMessage._(bytes);
      case MessageType.calibrate:
        return PixelsDieMessage._(bytes);
      case MessageType.calibrateFace:
        return PixelsDieMessage._(bytes);
      case MessageType.notifyUser:
        return PixelsDieMessage._(bytes);
      case MessageType.notifyUserAck:
        return PixelsDieMessage._(bytes);
      case MessageType.testHardware:
        return PixelsDieMessage._(bytes);
      case MessageType.storeValue:
        return PixelsDieMessage._(bytes);
      case MessageType.storeValueAck:
        return PixelsDieMessage._(bytes);
      case MessageType.setTopLevelState:
        return PixelsDieMessage._(bytes);
      case MessageType.programDefaultParameters:
        return PixelsDieMessage._(bytes);
      case MessageType.programDefaultParametersFinished:
        return PixelsDieMessage._(bytes);
      case MessageType.setDesignAndColor:
        return PixelsDieMessage._(bytes);
      case MessageType.setDesignAndColorAck:
        return PixelsDieMessage._(bytes);
      case MessageType.setCurrentBehavior:
        return PixelsDieMessage._(bytes);
      case MessageType.setCurrentBehaviorAck:
        return PixelsDieMessage._(bytes);
      case MessageType.setName:
        return PixelsDieMessage._(bytes);
      case MessageType.setNameAck:
        return PixelsDieMessage._(bytes);
      case MessageType.powerOperation:
        return PixelsDieMessage._(bytes);
      case MessageType.exitValidation:
        return PixelsDieMessage._(bytes);
      case MessageType.transferInstantAnimSet:
        return PixelsDieMessage._(bytes);
      case MessageType.transferInstantAnimSetAck:
        return PixelsDieMessage._(bytes);
      case MessageType.transferInstantAnimSetFinished:
        return PixelsDieMessage._(bytes);
      case MessageType.playInstantAnim:
        return PixelsDieMessage._(bytes);
      case MessageType.stopAllAnims:
        return PixelsDieMessage._(bytes);
      case MessageType.requestTemperature:
        return PixelsDieMessage._(bytes);
      case MessageType.temperature:
        return PixelsDieMessage._(bytes);
      case MessageType.enableCharging:
        return PixelsDieMessage._(bytes);
      case MessageType.disableCharging:
        return PixelsDieMessage._(bytes);
      case MessageType.discharge:
        return PixelsDieMessage._(bytes);
      case MessageType.blinkId:
        return PixelsDieMessage._(bytes);
      case MessageType.blinkIdAck:
        return PixelsDieMessage._(bytes);
      case MessageType.transferTest:
        return PixelsDieMessage._(bytes);
      case MessageType.transferTestAck:
        return PixelsDieMessage._(bytes);
      case MessageType.transferTestFinished:
        return PixelsDieMessage._(bytes);
      case MessageType.clearSettings:
        return PixelsDieMessage._(bytes);
      case MessageType.clearSettingsAck:
        return PixelsDieMessage._(bytes);

      // TESTING
      case MessageType.testBulkSend:
        return PixelsDieMessage._(bytes);
      case MessageType.testBulkReceive:
        return PixelsDieMessage._(bytes);
      case MessageType.setAllLEDsToColor:
        return PixelsDieMessage._(bytes);
      case MessageType.attractMode:
        return PixelsDieMessage._(bytes);
      case MessageType.printNormals:
        return PixelsDieMessage._(bytes);
      case MessageType.printA2DReadings:
        return PixelsDieMessage._(bytes);
      case MessageType.lightUpFace:
        return PixelsDieMessage._(bytes);
      case MessageType.setLEDToColor:
        return PixelsDieMessage._(bytes);
      case MessageType.printAnimControllerState:
        return PixelsDieMessage._(bytes);

      case MessageType.count:
        throw ArgumentError("Invalid message type");
    }
  }
}

class PixelsDieMessage {
  ByteData bytes;
  PixelsDieMessage._(this.bytes);
  MessageType get messageType => MessageType.fromValue(bytes.getUint8(0));
}

class WhoAreYou extends PixelsDieMessage {
  WhoAreYou() : super._(ByteData(1)..setUint8(0, 1));
  WhoAreYou._(ByteData bytes)
      : assert(bytes.lengthInBytes == 1),
        super._(bytes);
}

class IAmADie extends PixelsDieMessage {
  IAmADie._(ByteData bytes)
      : assert(bytes.lengthInBytes == 22),
        super._(bytes);
  int get ledCount => bytes.getUint8(1);
  Colorway get colorway => Colorway.fromValue(bytes.getUint8(2));
  DieType get dieType => DieType.fromValue(bytes.getUint8(3));
  int get dataSetHash => bytes.getUint32(4, Endian.little);
  int get pixelId => bytes.getInt32(8, Endian.little);
  int get availableFlash => bytes.getUint16(12, Endian.little);
  int get buildTimestamp => bytes.getUint32(14, Endian.little);
  RollState get rollState => RollState.fromValue(bytes.getUint8(18));
  int get currentFace => bytes.getUint8(19);
  int get batteryLevel => bytes.getUint8(20);
  int get batteryState => bytes.getUint8(21);
}

class RollStateMessage extends PixelsDieMessage {
  RollStateMessage._(ByteData bytes)
      : assert(bytes.lengthInBytes == 3),
        super._(bytes);
  RollState get rollState => RollState.fromValue(bytes.getUint8(1));
  int get currentFace => bytes.getUint8(2);
  @override
  String toString() =>
      "RollState: {state: $rollState, face: ${currentFace + 1}}";
}

class BatteryLevel extends PixelsDieMessage {
  BatteryLevel._(ByteData bytes)
      : assert(bytes.lengthInBytes == 3),
        super._(bytes);
  int get batteryLevel => bytes.getUint8(1);
  bool get charging => bytes.getUint8(2) != 0;
}

class Blink extends PixelsDieMessage {
  Blink() : super._(ByteData(14)..setUint8(0, 29));
  Blink._(ByteData bytes)
      : assert(bytes.lengthInBytes == 14),
        super._(bytes);
  int get count => bytes.getUint8(1);
  set count(int c) => bytes.setUint8(1, c);
  int get durationMs => bytes.getUint16(2, Endian.little);
  set durationMs(int d) => bytes.setUint16(2, d, Endian.little);
  Color get color => Color(bytes.getUint32(4, Endian.little));
  set color(Color c) => bytes.setUint32(4, c.value, Endian.little);
  int get faceMask => bytes.getUint32(8, Endian.little);
  set faceMask(int m) => bytes.setUint32(8, m, Endian.little);
  int get fade => bytes.getUint8(12);
  set fade(int f) => bytes.setUint8(12, f);
  bool get loop => bytes.getUint8(13) != 0;
  set loop(bool l) => bytes.setUint8(13, l ? 1 : 0);
}
