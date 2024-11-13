import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_web_api/Mains/api_handler.dart';
import 'package:flutter_web_api/Models/course_model.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class AddCourse extends StatefulWidget {
  final int userId;

  const AddCourse({super.key, required this.userId});

  @override
  State<AddCourse> createState() => _AddCourseState();
}

class _AddCourseState extends State<AddCourse> {
  final _formKey = GlobalKey<FormBuilderState>();
  ApiHandler apiHandler = ApiHandler();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Course"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 11, 11, 11),
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: MaterialButton(
        color: Colors.teal,
        textColor: Colors.white,
        padding: const EdgeInsets.all(20),
        onPressed: addCourse,
        child: const Text('Add'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              FormBuilderTextField(
                name: 'courseName',
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

  void addCourse() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();
    final data = _formKey.currentState!.value;

    // 新しいコースを作成
    final course = Course(
      courseId: 0,  // 新規のため0を設定
      courseName: data['courseName'],
    );

    // API リクエストを実行
    try {
      final response = await apiHandler.addCourseForUser(widget.userId, course);

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        // 成功
        print("Course and related round added successfully");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course added successfully!')),
        );
        Navigator.pop(context);
      } else {
        // エラーが発生した場合
        print("Failed to add course: ${response.statusCode}");
        print("Error body: ${response.body}");
        _showErrorDialog("Failed to add course. Please try again.");
      }
    } catch (e) {
      // ネットワークエラーなどをキャッチ
      print("Error adding course: $e");
      _showErrorDialog("Error adding course. Please check your connection and try again.");
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
}
