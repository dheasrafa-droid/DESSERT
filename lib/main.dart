import 'package:flutter/material.dart';
import 'package:dessert_engine/core/dessert_engine.dart';
import 'package:dessert_engine/dashboard/dashboard_main.dart';
import 'package:dessert_engine/ui/dessert_appbar.dart';
import 'package:dessert_engine/ui/dessert_drawer.dart';

void main() {
  runApp(const DessertApp());
}

class DessertApp extends StatelessWidget {
  const DessertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DESSERT Engine',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const DessertHomePage(),
    );
  }
}

class DessertHomePage extends StatefulWidget {
  const DessertHomePage({super.key});

  @override
  State<DessertHomePage> createState() => _DessertHomePageState();
}

class _DessertHomePageState extends State<DessertHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DessertEngine _engine = DessertEngine();

  @override
  void initState() {
    super.initState();
    _initializeEngine();
  }

  Future<void> _initializeEngine() async {
    await _engine.initialize();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      appBar: DessertAppBar(
        title: 'DESSERT ENGINE v1.0',
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      drawer: const DessertDrawer(),
      body: Stack(
        children: [
          // Engine 3D sebagai background utama
          if (_engine.isInitialized)
            DashboardMain(engine: _engine)
          else
            const Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurple,
              ),
            ),
        ],
      ),
    );
  }
}
