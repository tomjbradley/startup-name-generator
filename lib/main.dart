import 'package:shared_preferences/shared_preferences.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  String _theme = "Light";

  void loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _theme = prefs.getString("theme") ?? "Light";
    });
  }

  @override
  void initState() {
    super.initState();
    loadTheme();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData(
        colorScheme: (_theme == "Light"
            ? const ColorScheme.light(
                primary: Colors.white,
                onPrimary: Colors.black,
              )
            : const ColorScheme.dark(
                primary: Colors.black,
                onPrimary: Colors.white,
              )),
      ),
      home: HomeRoute(
        updateTheme: (newValue) async {
          SharedPreferences prefs = await SharedPreferences.getInstance();

          setState(() {
            _theme = newValue;
            prefs.setString("theme", newValue);
          });
        },
        suggestions: [],
      ),
    );
  }
}

class HomeRoute extends StatefulWidget {
  const HomeRoute(
      {super.key, required this.updateTheme, required this.suggestions});

  final Function updateTheme;
  final List<WordPair> suggestions;

  @override
  State<HomeRoute> createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  String _dropdownValue = "Light";
  List<String> _savedNames = [];
  List<WordPair> _suggestions = [];

  @override
  void initState() {
    super.initState();
    loadTheme();
    loadNames();
    setState(() {
      _suggestions = widget.suggestions;
    });
  }

  void loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _dropdownValue = prefs.getString("theme") ?? "Light";
    });
  }

  void loadNames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedNames = prefs.getStringList("names") ?? [];
    });
  }

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
            icon: const Icon(Icons.list),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SavedSuggestionsRoute(
                    onUpdateTheme: (newValue) {
                      widget.updateTheme(newValue);
                    },
                    suggestions: _suggestions,
                  ),
                ),
              );
            },
          ),
        ],
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      drawer: Drawer(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Settings",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              const Text("Version 1.0.0"),
              Builder(
                builder: (context) => TextButton(
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.clear();

                    if (!mounted) return;
                    Scaffold.of(context).closeDrawer();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Local data cleared.'),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    "Clear local data",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 30.0),
                child: Text(
                  "Theme",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DropdownButton(
                value: _dropdownValue,
                items: <String>["Light", "Dark"]
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _dropdownValue = newValue!;
                    widget.updateTheme(newValue);
                  });
                },
              ),
            ],
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          if (i.isOdd) return const Divider();

          final index = i ~/ 2;

          if (index >= _suggestions.length) {
            _suggestions.addAll(List.from(Set.from(generateWordPairs().take(10))
                .difference(Set.from(_savedNames))));
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
  const SavedSuggestionsRoute(
      {super.key, required this.onUpdateTheme, required this.suggestions});

  final Function onUpdateTheme;
  final List<WordPair> suggestions;

  @override
  State<SavedSuggestionsRoute> createState() => _SavedSuggestionsRouteState();
}

class _SavedSuggestionsRouteState extends State<SavedSuggestionsRoute> {
  List<String> _names = [];

  void saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _names = (prefs.getStringList("names") ?? [])..add(name);
      prefs.setStringList('names', _names);
    });
  }

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

  void unsaveName(String name) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _names = (prefs.getStringList("names") ?? [])..remove(name);
      prefs.setStringList(
          'names', (prefs.getStringList("names") ?? [])..remove(name));
    });
  }

  final TextEditingController _textFieldController = TextEditingController();
  String _valueText = "";

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add a name to the list'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  _valueText = value;
                });
              },
              controller: _textFieldController,
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Close'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              ElevatedButton(
                child: const Text('Add'),
                onPressed: () {
                  setState(() {
                    saveName(_valueText);
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved suggestions'),
        centerTitle: true,
        leading: BackButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeRoute(
                  updateTheme: (newValue) {
                    widget.onUpdateTheme(newValue);
                  },
                  suggestions: widget.suggestions,
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _displayTextInputDialog(context);
        },
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      body: ListView.builder(
        itemCount: (_names.isNotEmpty ? _names.length * 2 - 1 : 0),
        itemBuilder: (context, i) {
          if (i.isOdd && _names.length != 1) return const Divider();

          final index = i ~/ 2;

          return ListTile(
            title: Text(_names[index]),
            trailing: IconButton(
              icon: const Icon(
                Icons.remove_circle,
                color: Colors.red,
              ),
              onPressed: () {
                String name = _names[index];

                setState(() {
                  unsaveName(name);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Name removed from list.'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        saveName(name);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
