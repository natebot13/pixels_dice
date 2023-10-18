import 'dart:typed_data';

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

  count,
}

class PixelsDieMessage {
  MessageType messageType;
  ByteData bytes;
  factory PixelsDieMessage.fromList(List<int> data) {
    Uint8List uint8s = Uint8List.fromList(data);
    return PixelsDieMessage(ByteData.sublistView(uint8s));
  }
  PixelsDieMessage(this.bytes)
      : messageType = MessageType.values[bytes.getUint8(0)];
}

class IAmADie extends PixelsDieMessage {
  IAmADie(super.data) : assert(data.lengthInBytes == 22);
  int get ledCount => bytes.getUint8(1);
  int get color => bytes.getUint8(2);
  // ignore byte 3
  // ignore bytes 4-7
  int get pixelId => bytes.getInt32(8);
  int get availableFlash => bytes.getUint16(12);
  int get buildTimestamp => bytes.getUint32(14);
  int get rollState => bytes.getUint8(18);
  int get currentFace => bytes.getUint8(19);
  int get batteryLevel => bytes.getUint8(20);
  int get batteryState => bytes.getUint8(21);
}
