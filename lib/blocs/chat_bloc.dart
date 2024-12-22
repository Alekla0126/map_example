import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class ChatEvent {}

class MessageReceived extends ChatEvent {
  final String eventID;
  final String message;

  MessageReceived({required this.eventID, required this.message});
}

class MessagesRead extends ChatEvent {
  final String eventID;

  MessagesRead({required this.eventID});
}

class IncrementUnreadMessages extends ChatEvent {
  final String eventID;

  IncrementUnreadMessages({required this.eventID});
}

class ResetUnreadForEvent extends ChatEvent {
  final String eventID;

  ResetUnreadForEvent({required this.eventID});
}

// State
class ChatState {
  final Map<String, List<String>> eventMessages; // Messages per event
  final Map<String, int> unreadCounts; // Unread counts per event

  const ChatState({
    required this.eventMessages,
    required this.unreadCounts,
  });

  // Initial state factory
  factory ChatState.initial() {
    return ChatState(
      eventMessages: {},
      unreadCounts: {},
    );
  }

  // Copy method to update state immutably
  ChatState copyWith({
    Map<String, List<String>>? eventMessages,
    Map<String, int>? unreadCounts,
  }) {
    return ChatState(
      eventMessages: eventMessages ?? this.eventMessages,
      unreadCounts: unreadCounts ?? this.unreadCounts,
    );
  }
}

// Bloc
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatState.initial()) {
    // Register event handlers
    on<MessageReceived>(_onMessageReceived);
    on<MessagesRead>(_onMessagesRead);
    on<IncrementUnreadMessages>(_onIncrementUnreadMessages);
    on<ResetUnreadForEvent>(_onResetUnreadForEvent);
  }

  // Event Handlers

  // Handles receiving a new message for a specific event
  void _onMessageReceived(MessageReceived event, Emitter<ChatState> emit) {
    final updatedMessages = Map<String, List<String>>.from(state.eventMessages);
    final updatedCounts = Map<String, int>.from(state.unreadCounts);

    // Add the new message to the event's messages
    updatedMessages[event.eventID] = [
      ...(updatedMessages[event.eventID] ?? []),
      event.message
    ];

    // Increment unread count for the event
    updatedCounts[event.eventID] = (updatedCounts[event.eventID] ?? 0) + 1;

    emit(state.copyWith(
      eventMessages: updatedMessages,
      unreadCounts: updatedCounts,
    ));
  }

  // Handles marking messages as read for a specific event
  void _onMessagesRead(MessagesRead event, Emitter<ChatState> emit) {
    final updatedCounts = Map<String, int>.from(state.unreadCounts);

    // Reset unread count for the event
    updatedCounts[event.eventID] = 0;

    emit(state.copyWith(unreadCounts: updatedCounts));
  }

  // Handles incrementing unread messages for a specific event
  void _onIncrementUnreadMessages(
      IncrementUnreadMessages event, Emitter<ChatState> emit) {
    final updatedCounts = Map<String, int>.from(state.unreadCounts);
    updatedCounts[event.eventID] = (updatedCounts[event.eventID] ?? 0) + 1;

    emit(state.copyWith(unreadCounts: updatedCounts));
  }

  // Handles resetting unread messages for a specific event
  void _onResetUnreadForEvent(
      ResetUnreadForEvent event, Emitter<ChatState> emit) {
    final updatedCounts = Map<String, int>.from(state.unreadCounts);
    updatedCounts[event.eventID] = 0;

    emit(state.copyWith(unreadCounts: updatedCounts));
  }
}
