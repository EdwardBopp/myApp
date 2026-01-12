
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:open_earable_flutter/open_earable_flutter.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/exercise.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/pipeline/feature_extractors/statistical_feature_extractor.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/pipeline/feature_extractors/zero_crossing_extractor.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/pipeline/motion_Pipeline.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/pipeline/motion_detectors/nod_motion_detector.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/pipeline/window_Manager.dart';
import 'package:open_wearable/apps/rhythm_trainer/view/start_restart_button.dart';

class ExerciseView extends StatefulWidget {

  final Stream<List<SensorValue>>? sensorDataStream;
  final Exercise exercise;
  const ExerciseView({super.key, required this.sensorDataStream, required this.exercise});

  @override
  State<ExerciseView> createState() => _ExerciseViewState();
}

class _ExerciseViewState extends State<ExerciseView> {

  late Stream<List<SensorValue>>? sensorDataStream;
  late Exercise exercise;
  late MotionPipeline motionPipeline;

  StreamSubscription<List<SensorValue>>? sub;
  bool motionDetected = false;
  int countdownVal = 4;
  late Widget countDown;
  late Timer countdownTimer;
  
  @override
  void initState() {   

    super.initState();
    
    sensorDataStream = widget.sensorDataStream;
    countDown = PlatformText(countdownVal.toString());
    motionPipeline = getNewPipeline();
    
    exercise = widget.exercise;
    print("New Init State");
  }

  @override
  void didUpdateWidget(covariant ExerciseView oldWidget) {
    
    super.didUpdateWidget(oldWidget);
    sensorDataStream = oldWidget.sensorDataStream != widget.sensorDataStream ? widget.sensorDataStream : oldWidget.sensorDataStream; 
  }

  @override
  void dispose() {

    sub?.cancel();
    countdownTimer.cancel();
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

              sub = sensorDataStream?.listen((event) {

                
                exercise.setFirstTimestamp(event[0].timestamp);
                
                int motion = motionPipeline.processData(event);

                if(motion != -1){

                  exercise.update(motion);

                  if(exercise.exerciseFinished){

                    print("Exercise ready, resetting...");
                  }

                  setState(() {
                    motionDetected = true;
                  });

                  Timer(Duration(milliseconds: 100), () {
                    setState(() {

                      motionDetected = false;
                    });
                  });
                }
              });
            },
          
            onRestart: () {

              setState((){

                exercise = Exercise(
                  rhythmPattern: exercise.rhythmPattern,
                  name: exercise.name,
                );

                sub?.cancel();
                motionDetected = false;
                countdownVal = 4;
                countDown = PlatformText(countdownVal.toString());
                countdownTimer.cancel();     
                    
                motionPipeline = getNewPipeline();                           
              });
            },   
          ),
        ],
      ),
    );
  }

  MotionPipeline getNewPipeline(){

    return MotionPipeline(
      windowManagers: [
        WindowManager(windowSize: 60, overlap: 0.5),
        WindowManager(windowSize: 60, overlap: 0.5),
      ],
      featureExtractors: [
        [StatisticalFeatureExtractor()],
        [StatisticalFeatureExtractor(), ZeroCrossingExtractor()],
      ],
      motionDetector: NodMotionDetector(),
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
