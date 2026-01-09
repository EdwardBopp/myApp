import 'package:open_wearable/apps/rhythm_trainer/model/pipeline/motion_detectors/motionDetector.dart';

class NodMotionDetector implements MotionDetector {

  @override
  int detectMotion(Map<String, double> features) {

    if(features.isEmpty) return -1;
    if(!features.containsKey("sensor_1_corr_yz") || 
        !features.containsKey("sensor_0_corr_xy") || 
        !features.containsKey("sensor_1_sma") || 
        !features.containsKey("sensor_1_zero_crossing_detected") ||
        !features.containsKey("sensor_1_zero_crossing_timestamp")) {

      return -1;
    }

    if(features["sensor_1_corr_yz"]! > 0.7 && features["sensor_0_corr_xy"]! < -0.1 && features["sensor_1_sma"]! > 70.0 && features["sensor_1_zero_crossing_detected"]! == 1.0){

      return features["sensor_1_zero_crossing_timestamp"]!.toInt();

    }else {

      return -1;
    }

  }
}
