import 'package:attend/firebase_options.dart';
import 'package:attend/models/local_notification.dart';
import 'package:attend/models/network_connectivity.dart';
import 'package:attend/no_internet_screen.dart';
import 'package:attend/providers/auth_provider.dart';
import 'package:attend/providers/class_data_provider.dart';
import 'package:attend/providers/user_data_provider.dart';
import 'package:attend/screens/faculty_screens/attance_class_screen.dart';
import 'package:attend/screens/faculty_screens/create_attandance_sheet.dart';
import 'package:attend/screens/faculty_screens/faculty_home_screen.dart';
import 'package:attend/screens/faculty_screens/profile_details_screen.dart';
import 'package:attend/screens/first_screen.dart';
import 'package:attend/screens/student_screens/screens/student_profile_screen.dart';
import 'package:attend/screens/student_screens/screens/student_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotificationService().init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map _source = {ConnectivityResult.none: false};
  final NetworkConnectivity _networkConnectivity = NetworkConnectivity.instance;
  String string = '';

  @override
  void initState() {
    super.initState();
    _networkConnectivity.initialise();
    _networkConnectivity.myStream.listen((source) {
      _source = source;
      print('source $_source');
      // 1.
      switch (_source.keys.toList()[0]) {
        case ConnectivityResult.mobile:
          string = _source.values.toList()[0] ? 'Online' : 'Offline';
          break;
        case ConnectivityResult.wifi:
          string = _source.values.toList()[0] ? 'Online' : 'Offline';
          break;
        case ConnectivityResult.none:
        default:
          string = 'Offline';
      }
      // 2.
      setState(() {});
      // 3.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            string,
            style: TextStyle(fontSize: 30),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => UserDataProvider()),
        ChangeNotifierProvider(create: (ctx) => ClassProvider()),
        ChangeNotifierProvider(create: (ctx) => AuthDataProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        // home: string == 'Offline' ? const NoInternetScreen() : FirstScreen(),
        routes: {
          '/': (context) => const FirstScreen(),
          AttandanceClassScreen.routeName: (_) => AttandanceClassScreen(),
          CreateAttendacneSheet.routeName: (_) => const CreateAttendacneSheet(),
          ProfileDetailScreen.routeName: (_) => const ProfileDetailScreen(),
          FacultyHomeScreen.routeName: (_) => const FacultyHomeScreen(),
          StudentScreen.routeName: (_) => const StudentScreen(),
          StudentProfileScreen.routeName: (_) => const StudentProfileScreen(),
          NoInternetScreen.routeName: (_) => NoInternetScreen(),
        },
        // initialRoute: string == 'Offline' ? NoInternetScreen.routeName : '/',
        initialRoute: '/',
      ),
    );
  }
}
