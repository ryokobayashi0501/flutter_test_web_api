// lib/Course/add_hole.dart
import 'dart:convert'; // Added to use JSON
import 'package:flutter/material.dart';
import 'package:flutter_web_api/Mains/api_handler.dart';
import 'package:flutter_web_api/Models/hole_model.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class AddHole extends StatefulWidget {
  final int courseId;

  const AddHole({Key? key, required this.courseId}) : super(key: key);

  @override
  State<AddHole> createState() => _AddHoleState();
}

class _AddHoleState extends State<AddHole> {
  final _formKey = GlobalKey<FormBuilderState>();
  ApiHandler apiHandler = ApiHandler();
  bool isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a hole"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: isSubmitting ? null : addHole,
          child: isSubmitting
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : const Text('Add a hole'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // Button background color
            foregroundColor: Colors.white, // Button text color
          ),
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
                name: 'holeNumber',
                decoration: const InputDecoration(
                  labelText: 'Hole Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                initialValue: '1',
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'Please enter the hole number'),
                  FormBuilderValidators.integer(errorText: 'Please enter an integer'),
                  FormBuilderValidators.min(1, errorText: 'Hole number is 1 or higher'),
                ]),
              ),
              const SizedBox(height: 20),
              FormBuilderTextField(
                name: 'par',
                decoration: const InputDecoration(
                  labelText: 'Par',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                initialValue: '4',
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'Please enter the par'),
                  FormBuilderValidators.integer(errorText: 'Please enter an integer'),
                  FormBuilderValidators.min(3, errorText: 'Minimum par is 3'),
                  FormBuilderValidators.max(5, errorText: 'Maximum par is 5'),
                ]),
              ),
              const SizedBox(height: 20),
              FormBuilderTextField(
                name: 'yardage',
                decoration: const InputDecoration(
                  labelText: 'Yardage',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                initialValue: '400',
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'Please enter the yardage'),
                  FormBuilderValidators.integer(errorText: 'Please enter an integer'),
                  FormBuilderValidators.min(100, errorText: 'Yardage must be at least 100'),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // The addHole method in add_hole.dart
  void addHole() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        isSubmitting = true;
      });

      final formData = _formKey.currentState!.value;
      final holeNumber = int.parse(formData['holeNumber']);
      final par = int.parse(formData['par']);
      final yardage = int.parse(formData['yardage']);

      Hole newHole = Hole(
        holeId: null, // Set to null
        courseId: widget.courseId,
        holeNumber: holeNumber,
        par: par,
        yardage: yardage,
      );

      try {
        final response = await apiHandler.addHoleForCourse(widget.courseId, newHole);
        if (response.statusCode >= 200 && response.statusCode <= 299) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hole added successfully')),
          );
          Navigator.pop(context);
        } else {
          print("Failed to add hole: ${response.statusCode}");
          print("Response body: ${response.body}");
          _showErrorDialog("Failed to add hole. Please try again.");
        }
      } catch (e) {
        print("Error adding hole: $e");
        _showErrorDialog("An error occurred while adding the hole. Please check your connection and try again.");
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
