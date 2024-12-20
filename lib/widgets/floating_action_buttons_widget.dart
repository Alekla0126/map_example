import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/unread_messages_bloc.dart';
import '../widgets/floating_buttons.dart';
import 'package:flutter/material.dart';

class FloatingActionButtons extends StatelessWidget {
  final bool isDarkMode;
  final int unreadMessages;
  final VoidCallback onDarkModeToggle;
  final VoidCallback onAddMarker;
  final VoidCallback onViewFavorites;
  final VoidCallback openChat;

  const FloatingActionButtons({
    required this.isDarkMode,
    required this.unreadMessages,
    required this.onDarkModeToggle,
    required this.onAddMarker,
    required this.onViewFavorites,
    required this.openChat,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingButtons(
          isDarkMode: isDarkMode,
          onDarkModeToggle: onDarkModeToggle,
          onAddMarker: onAddMarker,
          onViewFavorites: onViewFavorites,
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          onPressed: openChat,
          child: Stack(
            children: [
              const Align(
                alignment: Alignment.center,
                child: Icon(Icons.chat),
              ),
              BlocBuilder<UnreadMessagesBloc, UnreadMessagesState>(
                builder: (context, state) {
                  if (state.unreadCount > 0) {
                    return Align(
                      alignment: Alignment.topRight,
                      child: CircleAvatar(
                        backgroundColor: Colors.red,
                        radius: 10,
                        child: Text(
                          '${state.unreadCount}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}