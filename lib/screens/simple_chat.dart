import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/unread_messages_bloc.dart';
import 'package:flutter/material.dart';

class SimpleChatScreen extends StatefulWidget {
  final String eventID;
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

    // Immediately mark all messages as read if in the current chat
    _markMessagesAsRead();
  }

  void _markMessagesAsRead() {
    context.read<UnreadMessagesBloc>().add(
          ResetUnreadForEvent(eventID: widget.eventID),
        );
    widget.onMessagesRead();
  }

  void _sendMessage(String text) {
    context.read<UnreadMessagesBloc>().add(
          AddMessageToEvent(eventID: widget.eventID, message: 'You: $text'),
        );
    _markMessagesAsRead(); // Ensure messages are marked as read immediately
    _messageController.clear();

    // Simulate friend response
    Future.delayed(const Duration(seconds: 2), () {
      context.read<UnreadMessagesBloc>().add(
            AddMessageToEvent(
              eventID: widget.eventID,
              message: 'Friend: Got it! Thanks for sharing.',
            ),
          );
      widget.onMessageReceived();
      _markMessagesAsRead(); // Mark friend’s response as read
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                          vertical: 5,
                          horizontal: 10,
                        ),
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
