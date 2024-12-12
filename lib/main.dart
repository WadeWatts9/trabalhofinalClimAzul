import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(const WeatherApp());

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String apiKey = "4d3ffd1fad51784814aab94e259d453d"; // API Key de Weatherstack.
  String location = "Rivera, Uruguay";
  String currentWeather = "Cargando clima...";
  String weatherDetails = "";

  final TextEditingController locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getWeather(location); // Carga el clima de Rivera al iniciar.
  }

  Future<void> getWeather(String loc) async {
    final url = Uri.parse(
        "http://api.weatherstack.com/current?access_key=$apiKey&query=$loc");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data != null && data['current'] != null && data['location'] != null) {
        setState(() {
          currentWeather =
              "${data['current']['temperature']}°C, ${data['current']['weather_descriptions'][0]}";
          weatherDetails = """
Humedad: ${data['current']['humidity']}%
Viento: ${data['current']['wind_speed']} km/h
Presión: ${data['current']['pressure']} hPa
          """;
        });
      } else {
        setState(() {
          currentWeather = "Datos del clima no disponibles.";
          weatherDetails = "";
        });
      }
    } else {
      setState(() {
        currentWeather = "Error al obtener datos del clima.";
        weatherDetails = "";
      });
      print("Error: ${response.body}");
    }
  }

  Future<void> getCurrentLocationWeather() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      String loc =
          "${position.latitude},${position.longitude}"; // Coordenadas actuales.
      await getWeather(loc);
    } catch (e) {
      print("Error obteniendo ubicación: $e");
      setState(() {
        currentWeather = "No se pudo obtener la ubicación actual.";
        weatherDetails = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ClimAzul"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: getCurrentLocationWeather,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: "Buscar ubicación",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (locationController.text.isNotEmpty) {
                      setState(() {
                        location = locationController.text;
                        getWeather(location);
                      });
                    }
                  },
                  child: const Text("Buscar"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (currentWeather.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        "Clima actual en $location:",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        currentWeather,
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        weatherDetails,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
