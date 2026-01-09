import 'package:open_wearable/apps/rhythm_trainer/model/motion_updatable.dart';


class Exercise implements MotionUpdatable {

  final List<double> rhythmPattern;
  final String name;
  List<int> motionTimestamps = [];

  Exercise({required this.rhythmPattern, required this.name});

  @override
  void update(int timeStampLastMotion) {

    motionTimestamps.add(timeStampLastMotion);

    int length = motionTimestamps.length;

    if(rhythmPattern.length + 1 != length) return;

    for(int i = 1; i < length; i++){

      double timeDiff = (motionTimestamps[i] - motionTimestamps[i - 1]) / 1000 / 2.0;
      print("Time diff $i: $timeDiff s");
      print("Expected time diff $i: ${rhythmPattern[i - 1]} s");

      if((timeDiff - rhythmPattern[i - 1]).abs() > 0.2){

        print("Rhythm off at interval $i");

      } else {

        print("Rhythm on at interval $i");
      }
    }

    motionTimestamps.clear();
    
  }


}
