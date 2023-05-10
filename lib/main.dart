import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:http/http.dart';
import 'package:redux/redux.dart';
import 'package:redux_epics/redux_epics.dart';

import 'src/actions/index.dart';
import 'src/data/unsplash_api.dart';
import 'src/epics/app_epics.dart';
import 'src/models/index.dart';
import 'src/presentation/home_page.dart';
import 'src/reducer/app_reducer.dart';

void main() {
  const String apiKey = 'R1q1obcW0W5Nb7rbamf1pM4YA3p_nZ2X0nliEKwSZDo';
  final Client client = Client();
  final UnsplashApi api = UnsplashApi(client, apiKey);
  final AppEpics epic = AppEpics(api);
  final Store<AppState> store = Store<AppState>(reducer,
      initialState: const AppState(), middleware: <Middleware<AppState>>[EpicMiddleware<AppState>(epic.call).call]);

  store.dispatch(GetImages.start(page: store.state.page, search: store.state.searchTerm));

  runApp(MyApp(store: store));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.store});

  final Store<AppState> store;

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: const HomePage(),
      ),
    );
  }
}
