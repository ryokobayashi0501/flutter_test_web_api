import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_web_api/Mains/api_handler.dart';
import 'package:flutter_web_api/Models/user_model.dart';
import 'package:flutter_web_api/Models/DTOs/users_model.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:http/http.dart' as http;

class AddUser extends StatefulWidget {
  const AddUser({super.key});

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final _formKey = GlobalKey<FormBuilderState>();
  ApiHandler apiHandler = ApiHandler();
  late List<User> existingUsers; // Keep existing user list

  void getData() async {
    existingUsers = await apiHandler.getUserData(); // Get a list of existing users
  }

  @override
  void initState() {
    super.initState();
    getData(); // Get existing data on initialization
  }

  void addUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final data = _formKey.currentState!.value;

      // Modify the part that converts to a number
      int yearsOfExperience = int.tryParse(data['yearsOfExperience']) ?? 0;
      int averageScore = int.tryParse(data['averageScore']) ?? 0;
      int scoreGoal = int.tryParse(data['scoreGoal'].toString()) ?? 0;
      double puttingGoal = double.tryParse(data['puttingGoal'].toString()) ?? 0.0;

      // Custom Validation
      if (scoreGoal >= averageScore) {
        _showErrorDialog("Score Goal must be greater than Average Score.");
        return;
      }

      bool usernameExists = existingUsers.any((user) => user.username == data['username']);
      if (usernameExists) {
        _showErrorDialog("Username already exists. Please use a different username.");
        return;
      }

      bool emailExists = existingUsers.any((user) => user.email == data['email']);
      if (emailExists) {
        _showErrorDialog("Email already exists. Please use a different email address.");
        return;
      }

      final user = User(
        userId: 0,
        name: data['name'],
        username: data['username'],
        email: data['email'],
        yearsOfExperience: yearsOfExperience,
        averageScore: averageScore,
        practiceFrequency: data['practiceFrequency'],
        scoreGoal: scoreGoal,
        puttingGoal: data['puttingGoal'],
        approachGoal: data['approachGoal'],
        shotGoal: data['shotGoal'],
        passwordHash: data['passwordHash']
      );

      await apiHandler.addUser(user);

      if (!mounted) return;
      Navigator.pop(context);
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
        title: const Text("Add User"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 11, 11, 11),
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: MaterialButton(
        color: Colors.teal,
        textColor: Colors.white,
        padding: const EdgeInsets.all(20),
        onPressed: addUser,
        child: const Text('Add'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              FormBuilderTextField(
                name: 'name',
                decoration: const InputDecoration(labelText: 'Name'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              ),

              const SizedBox(height: 10),
              FormBuilderTextField(
                name: 'username',
                decoration: const InputDecoration(labelText: 'Username'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              ),

              const SizedBox(height: 10),
              FormBuilderTextField(
                name: 'email',
                decoration: const InputDecoration(labelText: 'Email'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.email(
                      errorText: 'Please enter a valid email address'),
                ]),
              ),

              const SizedBox(height: 10),
              FormBuilderTextField(
                name: 'yearsOfExperience',
                decoration: const InputDecoration(labelText: 'Years of Experience'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.numeric(),
                ]),
              ),

              const SizedBox(height: 10),
              FormBuilderTextField(
                name: 'averageScore',
                decoration: const InputDecoration(labelText: 'Average Score'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.numeric(),
                ]),
              ),

              const SizedBox(height: 10),
              FormBuilderDropdown<int>(
                name: 'practiceFrequency',
                decoration: const InputDecoration(labelText: 'Practice Frequency'),
                items: List.generate(7, (index) => index + 1)
                    .map((number) => DropdownMenuItem(
                          value: number,
                          child: Text('$number'),
                        ))
                    .toList(),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              ),

              const SizedBox(height: 10),
              FormBuilderDropdown<int>(
                name: 'scoreGoal',
                decoration: const InputDecoration(labelText: 'Score Goal (62-110)'),
                items: List.generate(49, (index) => index + 62)
                    .map((number) => DropdownMenuItem(
                          value: number,
                          child: Text('$number'),
                        ))
                    .toList(),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              ),

              const SizedBox(height: 10),
              FormBuilderDropdown<double>(
                name: 'puttingGoal',
                decoration: const InputDecoration(labelText: 'Putting Goal (1.0 - 2.0)'),
                items: List.generate(11, (index) => 1.0 + (index * 0.1))
                    .map((value) => DropdownMenuItem(
                          value: value,
                          child: Text(value.toStringAsFixed(1)),
                        ))
                    .toList(),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              ),

              const SizedBox(height: 10),
              FormBuilderDropdown<String>(
                name: 'approachGoal',
                decoration: const InputDecoration(labelText: 'Approach Goal'),
                items: [
                  'Chipping around the green',
                  'Chip shots from the rough',
                  'Bunker shots',
                  'Approach shots under 50 yards',
                  'Chip shots with a high ball',
                  'Chip shots with spin',
                ].map((approach) => DropdownMenuItem(
                      value: approach,
                      child: Text(approach),
                    ))
                    .toList(),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              ),

              const SizedBox(height: 10),
              FormBuilderDropdown<String>(
                name: 'shotGoal',
                decoration: const InputDecoration(labelText: 'Shot Goal'),
                items: [
                  'Long shots',
                  'Accurate iron shots',
                  'Improve success rate on the green',
                  'Improve fairway hit rate',
                  'Hit a draw ball',
                  'Hit a fade ball',
                ].map((shot) => DropdownMenuItem(
                      value: shot,
                      child: Text(shot),
                    ))
                    .toList(),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              ),

              const SizedBox(height: 10),
              FormBuilderTextField(
                name: 'passwordHash',
                decoration: const InputDecoration(labelText: 'Password'),
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
