import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:aligather/colors.dart';

import '../widgets/event.dart';
import '../models.dart';

class ForeignProfilePage extends StatefulWidget {
  const ForeignProfilePage({super.key});

  @override
  State<ForeignProfilePage> createState() => _ForeignProfilePageState();
}

class _ForeignProfilePageState extends State<ForeignProfilePage> {
  late User user;
  late User profiledUser;
  late Future<void> profileDataFuture;

  List<Event> profileUserHostedEvents = [];
  List<Event> profileUserAttendedEvents = [];
  bool _hostedEvents = false; // Track whether the list is expanded or not

  Future<void> fetchProfiledUser(String profiledUserId) async {
    final Uri url = Uri.parse('http://192.168.100.9:3004/auth/user/get');

    final Map<String, dynamic> data = {
      'userId': profiledUserId,
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
        profiledUser = User(
            id: jsonResponse['_id'],
            name: jsonResponse['name'],
            location: jsonResponse['location'],
            attends: jsonResponse['attends']
        );
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

  Future<void> fetchUserHostedEvents() async {
    final Uri url = Uri.parse('http://192.168.100.9:3004/event/user/get');

    final Map<String, dynamic> data = {
      'userId': profiledUser.id,
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
        profileUserHostedEvents = (jsonResponse as List)
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
    print("Finished getting user hosted events");

  }

  Future<void> fetchUserAttendedEvents() async {
    final Uri url = Uri.parse('http://192.168.100.9:3004/event/get_multiple');

    final Map<String, dynamic> data = {
      'eventIds': profiledUser.attends,
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
        profileUserAttendedEvents = (jsonResponse as List)
            .map((eventJson) => Event.fromJson(eventJson))
            .toList();
      });
    } else {
      // Handle API error, e.g., show an error message
      print(jsonResponse);
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
    print("Finished getting user attended events \n $profileUserAttendedEvents");
  }

  Future<void> fetchEvents() async {
    final Uri url = Uri.parse('http://192.168.100.9:3004/event/user/get_all');

    final Map<String, dynamic> data = {
      'userId': profiledUser.id,
      'attendedEventIds': profiledUser.attends
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
        profileUserAttendedEvents = (jsonResponse['attended'] as List)
            .map((eventJson) => Event.fromJson(eventJson))
            .toList();

        profileUserHostedEvents = (jsonResponse['hosted'] as List)
            .map((eventJson) => Event.fromJson(eventJson))
            .toList();

        print("Finished getting user events \n");
        print("Attended: $profileUserAttendedEvents");
        print("Hosted: $profileUserHostedEvents");
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


  Future<void> init(String profiledUserId) async {
    await fetchProfiledUser(profiledUserId);
    fetchEvents();
    // fetchUserHostedEvents();
    // fetchUserAttendedEvents();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    user = args['user'];

    profileDataFuture = init(args['profiled_user_id']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
      ),
      body: Center(
        child: Container(
          color: MyColors.ultraLight,
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
                          Text(
                            profiledUser.name,
                            style: const TextStyle(
                              fontSize: 28.0, // Adjust the font size as needed
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8), // Add spacing

                          Text(
                            profiledUser.location,
                            style: const TextStyle(
                              fontSize: 16.0, // Adjust the font size as needed
                            ),
                          ),
                          const SizedBox(height: 16), // Add more spacing

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _hostedEvents = true;
                                  });
                                  fetchEvents();
                                },
                                child: const Text('Hosted events'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _hostedEvents = false;
                                  });
                                  fetchEvents();
                                },
                                child: const Text('Attending events'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16), // Add more spacing

                          // Expandable list of EventItems
                          Expanded(
                            child: ListView.builder(
                              itemCount: _hostedEvents ? profileUserHostedEvents.length : profileUserAttendedEvents.length, // Replace with your event list
                              itemBuilder: (BuildContext context, int index) {
                                return _hostedEvents ? EventItem(
                                    user: user,
                                    event: profileUserHostedEvents[index]
                                ) : EventItem(
                                    user: user,
                                    event: profileUserAttendedEvents[index]
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }
                  }
              )
          ),
        )
      )
    );
  }
}
