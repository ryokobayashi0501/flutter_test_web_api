import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_web_api/Models/course_model.dart';
import 'package:flutter_web_api/Mains/api_handler.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class EditCoursePage extends StatefulWidget {
  final Course course;

  const EditCoursePage({Key? key, required this.course}) : super(key: key);

  @override
  State<EditCoursePage> createState() => _EditCoursePageState();
}

class _EditCoursePageState extends State<EditCoursePage> {
  final _formKey = GlobalKey<FormBuilderState>();
  ApiHandler apiHandler = ApiHandler();

  void updateCourse() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final data = _formKey.currentState!.value;

      // コース名を更新
      final updatedCourse = Course(
        courseId: widget.course.courseId,
        //userId: widget.course.userId,
        courseName: data['courseName'],
      );

      try {
        final response = await apiHandler.updateCourse(updatedCourse);
        if (response.statusCode >= 200 && response.statusCode <= 299) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Course updated successfully!')),
          );
          Navigator.pop(context);
        } else {
          _showErrorDialog("Failed to update course. Please try again.");
        }
      } catch (e) {
        _showErrorDialog("Error updating course. Please check your connection and try again.");
      }
    } else {
      _showErrorDialog("Please correct the errors in the form.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Invalid Input"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Course"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 11, 11, 11),
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: MaterialButton(
        color: Colors.teal,
        textColor: Colors.white,
        padding: const EdgeInsets.all(20),
        onPressed: updateCourse,
        child: const Text('Update'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              FormBuilderTextField(
                name: 'courseName',
                initialValue: widget.course.courseName,
                decoration: const InputDecoration(labelText: 'Course Name'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
