import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:aligather/widgets/event.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models.dart';

class FeedPage extends StatefulWidget {
  final User user;

  const FeedPage({required this.user, super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  List<Event> events = [];

  Future<void> fetchEvents() async {
    final Uri url = Uri.parse('http://192.168.100.9:3004/event/get_all');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      setState(() {
        // Deserialize JSON into a list of Event objects
        events = (jsonResponse as List)
            .map((eventJson) => Event.fromJson(eventJson))
            .toList();
      });
    } else {
      // Handle API error, e.g., show an error message
      Fluttertoast.showToast(
          msg: 'Failed to fetch events. Status code: ${response.statusCode}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.blue,
          fontSize: 16.0
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView.builder(
          itemCount: events.length,
          itemBuilder: (BuildContext context, int index) {
            final event = events[index];
            return EventItem(user: widget.user, event: event);
          },
        ),
      )
    );
  }
}
