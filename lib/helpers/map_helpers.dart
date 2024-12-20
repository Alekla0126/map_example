



String generateMapboxUrl(bool isDarkMode) {
  final id = isDarkMode ? "mapbox/dark-v10" : "mapbox/light-v10";
  final accessToken =
      "pk.eyJ1IjoiYWxla2xhMDEyNiIsImEiOiJjbGp0NTNvd2UwM2RnM2VtbDlieHkwNTBiIn0.oEhomSTKaUBKdzIw2cyeSw";
  return "https://api.mapbox.com/styles/v1/$id/tiles/{z}/{x}/{y}?access_token=$accessToken";
}