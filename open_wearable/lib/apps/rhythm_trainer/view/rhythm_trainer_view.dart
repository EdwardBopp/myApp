
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
  

  @override
  void initState() {    
    super.initState();
    acceleroMeter = widget.acceleroMeter;
    gyroscope = widget.gyroscope;
    sensorDataStream = widget.sensorDataStream;
  }


  @override
  Widget build(BuildContext context) {

    return ListView(
      children: [
        StreamBuilder(
          stream: sensorDataStream,
          builder: (context, snapshot) {
                
            if(snapshot.hasData) {

              sensorValuesAccelero.add(snapshot.data![0]);
              sensorValuesGyro.add(snapshot.data![1]);
              detectMotion(sensorValuesGyro, sensorValuesAccelero, 12, 0.0);
              return Column(children: buildSensorValueTiles(sensorValuesAccelero, sensorValuesGyro));
            }else {

              return PlatformText("Waiting for sensor data...");
            }
            
          },),
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

  List<PlatformListTile> buildSensorValueTiles(List<SensorValue> acceleroData, List<SensorValue> gyroData) {

    final List<PlatformListTile> tiles = [];   
    List<double> acceleroMeterData = acceleroData.last.valueStrings.map((e) => double.tryParse(e) ?? 0.0).toList();
    List<double> gyroscopeData = gyroData.last.valueStrings.map((e) => double.tryParse(e) ?? 0.0).toList();

    tiles.add(
      PlatformListTile(
        title: Text("Accelerometer"),
        subtitle: Text(acceleroData.last.valueStrings.join(", ")),
      ),
    );
    tiles.add(
      PlatformListTile(
        title: Text("Gyroscope"),
        subtitle: Text(gyroData.last.valueStrings.join(", ")),
      ),
    );

    if (gyroscopeData[2] > 40.0 && acceleroMeterData[1] > -0.65 && acceleroMeterData[0] < -0.75){
      tiles.add(
        PlatformListTile(
          title: Text("Rhythm Alert"),
          subtitle: Text("High rotation detected!"),
        ),
      );
    }

    return tiles;
    
  }

  void setConfigForSensor(Sensor sensor) {

    SensorConfiguration config = sensor.relatedConfigurations.first;
      if (config is ConfigurableSensorConfiguration) {
        List<ConfigurableSensorConfigurationValue> values = config.values;
        if (config.availableOptions.any((o) => o is StreamSensorConfigOption)) {
          ConfigurableSensorConfigurationValue streamValue =
            values.firstWhere((v) => v.options.any((o) => o is StreamSensorConfigOption));

          config.setConfiguration(streamValue);
        }
      }
  }

  bool detectWindow(List<SensorValue> gyroValues, List<SensorValue> acceleroValues, int windowSize, double overLap){

    if(overLap < 0 || overLap >= 1){
      throw ArgumentError("overLap must be between 0 and 1");
    }

    int currentLength = gyroValues.length;

    if(currentLength < windowSize){
      return false;
    }

    int overlappingElements = (windowSize * overLap).toInt();
    return (currentLength + overlappingElements) % windowSize == 0;

  }

  void detectMotion(List<SensorValue> gyroValues, List<SensorValue> acceleroValues, int windowSize, double overLap){

    if (!detectWindow(gyroValues, acceleroValues, windowSize, overLap)) {

      //print("No window detected");
      return;
    }

    //print("Window detected");

    List<List<double>> gyroWindow = gyroValues.sublist(gyroValues.length - windowSize).map(convertSensorValueToDouble).toList();
    List<List<double>> acceleroWindow = acceleroValues.sublist(acceleroValues.length - windowSize).map(convertSensorValueToDouble).toList();

    List<double> gyroZ = gyroWindow.map((e) => e[2]).toList();
    List<double> gyroY = gyroWindow.map((e) => e[1]).toList();
    List<double> gyroX = gyroWindow.map((e) => e[0]).toList();

    List<double> acceleroX = acceleroWindow.map((e) => e[0]).toList();
    List<double> acceleroY = acceleroWindow.map((e) => e[1]).toList();

    double meanGyroZ = mean(gyroZ);
    double meanGyroY = mean(gyroY);
    double varianceGyroZ = variance(gyroZ, meanGyroZ);
    double varianceGyroY = variance(gyroY, meanGyroY);
    double covariance = sum(List.generate(gyroZ.length, (i) => (gyroZ[i] - meanGyroZ) * (gyroY[i] - meanGyroY))) / gyroZ.length;
    double correlationGyroZY = covariance / (varianceGyroZ * varianceGyroY);

    double meanAcceleroX = mean(acceleroX);
    double meanAcceleroY = mean(acceleroY);
    double varianceAcceleroX = variance(acceleroX, meanAcceleroX);
    double varianceAcceleroY = variance(acceleroY, meanAcceleroY);
    double covarianceAccelero = sum(List.generate(acceleroX.length, (i) => (acceleroX[i] - meanAcceleroX) * (acceleroY[i] - meanAcceleroY))) / acceleroX.length;
    double correlationAcceleroXY = covarianceAccelero / (varianceAcceleroX * varianceAcceleroY);

    double sma = maxAbs(gyroZ) + maxAbs(gyroY) + maxAbs(gyroX);


    print("Correlation between gyro Z and Y: $correlationGyroZY");
    print("Correlation between accelero X and Y: $correlationAcceleroXY");

    
    if(correlationGyroZY > 0.7 && correlationAcceleroXY < -0.7 && sma > 50.0){
      print("Significant motion detected with correlation: $correlationGyroZY and $correlationAcceleroXY");
    }

  }

  List<double> convertSensorValueToDouble(SensorValue sensorValues){

    List<double> doubleValues = sensorValues.valueStrings.map((e) => double.tryParse(e) ?? 0.0).toList();
    return doubleValues;
  }

  double sum(List<double> vals){

    return vals.fold(0.0, (a, b) => a + b);

  }

  double max(List<double> vals){

    return vals.fold(0.0, (a, b) => a > b ? a : b);

  }

  double variance(List<double> vals, double mean){

    return sqrt(sum(vals.map((e) => (e - mean) * (e - mean)).toList()) / vals.length);

  }

  double mean(List<double> vals){

    return sum(vals) / vals.length;

  }

  double maxAbs(List<double> vals){

    return vals.fold(0.0, (a, b) => a.abs() > b.abs() ? a : b).abs();

  }


 

}
