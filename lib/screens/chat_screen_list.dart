import '../blocs/unread_messages_bloc.dart' as unread_bloc;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'simple_chat.dart';

class ChatListScreen extends StatelessWidget {
  final List<Map<String, dynamic>> events;

  const ChatListScreen({Key? key, required this.events}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat List'),
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          final eventID = event['id'] ?? 'unknown-id';
          final eventName = event['name'] ?? 'Unnamed Event';

          return ListTile(
            title: Text(eventName),
            trailing: BlocBuilder<unread_bloc.UnreadMessagesBloc,
                unread_bloc.UnreadMessagesState>(
              builder: (context, state) {
                final unreadCount = state.eventUnreadCounts[eventID] ?? 0;
                if (unreadCount > 0) {
                  return CircleAvatar(
                    backgroundColor: Colors.red,
                    radius: 10,
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SimpleChatScreen(
                    eventID: eventID,
                    onMessageReceived: () {
                      context.read<unread_bloc.UnreadMessagesBloc>().add(
                          unread_bloc.AddMessageToEvent(
                              eventID: eventID, message: "New Message"));
                    },
                    onMessagesRead: () {
                      context
                          .read<unread_bloc.UnreadMessagesBloc>()
                          .add(unread_bloc.ResetUnreadForEvent(eventID: eventID));
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
