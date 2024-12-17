import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'map_bloc.dart';

class SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mapBloc = BlocProvider.of<MapBloc>(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search...",
          border: InputBorder.none,
          suffixIcon: Icon(Icons.search),
        ),
        onSubmitted: (query) {
          mapBloc.add(SearchLocation(query));
        },
      ),
    );
  }
}
