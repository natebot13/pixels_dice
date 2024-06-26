import 'package:flutter/material.dart';
import 'package:pixels_dice_flutter/pixels_dice_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    PixelsDiceScanner.searchAndConnect();
    print("scanning");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: StreamBuilder<List<PixelsDie>>(
          stream: PixelsDiceScanner.dice,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              print("have data: ${snapshot.data}");
              return ListView(
                children: snapshot.data!
                    .map(
                      (die) => Hero(
                        tag: die.name,
                        child: Material(
                          child: ListTile(
                            isThreeLine: true,
                            title: Text(die.name),
                            subtitle: Text(die.manufactureData.toString()),
                            onTap: () {
                              PixelsDiceScanner.stopSearching();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PixelsDiePage(die: die),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            } else {
              print("searching");
              return const CircularProgressIndicator();
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    PixelsDiceScanner.stopSearching();
    super.dispose();
  }
}

class PixelsDiePage extends StatelessWidget {
  final PixelsDie die;
  const PixelsDiePage({super.key, required this.die});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(die.name),
      ),
      body: FutureBuilder(
        future: die.connect(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            final snack = SnackBar(content: Text(snapshot.error!.toString()));
            ScaffoldMessenger.of(context).showSnackBar(snack);
            PixelsDiceScanner.searchAndConnect();
            Navigator.pop(context);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Hero(
                tag: die.name,
                child: Material(child: ListTile(title: Text(die.name))),
              ),
              Expanded(
                child: Center(
                  child: StreamBuilder(
                    stream: die.rollEvents,
                    initialData: RollEvent(
                      instant: DateTime.now(),
                      value: die.manufactureData.currentFace,
                    ),
                    builder: (context, snapshot) {
                      final roll = snapshot.data!;
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (child, animation) =>
                            RotationTransition(
                          turns: animation,
                          child: child,
                        ),
                        child: Text(
                          "${roll.value}",
                          key: ValueKey<DateTime>(roll.instant),
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
