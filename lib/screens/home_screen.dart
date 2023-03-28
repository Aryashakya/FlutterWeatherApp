import 'package:flutter/material.dart';
import 'package:flutter_weather_app/api/location.dart';
import 'package:flutter_weather_app/api/weather.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

import 'help_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _locationController = TextEditingController();
  String buttonText = 'Save';
  String location = '';
  String temperatureText = '';
  String temperatureCelsius = '';
  String temperatureIconUrl = '';
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _locationController.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
      if (_locationController.text.isEmpty) {
        getCurrentData();
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
      setState(() {
        location = data!['location'];
        temperatureText = data['temp_text'];
        temperatureCelsius = data['temp_c'].toString();
        temperatureIconUrl = 'http://${data['temp_icon'].substring(2)}';
        _isLoading = false;
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
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
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
                          print('data: $data');
                          setState(() {
                            location = data!['location'];
                            temperatureText = data['temp_text'];
                            temperatureCelsius = data['temp_c'].toString();
                            temperatureIconUrl =
                                'http://${data['temp_icon'].substring(2)}';
                            _isLoading = false;
                          });
                        }
                        if (data == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Error: Cannot get temperature.')));
                          _isLoading = false;
                        }
                      }
                      if (_locationController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Error: Location Name is empty.')));
                      }
                    },
                    child: Text(buttonText),
                  )
                ],
              ),
              const SizedBox(
                height: 80.0,
              ),
              _isLoading
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : Column(
                      children: [
                        Text(
                          location,
                          style: GoogleFonts.lato(
                              fontSize: 40, fontWeight: FontWeight.bold),
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
                            Image.network(temperatureIconUrl),
                            const SizedBox(
                              width: 20.0,
                            ),
                            Text(
                              temperatureText,
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
