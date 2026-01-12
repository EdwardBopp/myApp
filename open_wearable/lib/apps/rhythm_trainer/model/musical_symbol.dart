enum MusicalSymbol {


  quarterNote(1),
  halfNote(2),
  wholeNote(4),
  eighthNote(0.5),
  restQuarter(1),
  restHalf(2),
  restWhole(4),
  restEighth(0.5);

  
  final double duration;

  const MusicalSymbol(this.duration);
}
