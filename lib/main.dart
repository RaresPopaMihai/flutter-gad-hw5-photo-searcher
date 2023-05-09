import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:homework5/src/actions/index.dart';
import 'package:homework5/src/reducer/app_reducer.dart';
import 'package:http/http.dart';
import 'package:redux/redux.dart';
import 'package:redux_epics/redux_epics.dart';

import 'src/data/unsplash_api.dart';
import 'src/epics/app_epics.dart';
import 'src/models/index.dart';
import 'src/presentation/containers/index.dart';

void main() {
  final String apiKey = 'R1q1obcW0W5Nb7rbamf1pM4YA3p_nZ2X0nliEKwSZDo';
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ImagesContainer(
        builder: (BuildContext context, List<Picture> images) {
          return GridView.builder(
            itemCount: images.length,
            itemBuilder: (BuildContext context, int index) {
              final Picture picture = images[index];

              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  GridTile(
                    child: Image.network(
                      picture.urls.regular,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Align(
                      alignment: AlignmentDirectional.bottomEnd,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: AlignmentDirectional.topCenter,
                            colors: <Color>[Colors.white10, Colors.transparent],
                          ),
                        ),
                        child: ListTile(
                          title: Text(picture.user.name),
                          trailing: CircleAvatar(
                            backgroundImage: NetworkImage(picture.user.profileImage.small),
                          ),
                        ),
                      )),
                ],
              );
            },
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
          );
        },
      ),
    );
  }
}
