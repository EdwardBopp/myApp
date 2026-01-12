
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:open_earable_flutter/open_earable_flutter.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/exercise.dart';
import 'package:open_wearable/apps/rhythm_trainer/controller/exercise_controller.dart';
import 'package:open_wearable/apps/rhythm_trainer/view/start_restart_button.dart';

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
  
  @override
  void initState() {   

    super.initState();
    
    exerciseController = ExerciseController(
      exercise: widget.exercise,
      sensorDataStream: widget.sensorDataStream,
    );

    countDown = PlatformText(countdownVal.toString());
    print("New Init State");
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

              setState((){

                exerciseController.reset();              
                motionDetected = false;
                countdownVal = 4;
                countDown = PlatformText(countdownVal.toString());
                countdownTimer?.cancel();     
                    
                                    
              });
            },   
          ),

          AnimatedBuilder(
            
            animation: exerciseController, 
            builder: (_, __) {

              bool exerciseFinished = exerciseController.isExerciseCompleted();

              if(exerciseFinished){

                exerciseController.reset();

                return PlatformListTile(
                  title: Text("Exercise Completed"),
                  subtitle: Text("Well done! You have completed the exercise."),
                );

              } else {

                return PlatformListTile(
                  title: Text("Exercise Incomplete"),
                  subtitle: Text("Keep going! You haven't finished the exercise yet."),
                );
              }
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


}
