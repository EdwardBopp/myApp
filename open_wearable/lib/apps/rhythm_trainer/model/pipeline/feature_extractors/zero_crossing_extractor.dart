import 'package:open_earable_flutter/open_earable_flutter.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/pipeline/feature_extractors/feature_extractor.dart';

class ZeroCrossingExtractor implements FeatureExtractor {


  int lastMotionTimeStamp = -1;

  @override
  Map<String, double> extractFeatures(List<SensorValue> window) {

    List<double> gyroZ = window.map((e) => double.tryParse(e.valueStrings[2]) ?? 0.0).toList();

    double old = gyroZ[0];
    double crossingValue = 0.0;
    int index = 0;
    double val;
    bool tinyCrossing = false;
    int zeroCrossingTimeStamp = 0;
    double zeroCrossingValue = 0.0;
    Map<String, double> zeroCrossing = {};

    for(int i = 0; i < gyroZ.length; i++){

      val = gyroZ[i];

      if(old >= 0.0 && val < 0.0){
        
        SensorValue currentSensorValue = window[index];
        if(index - 20 >= 0){

          SensorValue somePreviousSensorValue = window[index - 20];
          double valuePrevious = double.tryParse(somePreviousSensorValue.valueStrings[2]) ?? 0.0;
          
          tinyCrossing = valuePrevious < 20.0;
        }
        
        zeroCrossingTimeStamp= currentSensorValue.timestamp;
        zeroCrossingValue = double.tryParse(currentSensorValue.valueStrings[2]) ?? 0.0;

        if(!(zeroCrossingTimeStamp == lastMotionTimeStamp || tinyCrossing)){

          lastMotionTimeStamp = zeroCrossingTimeStamp;
          crossingValue = val;

          zeroCrossing["zero_crossing_timestamp"] = zeroCrossingTimeStamp.toDouble();
          zeroCrossing["zero_crossing_value"] = zeroCrossingValue;
          zeroCrossing["zero_crossing_gyro_z"] = crossingValue;
          zeroCrossing["zero_crossing_detected"] = 1.0;  
          return zeroCrossing;
        }
      }

      index++;
      old = val;  
    }
    
    return zeroCrossing;
  }


}
