// lib/Pages/add_course.dart
import 'package:flutter/material.dart';
import 'package:flutter_web_api/Mains/api_handler.dart';
import 'package:flutter_web_api/Models/course_model.dart';
import 'package:flutter_web_api/Models/hole_model.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'dart:convert'; // Added
import 'package:flutter/material.dart';

class AddCourse extends StatefulWidget {
  final int userId;

  const AddCourse({Key? key, required this.userId}) : super(key: key);

  @override
  State<AddCourse> createState() => _AddCourseState();
}

class _AddCourseState extends State<AddCourse> {
  final _formKey = GlobalKey<FormBuilderState>();
  ApiHandler apiHandler = ApiHandler();
  bool isSubmitting = false;

  // List of holes
  List<Hole> holes = List.generate(
    18,
    (index) => Hole(
      holeId: null,
      courseId: 0, // Since the course has not been created yet, set to 0
      holeNumber: index + 1,
      par: 4,      // Default value
      yardage: 400, // Default value
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Course"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 5, 5, 5),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: isSubmitting ? null : addCourse,
          child: isSubmitting
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : const Text('Add Course'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FormBuilderTextField(
                name: 'courseName',
                decoration: const InputDecoration(
                  labelText: 'Course Name',
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'Please enter the course name'),
                  FormBuilderValidators.minLength(3, errorText: 'Please enter at least 3 characters'),
                ]),
              ),
              const SizedBox(height: 20),
              const Text(
                "Hole Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: holes.length,
                itemBuilder: (context, index) {
                  final hole = holes[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            "Hole ${hole.holeNumber}",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: FormBuilderTextField(
                                  name: 'par_$index',
                                  initialValue: hole.par.toString(),
                                  decoration: const InputDecoration(
                                    labelText: 'Par',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(errorText: 'Please enter the par'),
                                    FormBuilderValidators.integer(errorText: 'Please enter an integer'),
                                    FormBuilderValidators.min(3, errorText: 'Minimum par is 3'),
                                    FormBuilderValidators.max(5, errorText: 'Maximum par is 5'),
                                  ]),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: FormBuilderTextField(
                                  name: 'yardage_$index',
                                  initialValue: hole.yardage.toString(),
                                  decoration: const InputDecoration(
                                    labelText: 'Yardage',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(errorText: 'Please enter the yardage'),
                                    FormBuilderValidators.integer(errorText: 'Please enter an integer'),
                                    FormBuilderValidators.min(100, errorText: 'Yardage must be at least 100'),
                                  ]),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addCourse() async {
  if (_formKey.currentState?.saveAndValidate() ?? false) {
    setState(() {
      isSubmitting = true;
    });

    final formData = _formKey.currentState!.value;
    final courseName = formData['courseName'];
    const String imageUri = "https://source.unsplash.com/300x200/?golf"; // 固定の画像URIを設定

    try {
      // Add course
      final response = await apiHandler.addCourseForUser(widget.userId, courseName, holes, imageUri);
      if (response.statusCode == 201) {
        // Get the course ID
        final Map<String, dynamic> responseData = json.decode(response.body);
        final int courseId = responseData['courseId'];

        // Retrieve and update hole information
        for (int i = 0; i < holes.length; i++) {
          final par = int.parse(formData['par_$i']);
          final yardage = int.parse(formData['yardage_$i']);

          holes[i].courseId = courseId;
          holes[i].par = par;
          holes[i].yardage = yardage;

          await apiHandler.addHoleForCourse(courseId, holes[i]);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course added successfully')),
        );
        Navigator.pop(context);
      } else {
        print("Failed to add course: ${response.statusCode}");
        print("Response body: ${response.body}");
        _showErrorDialog("Failed to add course, please try again.");
      }
    } catch (e) {
      print("Error adding course: $e");
      _showErrorDialog("An error occurred while adding the course. Please check your connection and try again.");
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  } else {
    _showErrorDialog("Please correct the errors in the form.");
  }
}


  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Input Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
