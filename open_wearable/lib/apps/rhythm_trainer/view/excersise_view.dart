
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:open_earable_flutter/open_earable_flutter.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/exercise.dart';
import 'package:open_wearable/apps/rhythm_trainer/controller/exercise_controller.dart';
import 'package:open_wearable/apps/rhythm_trainer/view/start_restart_button.dart';
import 'package:simple_sheet_music/simple_sheet_music.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/libs/symbol_converter.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/libs/symbols.dart';

class ExerciseView extends StatefulWidget {

  final Stream<List<SensorValue>> sensorDataStream;
  final Exercise exercise;
  const ExerciseView({super.key, required this.sensorDataStream, required this.exercise});

  @override
  State<ExerciseView> createState() => _ExerciseViewState();
}

class _ExerciseViewState extends State<ExerciseView> {

  late ExerciseController exerciseController;

  bool motionDetected = false;
  int countdownVal = 4;
  late Widget countDown;
  Timer? countdownTimer;

  late final Measure measure;
  late Widget sheet;
  
  
  @override
  void initState() {   

    super.initState();
    
    exerciseController = ExerciseController(
      exercise: widget.exercise,
      sensorDataStream: widget.sensorDataStream,
    );

    countDown = PlatformText(countdownVal.toString());
    print("New Init State");

    // Define musical measures

    List<MusicalSymbol> symbolList = widget.exercise.rhythmPattern.map(SymbolConverter.convert).toList();
    symbolList.insert(0, Symbols.clef);
    measure = Measure(symbolList);
   
  }

  @override
  void didUpdateWidget(covariant ExerciseView oldWidget) {
    
    super.didUpdateWidget(oldWidget);
    exerciseController.updateStream(widget.sensorDataStream);
  }



  @override
  void dispose() {

    exerciseController.reset();
    countdownTimer?.cancel();
    print("Disposed Sensor Value View");
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return Material(
      
      child: ListView(

        children: [

          countDown,
          motionNotifier(),

          Startrestartbutton(
            
            onStart: () {

              countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {

                if(countdownVal <= 0){

                  timer.cancel();
                }else{

                  setState(() {
                      countdownVal--;
                      countDown = PlatformText(countdownVal.toString());
                  });              
                }           
              });

              exerciseController.start();
              
            },
          
            onRestart: () {

              setState(resetExerciseView);
            },   
          ),

          AnimatedBuilder(
            
            animation: exerciseController.exercise, 
            builder: (_, __) {

              Exercise exercise = exerciseController.exercise;

              if(exercise.errorHappened){

                //print("Error happened");

                //print(measure.musicalSymbols);
                //print(exercise.getCurrentNotePosition() + 1);

                Note missedNote = measure.musicalSymbols.removeAt(exercise.getCurrentNotePosition() + 1) as Note;
                measure.musicalSymbols.insert(exercise.getCurrentNotePosition() + 1, Symbols.coloredNotes[missedNote.noteDuration]![Colors.red]!);
               
              }else if(exercise.motionTimestamps.isNotEmpty){

                //print("Note hit");
                //print(measure.musicalSymbols);
                //print(exercise.notePositions);
                //print(exercise.getCurrentNotePosition() + 1);
              
                Note hitNote = measure.musicalSymbols.removeAt(exercise.getCurrentNotePosition() + 1) as Note;
                measure.musicalSymbols.insert(exercise.getCurrentNotePosition() + 1, Symbols.coloredNotes[hitNote.noteDuration]![Colors.green]!);

              }
              
              return SimpleSheetMusic(

                height: MediaQuery.of(context).size.height / 8,
                width: MediaQuery.of(context).size.width,
                measures: [
                  measure,
                ],
              );
            },          
          ),
        ],
      ),
    );
  }

  Widget motionNotifier(){

    if(motionDetected){
      
      return PlatformListTile(
        title: Text("Rhythm Alert"),
        subtitle: Text("High rotation detected!"),
      );

    } else {
      return PlatformListTile(
        title: Text("Test"),
        subtitle: Text("Waiting for motion"),
      );
    }
  }

  void resetExerciseView(){

    setState((){

      exerciseController.reset();              
      motionDetected = false;
      countdownVal = 4;
      countDown = PlatformText(countdownVal.toString());
      countdownTimer?.cancel();   
  
      for(int indexNote in exerciseController.exercise.notePositions){

        indexNote++;
        Note note = measure.musicalSymbols[indexNote] as Note;
        measure.musicalSymbols[indexNote] = Symbols.coloredNotes[note.noteDuration]![Colors.black]!;
      }                           
    });

  }




}
