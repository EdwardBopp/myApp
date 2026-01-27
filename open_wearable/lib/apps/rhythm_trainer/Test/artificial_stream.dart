import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:open_earable_flutter/open_earable_flutter.dart';

class ArtificialStream {

  StreamController<List<SensorValue>>? _controller;
  int index = 0;

  List<SensorValue> getSensorValues(String filepath) {

    File artificialDataFile = File(filepath);
    List<String> lines = artificialDataFile.readAsLinesSync();
    lines.removeAt(0);

    List<String> values;
    List<SensorValue> sensorValues = [];

    for(String line in lines){
      
      values = line.split(',');
      sensorValues.add(SensorDoubleValue(
        timestamp: int.parse(values[0]),
        values: [
          double.parse(values[1]),
          double.parse(values[2]),
          double.parse(values[3]),
        ],
      ),);
    }

    return sensorValues;

  }


  List<SensorValue> helper(List<String> lines){

    List<String> values;
    List<SensorValue> sensorValues = [];

    for(String line in lines){

      values = line.split(',');
      if(values.isEmpty) continue;

      try{
      sensorValues.add(SensorDoubleValue(
        timestamp: int.parse(values[0]),
        values: [
          double.parse(values[1]),
          double.parse(values[2]),
          double.parse(values[3]),
        ],
      ),);} catch(e){
        print("Error parsing line: $line");
        print(values);        
      }
    }

    return sensorValues;
  }


    Future<void> startArtificialStream({required String acceleroPath, required String gyroPath}) async {

      await rootBundle.loadString(acceleroPath, cache: false).then((acceleroValue) async {

        await rootBundle.loadString(gyroPath, cache: false).then((gyroValue) {

          List<String> acceleroLines = acceleroValue.trim().split('\n');
          acceleroLines.removeAt(0);
          List<String> gyroLines = gyroValue.trim().split('\n');
          gyroLines.removeAt(0);

          List<SensorValue> acceleroValues = helper(acceleroLines);
          List<SensorValue> gyroValues = helper(gyroLines);

          _controller = StreamController<List<SensorValue>>();
  
          Timer.periodic(Duration(milliseconds: 10), (timer) {

            if(index < gyroValues.length && index < acceleroValues.length){
              _controller!.add([acceleroValues[index], gyroValues[index]]);
              //print("Gyro: ${gyroValues[index].valueStrings[0]}, Accelero: ${acceleroValues[index].valueStrings[0]}");

            }else {
              
              timer.cancel();
              _controller!.close();
            }
            
            index++;
          });
        });
      }
    );

  }


  void startArtificialStreamTest({required String acceleroPath, required String gyroPath}) {

    List<SensorValue> gyroValues = getSensorValues(gyroPath);
    List<SensorValue> acceleroValues = getSensorValues(acceleroPath);
    
    _controller = StreamController<List<SensorValue>>();
    
    Timer.periodic(Duration(milliseconds: 10), (timer) {

      print("Timer running, index: $index");

      if(index < gyroValues.length && index < acceleroValues.length){
        _controller!.add([acceleroValues[index], gyroValues[index]]);
        print("Gyro: ${gyroValues[index].valueStrings[0]}, Accelero: ${acceleroValues[index].valueStrings[0]}");

      }else {
        
        timer.cancel();
        _controller!.close();
      }
      
      index++;
    });
  }

  StreamController<List<SensorValue>>? get controller => _controller;
}
