import 'package:open_earable_flutter/open_earable_flutter.dart';


class WindowManager {


  final int windowSize;
  final double overlap;
  final List<SensorValue> _buffer = [];
  late final int overlappingElements;
  late final int remainingLength;

  WindowManager({required this.windowSize, this.overlap = 0.5}) :

  
    assert(overlap >= 0.0 && overlap < 1.0, 'Overlap must be between 0.0 and 1.0'),
    overlappingElements = (windowSize * overlap).toInt(),
    remainingLength = windowSize - (windowSize * overlap).toInt();


  void processSample(SensorValue sample) {

    _buffer.add(sample);

   
    if(_buffer.length > windowSize){

      //print("Time difference 60 samples. ${_buffer.last.timestamp - _buffer.first.timestamp}");
      _buffer.removeRange(0, remainingLength);
    }
  }

  bool isWindowReady() {

    return _buffer.length == windowSize;
  }

  List<SensorValue> getWindow() {

    return _buffer;
  } 
}
