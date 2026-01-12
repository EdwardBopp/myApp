import 'package:open_wearable/apps/rhythm_trainer/model/motion_updatable.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/musical_symbol.dart';


class Exercise implements MotionUpdatable {

  final List<MusicalSymbol> rhythmPattern;
  final List<double> rhythmPatternDurations = [];
  final String name;
  List<int> motionTimestamps = [];
  int firstTimeStamp = 0;
  bool firstTimeStampSet = false;
  final bool countIn;
  int delayToFirstMotion = 4000;
  bool exerciseFinished = false;

  Exercise({required this.rhythmPattern, required this.name, this.countIn = true}) {
    
    print("Creating Exercise: $name");
    convertPatternToDurations(rhythmPattern);
    
  }


  @override
  void update(int timeStampLastMotion) {

    if(motionTimestamps.isEmpty && ((timeStampLastMotion - firstTimeStamp) / 2) - delayToFirstMotion < -500){

      print(((timeStampLastMotion - firstTimeStamp) / 2));
      print("Too early motion detected, waiting for the first motion...");
      return;
    } 

    motionTimestamps.add(timeStampLastMotion);

    if(motionTimestamps.length == 1) {

      print((motionTimestamps.first - firstTimeStamp) / 2.0);
      
      if(((motionTimestamps.first - firstTimeStamp) / 2.0 - delayToFirstMotion).abs() > 500){ 
        
        print("not precise enough");
        
      }
    }

    int length = motionTimestamps.length;

    if(rhythmPatternDurations.length + 1 != length) return;

    for(int i = 1; i < length; i++){

      double timeDiff = (motionTimestamps[i] - motionTimestamps[i - 1]) / 1000 / 2.0;
      print("Time diff $i: $timeDiff s");
      print("Expected time diff $i: ${rhythmPatternDurations[i - 1]} s");

      if((timeDiff - rhythmPatternDurations[i - 1]).abs() > 0.2){

        print("Rhythm off at interval $i");

      } else {

        print("Rhythm on at interval $i");
      }
    }

    exerciseFinished = true;
    motionTimestamps.clear();
    
  }

  void setFirstTimestamp(int timestamp) {

    if(firstTimeStampSet) return;
    firstTimeStamp = timestamp;
    firstTimeStampSet = true;
  }

  void convertPatternToDurations(List<MusicalSymbol> pattern){

    print("Converting rhythm pattern to durations...");

    for(MusicalSymbol symbol in pattern) {

      switch(symbol) {

        case MusicalSymbol.quarterNote || MusicalSymbol.eighthNote || MusicalSymbol.halfNote || MusicalSymbol.wholeNote:
          rhythmPatternDurations.add(symbol.duration);

        case MusicalSymbol.restQuarter || MusicalSymbol.restEighth || MusicalSymbol.restHalf || MusicalSymbol.restWhole: 

          if(rhythmPatternDurations.isEmpty) {

            delayToFirstMotion += (symbol.duration * 1000).toInt();
          } else {

            rhythmPatternDurations[rhythmPatternDurations.length - 1] += symbol.duration;
          }
      }
    }

    
    rhythmPatternDurations.removeLast();

    print("Rhythm Pattern Durations: $rhythmPatternDurations");
    print("Delay to first motion: $delayToFirstMotion ms");
    print("Rhythm Pattern $rhythmPattern");

   
  }
}
