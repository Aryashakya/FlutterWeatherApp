import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_weather_app/api/location.dart';
import 'package:flutter_weather_app/api/weather.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'help_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

String buttonText = 'Save';
String? location;
String? temperatureText;
String? temperatureCelsius;
String? temperatureIconUrl;
bool _isLoading = false;

saveWeather(String location, String temperatureText, String temperatureCelsius,
    String temperatureIconUrl) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("location", location);
  await prefs.setString("temperatureText", temperatureText);
  await prefs.setString("temperatureCelsius", temperatureCelsius);
  await prefs.setString("temperatureIconUrl", temperatureIconUrl);
}

getSavedWeather() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  location = prefs.getString("location");
  temperatureText = prefs.getString("temperatureText");
  temperatureCelsius = prefs.getString("temperatureCelsius");
  temperatureIconUrl = prefs.getString("temperatureIconUrl");
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  final TextEditingController _locationController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _locationController.dispose();
    _connectivitySubscription.cancel();
  }

  @override
  void initState() {
    super.initState();
    initialize();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  initialize() async {
    await initConnectivity();
    await getSavedWeather();
    if (mounted) {

      if (_locationController.text.isEmpty &&
          location == null &&
          _connectionStatus != ConnectivityResult.none) {
        setState(() {
          _isLoading = true;
        });
        await getCurrentData();
      }
      if (location != null) {
        _locationController.text = location!;
      }
      if (_locationController.text == location) {
        setState(() {
          buttonText = 'Update';
        });
      } else {
        setState(() {
          buttonText = 'Save';
        });
      }
    }
  }

  getCurrentData() async {
    Position? currentPosition;
    Map? data;
    currentPosition = await getCurrentPosition();
    if (currentPosition != null) {
      data = await getWeather(
          '${currentPosition.latitude},${currentPosition.longitude}');
    }
    if (data != null) {
      if (mounted) {
        setState(() {
          location = data!['location'];
          temperatureText = data['temp_text'];
          temperatureCelsius = data['temp_c'].toString();
          temperatureIconUrl = 'http://${data['temp_icon'].substring(2)}';
          _isLoading = false;
        });
        if (location != null) {
          await saveWeather(location!, temperatureText!, temperatureCelsius!,
              temperatureIconUrl!);
        }
      }
    }
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }

    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
    await getSavedWeather();
    if (_connectionStatus != ConnectivityResult.none &&
        _locationController.text.isEmpty &&
        location == null) {
      await getCurrentData();
    }
    if (location != null) {
      _locationController.text = location!;
    }
    if (_locationController.text == location) {
      setState(() {
        buttonText = 'Update';
      });
    } else {
      setState(() {
        buttonText = 'Save';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const HelpScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.help))
        ],
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
        title: Text(
          "Weather App",
          style: GoogleFonts.lora(fontSize: 32.0),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: (_connectionStatus == ConnectivityResult.none)
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_outlined, size: 80),
                      const SizedBox(
                        height: 20.0,
                      ),
                      Text(
                        "Please connect to internet",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    const SizedBox(height: 30.0),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              if (_locationController.text == location) {
                                setState(() {
                                  buttonText = 'Update';
                                });
                              } else {
                                setState(() {
                                  buttonText = 'Save';
                                });
                              }
                            },
                            controller: _locationController,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: InputDecoration(
                              hintText: "Enter name of location",
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                  width: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                  width: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              contentPadding: const EdgeInsets.all(8.0),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            if (_locationController.text.isNotEmpty) {
                              setState(() {
                                _isLoading = true;
                              });
                              Map? data;
                              data = await getWeather(_locationController.text);
                              if (data != null) {
                                setState(() {
                                  location = data!['location'];
                                  temperatureText = data['temp_text'];
                                  temperatureCelsius =
                                      data['temp_c'].toString();
                                  temperatureIconUrl =
                                      'http://${data['temp_icon'].substring(2)}';
                                  _isLoading = false;
                                });
                                if (location != null) {
                                  await saveWeather(location!, temperatureText!,
                                      temperatureCelsius!, temperatureIconUrl!);
                                }
                              }
                              if (data == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Error: Cannot get temperature.')));
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            }
                            if (_locationController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Error: Location Name is empty.')));
                            }
                          },
                          child: Text(buttonText),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 80.0,
                    ),
                    (_isLoading || location == null)
                        ? const Center(
                            child: CircularProgressIndicator.adaptive())
                        : Column(
                            children: [
                              Text(
                                location!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 40.0,
                              ),
                              Text(
                                '$temperatureCelsius °C',
                                style: GoogleFonts.lato(fontSize: 24),
                              ),
                              const SizedBox(
                                height: 40.0,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(temperatureIconUrl!),
                                  const SizedBox(
                                    width: 20.0,
                                  ),
                                  Text(
                                    temperatureText!,
                                    style: GoogleFonts.lato(fontSize: 20),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ],
                ),
        ),
      ),
    );
  }
}
