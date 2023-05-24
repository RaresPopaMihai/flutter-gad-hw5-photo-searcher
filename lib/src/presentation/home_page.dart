import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../actions/index.dart';
import '../models/index.dart';
import 'containers/index.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final double height = MediaQuery.of(context).size.height;
    final double offset = _scrollController.position.pixels;
    final double maxScrollExtent = _scrollController.position.maxScrollExtent;
    final Store<AppState> store = StoreProvider.of<AppState>(context);
    if (store.state.hasMore && !store.state.isLoading && maxScrollExtent - offset < 3 * height) {
      store.dispatch(GetImages.start(page: store.state.page, search: store.state.searchTerm));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration.collapsed(hintText: 'Picture Theme...'),
          onChanged: (String value) {
            if (value.isEmpty) {
              return;
            }
            StoreProvider.of<AppState>(context).dispatch(GetImages.start(page: 1, search: value));
          },
        ),
      ),
      body: IsLoadingContainer(builder: (BuildContext context, bool isLoading) {
        return ImagesContainer(builder: (BuildContext context, List<Picture> images) {
          if (isLoading && images.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final Picture picture = images[index];

                    return GestureDetector(
                      onTap: (){
                        StoreProvider.of<AppState>(context).dispatch(SetSelectedImage(picture.id));
                         Navigator.pushNamed(context, '/details');
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          GridTile(
                            child: CachedNetworkImage(
                              imageUrl: picture.urls.regular,
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
                      ),
                    );
                  },
                  childCount: images.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
              ),
              if (isLoading)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
            ],
          );
        });
      }),
    );
  }
}
