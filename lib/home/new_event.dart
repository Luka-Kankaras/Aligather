import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aligather/colors.dart';
import 'dart:math';

import '../models.dart';

class NewEventPage extends StatefulWidget {
  final User user;

  const NewEventPage({required this.user, Key? key}) : super(key: key);

  @override
  State<NewEventPage> createState() => _NewEventPageState();
}

class _NewEventPageState extends State<NewEventPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _getImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _selectedImage = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  Future<void> _addEvent({
    required String hostId,
    required String hostName,
    required String name,
    required String description,
    required String location,
    required File? imageFile, // Pass the selected image file here
  }) async {
    final Uri url = Uri.parse('http://192.168.100.9:3004/event/add'); // Replace with your server URL

    if(imageFile == null) return;

    try {
      final request = http.MultipartRequest('POST', url);

      // Add the hostId, name, description, and location as request fields
      request.fields['hostId'] = hostId;
      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['location'] = location;
      request.fields['hostName'] = hostName;

      Random random = Random();
      final seed = random.nextInt(100000);
      final DateTime now = DateTime.now();
      final timestamp = '${now.hour}:${now.minute}:${now.second}';
      final extension = imageFile.path.split('.').last;
      final picturePath = '${hostId}_${seed}_$timestamp.$extension';
      request.fields['picturePath'] = picturePath;

      // Attach the image file to the request
      request.files.add(http.MultipartFile(
        'picture', // This should match the field name you used on the server ('picture' in your Node.js code)
        http.ByteStream(imageFile.openRead()), // Byte stream of the image file
        await imageFile.length(), // Length of the image file in bytes
        filename: picturePath, // Name to give to the file on the server
      ));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      if (response.statusCode == 201) {
        // Event creation was successful
        Fluttertoast.showToast(
            msg: 'Event added!',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.blue,
            fontSize: 16.0
        );


      } else {
        // Handle errors
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
    } catch (e) {
      // Handle exceptions
      Fluttertoast.showToast(
          msg: 'Error: $e',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.blue,
          fontSize: 16.0
      );
    }
  }

  Future<void> _handleAddEvent() async {
    if (_formKey.currentState!.validate()) {
      // Start loading
      setState(() {
        _isLoading = true;
      });

      try {
        // Call addEvent and wait for it to complete
        await _addEvent(
          hostId: widget.user.id,
          hostName: widget.user.name,
          name: _nameController.text,
          description: _descriptionController.text,
          location: _locationController.text,
          imageFile: _selectedImage,
        );

        // Reset the form
        _formKey.currentState!.reset();
        _nameController.text = '';
        _locationController.text = '';
        _descriptionController.text = '';

        // Clear the selected image
        setState(() {
          _selectedImage = null;
        });
      } catch (e) {
        // Handle any errors that occur during addEvent
      } finally {
        // Stop loading, whether addEvent succeeded or not
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: MyColors.ultraLight,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.blue,
              ),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: MyColors.light,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(labelText: 'Name'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a name';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            maxLines: null,
                            controller: _descriptionController,
                            decoration: const InputDecoration(labelText: 'Description'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a description';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _locationController,
                            decoration: const InputDecoration(labelText: 'Location'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a location';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _getImage,
                            child: const Text('Select Image'),
                          ),
                          const SizedBox(height: 8),
                          if (_selectedImage != null)
                            Center(
                              child: Image.file(
                                _selectedImage!,
                                width: double.infinity,
                              ),
                            ),

                          const SizedBox(height: 16),
                          Center(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleAddEvent,
                              child: _isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text('Add Event'),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ),
              )
            )
          ),
        ),
      )
    );
  }
}


