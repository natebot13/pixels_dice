import 'dart:async';

// DieRolls are 1-indexed (a d20 ranges from 1 to 20)
class DieRoll {
  final int roll;
  final int size;
  DieRoll(this.roll, this.size);
}

class _DieMathResult {
  final DieRoll? result;
  final DieRoll leftoverEntropy;
  _DieMathResult(this.result, this.leftoverEntropy);
}

enum EntropyUseStrategy {
  always,
  upwardsOnly,
  never,
}

class DieConverter {
  // should be the max int value - 20^x where x is somewhat arbitrary but should be at least 1 or 2 (I chose 4)
  static const int MAX_DIE_SIZE = 9223372036854775807 - 160000;

  // these two are the main properties to configure the behavior of this class
  int targetDieSize = 6;
  var entropyUseStrategy = EntropyUseStrategy.always;

  DieRoll _leftoverEntropy = DieRoll(1, 1);
  Stream<DieRoll> input;
  final _outputController = StreamController<DieRoll>();
  Stream<DieRoll> get output => _outputController.stream;

  DieConverter({required this.input}) {
    input.listen(receiveRollData);
  }

  static _DieMathResult _attemptConversion(DieRoll data, int targetDieSize) {
    if (data.size < targetDieSize) {
      return _DieMathResult(null, data);
    }

    final int cutoff = (data.size ~/ targetDieSize) * targetDieSize;
    if (data.roll <= cutoff) {
      final resultRoll = data.roll % targetDieSize;
      final result =
          DieRoll(resultRoll == 0 ? targetDieSize : resultRoll, targetDieSize);
      final leftoverEntropy = DieRoll(
          (data.roll - 1) ~/ targetDieSize + 1, cutoff ~/ targetDieSize);
      return _DieMathResult(result, leftoverEntropy);
    } else {
      final leftoverEntropy = DieRoll(data.roll - cutoff, data.size - cutoff);
      return _DieMathResult(null, leftoverEntropy);
    }
  }

  void _accumulateLeftoverEntropy(DieRoll entropy) {
    if (MAX_DIE_SIZE ~/ entropy.size >= _leftoverEntropy.size) {
      _leftoverEntropy = DieRoll(
          _leftoverEntropy.roll + (entropy.roll - 1) * _leftoverEntropy.size,
          _leftoverEntropy.size * entropy.size);
    }
  }

  void receiveRollData(DieRoll data) {
    // first try to use the new data to get a result
    _DieMathResult answer = _attemptConversion(data, targetDieSize);
    _accumulateLeftoverEntropy(answer.leftoverEntropy);
    if (answer.result != null) {
      _outputController.sink.add(answer.result!);
      return;
    }

    // check if the settings allow for use of accumulated entropy
    if (entropyUseStrategy == EntropyUseStrategy.never) {
      return;
    } else if (entropyUseStrategy == EntropyUseStrategy.upwardsOnly) {
      if (data.size >= targetDieSize) {
        return;
      }
    }

    // use the leftover entropy to get a new result
    answer = _attemptConversion(_leftoverEntropy, targetDieSize);
    _leftoverEntropy = answer.leftoverEntropy;
    if (answer.result != null) {
      _outputController.sink.add(answer.result!);
    }
  }
}
