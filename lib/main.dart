import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'models/picture.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String apiKey = 'R1q1obcW0W5Nb7rbamf1pM4YA3p_nZ2X0nliEKwSZDo';
  final TextEditingController _searchImageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchTerm = 'star wars';
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  final List<Picture> _images = <Picture>[];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random Images'),
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                    controller: _searchImageController,
                    decoration: const InputDecoration(
                      label: Text('Image theme...'),
                      prefixIcon: Icon(Icons.search),
                      prefixIconColor: Colors.lightBlue,
                    )),
              ),
              TextButton(
                  onPressed: () {
                    _searchTerm = _searchImageController.text;
                    if (_searchTerm.isEmpty) {
                      _searchTerm = 'random';
                    }
                    _page = 1;
                    getImages(search: _searchTerm, page: 1);
                  },
                  style: TextButton.styleFrom(backgroundColor: Colors.lightBlue, foregroundColor: Colors.white),
                  child: const Text('Search'))
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: _images.isEmpty
                ? const Center(
                    child: Text(
                      'No Images Found',
                      style: TextStyle(fontSize: 50),
                    ),
                  )
                : GridView.builder(
                    controller: _scrollController,
                    itemCount: _images.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Picture picture = _images[index];

                      return Stack(
                        fit: StackFit.expand,
                        children: [
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
                                        colors: [Colors.white10, Colors.transparent])),
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
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getImages(page: _page);

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final height = MediaQuery.of(context).size.height;
    final double offset = _scrollController.position.pixels;
    final double maxRange = _scrollController.position.maxScrollExtent;

    if (_hasMore && !_isLoading && (maxRange - offset) < height * 3) {
      getImages(page: ++_page);
    }
  }

  Future<void> getImages({String? search, required int page}) async {
    setState(() {
      _isLoading = true;
    });
    if (page == 1) {
      _images.clear();
    }
    final String query = search ?? _searchTerm;
    final http.Client client = http.Client();
    final Uri uri = Uri.parse('https://api.unsplash.com/search/photos?query=$query&per_page=38&page=$page');
    final http.Response response =
        await client.get(uri, headers: <String, String>{'Authorization': 'Client-ID $apiKey'});
    if (response.statusCode == 200) {
      final Map<String, dynamic> result = jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> imageResults = result['results'] as List<dynamic>;
      _hasMore = int.parse(result['total_pages'] as String) < page;

      setState(() {
        _images.addAll(imageResults.cast<Map<dynamic, dynamic>>().map((Map json) => Picture.fromJson(json)));
        _isLoading = false;
      });
    }
  }
}
