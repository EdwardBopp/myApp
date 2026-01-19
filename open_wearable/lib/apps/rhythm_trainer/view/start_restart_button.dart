import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class Startrestartbutton extends StatefulWidget {

  final Function onStart;
  final Function onRestart;
  const Startrestartbutton({super.key, required this.onStart, required this.onRestart});

  @override
  State<Startrestartbutton> createState() => _StartrestartbuttonState();

}

class _StartrestartbuttonState extends State<Startrestartbutton> {

  bool isVisible = true;
  
  @override
  Widget build(BuildContext context) {

    return Visibility(

      visible: isVisible,
      
      replacement: PlatformElevatedButton(
        child: PlatformText("Restart"),
        onPressed: () {

          setState(() {
            isVisible = true;
          });

          widget.onRestart();

        },
      ),

      child: PlatformElevatedButton(
      
        child: PlatformText("Start"),
        onPressed: () {

          setState(() {

            isVisible = false;

          });

          widget.onStart();      
        },
      ),
    );
  }
}