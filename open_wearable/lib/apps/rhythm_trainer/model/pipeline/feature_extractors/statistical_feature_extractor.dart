import 'package:open_wearable/apps/rhythm_trainer/model/pipeline/feature_extractors/feature_extractor.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/libs/math.dart';
import 'package:open_earable_flutter/open_earable_flutter.dart';

class StatisticalFeatureExtractor implements FeatureExtractor {

  @override
  Map<String, double> extractFeatures(List<SensorValue> window) {

    
    List<List<double>> data = window.map(convertSensorValueToDouble).toList();
    List<double> xAxis = data.map((e) => e[0]).toList();
    List<double> yAxis = data.map((e) => e[1]).toList();
    List<double> zAxis = data.map((e) => e[2]).toList();

    Map<String, double> features = {};

    features["mean_x"] = Math.mean(xAxis);
    features["mean_y"] = Math.mean(yAxis);
    features["mean_z"] = Math.mean(zAxis);
    features["std_x"] = Math.stdDeviation(xAxis, features["mean_x"]!);
    features["std_y"] = Math.stdDeviation(yAxis, features["mean_y"]!);
    features["std_z"] = Math.stdDeviation(zAxis, features["mean_z"]!);
    features["cov_xy"] = Math.covariance(xAxis, yAxis);
    features["cov_xz"] = Math.covariance(xAxis, zAxis);
    features["cov_yz"] = Math.covariance(yAxis, zAxis);
    features["corr_xy"] = Math.correlation(xAxis, yAxis);
    features["corr_xz"] = Math.correlation(xAxis, zAxis);
    features["corr_yz"] = Math.correlation(yAxis, zAxis);
    features["sma"] = Math.maxAbs(xAxis) + Math.maxAbs(yAxis) + Math.maxAbs(zAxis);

    return features;
  }

  List<double> convertSensorValueToDouble(SensorValue sensorValues){

    
    List<double> doubleValues = sensorValues.valueStrings.map((e) => double.tryParse(e) ?? 0.0).toList();
    return doubleValues;
  }



}
