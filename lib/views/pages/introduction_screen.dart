import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroductionScreens extends StatelessWidget {
  const IntroductionScreens({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: IntroductionScreen(
        pages: [
          PageViewModel(
            title: 'Welcome to empowering your health',
            body:
                'This is the home page. It gives you an overview of devices, recent sessions, and contact. You can always tap (fill this) to view this guide again.',
            image: buildImage("images/image_1.png"),
            //getPageDecoration, a method to customise the page style
            decoration: getPageDecoration(),
          ),
          PageViewModel(
            title: 'Bluetooth page',
            body:
                'Here is where you can find and connect to your health devices like an ECG. Select the device you want and tap on it to attempt to connect.',
            image: buildImage("images/image_2.png"),
            //getPageDecoration, a method to customise the page style
            decoration: getPageDecoration(),
          ),
          PageViewModel(
            title: 'Real time charting',
            body:
                'Once you connect to the device, we will chart the data in real time as we receive it. Do not worry - all the data is being saved so have no fear.',
            image: buildImage("images/image_3.png"),
            //getPageDecoration, a method to customise the page style
            decoration: getPageDecoration(),
          ),
          PageViewModel(
            title: 'View previous charts',
            body:
                "After a session is completed, you can view your session's chart anytime via the sessions page.",
            image: buildImage("images/image_3.png"),
            //getPageDecoration, a method to customise the page style
            decoration: getPageDecoration(),
          ),
        ],
        onDone: () {
          if (kDebugMode) {
            print("Done clicked");
          }
        },
        //ClampingScrollPhysics prevent the scroll offset from exceeding the bounds of the content.
        scrollPhysics: const ClampingScrollPhysics(),
        showDoneButton: true,
        showNextButton: true,
        showSkipButton: true,
        skip: const Text("Skip", style: TextStyle(fontWeight: FontWeight.w600)),
        next: const Icon(Icons.forward),
        done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w600)),
        dotsDecorator: getDotsDecorator(),
      ),
    );
  }

  //widget to add the image on screen
  Widget buildImage(String imagePath) {
    return Center(child: Image.asset(imagePath, width: 450, height: 200));
  }

  //method to customise the page style
  PageDecoration getPageDecoration() {
    return const PageDecoration(
      imagePadding: EdgeInsets.only(top: 120),
      pageColor: Colors.white,
      bodyPadding: EdgeInsets.only(top: 8, left: 20, right: 20),
      titlePadding: EdgeInsets.only(top: 50),
      bodyTextStyle: TextStyle(color: Colors.black54, fontSize: 15),
    );
  }

  //method to customize the dots style
  DotsDecorator getDotsDecorator() {
    return const DotsDecorator(
      spacing: EdgeInsets.symmetric(horizontal: 2),
      activeColor: Colors.indigo,
      color: Colors.grey,
      activeSize: Size(12, 5),
      activeShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
    );
  }
}
