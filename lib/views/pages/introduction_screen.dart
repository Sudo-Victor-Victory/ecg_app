import 'package:ecg_app/data/classes/constants.dart';
import 'package:ecg_app/views/widgets/scaled_text.dart';
import 'package:ecg_app/views/widgets/widget_tree.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroductionScreens extends StatelessWidget {
  const IntroductionScreens({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ScaledText(
          "Introduction",
          baseSize: KTextSize.xxxl,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: KColors.eerieBlack,
          ),
        ),
        backgroundColor: KColors.red,
        centerTitle: true,
      ),
      body: IntroductionScreen(
        pages: [
          PageViewModel(
            title: 'Welcome to the start of empowering your health.',
            body:
                'This is the home page. It gives you an overview of devices, recent sessions, and contact. You can always tap (fill this) to view this guide again.',
            image: _buildImage("Intro_Home.gif"),
            decoration: getPageDecoration().copyWith(
              imageFlex: 6, // bigger = more space for the image
              bodyFlex: 2, // smaller = less space for the text
              imagePadding: const EdgeInsets.only(top: 20),
            ),
          ),
          PageViewModel(
            title: 'Bluetooth page',
            body:
                'Here is where you can find and connect to your health devices like an ECG. Select the device you want and tap on it to attempt to connect.',
            image: _buildImage("Intro_Bluetooth.gif"),
            decoration: getPageDecoration().copyWith(
              imageFlex: 6, // bigger = more space for the image
              bodyFlex: 2, // smaller = less space for the text
              imagePadding: const EdgeInsets.only(top: 20),
            ),
          ),
          PageViewModel(
            title: 'Real time charting',
            body:
                'Once you connect to the device, we will chart the data in real time as we receive it. Do not worry - all the data is being saved so you can view it again.',
            image: _buildImage("Intro_RealTime.gif"),
            decoration: getPageDecoration().copyWith(
              imageFlex: 6, // bigger = more space for the image
              bodyFlex: 2, // smaller = less space for the text
              imagePadding: const EdgeInsets.only(top: 20),
            ),
          ),
          PageViewModel(
            title: 'View previous charts',
            body:
                "After a session is completed, you can view your session's chart anytime via the sessions page.",
            image: _buildImage("Intro_Historical.gif"),
            decoration: getPageDecoration().copyWith(
              imageFlex: 6, // bigger = more space for the image
              bodyFlex: 2, // smaller = less space for the text
              imagePadding: const EdgeInsets.only(top: 20),
            ),
          ),
        ],
        onDone: () {
          if (kDebugMode) {
            print("Done clicked");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WidgetTree()),
            );
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

        globalFooter: const SizedBox(height: 15),
      ),
    );
  }

  //widget to add the image on screen
  Widget _buildImage(String assetName) {
    return Image.asset(
      'assets/images/$assetName',
      fit: BoxFit.contain, // preserves aspect ratio
    );
  }

  //method to customise the page style
  PageDecoration getPageDecoration() {
    return const PageDecoration(
      imagePadding: EdgeInsets.only(top: 120),
      pageColor: Colors.white,
      bodyPadding: EdgeInsets.only(top: 8, left: 20, right: 20),
      titlePadding: EdgeInsets.only(top: 50),
      bodyTextStyle: TextStyle(color: KColors.eerieBlack, fontSize: 15),
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
