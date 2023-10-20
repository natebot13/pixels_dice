enum DieType {
  unknown,
  d4,
  d6,
  d8,
  d10,
  d00,
  d12,
  d20,
  pd6,
  fd6;

  static fromValue(int value) {
    return values[value];
  }
}

// This enum describes what the dice looks like, so the App can use the appropriate 3D model/color
// Need to add
enum Colorway {
  unknown(0),
  onyxBlack(1),
  hematiteGrey(2),
  midnightGalaxy(3),
  auroraSky(4),
  clear(5),
  custom(0xFF);

  const Colorway(this.value);
  final int value;

  static Colorway fromValue(int value) {
    try {
      return values.where((element) => element.value == value).first;
    } on StateError {
      throw ArgumentError("Invalid Colorway value");
    }
  }
}

enum RollState {
  unknown,
  onFace,
  handling,
  rolling,
  crooked,
  count;

  static RollState fromValue(int value) {
    return values[value];
  }
}
