
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:open_earable_flutter/open_earable_flutter.dart';
import 'package:open_wearable/apps/rhythm_trainer/controller/bpm_calculator_controller.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/bpmCalculator.dart';
import 'package:open_wearable/apps/rhythm_trainer/view/start_restart_button.dart';


class BpmCalculatorView extends StatefulWidget {

  final Stream<List<SensorValue>> sensorDataStream;
  final BPMcalculator bpmCalculator;
  const BpmCalculatorView({super.key, required this.sensorDataStream, required this.bpmCalculator});

  @override
  State<BpmCalculatorView> createState() => _BpmCalculatorViewState();
}

class _BpmCalculatorViewState extends State<BpmCalculatorView> {

  late BPMCalculatorController bpmCalculatorController;
  bool motionDetected = false;
  
  
  @override
  void initState() {   

    super.initState();
   
    bpmCalculatorController = BPMCalculatorController(
      sensorDataStream: widget.sensorDataStream,
      bpmCalc: widget.bpmCalculator,
    );

    print("New Init State");
  }

  @override
  void didUpdateWidget(covariant BpmCalculatorView oldWidget) {
    
    super.didUpdateWidget(oldWidget);
    bpmCalculatorController.updateStream(widget.sensorDataStream);
  }

  @override
  void dispose() {

    bpmCalculatorController.reset();
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

                bpmCalculatorController.reset();
                motionDetected = false;
              
              });         
            },

            onStart: () {

              bpmCalculatorController.start();
            },
          ),

          AnimatedBuilder(
            animation: bpmCalculatorController,
            
            builder: (_, __){

              bool calculating = bpmCalculatorController.isCalculating();

              if(calculating){

                return PlatformText("Calculating BPM...");

              } else {

                int bpm = widget.bpmCalculator.getBPM();
                bpmCalculatorController.reset();
                return PlatformText("Calculated BPM: $bpm");   
              }
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
