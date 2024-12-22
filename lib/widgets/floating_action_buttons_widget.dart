import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/unread_messages_bloc.dart';
import '../widgets/floating_buttons.dart';
import 'package:flutter/material.dart';
import '../screens/auth_screen.dart';
import '../blocs/auth_bloc.dart';

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
      ),
    );
  }
}
