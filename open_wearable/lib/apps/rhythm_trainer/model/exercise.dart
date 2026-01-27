import 'package:flutter/material.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/motion_updatable.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/musical_symbol.dart' as rt;

class Exercise extends ChangeNotifier implements MotionUpdatable {

  final List<rt.MusicalSymbol> rhythmPattern;
  late final List<int> _notePositions;
  final List<double> rhythmPatternDurations = [];
  final List<int> motionTimestamps = [];

  final String name;
  
  int firstTimeStamp = 0;
  bool firstTimeStampSet = false;
  final bool countIn;
  int delayToFirstMotion = 4000;

  bool exerciseFinished = false;
  bool errorHappened = false;

  double _timeStampDiffFactor = 1.0;

  Exercise({required this.rhythmPattern, required this.name, this.countIn = true}) {
    
    print("Creating Exercise: $name");
    convertPatternToDurations(rhythmPattern);
    _notePositions = getNotePositions(rhythmPattern);
    
  }


  @override
  void update(int timeStampLastMotion) {

    if(exerciseFinished || errorHappened) return;

    bool firstMotionTooEarly = motionTimestamps.isEmpty && timeStampDiffInMs(timeStampLastMotion, firstTimeStamp) - 4000 < -500;

    if(firstMotionTooEarly){

      print(timeStampDiffInMs(timeStampLastMotion, firstTimeStamp));
      print("Too early motion detected, waiting for the first motion...");
      return;
    } 

    motionTimestamps.add(timeStampLastMotion);


    if(motionTimestamps.length == 1) {

      print("First motion detected at timestamp: $timeStampLastMotion");
      print(timeStampDiffInMs(motionTimestamps.first, firstTimeStamp));
      print("First time stamp: $firstTimeStamp");
      
      if((timeStampDiffInMs(motionTimestamps.first, firstTimeStamp) - delayToFirstMotion).abs() > 500){ 
        
        print("not precise enough");
        errorHappened = true;
      }

      notifyListeners();
      return;
    }

    double diff = (motionTimestamps.last - motionTimestamps[motionTimestamps.length - 2]) / 1000 / _timeStampDiffFactor;
    print("Diff between last two motions: $diff s");

    if((diff - rhythmPatternDurations[motionTimestamps.length - 2]).abs() > 0.2){

      print("Large delay detected"); 
      errorHappened = true;
      notifyListeners();   // consecutive motion is not precise enough
      return;
    }

    notifyListeners(); // motion accepted

    int length = motionTimestamps.length;

    if(rhythmPatternDurations.length + 1 != length) return;

    for(int i = 1; i < length; i++){

      double timeDiff = (motionTimestamps[i] - motionTimestamps[i - 1]) / 1000 / _timeStampDiffFactor;
      print("Time diff $i: $timeDiff s");
      print("Expected time diff $i: ${rhythmPatternDurations[i - 1]} s");

      if((timeDiff - rhythmPatternDurations[i - 1]).abs() > 0.2){

        print("Rhythm off at interval $i");

      } else {

        print("Rhythm on at interval $i");
      }
    }

    exerciseFinished = true;
    notifyListeners();
  }

  void setFirstTimestamp(int timestamp) {

    if(firstTimeStampSet) return;
    firstTimeStamp = timestamp;
    firstTimeStampSet = true;
  }

  void convertPatternToDurations(List<rt.MusicalSymbol> pattern){

    print("Converting rhythm pattern to durations...");

    for(rt.MusicalSymbol symbol in pattern) {
      switch(symbol) {

        case rt.MusicalSymbol.quarterNote || rt.MusicalSymbol.eighthNote || rt.MusicalSymbol.halfNote || rt.MusicalSymbol.wholeNote:
          rhythmPatternDurations.add(symbol.duration);

        case rt.MusicalSymbol.restQuarter || rt.MusicalSymbol.restEighth || rt.MusicalSymbol.restHalf || rt.MusicalSymbol.restWhole: 

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

  List<int> getNotePositions(List<rt.MusicalSymbol> pattern){

    int position = 0;
    List<int> positions = [];

    for(rt.MusicalSymbol symbol in pattern) {

      switch(symbol) {

        case rt.MusicalSymbol.quarterNote || rt.MusicalSymbol.eighthNote || rt.MusicalSymbol.halfNote || rt.MusicalSymbol.wholeNote:
          positions.add(position);

        case rt.MusicalSymbol.restQuarter || rt.MusicalSymbol.restEighth || rt.MusicalSymbol.restHalf || rt.MusicalSymbol.restWhole: 
          
      }

      position += 1;
    }

    return positions;
  }

  int getCurrentNotePosition(){

    //print("Getting current note position for motion count: ${motionTimestamps.length}");
    //print("Note positions: $notePositions");

    return notePositions[motionTimestamps.length - 1];
  }

  List<int> get notePositions => _notePositions;

  int timeStampDiffInMs(int timestamp1, int timestamp2){

    return ((timestamp1 - timestamp2) / _timeStampDiffFactor).toInt();
  }

  void setDiffFactor(double factor){

    if(_timeStampDiffFactor != 1.0) return;
    _timeStampDiffFactor = factor;
  }




}
