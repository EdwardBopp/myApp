import 'package:flutter/material.dart';
import 'package:open_earable_flutter/open_earable_flutter.dart';
import 'package:open_wearable/apps/rhythm_trainer/controller/motion_controller.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/bpmCalculator.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/pipeline/feature_extractors/statistical_feature_extractor.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/pipeline/feature_extractors/zero_crossing_extractor.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/pipeline/motion_Pipeline.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/pipeline/motion_detectors/nod_motion_detector.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/pipeline/window_Manager.dart';

class BPMCalculatorController extends ChangeNotifier{

  BPMcalculator bpmCalculator;
  MotionController motionController;


  BPMCalculatorController({required Stream<List<SensorValue>> sensorDataStream, required BPMcalculator bpmCalc})
      : bpmCalculator = bpmCalc,
        motionController = MotionController(
          sensorDataStream: sensorDataStream,
          motionPipeline: MotionPipeline(
            windowManagers: [
              WindowManager(windowSize: 60, overlap: 0.5),
              WindowManager(windowSize: 60, overlap: 0.5),
            ],
            featureExtractors: [
              [StatisticalFeatureExtractor()],
              [StatisticalFeatureExtractor(), ZeroCrossingExtractor()],
            ],
            motionDetector: NodMotionDetector(),
          ),
        );

  void reset(){

    bpmCalculator = BPMcalculator();
    motionController.resetPipeline();
    motionController.cancelSubscription();
  }

  void start(){

    motionController.subscribeMotionData((event, motion) {
      
      if(motion != -1){

        bpmCalculator.update(motion);
        notifyListeners();
      }
    });
  }

  void updateStream(Stream<List<SensorValue>> sensorDataStream){

    motionController.updateStream(sensorDataStream);
  }

  bool isCalculating(){

    return bpmCalculator.isCalculating;
  }
  
}
