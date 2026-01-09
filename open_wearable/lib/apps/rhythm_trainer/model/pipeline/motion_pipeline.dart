import 'package:open_earable_flutter/open_earable_flutter.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/pipeline/feature_extractors/feature_extractor.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/pipeline/motion_detectors/motionDetector.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/pipeline/window_Manager.dart';

class MotionPipeline {

  final List<WindowManager> windowManagers;
  final List<List<FeatureExtractor>> featureExtractors;
  final MotionDetector motionDetector;

  int debugCounter = 0;
  int motionCounter = 0;
  bool windowReady = false;

  List<SensorValue>? lastWindow;


  MotionPipeline({
    required this.windowManagers,
    required this.featureExtractors,
    required this.motionDetector,
  });

  int processData(List<SensorValue> sensorValues) {

    Map<String, double> allFeatures = {};


    for(int i = 0; i < sensorValues.length; i++) {
      
      windowManagers[i].processSample(sensorValues[i]);
      
      if(windowManagers[i].isWindowReady()) {

        List<SensorValue> window = windowManagers[i].getWindow();
        
        if(i == 1) {
          lastWindow = window;
          windowReady = true;
        }
        

        for(int j = 0; j < featureExtractors[i].length; j++) {

          Map<String, double> features = featureExtractors[i][j].extractFeatures(window);
          allFeatures.addAll(addIdToKeys(features, "sensor_$i"));

        }

      }
    }

    int motion = motionDetector.detectMotion(allFeatures);

    if(motion != -1) {

      motionCounter += 1;
      print("Motion Detected! Total motions detected: $motionCounter");
      printDebugInfo(allFeatures);
      
    }else if(windowReady) {

      //print("No motion detected.");
      //printDebugInfo(allFeatures);
        
    }
  
    return motion;
  }


  Map<String, double> addIdToKeys(Map<String, double> features, String uniqueId) {
    Map<String, double> updatedFeatures = {};
    features.forEach((key, value) {
      updatedFeatures["${uniqueId}_$key"] = value;
    });
    return updatedFeatures;
  }

  void printDebugInfo(Map<String, double> allFeatures) {

  
    List<SensorValue> window = lastWindow!;
    print("########### New Window ###########");

    int counter = 1;

    for(SensorValue sv in window) {

      //print("Sample $counter: ${sv.valueStrings.toString()} at ${sv.timestamp}");
      counter++;
    }

    for(var entry in allFeatures.entries) {
      print("${entry.key}: ${entry.value}\n");
    }

    print("################################################");
    debugCounter += 1;
    
  }


}
