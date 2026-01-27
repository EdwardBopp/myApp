
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:open_earable_flutter/open_earable_flutter.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/bpm_calculator.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/exercise.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/musical_symbol.dart';
import 'package:open_wearable/apps/rhythm_trainer/view/bpm_calculator_view.dart';
import 'package:open_wearable/apps/rhythm_trainer/view/excersise_view.dart';
import 'package:open_wearable/view_models/sensor_configuration_provider.dart';
import 'package:provider/provider.dart';



class RhythmTrainerView extends StatefulWidget {

  //final Wearable wearable;

  const RhythmTrainerView({
    super.key, 
    //required this.wearable,
  });

  @override
  State<RhythmTrainerView> createState() => _RhythmTrainerViewState();

}


class _RhythmTrainerViewState extends State<RhythmTrainerView> {

  /*late final Wearable wearable;
  late final Sensor acceleroMeter;
  late final Sensor gyroscope;*/
  Stream<List<SensorValue>>? sensorDataStream;

  @override
  void initState() {

    super.initState();
    sensorDataStream = Stream<List<SensorValue>>.periodic(
      Duration(milliseconds: 1000), 
      (count) {

        List<SensorValue> sensorTuple = [SensorDoubleValue(timestamp: count, values: [1.0, 1.0, 1.0]),
                                        SensorDoubleValue(timestamp: count, values: [1.0, 1.0, 1.0]), 
                                        ];

        
        return sensorTuple;

      },
    ).asBroadcastStream();
  


    /*wearable = widget.wearable;
    
    if(wearable is SensorManager) {
    
      acceleroMeter = (wearable as SensorManager).sensors.first;
      gyroscope = (wearable as SensorManager).sensors[1];

      
      WidgetsBinding.instance.addPostFrameCallback((_) {

        setConfig(acceleroMeter);
        setConfig(gyroscope);   
        
      });

      Timer(Duration(seconds: 1), () {

        setState(() {
          
          sensorDataStream = Rx.combineLatest2(acceleroMeter.sensorStream, gyroscope.sensorStream, (a, b) {

            List<SensorValue> sensorTuple = List<SensorValue>.filled(2, SensorValue(valueStrings: [], timestamp: 0));
            sensorTuple[0] = a;
            sensorTuple[1] = b;
            return sensorTuple;

          }).asBroadcastStream();

          StreamSubscription? sub = sensorDataStream?.listen((event) {
            
          },);

          sub?.cancel();

        });        
      });
 
    }*/

  }

  @override
  Widget build(BuildContext context) {

    print("Building Rhythm Trainer View");


    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: PlatformText("Rhythm Trainer"),
      ),
      body: //(wearable is SensorManager)
          //? 
          PlatformTabScaffold(

            tabController: PlatformTabController(initialIndex: 0),

            bodyBuilder: (context, index) {
   
              switch(index) {

                case 1:
                  return Center(
                    
                    child:  BpmCalculatorView(
                      
                      sensorDataStream: sensorDataStream!,                    
                      bpmCalculator: BPMcalculator(),
                    ),
                  );

                default: 

                  return ListView(
                      children: [

                        Card(

                          color: Colors.white,
                          elevation: 1,

                          child: PlatformListTile(
                            title: PlatformText("Exercise 1"),
                            onTap: () {

                              Navigator.push(
                                
                                context,
                                platformPageRoute(
                                  context: context,
                                  builder: (context) {

                                    return PlatformScaffold(

                                      appBar: PlatformAppBar(
                                        title: PlatformText("Exercise 1"),
                                      ),
                                      body: ExerciseView(

                                        sensorDataStream: sensorDataStream!,                               
                                        exercise: Exercise(
                                          rhythmPattern: [MusicalSymbol.restQuarter, MusicalSymbol.quarterNote, MusicalSymbol.quarterNote, MusicalSymbol.quarterNote], 
                                          name: "Exercise 1",),
                                      ),
                                    );                   
                                  },
                                ),       
                              );
                            },
                          ),
                
                        ),

                        
                        PlatformListTile(
                          title: PlatformText("Exercise 2"),
                          onTap: () {

                            Navigator.push(
                              
                              context,
                              platformPageRoute(
                                context: context,
                                builder: (context) {

                                  return PlatformScaffold(

                                    appBar: PlatformAppBar(
                                      title: PlatformText("Exercise 2"),
                                    ),
                                    body: ExerciseView(
                                      
                                      sensorDataStream: sensorDataStream!,
                                      exercise: Exercise(
                                        rhythmPattern: [MusicalSymbol.restEighth, MusicalSymbol.eighthNote, MusicalSymbol.quarterNote, MusicalSymbol.quarterNote, MusicalSymbol.quarterNote], 
                                        name: "Exercise 2",
                                        ),
                                      ),
                                    );                   
                                },
                              ),       
                            );
                          },
                        ),
                      ],
                    );
                
              }
            },
            items: [

              BottomNavigationBarItem(
                icon: Icon(Icons.music_note),
                label: "Rhythm",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.speed),
                label: "BPM",
              ),


            ],


          ), 
               
          /*: Center(
              child: PlatformText("No eSense device connected"),
            ),*/
    );
  }

  


  void setConfig(Sensor sensor){

    SensorConfigurationProvider configProvider = Provider.of<SensorConfigurationProvider>(context, listen: false);
    SensorConfiguration configuration = sensor.relatedConfigurations.first;
    late ConfigurableSensorConfigurationValue streamValue;

    if (configuration is ConfigurableSensorConfiguration &&
      configuration.availableOptions.contains(StreamSensorConfigOption())) {
    configProvider.addSensorConfigurationOption(configuration, StreamSensorConfigOption());
    }

    List<SensorConfigurationValue> values = configProvider.getSensorConfigurationValues(configuration, distinct: true);

    for(var val in values){

      if(val is ConfigurableSensorConfigurationValue){

        print("normal value: ${val.toString()}");

        if(val.options.any((o) => o is StreamSensorConfigOption) && val.toString().contains("100.0")){
          print("selected value: ${val.toString()}");
          streamValue = val;
        }

      }
    }  

    configProvider.addSensorConfiguration(configuration, streamValue);

    SensorConfigurationValue selectedValue = configProvider.getSelectedConfigurationValue(configuration)!;
    configuration.setConfiguration(selectedValue);
   


  }

  


  
}
