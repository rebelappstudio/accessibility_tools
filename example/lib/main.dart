import 'package:flutter/material.dart';
import 'package:accessibility_tools/accessibility_tools.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return AccessibilityTools(
          checkFontOverflows: true,
          child: child,
        );
      },
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OtherPage()),
                );
              },
              child: const Text('Other page'),
            ),
            SizedBox(
              width: 100,
              child: Row(children: const [Text('Hello testing')]),
            ),
            Padding(
              padding: const EdgeInsets.all(50.0),
              child: SizedBox(
                width: 40,
                height: 40,
                child: InkWell(
                  onTap: () {},
                  child: const Icon(Icons.person),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OtherPage extends StatelessWidget {
  const OtherPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          const Text('Too small'),
          Center(
            child: Container(
              color: Colors.yellow,
              width: 10,
              height: 10,
              child: InkWell(
                onTap: () {},
                child: Container(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
