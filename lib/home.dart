import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  var _locationData;
  late List<dynamic> _weatherData;
  var _isLoading = true;
  var _isCelsius = true;

  final apiKey = 'd638fba0f934931377c87630fd7a9545';

  @override
  void initState() {
    super.initState();
    _getLocationData();
  }

  Future<void> _getLocationData() async {
    var locationService = Location();
    _locationData = await locationService.getLocation();
    _getWeatherData();
  }

  Future<void> _getWeatherData() async {
    var lat = _locationData.latitude;
    var lon = _locationData.longitude;

    // Fetch the current weather data
    var currentWeatherUrl =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey';
    var currentWeatherResponse = await http.get(Uri.parse(currentWeatherUrl));

    // Fetch the forecast data for the next 5 days
    var forecastUrl =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&units=metric&appid=$apiKey';
    var forecastResponse = await http.get(Uri.parse(forecastUrl));

    if (currentWeatherResponse.statusCode == 200 &&
        forecastResponse.statusCode == 200) {
      var currentWeatherData = json.decode(currentWeatherResponse.body);
      var forecastData = json.decode(forecastResponse.body);

      setState(() {
        _isLoading = false;
        _weatherData = [currentWeatherData, ...forecastData['list']];
      });
    } else {
      print('Failed to fetch weather data');
    }
  }

  String _formatTemperature(double temperature) {
    return _isCelsius ? '$temperature°C' : '${temperature * 1.8 + 32}°F';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Weather App')),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_weatherData[0]['name']}, ${_weatherData[0]['sys']['country']}',
                    style: TextStyle(fontSize: 20, color: Colors.green[600]),
                  ),
                  SizedBox(height: 10),
                  Text(
                    _formatTemperature(_weatherData[0]['main']['temp']),
                    style: TextStyle(fontSize: 44, color: Colors.blue[600]),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              _isCelsius = true;
                            });
                          },
                          child: Image.network(
                            'https://img.icons8.com/external-yogi-aprelliyanto-basic-outline-yogi-aprelliyanto/64/228BE6/external-celsius-weather-yogi-aprelliyanto-basic-outline-yogi-aprelliyanto.png',
                            width: 30,
                            height: 30,
                            fit: BoxFit.cover,
                          )),
                      SizedBox(width: 30),
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              _isCelsius = false;
                            });
                          },
                          child: Image.network(
                            'https://img.icons8.com/external-yogi-aprelliyanto-basic-outline-yogi-aprelliyanto/64/228BE6/external-fahrenheit-weather-yogi-aprelliyanto-basic-outline-yogi-aprelliyanto.png',
                            width: 30,
                            height: 30,
                            fit: BoxFit.cover,
                          )),
                    ],
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: PageScrollPhysics(),
                    itemCount: _weatherData.length,
                    itemBuilder: (context, index) {
                      var weather = _weatherData[index];
                      var date = DateTime.fromMillisecondsSinceEpoch(
                          weather['dt'] * 1000);
                      var day = DateFormat('EEEE').format(date);
                      var time = DateFormat('jm').format(date);
                      var temperature = weather['main']['temp'];
                      var iconCode = weather['weather'][0]['icon'];
                      var isCurrentWeather = index == 0;

                      return Card(
                        child: ListTile(
                          leading: Image.network(
                              'https://openweathermap.org/img/w/$iconCode.png'),
                          title: Text('$day, $time'),
                          subtitle: Text('${_formatTemperature(temperature)}'),
                          trailing: isCurrentWeather
                              ? null
                              : Text(
                                  '${weather['weather'][0]['description']}',
                                  style: TextStyle(fontSize: 12),
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
