import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../widgets/event.dart';
import '../models.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({required this.user, super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Event> userHostedEvents = [];
  List<Event> userAttendedEvents = [];
  bool _hostedEvents = false; // Track whether the list is expanded or not
  late Future<void> profileDataFuture = init();

  Future<void> fetchUserHostedEvents() async {
    final Uri url = Uri.parse('http://192.168.100.9:3004/event/user/get');

    final Map<String, dynamic> data = {
      'userId': widget.user.id,
    };

    // Encode the map as JSON
    final String jsonData = jsonEncode(data);

    // Set the request headers
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonData,
    );
    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      setState(() {
        // Deserialize JSON into a list of Event objects
        userHostedEvents = (jsonResponse as List)
            .map((eventJson) => Event.fromJson(eventJson))
            .toList();
      });
    } else {
      // Handle API error, e.g., show an error message
      Fluttertoast.showToast(
          msg: '${jsonResponse['error']}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.blue,
          fontSize: 16.0
      );
    }
  }

  Future<void> fetchUserAttendedEvents() async {
    final Uri url = Uri.parse('http://192.168.100.9:3004/event/get_multiple');

    final Map<String, dynamic> data = {
      'eventIds': widget.user.attends,
    };

    // Encode the map as JSON
    final String jsonData = jsonEncode(data);

    // Set the request headers
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonData,
    );
    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      setState(() {
        // Deserialize JSON into a list of Event objects
        userAttendedEvents = (jsonResponse as List)
            .map((eventJson) => Event.fromJson(eventJson))
            .toList();
      });
    } else {
      // Handle API error, e.g., show an error message
      Fluttertoast.showToast(
          msg: '${jsonResponse['error']}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.blue,
          fontSize: 16.0
      );
    }
  }

  Future<void> init() async {
    await fetchUserHostedEvents();
    await fetchUserAttendedEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<void>(
            future: profileDataFuture,
            builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // Loading indicator while fetching data
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Display user's name with a big font
                  Text(
                    widget.user.name,
                    style: const TextStyle(
                      fontSize: 28.0, // Adjust the font size as needed
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8), // Add spacing

                  // Display user's location
                  Text(
                    widget.user.location,
                    style: const TextStyle(
                      fontSize: 16.0, // Adjust the font size as needed
                    ),
                  ),
                  const SizedBox(height: 16), // Add more spacing

                  // Display a drop-down list of events hosted by the user
                  // You can use a ListView or a DropdownButton, depending on your design
                  // Example using ListView:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _hostedEvents = true;
                          });
                          await fetchUserHostedEvents();
                        },
                        child: const Text('Hosted events'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _hostedEvents = false;
                          });
                          await fetchUserAttendedEvents();
                        },
                        child: const Text('Attending events'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16), // Add more spacing
                  // Expandable list of EventItems
                  Expanded(
                    child: ListView.builder(
                      itemCount: _hostedEvents ? userHostedEvents.length : userAttendedEvents.length,
                      itemBuilder: (BuildContext context, int index) {
                        return EventItem(
                          user: widget.user,
                          event: _hostedEvents ? userHostedEvents[index] : userAttendedEvents[index],
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          }
        )
      )
    );
  }
}
