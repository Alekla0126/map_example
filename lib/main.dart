import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'reducers/dark_mode_reducer.dart';
import 'blocs/unread_messages_bloc.dart';
import 'package:flutter/material.dart';
import 'blocs/dark_mode_bloc.dart';
import 'package:redux/redux.dart';
import 'screens/auth_screen.dart';
import 'screens/simple_chat.dart';
import 'screens/map_screen.dart';
import 'firebase_options.dart';
import 'blocs/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final darkModeStore = Store<bool>(
    darkModeReducer,
    initialState: false, // Default to light mode
  );

  runApp(MyApp(store: darkModeStore));
}

class MyApp extends StatelessWidget {
  final Store<bool> store;

  const MyApp({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreProvider<bool>(
      store: store,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => UnreadMessagesBloc()..add(IncrementUnreadMessages()),
          ),
          BlocProvider(
            create: (_) => AuthBloc(),
          ),
          BlocProvider(
            create: (_) => DarkModeBloc(), // Add the DarkModeBloc
          ),
        ],
        child: StoreBuilder<bool>(
          builder: (context, darkModeStore) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'TapMap',
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              themeMode: darkModeStore.state ? ThemeMode.dark : ThemeMode.light,
              initialRoute: '/',
              routes: {
                '/': (context) => AuthScreen(),
                '/map': (context) => MapScreen(),
                '/chat': (context) => SimpleChatScreen(
                      onMessageReceived: () {
                        context
                            .read<UnreadMessagesBloc>()
                            .add(IncrementUnreadMessages());
                      },
                      onMessagesRead: () {
                        context
                            .read<UnreadMessagesBloc>()
                            .add(ResetUnreadMessages());
                      },
                    ),
              },
            );
          },
        ),
      ),
    );
  }
}
