
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:open_earable_flutter/open_earable_flutter.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/math.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/motion_updatable.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/pipeline/feature_extractors/statistical_feature_extractor.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/pipeline/feature_extractors/zero_crossing_extractor.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/pipeline/motion_Pipeline.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/pipeline/motion_detectors/nod_motion_detector.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/pipeline/window_Manager.dart';




class MotionDetector extends StatefulWidget {

  final Sensor acceleroMeter;
  final Sensor gyroscope;
  final Stream<List<SensorValue>>? sensorDataStream;
  final MotionUpdatable motionUpdatable;
  const MotionDetector({super.key, required this.acceleroMeter, required this.gyroscope, required this.sensorDataStream, required this.motionUpdatable});

  @override
  State<MotionDetector> createState() => _MotionDetectorState();
}

class _MotionDetectorState extends State<MotionDetector> {

  late Sensor acceleroMeter;
  late Sensor gyroscope;
  late Stream<List<SensorValue>>? sensorDataStream;
  late MotionUpdatable motionUpdatable;
  final MotionPipeline motionPipeline = MotionPipeline(
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

  List<SensorValue> sensorValuesAccelero = [];
  List<SensorValue> sensorValuesGyro = [];
  StreamSubscription<List<SensorValue>>? sub;
  bool motionDetected = false;
  int lastMotionTimeStamp = 0;
  int counterMotion = 0;
  int windowSize = 60;
  

  @override
  void initState() {   

    super.initState();
    acceleroMeter = widget.acceleroMeter;
    gyroscope = widget.gyroscope;
    sensorDataStream = widget.sensorDataStream;
    
    motionUpdatable = widget.motionUpdatable;
    print("New Init State");
  }

  @override
  void didUpdateWidget(covariant MotionDetector oldWidget) {
    
    super.didUpdateWidget(oldWidget);

    acceleroMeter = oldWidget.acceleroMeter != widget.acceleroMeter ? widget.acceleroMeter : oldWidget.acceleroMeter;
    gyroscope = oldWidget.gyroscope != widget.gyroscope ? widget.gyroscope : oldWidget.gyroscope;
    sensorDataStream = oldWidget.sensorDataStream != widget.sensorDataStream ? widget.sensorDataStream : oldWidget.sensorDataStream; 
    motionUpdatable = oldWidget.motionUpdatable != widget.motionUpdatable ? widget.motionUpdatable : oldWidget.motionUpdatable;

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
          PlatformElevatedButton(
            child: PlatformText("Start Streaming"),
            onPressed: () {

              // ignore: unnecessary_lambdas
              sub = sensorDataStream?.listen((event) {

                int motion = motionPipeline.processData(event);

                if(motion != -1){

                  motionUpdatable.update(motion);

                  setState(() {
                    motionDetected = true;
                  });

                  Timer(Duration(milliseconds: 100), () {
                    setState(() {

                      motionDetected = false;
                    });
                  });
                }


                /*if(motion){

                  setState(() {
                    motionDetected = true;
                  });

                  Timer(Duration(milliseconds: 100), () {
                    setState(() {

                      motionDetected = false;
                    });
                  });              
                }*/

                /*sensorValuesAccelero.add(event[0]);
                sensorValuesGyro.add(event[1]);
                
                if(sensorValuesGyro.isNotEmpty && sensorValuesGyro.length == windowSize){
                  int timeDifference = sensorValuesGyro.last.timestamp - sensorValuesGyro.first.timestamp;
                  //print("Time for 60 gyro samples: $timeDifference s");
                }
                
                if(detectMotion(sensorValuesGyro, sensorValuesAccelero, windowSize)){

                  setState(() {
                    motionDetected = true;
                  });

                  Timer(Duration(milliseconds: 100), () {
                    setState(() {

                      motionDetected = false;
                    });
                  });              
                }
                
                keepWindowSize(sensorValuesAccelero, windowSize, 0.5);
                keepWindowSize(sensorValuesGyro, windowSize, 0.5);*/  
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


  bool detectMotion(List<SensorValue> gyroValues, List<SensorValue> acceleroValues, int windowSize){

    if(gyroValues.length != windowSize || acceleroValues.length != windowSize){
      return false;
    }

    List<List<double>> gyroWindow = gyroValues.sublist(gyroValues.length - windowSize).map(convertSensorValueToDouble).toList();
    List<List<double>> acceleroWindow = acceleroValues.sublist(acceleroValues.length - windowSize).map(convertSensorValueToDouble).toList();

    List<double> gyroZ = gyroWindow.map((e) => e[2]).toList();
    List<double> gyroY = gyroWindow.map((e) => e[1]).toList();
    List<double> gyroX = gyroWindow.map((e) => e[0]).toList();

    List<double> acceleroX = acceleroWindow.map((e) => e[0]).toList();
    List<double> acceleroY = acceleroWindow.map((e) => e[1]).toList();

    double meanGyroZ = Math.mean(gyroZ);
    double meanGyroY = Math.mean(gyroY);
    double stdDeviationGyroZ = Math.stdDeviation(gyroZ, meanGyroZ);
    double stdDeviationGyroY = Math.stdDeviation(gyroY, meanGyroY);
    double covariance = Math.sum(List.generate(gyroZ.length, (i) => (gyroZ[i] - meanGyroZ) * (gyroY[i] - meanGyroY))) / gyroZ.length;
    double correlationGyroZY = covariance / (stdDeviationGyroZ * stdDeviationGyroY);

    double meanAcceleroX = Math.mean(acceleroX);
    double meanAcceleroY = Math.mean(acceleroY);
    double stdDeviationAcceleroX = Math.stdDeviation(acceleroX, meanAcceleroX);
    double stdDeviationAcceleroY = Math.stdDeviation(acceleroY, meanAcceleroY);
    double covarianceAccelero = Math.sum(List.generate(acceleroX.length, (i) => (acceleroX[i] - meanAcceleroX) * (acceleroY[i] - meanAcceleroY))) / acceleroX.length;
    double correlationAcceleroXY = covarianceAccelero / (stdDeviationAcceleroX * stdDeviationAcceleroY);

    double sma = Math.maxAbs(gyroZ) + Math.maxAbs(gyroY) + Math.maxAbs(gyroX);

    double old = gyroZ[0];
    bool zeroCrossingDetected = false;
    double crossingValue = -9999.0;

    int index = 0;
    int zeroCrossingTimeStamp = 0;
    double zeroCrossingValue = 0.0;
    bool tinyCrossing = false;

    
    for(double val in gyroZ){

      if(old >= 0.0 && val < 0.0){
        
        zeroCrossingDetected = true;
        crossingValue = val;

        SensorValue currentSensorValue = gyroValues[gyroValues.length - windowSize + index];
        if(gyroValues.length - windowSize + index - 20 >= 0){
          SensorValue somePreviousSensorValue = gyroValues[gyroValues.length - windowSize + index - 20];
          double valuePrevious = double.tryParse(somePreviousSensorValue.valueStrings[2]) ?? 0.0;
          
          tinyCrossing = valuePrevious < 20.0;
        }
        
        zeroCrossingTimeStamp= currentSensorValue.timestamp;
        zeroCrossingValue = double.tryParse(currentSensorValue.valueStrings[2]) ?? 0.0;

        if(zeroCrossingTimeStamp == lastMotionTimeStamp || tinyCrossing){
          return false;
        }

        lastMotionTimeStamp = zeroCrossingTimeStamp;
        break;
        
      }

      index++;
      old = val;  
    }

    if((correlationGyroZY > 0.7 && correlationAcceleroXY < -0.1) && (sma > 70.0 && zeroCrossingDetected)){

      counterMotion++;

      String debugMsg = "";
      print("########## New Motion Detected ##########\n");

      int internalCounter = 0;
      for(double val in gyroZ){
        internalCounter++;
        print("$internalCounter: $val");
        
      }

      String featuresDebug = "";

      featuresDebug += "Motion detected: true\n";
      featuresDebug += "Correlation Gyro ZY: $correlationGyroZY\n";
      featuresDebug += "Correlation Accelero XY: $correlationAcceleroXY\n";
      featuresDebug += "SMA: $sma\n";
      featuresDebug += "Zero crossing detected: $zeroCrossingDetected\n";
      featuresDebug += "Crossing value: $crossingValue\n";
      featuresDebug += "Zero crossing value: $zeroCrossingValue\n";
      featuresDebug += "Zero crossing timestamp: $zeroCrossingTimeStamp\n";
      featuresDebug += "Motion count: $counterMotion\n";
      featuresDebug += "#########################################\n";
      print(debugMsg);
      print(featuresDebug);

      motionUpdatable.update(lastMotionTimeStamp);
      
      
      
      
      //print("Significant motion detected with correlation: $correlationGyroZY, $correlationAcceleroXY , SMA: $sma, Zero crossing: $zeroCrossingDetected");
      return true;

    }else{

      String debugMsg = "";

      //print("########## No Significant Motion ##########\n");
      int internalCounter = 0;
      for(double val in gyroZ){
        internalCounter++;
        //print("$internalCounter: $val");
      }
      String featuresDebug = "";
      featuresDebug += "Motion detected: false\n";
      featuresDebug += "Buffer length: ${gyroValues.length}\n";
      featuresDebug += "Window buffer: ${gyroWindow.length}\n";
      featuresDebug += "gyroZ length: ${gyroZ.length}\n";
      featuresDebug += "Internal counter: $internalCounter\n";
      featuresDebug += "Correlation Gyro ZY: $correlationGyroZY\n";
      featuresDebug += "Correlation Accelero XY: $correlationAcceleroXY\n";
      featuresDebug += "SMA: $sma\n";
      featuresDebug += "Zero crossing detected: $zeroCrossingDetected\n";
      featuresDebug += "#########################################\n";
      //print(debugMsg);
      //print(featuresDebug);

      //print("No significant motion detected. Correlation: $correlationGyroZY and $correlationAcceleroXY, SMA: $sma, Zero crossing: $zeroCrossingDetected");
    }

    return false;

  }

  List<double> convertSensorValueToDouble(SensorValue sensorValues){

    List<double> doubleValues = sensorValues.valueStrings.map((e) => double.tryParse(e) ?? 0.0).toList();
    return doubleValues;
  }

  void keepWindowSize(List<SensorValue> list, int windowSize, double overLap){

    int bufferLength = list.length;
    int overlappingElements = (windowSize * overLap).toInt();
    int remainingLength = windowSize - overlappingElements;

    if(bufferLength == windowSize){

      list.removeRange(0, remainingLength);

    }
    
  }

  


  

}
