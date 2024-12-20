import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'reducers/dark_mode_reducer.dart';
import 'blocs/unread_messages_bloc.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'screens/simple_chat.dart';
import 'screens/map_screen.dart';

void main() {
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
      child: BlocProvider(
        create: (_) => UnreadMessagesBloc()..add(IncrementUnreadMessages()),
        child: StoreBuilder<bool>(
          builder: (context, darkModeStore) {
            return BlocListener<UnreadMessagesBloc, UnreadMessagesState>(
              listener: (context, state) {
                // Handle unread message changes
                if (state.unreadCount > 0) {
                  debugPrint("New message received. Unread count: ${state.unreadCount}");
                }
              },
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'TapMap',
                theme: ThemeData.light(),
                darkTheme: ThemeData.dark(),
                themeMode: darkModeStore.state ? ThemeMode.dark : ThemeMode.light,
                home: MapScreen(),
                routes: {
                  '/chat': (context) => SimpleChatScreen(
                        onMessageReceived: () {
                          context.read<UnreadMessagesBloc>().add(IncrementUnreadMessages());
                        },
                        onMessagesRead: () {
                          context.read<UnreadMessagesBloc>().add(ResetUnreadMessages());
                        },
                      ),
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
