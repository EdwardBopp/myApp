import 'dart:math';

class Math {

  Math._();

  static double sum(List<double> vals){

    return vals.fold(0.0, (a, b) => a + b);

  }

  static double stdDeviation(List<double> vals, double mean){

    return sqrt(sum(vals.map((e) => (e - mean) * (e - mean)).toList()) / vals.length);

  }

  static double mean(List<double> vals){

    return sum(vals) / vals.length;

  }

  static double maxAbs(List<double> vals){

    return vals.fold(0.0, (a, b) => a.abs() > b.abs() ? a : b).abs();

  }

  static double covariance(List<double> x, List<double> y){

    double meanX = mean(x);
    double meanY = mean(y);
    double cov = 0.0;

    for(int i = 0; i < x.length; i++){

      cov += (x[i] - meanX) * (y[i] - meanY);

    }

    return cov / x.length;
  }

  static double correlation(List<double> x, List<double> y){

    double stdX = stdDeviation(x, mean(x));
    double stdY = stdDeviation(y, mean(y));
    double covXY = covariance(x, y);

    return covXY / (stdX * stdY);

  }
} 
 
  
