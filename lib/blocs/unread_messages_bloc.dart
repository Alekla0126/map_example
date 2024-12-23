import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

// ----------------------------------------------------------------------
// EVENTS
// ----------------------------------------------------------------------
abstract class UnreadMessagesEvent {}

class AddMessageToEvent extends UnreadMessagesEvent {
  final String eventID;
  final String message;
  AddMessageToEvent({required this.eventID, required this.message});
}

class ResetUnreadForEvent extends UnreadMessagesEvent {
  final String eventID;
  ResetUnreadForEvent({required this.eventID});
}

class ScheduleInitialMessagesForEvent extends UnreadMessagesEvent {
  final String eventID;
  ScheduleInitialMessagesForEvent({required this.eventID});
}

class IncrementUnreadMessages extends UnreadMessagesEvent {
  final String eventID;
  IncrementUnreadMessages({required this.eventID});
}

class MarkInitialMessagesSent extends UnreadMessagesEvent {
  final String eventID;
  MarkInitialMessagesSent(this.eventID);
}

// ----------------------------------------------------------------------
// STATE
// ----------------------------------------------------------------------

class UnreadMessagesState {
  final Map<String, int> eventUnreadCounts;
  final Map<String, List<String>> eventMessages;
  final Set<String> hasSentInitialMessages;

  UnreadMessagesState({
    required this.eventUnreadCounts,
    required this.eventMessages,
    required this.hasSentInitialMessages,
  });

  factory UnreadMessagesState.initial() {
    return UnreadMessagesState(
      eventUnreadCounts: {},
      eventMessages: {},
      hasSentInitialMessages: {},
    );
  }

  UnreadMessagesState copyWith({
    Map<String, int>? eventUnreadCounts,
    Map<String, List<String>>? eventMessages,
    Set<String>? hasSentInitialMessages,
  }) {
    return UnreadMessagesState(
      eventUnreadCounts: eventUnreadCounts ?? this.eventUnreadCounts,
      eventMessages: eventMessages ?? this.eventMessages,
      hasSentInitialMessages:
          hasSentInitialMessages ?? this.hasSentInitialMessages,
    );
  }
}

// ----------------------------------------------------------------------
// BLOC
// ----------------------------------------------------------------------

class UnreadMessagesBloc
    extends Bloc<UnreadMessagesEvent, UnreadMessagesState> {
  UnreadMessagesBloc() : super(UnreadMessagesState.initial()) {
    on<AddMessageToEvent>(_onAddMessageToEvent);
    on<ResetUnreadForEvent>(_onResetUnreadForEvent);
    on<ScheduleInitialMessagesForEvent>(_onScheduleInitialMessagesForEvent);
    on<IncrementUnreadMessages>(_onIncrementUnreadMessages);
    on<MarkInitialMessagesSent>(_onMarkInitialMessagesSent);
  }

  void _onAddMessageToEvent(
    AddMessageToEvent event,
    Emitter<UnreadMessagesState> emit,
  ) {
    final updatedEventMessages =
        Map<String, List<String>>.from(state.eventMessages);
    final updatedUnreadCounts = Map<String, int>.from(state.eventUnreadCounts);

    updatedEventMessages[event.eventID] = [
      ...?updatedEventMessages[event.eventID],
      event.message
    ];

    updatedUnreadCounts[event.eventID] =
        (updatedUnreadCounts[event.eventID] ?? 0) + 1;

    emit(state.copyWith(
      eventMessages: updatedEventMessages,
      eventUnreadCounts: updatedUnreadCounts,
    ));

    print("Message added to ${event.eventID}: ${event.message}");
  }

  void _onResetUnreadForEvent(
    ResetUnreadForEvent event,
    Emitter<UnreadMessagesState> emit,
  ) {
    final updatedUnreadCounts = Map<String, int>.from(state.eventUnreadCounts);

    updatedUnreadCounts[event.eventID] = 0;

    emit(state.copyWith(
      eventUnreadCounts: updatedUnreadCounts,
    ));

    print("Unread messages reset for ${event.eventID}");
  }

  Future<void> _onScheduleInitialMessagesForEvent(
    ScheduleInitialMessagesForEvent event,
    Emitter<UnreadMessagesState> emit,
  ) async {
    final initialMessages = [
      "Welcome to event \"${event.eventID}\"!",
      "Let us know if you need help here.",
      "Don't forget to check the other events too!"
    ];

    for (var message in initialMessages) {
      Future.delayed(const Duration(seconds: 3), () {
        add(AddMessageToEvent(eventID: event.eventID, message: message));
      });
    }

    print("Scheduled initial messages for ${event.eventID}");
  }

  void _onIncrementUnreadMessages(
    IncrementUnreadMessages event,
    Emitter<UnreadMessagesState> emit,
  ) {
    final updatedUnreadCounts = Map<String, int>.from(state.eventUnreadCounts);

    updatedUnreadCounts[event.eventID] =
        (updatedUnreadCounts[event.eventID] ?? 0) + 1;

    emit(state.copyWith(eventUnreadCounts: updatedUnreadCounts));

    print("Unread messages incremented for ${event.eventID}");
  }

  void _onMarkInitialMessagesSent(
    MarkInitialMessagesSent event,
    Emitter<UnreadMessagesState> emit,
  ) {
    final updatedHasSent = Set<String>.from(state.hasSentInitialMessages);
    updatedHasSent.add(event.eventID);

    emit(state.copyWith(hasSentInitialMessages: updatedHasSent));
  }
}
