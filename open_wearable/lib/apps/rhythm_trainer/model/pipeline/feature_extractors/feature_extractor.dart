import 'package:open_earable_flutter/open_earable_flutter.dart';

abstract class FeatureExtractor {
  Map<String, double> extractFeatures(List<SensorValue> window);
}
