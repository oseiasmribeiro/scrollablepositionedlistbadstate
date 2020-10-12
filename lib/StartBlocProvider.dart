import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.Dart';
import '_message/ReadingMessage.dart';
import '_message/bloc/ReadingMessage-bloc.dart';

class StartBlocProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      child: MyApp(),
      blocs: [
        Bloc((i) => ReadingMessageBloc()),
      ]
    );
  }
}
