import "package:open_wearable/apps/rhythm_trainer/Test/artificial_stream.dart";

 
void main() async {

  ArtificialStream artificialStream = ArtificialStream();
  artificialStream.startArtificialStreamTest(acceleroPath: 'C:\\dev\\MobileComputing\\myApp\\open_wearable\\lib\\apps\\rhythm_trainer\\Test\\stream_data\\60BPM\\eSense-0723_Accelerometer.csv',
                                        gyroPath: 'C:\\dev\\MobileComputing\\myApp\\open_wearable\\lib\\apps\\rhythm_trainer\\Test\\stream_data\\60BPM\\eSense-0723_Gyroscope.csv',
  );

  
  await Future.delayed(Duration(seconds: 30));
  
}
