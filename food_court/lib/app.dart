import 'package:flutter/material.dart';
import 'package:food_court/providers/cart_provider.dart';
import 'package:food_court/screens/home_page.dart';
import 'package:food_court/screens/login_screen.dart';
import 'package:food_court/screens/registration_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/user_orders_screen.dart';
import 'services/firebase_service.dart';

class OnlineFoodOrderingApp extends StatefulWidget {
  @override
  _OnlineFoodOrderingAppState createState() => _OnlineFoodOrderingAppState();
}

class _OnlineFoodOrderingAppState extends State<OnlineFoodOrderingApp> {
  late Future<FirebaseApp> _firebaseInitialization;

  @override
  void initState() {
    super.initState();
    _firebaseInitialization = Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _firebaseInitialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MultiProvider(
            providers: [
              Provider(create: (_) => FirebaseService()),
              ChangeNotifierProvider(create: (_) => CartProvider()),
            ],
            child: MaterialApp(
              title: 'Online Food Ordering',
              theme: ThemeData(
                brightness: Brightness.dark,
                primaryColor: Colors.black,
                scaffoldBackgroundColor: Colors.black,
                textTheme: GoogleFonts.robotoTextTheme(
                  Theme.of(context).textTheme.apply(
                    bodyColor: Colors.white,
                    displayColor: Colors.white,
                  ),
                ),
                appBarTheme: AppBarTheme(
                  backgroundColor: Colors.black,
                  elevation: 0,
                ),
                bottomNavigationBarTheme: BottomNavigationBarThemeData(
                  backgroundColor: Colors.black,
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.grey,
                ),
              ),
              initialRoute: '/login',
              routes: {
                '/login': (context) => LoginScreen(),
                '/home': (context) => HomePage(),

                '/register': (context) => RegistrationScreen(),

                '/user_orders': (context) => UserOrdersScreen(),
              },
            ),
          );
        }
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Error initializing Firebase')),
            ),
          );
        }
        return MaterialApp(
          home: Scaffold(body: Center(child: CircularProgressIndicator())),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = <Widget>[];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
