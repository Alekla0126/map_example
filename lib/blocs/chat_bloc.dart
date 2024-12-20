import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class ChatEvent {}

class MessageReceived extends ChatEvent {}

class MessagesRead extends ChatEvent {}

// State
class ChatState {
  final int unreadMessages;

  ChatState(this.unreadMessages);
}

// Bloc
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatState(0));

  Stream<ChatState> mapEventToState(ChatEvent event) async* {
    if (event is MessageReceived) {
      yield ChatState(state.unreadMessages + 1);
    } else if (event is MessagesRead) {
      yield ChatState(0); // Reset unread count
    }
  }
}