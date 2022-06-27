import 'package:shared_preferences/shared_preferences.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Colors.white,
          onPrimary: Colors.black,
        ),
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => const FirstScreen(),
        "/second": (context) => const SecondScreen(),
      },
    );
  }
}

class FirstScreen extends StatelessWidget {
  const FirstScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup Name Generator'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.format_list_bulleted),
            onPressed: () {
              Navigator.pushNamed(context, '/second');
            },
          )
        ],
      ),
      body: const Center(
        child: RandomWords(),
      ),
    );
  }
}

class SecondScreen extends StatefulWidget {
  const SecondScreen({super.key});

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  final _biggerFont = const TextStyle(fontSize: 18);
  List<String> names = [];

  @override
  void initState() {
    _getNames();
    super.initState();
  }

  void _getNames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? response = prefs.getStringList("saved_names");

    setState(() {
      names = response ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved suggestions'),
        centerTitle: true,
      ),
      body: Center(
        child: ListView(children: [
          for (var name in names)
            ListTile(
              title: Text(name),
            ),
        ]),
      ),
    );
  }
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _biggerFont = const TextStyle(fontSize: 18);
  List<String> _savedNames = <String>[];

  @override
  void initState() {
    _getNames();
    super.initState();
  }

  void _getNames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? response = prefs.getStringList("saved_names");

    setState(() {
      _savedNames = response ?? [];
    });
  }

  _saveName(String name) async {
    setState(() {
      _savedNames.add(name);

      _savedNames = _savedNames;
    });

    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList('saved_names', _savedNames);
  }

  _removeName(String name) async {
    setState(() {
      _savedNames.remove(name);

      _savedNames = _savedNames;
    });

    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList('saved_names', _savedNames);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        if (i.isOdd) return const Divider();

        final index = i ~/ 2;
        if (index >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs().take(10));
        }

        return ListTile(
          title: Text(
            _suggestions[index].asPascalCase,
            style: _biggerFont,
          ),
          trailing: IconButton(
            icon: (!_savedNames.contains(_suggestions[index].asPascalCase))
                ? Icon(Icons.favorite_outline)
                : Icon(
                    Icons.favorite,
                    color: Colors.pink,
                  ),
            onPressed: () {
              if (_savedNames.contains(_suggestions[index].asPascalCase)) {
                _removeName(_suggestions[index].asPascalCase);
              } else {
                _saveName(_suggestions[index].asPascalCase);
              }
            },
          ),
        );
      },
    );
  }
}

class RandomWords extends StatefulWidget {
  const RandomWords({super.key});

  @override
  State<RandomWords> createState() => _RandomWordsState();
}
