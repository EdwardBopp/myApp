
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:open_earable_flutter/open_earable_flutter.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/bpmCalculator.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/motion_updatable.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/pipeline/feature_extractors/statistical_feature_extractor.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/pipeline/feature_extractors/zero_crossing_extractor.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/pipeline/motion_Pipeline.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/pipeline/motion_detectors/nod_motion_detector.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/pipeline/window_Manager.dart';
import 'package:open_wearable/apps/rhythm_trainer/view/start_restart_button.dart';


class BpmCalculatorView extends StatefulWidget {

  final Stream<List<SensorValue>>? sensorDataStream;
  final BPMcalculator bpmCalculator;
  const BpmCalculatorView({super.key, required this.sensorDataStream, required this.bpmCalculator});

  @override
  State<BpmCalculatorView> createState() => _BpmCalculatorViewState();
}

class _BpmCalculatorViewState extends State<BpmCalculatorView> {

  late Stream<List<SensorValue>>? sensorDataStream;
  late BPMcalculator bpmCalculator;
  
  MotionPipeline motionPipeline = MotionPipeline(
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

  StreamSubscription<List<SensorValue>>? sub;
  bool motionDetected = false;
  
  @override
  void initState() {   

    super.initState();
    sensorDataStream = widget.sensorDataStream;
    
    bpmCalculator = widget.bpmCalculator;
    print("New Init State");
  }

  @override
  void didUpdateWidget(covariant BpmCalculatorView oldWidget) {
    
    super.didUpdateWidget(oldWidget);
    sensorDataStream = oldWidget.sensorDataStream != widget.sensorDataStream ? widget.sensorDataStream : oldWidget.sensorDataStream; 
    bpmCalculator = oldWidget.bpmCalculator != widget.bpmCalculator ? widget.bpmCalculator : oldWidget.bpmCalculator;

  }

  @override
  void dispose() {

    sub?.cancel();
    print("Disposed Sensor Value View");
    super.dispose();
    
  }


  @override
  Widget build(BuildContext context) {

    return Material(
      
      child: ListView(
        children: [
          motionNotifier(),

          Startrestartbutton(

            onRestart: () { 
            
              setState(() {

                bpmCalculator = BPMcalculator();
                motionPipeline = MotionPipeline(
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

                sub?.cancel();
                
                motionDetected = false;
              
              });
              
            },

            onStart: () {

              sub = sensorDataStream?.listen((event) {

                int motion = motionPipeline.processData(event);

                if(motion != -1){

                  bpmCalculator.update(motion);

                  if(!bpmCalculator.isCalculating){

                    print("BPM Calculation finished, resetting...");
                  

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
