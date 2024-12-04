import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_web_api/Mains/api_handler.dart';
import 'package:flutter_web_api/Models/user_model.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:http/http.dart' as http;

class EditPage extends StatefulWidget {
  final User user;
  const EditPage({super.key, required this.user});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  ApiHandler apiHandler = ApiHandler();
  late http.Response response;

  void UpdateDatta() async {
  if (_formKey.currentState!.saveAndValidate()) {
    final data = _formKey.currentState!.value;

    final user = User(
      userId: widget.user.userId,
      name: data['name'],
      username: data['username'],
      email: data['email'],
      yearsOfExperience: int.parse(data['yearsOfExperience']),
      averageScore: int.parse(data['averageScore']),
      practiceFrequency: int.parse(data['practiceFrequency']),
      scoreGoal: int.parse(data['scoreGoal']),
      puttingGoal: double.parse(data['puttingGoal']),
      approachGoal: data['approachGoal'],
      shotGoal: data['shotGoal'],
      passwordHash: data['passwordHash'],
    );

    final response = await apiHandler.updateUser(
      userId: widget.user.userId,
      user: user,
    );

    if (response.statusCode >= 200 && response.statusCode <= 299) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User updated successfully!')),
      );
    } else {
      print("Error: ${response.statusCode} - ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update user: ${response.statusCode}')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Page"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: MaterialButton(
        color: Colors.teal,
        textColor: Colors.white,
        padding: const EdgeInsets.all(20),
        onPressed: UpdateDatta,
        child: const Text('Update'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: FormBuilder(
          key: _formKey,
          initialValue: {
            'name': widget.user.name,
            'username': widget.user.username,
            'email': widget.user.email,
            'yearsOfExperience': widget.user.yearsOfExperience.toString(),
            'averageScore': widget.user.averageScore.toString(),
            'practiceFrequency': widget.user.practiceFrequency.toString(),
            'scoreGoal': widget.user.scoreGoal.toString(),
            'puttingGoal': widget.user.puttingGoal.toString(),
            'approachGoal': widget.user.approachGoal,
            'shotGoal': widget.user.shotGoal,
            'passwordHash': widget.user.passwordHash
          },
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
              FormBuilderTextField(
                name: 'practiceFrequency',
                decoration: const InputDecoration(labelText: 'Practice Frequency'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.numeric(),
                ]),
              ),

              const SizedBox(height: 10),
              FormBuilderTextField(
                name: 'scoreGoal',
                decoration: const InputDecoration(labelText: 'Score Goal'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.numeric(),
                ]),
              ),

              const SizedBox(height: 10),
              FormBuilderTextField(
                name: 'puttingGoal',
                decoration: const InputDecoration(labelText: 'Putting Goal'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.numeric(),
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
                decoration: const InputDecoration(labelText: 'password'),
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
