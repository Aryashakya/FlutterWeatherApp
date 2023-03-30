import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

const apiKey = String.fromEnvironment('API_KEY');

Future<Map?> getWeather(String location) async {
  if (apiKey.isEmpty) {
    throw AssertionError('API_KEY is not set');
  }
  var url = Uri.http(
      'api.weatherapi.com', '/v1/current.json', {'key': apiKey, 'q': location});
  var response = await http.get(url);
  if (response.statusCode == 200) {
    var jsonResponse =
        convert.jsonDecode(response.body) as Map<String, dynamic>;

    return {
      'location': jsonResponse['location']['name'],
      'temp_c': jsonResponse['current']['temp_c'],
      'temp_text': jsonResponse['current']['condition']['text'],
      'temp_icon': jsonResponse['current']['condition']['icon']
    };
  } else {
    return null;
  }
}
