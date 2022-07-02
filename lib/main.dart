import 'package:shared_preferences/shared_preferences.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

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
      home: const HomeRoute(),
    );
  }
}

class HomeRoute extends StatefulWidget {
  const HomeRoute({super.key});

  @override
  State<HomeRoute> createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  final List<WordPair> _suggestions = [];
  List<String> _savedNames = [];

  void saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _savedNames = (prefs.getStringList("names") ?? [])..add(name);
      prefs.setStringList('names', _savedNames);
    });
  }

  void unsaveName(String name) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _savedNames = (prefs.getStringList("names") ?? [])..remove(name);
      prefs.setStringList(
          'names', (prefs.getStringList("names") ?? [])..remove(name));
    });
  }

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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SavedSuggestionsRoute()));
            },
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          if (i.isOdd) return const Divider();

          final index = i ~/ 2;

          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }

          String suggestion = _suggestions[index].asPascalCase;

          return ListTile(
            title: Text(
              suggestion,
            ),
            trailing: IconButton(
              icon: (_savedNames.contains(suggestion)
                  ? const Icon(
                      Icons.favorite,
                      color: Colors.pink,
                    )
                  : const Icon(Icons.favorite_outline)),
              onPressed: () {
                setState(() {
                  if (_savedNames.contains(suggestion)) {
                    unsaveName(suggestion);
                  } else {
                    saveName(suggestion);
                  }
                });
              },
            ),
          );
        },
      ),
    );
  }
}

class SavedSuggestionsRoute extends StatefulWidget {
  const SavedSuggestionsRoute({Key? key}) : super(key: key);

  @override
  State<SavedSuggestionsRoute> createState() => _SavedSuggestionsRouteState();
}

class _SavedSuggestionsRouteState extends State<SavedSuggestionsRoute> {
  List<String> _names = [];

  void loadNames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _names = prefs.getStringList("names") ?? [];
    });
  }

  @override
  void initState() {
    super.initState();
    loadNames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved suggestions'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: (_names.isNotEmpty ? _names.length * 2 - 1 : 0),
        itemBuilder: (context, i) {
          if (i.isOdd && _names.length != 1) return const Divider();

          final index = i ~/ 2;

          return ListTile(
            title: Text(_names[index]),
          );
        },
      ),
    );
  }
}
