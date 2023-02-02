import 'package:flutter/material.dart';
import 'package:accessibility_tools/accessibility_tools.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData.dark(),
      home: const MyHomePage(),
      localizationsDelegates: [
        AppLocalizationDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fi', 'FI'),
        Locale('en', 'US'),
      ],
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
              child: Text(AppLocalizations.of(context).secondPage),
            ),
            SizedBox(
              width: 100,
              child: Row(
                children: [
                  Text(AppLocalizations.of(context).greetings),
                ],
              ),
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

class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String get greetings {
    switch (locale.languageCode.toLowerCase()) {
      case 'fi':
        return 'Moi!';
      case 'en':
      default:
        return 'Hello!';
    }
  }

  String get secondPage {
    switch (locale.languageCode.toLowerCase()) {
      case 'fi':
        return 'Toinen sivu';
      case 'en':
      default:
        return 'Other page';
    }
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalizations> {
  @override
  bool isSupported(Locale locale) =>
      ['fi', 'en'].contains(locale.languageCode.toLowerCase());

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
