import 'package:open_earable_flutter/open_earable_flutter.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/exercise.dart';
import 'package:open_wearable/apps/rhythm_trainer/controller/motion_controller.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/pipeline/feature_extractors/statistical_feature_extractor.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/pipeline/feature_extractors/zero_crossing_extractor.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/pipeline/motion_Pipeline.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/pipeline/motion_detectors/nod_motion_detector.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/pipeline/window_Manager.dart';

class ExerciseController {


  Exercise _exercise;
  Exercise get exercise => _exercise;
  final MotionController _motionController;

  ExerciseController({required Exercise exercise, required Stream<List<SensorValue>> sensorDataStream})
      : _exercise = exercise,
        _motionController = MotionController(
          sensorDataStream: sensorDataStream,
          motionPipeline: MotionPipeline(
            windowManagers: [
              WindowManager(windowSize: 60, overlap: 0.5),
              WindowManager(windowSize: 60, overlap: 0.5),
            ],
            featureExtractors: [
              [StatisticalFeatureExtractor()],
              [StatisticalFeatureExtractor(), ZeroCrossingExtractor()],
            ],
            motionDetector: NodMotionDetector(),
          ),
        );

    

  void start(){

    _motionController.subscribeMotionData((event, motion) {
      _exercise.setFirstTimestamp(event[0].timestamp);
      
      if(motion != -1){

        _exercise.update(motion);
      }
    });
  }

  void reset(){

    _exercise = Exercise(
      rhythmPattern: _exercise.rhythmPattern, 
      name: _exercise.name, 
      countIn: _exercise.countIn,
    );

    _motionController.resetPipeline();
    _motionController.cancelSubscription();

  }

  void updateStream(Stream<List<SensorValue>> newStream){

    _motionController.updateStream(newStream);
  }

  bool isExerciseCompleted(){

    return _exercise.exerciseFinished;
  }
}
