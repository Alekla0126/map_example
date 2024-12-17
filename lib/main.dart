import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'reducers/marker_reducer.dart';
import 'screens/intro_screen.dart';
import 'states/marker_state.dart';

void main() {
  final store = Store<MarkerState>(markerReducer, initialState: initialState);

  runApp(StoreProvider(
    store: store,
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: IntroScreen(),
    );
  }
}
