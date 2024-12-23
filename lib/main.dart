import 'package:map_example/blocs/unread_messages_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'reducers/dark_mode_reducer.dart';
import 'screens/chat_screen_list.dart';
import 'package:flutter/material.dart';
import 'blocs/dark_mode_bloc.dart';
import 'screens/simple_chat.dart';
import 'package:redux/redux.dart';
import 'screens/auth_screen.dart';
import 'screens/map_screen.dart';
import 'firebase_options.dart';
import 'blocs/auth_bloc.dart';
import 'blocs/chat_bloc.dart';

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
    // Sample list of events to pass to ChatListScreen
    final List<Map<String, dynamic>> events = [
      {'id': 'event-1', 'name': 'Event 1'},
      {'id': 'event2', 'name': 'Event 2'},
      {'id': 'event3', 'name': 'Event 3'},
    ];

    return StoreProvider<bool>(
      store: store,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => ChatBloc(),
          ),
          BlocProvider(
            create: (_) => AuthBloc(),
          ),
          BlocProvider(
            create: (_) => DarkModeBloc(),
          ),
          BlocProvider(
            create: (context) {
              final unreadBloc = UnreadMessagesBloc();

              // -------------- DISPATCH INITIAL MESSAGES --------------
              // Send 3 initial messages to "event-1" at app startup
              unreadBloc.add(AddMessageToEvent(
                eventID: 'event-1',
                message: 'Welcome to Event 1!',
              ));
              unreadBloc.add(AddMessageToEvent(
                eventID: 'event-1',
                message: 'Let me know if you have questions about the event.',
              ));
              // --------------------------------------------------------

              return unreadBloc;
            },
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
                '/chatList': (context) => ChatListScreen(events: events),
                '/chat': (context) {
                  final args = ModalRoute.of(context)!.settings.arguments
                      as Map<String, dynamic>;
                  return SimpleChatScreen(
                    eventID: args['eventID'],
                    onMessageReceived: () {
                      context.read<ChatBloc>().add(
                        MessageReceived(
                          eventID: args['eventID'],
                          message: 'New message received!',
                        ),
                      );
                    },
                    onMessagesRead: () {
                      context.read<ChatBloc>().add(
                        MessagesRead(eventID: args['eventID']),
                      );
                    },
                  );
                },
              },
            );
          },
        ),
      ),
    );
  }
}
