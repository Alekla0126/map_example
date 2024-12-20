import 'package:flutter_bloc/flutter_bloc.dart';

/// Dark Mode Events
abstract class DarkModeEvent {}

class ToggleDarkMode extends DarkModeEvent {}

/// Dark Mode State
class DarkModeBlocState {
  final bool isDarkMode;

  DarkModeBlocState({required this.isDarkMode});
}

/// Dark Mode BLoC
class DarkModeBloc extends Bloc<DarkModeEvent, DarkModeBlocState> {
  DarkModeBloc() : super(DarkModeBlocState(isDarkMode: false));

  Stream<DarkModeBlocState> mapEventToState(DarkModeEvent event) async* {
    if (event is ToggleDarkMode) {
      yield DarkModeBlocState(isDarkMode: !state.isDarkMode);
    }
  }
}

// Dark Mode State
class DarkModeState {
  final bool isDarkMode;

  DarkModeState({required this.isDarkMode});

  DarkModeState toggle() {
    return DarkModeState(isDarkMode: !isDarkMode);
  }

  static DarkModeState initialState() {
    return DarkModeState(isDarkMode: false); // Default to light mode
  }
}