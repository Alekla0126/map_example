import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class UnreadMessagesEvent {}

class IncrementUnreadMessages extends UnreadMessagesEvent {}

class ResetUnreadMessages extends UnreadMessagesEvent {}

class ScheduleInitialMessages extends UnreadMessagesEvent {}

// State
class UnreadMessagesState {
  final int unreadCount;
  final List<String> messages;

  UnreadMessagesState({
    required this.unreadCount,
    required this.messages,
  });
}

// Bloc
class UnreadMessagesBloc extends Bloc<UnreadMessagesEvent, UnreadMessagesState> {
  UnreadMessagesBloc()
      : super(UnreadMessagesState(unreadCount: 0, messages: [])) {
    on<IncrementUnreadMessages>(_incrementUnreadMessages);
    on<ResetUnreadMessages>(_resetUnreadMessages);
    on<ScheduleInitialMessages>(_scheduleInitialMessages);

    // Schedule initial messages
    add(ScheduleInitialMessages());
  }

  void _incrementUnreadMessages(
      IncrementUnreadMessages event, Emitter<UnreadMessagesState> emit) {
    emit(UnreadMessagesState(
      unreadCount: state.unreadCount + 1,
      messages: state.messages,
    ));
  }

  void _resetUnreadMessages(
      ResetUnreadMessages event, Emitter<UnreadMessagesState> emit) {
    emit(UnreadMessagesState(unreadCount: 0, messages: state.messages));
  }

  Future<void> _scheduleInitialMessages(
      ScheduleInitialMessages event, Emitter<UnreadMessagesState> emit) async {
    final initialMessages = [
      "Welcome to the chat!",
      "Let us know if you need help.",
      "Don't forget to check the events nearby!"
    ];

    for (var message in initialMessages) {
      await Future.delayed(const Duration(seconds: 3));
      emit(UnreadMessagesState(
        unreadCount: state.unreadCount + 1,
        messages: [...state.messages, message],
      ));
    }
  }
}
