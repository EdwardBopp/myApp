import 'package:open_wearable/apps/rhythm_trainer/model/motion_updatable.dart';

class BPMcalculator implements MotionUpdatable {

    final List<int> motionTimestamps = [];
    bool isCalculating = true;
    late double bpm;
    double _timeStampDiffFactor = 1.0;

    @override
    void update(int timeStampLastMotion) {

      motionTimestamps.add(timeStampLastMotion);

      int length = motionTimestamps.length;

      if(length != 4) return;

      double sum = 0;

      for(int i = 1; i < length; i++){

      print("Time diff $i: ${(motionTimestamps[i] - motionTimestamps[i - 1]).toDouble() / 1000.0 / _timeStampDiffFactor!} s"); 

      sum += ((motionTimestamps[i] - motionTimestamps[i - 1]) / _timeStampDiffFactor! / 1000);

      }

      print(sum);

      double avgTimeDiff = sum / (length - 1); 
      bpm = (60.0 / avgTimeDiff); 
      print("Estimated BPM: $bpm");
      isCalculating = false;
      motionTimestamps.clear();
    }

  double getBPM(){

    return bpm;
  }

  void setDiffFactor(double factor){

    if(_timeStampDiffFactor != 1.0) return;
    _timeStampDiffFactor = factor;
  }
  
}
