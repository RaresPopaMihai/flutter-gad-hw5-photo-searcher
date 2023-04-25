import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
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
  static const String API_KEY = 'R1q1obcW0W5Nb7rbamf1pM4YA3p_nZ2X0nliEKwSZDo';
  final TextEditingController _searchImageController = TextEditingController();
  String searchTerm = 'star wars';
  final List<String> _images = <String>[];

  @override
  void initState() {
    super.initState();
    getImages();
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
                  )
                ),
              ),
              TextButton(
                  onPressed: () {
                    searchTerm = _searchImageController.text;
                    if (searchTerm.isEmpty) {
                      searchTerm = 'random';
                    }
                    getImages(search: searchTerm);
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
                    itemCount: _images.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GridTile(child: Image.network(_images[index]));
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

  Future<void> getImages({String? search}) async {
    _images.clear();
    final String query = search ?? searchTerm;
    final http.Client client = http.Client();
    final Uri uri = Uri.parse('https://api.unsplash.com/search/photos?query=$query');
    final http.Response response =
        await client.get(uri, headers: <String, String>{'Authorization': 'Client-ID $API_KEY'});
    if (response.statusCode == 200) {
      final Map<String, dynamic> result = jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> imageResults = result['results'] as List<dynamic>;
      setState(() {
        for (final dynamic imageResult in imageResults) {
          final Map<String, dynamic> image = imageResult as Map<String, dynamic>;
          final Map<String, dynamic> imageUrl = image['urls'] as Map<String, dynamic>;

          _images.add(imageUrl['regular'] as String);
        }
      });
    }
  }
}
