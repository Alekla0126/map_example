import '../blocs/unread_messages_bloc.dart' as unread_bloc;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/floating_buttons.dart';
import 'package:flutter/material.dart';
import '../screens/auth_screen.dart';
import '../blocs/auth_bloc.dart';

class FloatingActionButtons extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onDarkModeToggle;
  final VoidCallback onAddMarker;
  final VoidCallback onViewFavorites;
  final VoidCallback openChat;

  const FloatingActionButtons({
    required this.isDarkMode,
    required this.onDarkModeToggle,
    required this.onAddMarker,
    required this.onViewFavorites,
    required this.openChat,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacementNamed(context, '/map');
        } else if (state is AuthUnauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => AuthScreen()),
            (route) => false,
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Floating buttons for dark mode, markers, etc.
          FloatingButtons(
            isDarkMode: isDarkMode,
            onDarkModeToggle: onDarkModeToggle,
            onAddMarker: onAddMarker,
            onViewFavorites: onViewFavorites,
            onLogout: () {
              // Dispatch LogoutEvent via AuthBloc
              context.read<AuthBloc>().add(LogoutEvent());
            },
          ),
          const SizedBox(height: 16),

          // Chat button with unread messages badge
          FloatingActionButton(
            onPressed: openChat,
            child: Stack(
              children: [
                const Align(
                  alignment: Alignment.center,
                  child: Icon(Icons.chat),
                ),

                // BlocBuilder to show the total unread messages badge
                BlocBuilder<unread_bloc.UnreadMessagesBloc,
                    unread_bloc.UnreadMessagesState>(
                  builder: (context, state) {
                    // Calculate total unread messages across all events
                    final totalUnreadMessages = state.eventUnreadCounts.values
                        .fold(0, (sum, count) => sum + count);

                    if (totalUnreadMessages > 0) {
                      return Align(
                        alignment: Alignment.topRight,
                        child: CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 10,
                          child: Text(
                            '$totalUnreadMessages',
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
      ),
    );
  }
}
