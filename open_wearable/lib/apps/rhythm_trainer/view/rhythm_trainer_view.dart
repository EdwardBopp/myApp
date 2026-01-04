
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:open_earable_flutter/open_earable_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:math';


class RhythmTrainerView extends StatelessWidget {

  final Wearable wearable;

  const RhythmTrainerView({
    super.key, 
    required this.wearable,
  });




  @override
  Widget build(BuildContext context) {

    late final Sensor acceleroMeter;
    late final Sensor gyroscope;
    late final Stream<List<SensorValue>> sensorDataStream;

    if(wearable is SensorManager) {
    
      acceleroMeter = (wearable as SensorManager).sensors.first;
      gyroscope = (wearable as SensorManager).sensors[1];
      sensorDataStream = Rx.combineLatest2(acceleroMeter.sensorStream, gyroscope.sensorStream, (a, b) {

        List<SensorValue> sensorTuple = List<SensorValue>.filled(2, SensorValue(valueStrings: [], timestamp: 0));
        sensorTuple[0] = a;
        sensorTuple[1] = b;
        return sensorTuple;

      });
          
    }

    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: PlatformText("Rhythm Trainer"),
      ),
      body: (wearable is SensorManager)
          ? SensorValueView(
              acceleroMeter: acceleroMeter,
              gyroscope: gyroscope,
              sensorDataStream: sensorDataStream,
            )
          : Center(
              child: PlatformText("No eSense device connected"),
            ),
    );
  }
}

class SensorValueView extends StatefulWidget {

  final Sensor acceleroMeter;
  final Sensor gyroscope;
  final Stream<List<SensorValue>> sensorDataStream;
  const SensorValueView({super.key, required this.acceleroMeter, required this.gyroscope, required this.sensorDataStream});

  @override
  State<SensorValueView> createState() => _SensorValueViewState();
}

class _SensorValueViewState extends State<SensorValueView> {

  late final Sensor acceleroMeter;
  late final Sensor gyroscope;
  late final Stream<List<SensorValue>> sensorDataStream;
  List<SensorValue> sensorValuesAccelero = [];
  List<SensorValue> sensorValuesGyro = [];
  late StreamSubscription<List<SensorValue>> sub;
  bool motionDetected = false;
  int timeStampLastZeroCrossing = 0;
  int counterMotion = 0;
  List<int> motionTimestamps = [];
  

