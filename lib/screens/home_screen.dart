// ignore_for_file: use_build_context_synchronously, use_key_in_widget_constructors, library_private_types_in_public_api

import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tienphat_flutter/screens/login_screen.dart';
import '../widgets/svg_from_web.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  List<dynamic> _posts = [];
  String _currentSort = 'date';

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    _loadPosts();
  }

  Future<void> _loadUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      setState(() {});
    }
  }

  Future<void> _loadPosts() async {
    await Future.delayed(Duration(seconds: Random().nextInt(3) + 2));
    final dataString = await rootBundle.loadString('assets/data.json');
    final List<dynamic> data = jsonDecode(dataString);

    setState(() {
      _posts = data;
      _sortPosts();
      _isLoading = false;
    });
  }

  void _sortPosts() {
    _posts.sort((a, b) {
      switch (_currentSort) {
        case 'like':
          return b['liked'].compareTo(a['liked']);
        case 'share':
          return b['shared'].compareTo(a['shared']);
        case 'comment':
          return b['comments'].compareTo(a['comments']);
        case 'date':
        default:
          return b['createdDate'].compareTo(a['createdDate']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          DropdownButton<String>(
            value: _currentSort,
            onChanged: (String? newValue) {
              setState(() {
                _currentSort = newValue!;
                _sortPosts();
              });
            },
            items: <String>['date', 'like', 'share', 'comment']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text('Sort by: $value'),
              );
            }).toList(),
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('user');
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => LoginScreen()));
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: SpinKitCircle(
                color: Colors.blue,
                size: 50.0,
              ),
            )
          : ListView.builder(
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SvgFromWeb(
                        svgUrl: _posts[index]['image'],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(_posts[index]['title'],
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Likes: ${_posts[index]['liked']}'),
                            Text('Shares: ${_posts[index]['shared']}'),
                            Text('Comments: ${_posts[index]['comments']}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
