import 'package:open_wearable/apps/rhythm_trainer/model/motion_updatable.dart';

class BPMcalculator implements MotionUpdatable {

    final List<int> motionTimestamps = [];
    bool isCalculating = true;
    late int bpm;

    @override
    void update(int timeStampLastMotion) {

        motionTimestamps.add(timeStampLastMotion);

        int length = motionTimestamps.length;

        if(length != 4) return;

        int sum = 0;

        for(int i = 1; i < length; i++){

        print("Time diff $i: ${(motionTimestamps[i] - motionTimestamps[i - 1]).toDouble() / 1000.0 / 2.0} s");

        sum += (motionTimestamps[i] - motionTimestamps[i - 1]);

        }

        double avgTimeDiff = sum / (length - 1) / 1000.0; 
        bpm = (60.0 / avgTimeDiff).toInt() * 2; // For some reason we need to multiply by 2 to get the correct BPM
        print("Estimated BPM: $bpm");
        isCalculating = false;
        motionTimestamps.clear();
    }

  int getBPM(){

    return bpm;
  }
  
}
