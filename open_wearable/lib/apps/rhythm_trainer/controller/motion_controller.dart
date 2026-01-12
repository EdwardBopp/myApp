import 'dart:async';

import 'package:open_earable_flutter/open_earable_flutter.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/pipeline/feature_extractors/zero_crossing_extractor.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/pipeline/motion_Pipeline.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/pipeline/motion_detectors/nod_motion_detector.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/pipeline/window_Manager.dart';

import '../model/pipeline/feature_extractors/statistical_feature_extractor.dart';

class MotionController {

  Stream<List<SensorValue>> _sensorDataStream;
  MotionPipeline _motionPipeline;

  MotionController({required Stream<List<SensorValue>> sensorDataStream, required MotionPipeline motionPipeline})
      : _sensorDataStream = sensorDataStream,
        _motionPipeline = motionPipeline;

  StreamSubscription<List<SensorValue>>? sub;


  void subscribeMotionData(void Function(List<SensorValue>, int) listenFunc){

    sub = _sensorDataStream.listen((event) {

      int timeStampLastMotion = _motionPipeline.processData(event);
      listenFunc(event, timeStampLastMotion);

    });

  }

  void resetPipeline(){

    _motionPipeline = MotionPipeline(
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

  }

  void cancelSubscription(){

    sub?.cancel();
  }

  void updateStream(Stream<List<SensorValue>> newStream){

    if(newStream == _sensorDataStream) return;
    _sensorDataStream = newStream;

  }

}
