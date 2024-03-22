import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

class SvgFromWeb extends StatefulWidget {
  final String svgUrl;

  SvgFromWeb({Key? key, required this.svgUrl}) : super(key: key);

  @override
  _SvgFromWebState createState() => _SvgFromWebState();
}

class _SvgFromWebState extends State<SvgFromWeb> {
  late Future<String> svgData;

  @override
  void initState() {
    super.initState();
    svgData = fetchSvgData(widget.svgUrl);
  }

  Future<String> fetchSvgData(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      String svgData = response.body;
      svgData = svgData.replaceAll('width="100%"', '');
      svgData = svgData.replaceAll('height="100%"', '');
      return svgData;
    } else {
      throw Exception('Failed to load SVG data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: svgData,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData) {
          return SvgPicture.string(
            snapshot.data!,
            fit: BoxFit.contain,
          );
        } else if (snapshot.hasError) {
          return const Text('Error loading SVG.');
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
