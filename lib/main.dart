import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:quickbill/firebase_options.dart';
import 'Pages/HomePage.dart';
import 'Pages/BillGenerationPage.dart';
import 'Pages/LogIn.dart';
import 'Pages/ModifyPage.dart';
import 'Pages/Signup.dart';
import 'Pages/StockManagementPage.dart';
import 'Pages/sample.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform );
  runApp(QuickBillApp());
}

class QuickBillApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner : false,
      title: 'QuickBill: Business Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
      routes: {
        '/home': (context) => HomePage(),
        '/shopManagement': (context) => ShopManagementPage(),
        '/stockManagement': (context) => StockManagementPage(),
        '/billGeneration': (context) => BillGenerationPage(),
        '/salesRecords': (context) => SalesRecordsPage(),
        '/modify':(context) => ModifyPage(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),

      },
    );
  }
}
