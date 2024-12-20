import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/unread_messages_bloc.dart';
import 'package:flutter/material.dart';

class SimpleChatScreen extends StatefulWidget {
  final VoidCallback onMessageReceived;
  final VoidCallback onMessagesRead;

  const SimpleChatScreen({
    super.key,
    required this.onMessageReceived,
    required this.onMessagesRead,
  });

  @override
  _SimpleChatScreenState createState() => _SimpleChatScreenState();
}

class _SimpleChatScreenState extends State<SimpleChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Mark messages as read
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UnreadMessagesBloc>().add(ResetUnreadMessages());
      widget.onMessagesRead();
    });
  }

  void _sendMessage(String text) {
    setState(() {
      context.read<UnreadMessagesBloc>().state.messages.add('You: $text');
    });
    widget.onMessagesRead();
    _messageController.clear();

    // Simulate a friend's response after a delay
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        context
            .read<UnreadMessagesBloc>()
            .state
            .messages
            .add('Friend: Got it! Thanks for sharing.');
      });
      widget.onMessageReceived();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<UnreadMessagesBloc, UnreadMessagesState>(
              builder: (context, state) {
                return ListView.builder(
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message = state.messages[index];
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
