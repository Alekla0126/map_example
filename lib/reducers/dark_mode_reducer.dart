enum DarkModeActions { ToggleDarkMode }

bool darkModeReducer(bool state, dynamic action) {
  if (action == DarkModeActions.ToggleDarkMode) {
    return !state;
  }
  return state;
}