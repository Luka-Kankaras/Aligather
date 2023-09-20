import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:aligather/colors.dart';

import '../models.dart';


class EventItem extends StatefulWidget {
  final User user;
  final Event event;

  const EventItem({super.key, required this.user, required this.event});

  @override
  State<EventItem> createState() => _EventItemState();
}

class _EventItemState extends State<EventItem> {

  bool isAttending = false;
  bool isIconCooldown = false;

  Future<void> updateAttends(String eventId, String userId, List<dynamic> eventAttends, List<dynamic> userAttends) async {
    final Uri url = Uri.parse('http://192.168.100.9:3004/event/ultimo');

    // Create a map containing the data you want to send as JSON
    final Map<String, dynamic> data = {
      'eventId': eventId,
      'eventAttends': eventAttends,
      'userId': userId,
      'userAttends': userAttends
    };

    // Encode the map as JSON
    final String jsonData = jsonEncode(data);

    // Set the request headers
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    await http.post(
      url,
      headers: headers,
      body: jsonData,
    );
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      isAttending = widget.event.attends.contains(widget.user.id);
    });

    return Container(
      margin: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: isAttending ? Colors.teal : Colors.blue,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Container(
            decoration: BoxDecoration(
              color: MyColors.light,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/f_profile', arguments: {
                        'user': widget.user,
                        'profiled_user_id': widget.event.hostId
                      });
                    },
                    child: Text(
                      widget.event.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hosted by: ${widget.event.hostName}',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Location: ${widget.event.location}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Divider(
                    color: isAttending ? Colors.teal : Colors.blue,
                    thickness: 1,
                  ),
                  Text(
                    widget.event.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  CachedNetworkImage(
                    imageUrl:
                    'http://192.168.100.9:3004/assets/${widget.event.picturePath}',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, ur1) => const CircularProgressIndicator(),
                    errorWidget: (context, ur1, error) => const Icon(Icons.error),
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    alignment: Alignment.bottomRight, // Set alignment to bottom right
                    children: [
                      IconButton(
                        icon: const Icon(Icons.airplane_ticket),
                        color: isAttending ? Colors.teal : Colors.blue,
                        onPressed: () async {
                          if(isIconCooldown) return;

                          setState(() {
                            isIconCooldown = true;
                          });

                          if (isAttending) {
                            widget.event.attends.remove(widget.user.id);
                            widget.user.attends.remove(widget.event.id);
                          } else {
                            widget.event.attends.add(widget.user.id);
                            widget.user.attends.add(widget.event.id);
                          }

                          // Update live data
                          await updateAttends(widget.event.id, widget.user.id,
                              widget.event.attends, widget.user.attends);

                          setState(() {
                            isAttending = !isAttending;
                            isIconCooldown = false;
                          });
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isAttending ? Colors.teal : Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${widget.event.attends.length}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}


