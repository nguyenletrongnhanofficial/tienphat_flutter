import 'package:http/http.dart' as http;

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
