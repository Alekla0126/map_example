import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/unread_messages_bloc.dart';

class SimpleChatScreen extends StatefulWidget {
  final String eventID; // Event ID to identify this chat
  final VoidCallback onMessageReceived;
  final VoidCallback onMessagesRead;

  const SimpleChatScreen({
    Key? key,
    required this.eventID,
    required this.onMessageReceived,
    required this.onMessagesRead,
  }) : super(key: key);

  @override
  _SimpleChatScreenState createState() => _SimpleChatScreenState();
}

class _SimpleChatScreenState extends State<SimpleChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Mark messages as read for the specific event
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UnreadMessagesBloc>().add(
        ResetUnreadForEvent(eventID: widget.eventID),
      );
      widget.onMessagesRead();
    });

    // Simulate initial messages for the first point
    if (widget.eventID == 'event-0') {
      _simulateInitialMessages();
    }
  }

  void _simulateInitialMessages() {
    final simulatedMessages = [
      'Friend: Welcome to the first point!',
      'Friend: Let me know if you have questions.',
      'Friend: Check out the details on the map!',
    ];

    Future.forEach<String>(simulatedMessages, (message) async {
      await Future.delayed(const Duration(seconds: 2));
      context.read<UnreadMessagesBloc>().add(
            AddMessageToEvent(eventID: widget.eventID, message: message),
          );
      widget.onMessageReceived();
    });
  }

  void _sendMessage(String text) {
    context.read<UnreadMessagesBloc>().add(
          AddMessageToEvent(eventID: widget.eventID, message: 'You: $text'),
        );
    widget.onMessagesRead();
    _messageController.clear();

    // Simulate a friend's response after a delay
    Future.delayed(const Duration(seconds: 2), () {
      context.read<UnreadMessagesBloc>().add(
            AddMessageToEvent(
                eventID: widget.eventID,
                message: 'Friend: Got it! Thanks for sharing.'),
          );
      widget.onMessageReceived();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat for ${widget.eventID}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<UnreadMessagesBloc, UnreadMessagesState>(
              builder: (context, state) {
                final messages = state.eventMessages[widget.eventID] ?? [];
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isUserMessage = message.startsWith('You:');
                    return Align(
                      alignment: isUserMessage
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isUserMessage
                              ? Colors.blue
                              : isDarkMode
                                  ? Colors.grey[700]
                                  : Colors.grey[300],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          message,
                          style: TextStyle(
                            color: isUserMessage
                                ? Colors.white
                                : isDarkMode
                                    ? Colors.white70
                                    : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onSubmitted: (text) {
                      if (text.trim().isNotEmpty) {
                        _sendMessage(text.trim());
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final text = _messageController.text.trim();
                    if (text.isNotEmpty) {
                      _sendMessage(text);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
