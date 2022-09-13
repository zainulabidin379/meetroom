import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meetroom/sharedScreens/wrapper.dart';
import 'package:meetroom/services/auth.dart';
import 'package:meetroom/shared/user.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FlutterDownloader.initialize(
    debug: false,
    ignoreSsl: true
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return StreamProvider<TheUser?>.value(
      value: AuthService().user,
      initialData: null,
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MeetRoom',
        theme: ThemeData(
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: AppBarTheme(
            toolbarTextStyle:
                GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
                    .bodyText2,
            titleTextStyle:
                GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
                    .headline6,
          ),
        ),
        home: const Wrapper(),
      ),
    );
  }
}