  @override
  void initState() {    
    super.initState();
    acceleroMeter = widget.acceleroMeter;
    gyroscope = widget.gyroscope;
    sensorDataStream = widget.sensorDataStream;
    setConfigForSensor(acceleroMeter);
    setConfigForSensor(gyroscope);
    int windowSize = 60;
  
    sub = sensorDataStream.listen((event) {
  
      sensorValuesAccelero.add(event[0]);
      sensorValuesGyro.add(event[1]);
      

      if(sensorValuesGyro.isNotEmpty && sensorValuesGyro.length == windowSize){
        int timeDifference = sensorValuesGyro.last.timestamp - sensorValuesGyro.first.timestamp;
        //print("Time for 60 gyro samples: ${timeDifference} s");
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
    keepWindowSize(sensorValuesGyro, windowSize, 0.5);    
  });


    print("New Init State");
  }

  @override
  void dispose() {
    
    super.dispose();
    sub.cancel();
    print("Disposed Sensor Value View");
  }


  @override
  Widget build(BuildContext context) {

    return ListView(
      children: [
        test(),
        PlatformElevatedButton(
          child: PlatformText("Start Streaming"),
          onPressed: () {

            setConfigForSensor(acceleroMeter);
            setConfigForSensor(gyroscope);
          },
        ),
      ],
    );
  }

  Widget test(){

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

  
  void setConfigForSensor(Sensor sensor) {

    SensorConfiguration config = sensor.relatedConfigurations.first;
      if (config is ConfigurableSensorConfiguration) {
        List<ConfigurableSensorConfigurationValue> values = config.values;

        if (config.availableOptions.any((o) => o is StreamSensorConfigOption)) {  

          late ConfigurableSensorConfigurationValue streamValue;
             
          for(var val in values){

            print("normal value: ${val.toString()}");

            if(val.options.any((o) => o is StreamSensorConfigOption) && val.toString().contains("100.0")){
              print("selected value: ${val.toString()}");
              streamValue = val;
            }
          }      
          config.setConfiguration(streamValue);  
                   
        }   
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

    double meanGyroZ = mean(gyroZ);
    double meanGyroY = mean(gyroY);
    double stdDeviationGyroZ = stdDeviation(gyroZ, meanGyroZ);
    double stdDeviationGyroY = stdDeviation(gyroY, meanGyroY);
    double covariance = sum(List.generate(gyroZ.length, (i) => (gyroZ[i] - meanGyroZ) * (gyroY[i] - meanGyroY))) / gyroZ.length;
    double correlationGyroZY = covariance / (stdDeviationGyroZ * stdDeviationGyroY);

    double meanAcceleroX = mean(acceleroX);
    double meanAcceleroY = mean(acceleroY);
    double stdDeviationAcceleroX = stdDeviation(acceleroX, meanAcceleroX);
    double stdDeviationAcceleroY = stdDeviation(acceleroY, meanAcceleroY);
    double covarianceAccelero = sum(List.generate(acceleroX.length, (i) => (acceleroX[i] - meanAcceleroX) * (acceleroY[i] - meanAcceleroY))) / acceleroX.length;
    double correlationAcceleroXY = covarianceAccelero / (stdDeviationAcceleroX * stdDeviationAcceleroY);

    double sma = maxAbs(gyroZ) + maxAbs(gyroY) + maxAbs(gyroX);

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

        if(zeroCrossingTimeStamp == timeStampLastZeroCrossing || tinyCrossing){
          return false;
        }

        timeStampLastZeroCrossing = zeroCrossingTimeStamp;
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

      motionTimestamps.add(zeroCrossingTimeStamp);
      checkRhythm(motionTimestamps, [1.0, 0.5, 0.5, 1, 0.5]);
      //bpmCalculation();

      //if(motionTimestamps.length == 4) resetTimeStamps();
      
      
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

  double sum(List<double> vals){

    return vals.fold(0.0, (a, b) => a + b);

  }

  
  double stdDeviation(List<double> vals, double mean){

    return sqrt(sum(vals.map((e) => (e - mean) * (e - mean)).toList()) / vals.length);

  }

  double mean(List<double> vals){

    return sum(vals) / vals.length;

  }

  double maxAbs(List<double> vals){

    return vals.fold(0.0, (a, b) => a.abs() > b.abs() ? a : b).abs();

  }

  void bpmCalculation(){

    int length = motionTimestamps.length;

    if(length != 4) return;

    int sum = 0;

    for(int i = 1; i < length; i++){

      print("Time diff $i: ${(motionTimestamps[i] - motionTimestamps[i - 1]).toDouble() / 1000.0} s");

      sum += (motionTimestamps[i] - motionTimestamps[i - 1]);

    }

    double avgTimeDiff = sum / (length - 1) / 1000.0; 
    int bpm = (60.0 / avgTimeDiff).toInt() * 2; // For some reason we need to multiply by 2 to get the correct BPM
    print("Estimated BPM: $bpm");
    
  }

  void resetTimeStamps(){

    motionTimestamps = [];
  }

  void keepWindowSize(List<SensorValue> list, int windowSize, double overLap){

    int bufferLength = list.length;
    int overlappingElements = (windowSize * overLap).toInt();
    int remainingLength = windowSize - overlappingElements;

    if(bufferLength == windowSize){

      list.removeRange(0, remainingLength);

    }
    
  }

  void checkRhythm(List<int> motionTimestamps, List<double> timeStampsExpectedDifferences){

    if(timeStampsExpectedDifferences.length + 1 != motionTimestamps.length) return;

    for(int i = 1; i < motionTimestamps.length; i++){

      double timeDiff = (motionTimestamps[i] - motionTimestamps[i - 1]) / 1000 / 2.0;
      print("Time diff $i: $timeDiff s");
      print("Expected time diff $i: ${timeStampsExpectedDifferences[i - 1]} s");

      if((timeDiff - timeStampsExpectedDifferences[i - 1]).abs() > 0.2){

        print("Rhythm off at interval $i");

      } else {

        print("Rhythm on at interval $i");
      }
    }

    motionTimestamps.clear();
  }

}
