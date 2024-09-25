import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Providers/CartProvide.dart';
import 'Pages/HomePage.dart';
import 'Pages/BillGenerationPage.dart';
import 'Pages/LogIn.dart';
import 'Pages/ItemForm.dart';
import 'Pages/SalesRecordPage.dart';
import 'Pages/Signup.dart';
import 'Pages/StockManagementPage.dart';
import 'Pages/ShopManagementPage.dart';
import 'Providers/ShopProvider.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
      MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ShopProvider()),
        ChangeNotifierProvider(create: (context) => Cart()),
      ],
      child: QuickBillApp(),
    ),
  );
}

class QuickBillApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QuickBill: Business Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthWrapper(), // Wrap your routes with AuthWrapper
      routes: {
        '/home': (context) => HomePage(),
        '/shopManagement': (context) => ShopManagementPage(),
        '/stockManagement': (context) => StockManagementPage(),
        '/billGeneration': (context) => BillGenerationPage(),
        // '/salesRecords': (context) => SalesRecordPage(),
        '/modify': (context) => ItemForm(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the authentication state is loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If the user is not logged in, redirect to LoginPage with a message
        if (!snapshot.hasData) {
          final route = ModalRoute.of(context)?.settings.name;
          if (route != null && route != '/') {
            return LoginPage(message: 'Please login to access this page');
          }
          return LoginPage();
        }

        // Load shop data after login
        final user = snapshot.data;
        Provider.of<ShopProvider>(context, listen: false).loadShopData(_auth.currentUser?.email);

        return HomePage();
      },
    );
  }
}

