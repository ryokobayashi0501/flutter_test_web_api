import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_web_api/api_handler.dart';
import 'package:flutter_web_api/model.dart';
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

  void UpdateDatta() async{
    if(_formKey.currentState!.saveAndValidate()){
      final data = _formKey.currentState!.value;

      final user = User(
        userId: widget.user.userId,
        name: data['name'],
        username: data['username'],
        email: data['email'], //change address to email
        yearsOfExperience: int.parse(data['yearsOfExperience']),
        averageScore: data['averageScore'],
        practiceFrequency: data['practiceFrequency'],
        scoreGoal: int.parse(data['scoreGoal']),
        puttingGoal: double.parse(data['puttingGoal']),
        approachGoal: data['approachGoal'],
      );

      response = await apiHandler.updateUser(
        userId: widget.user.userId, 
        user: user
        );
    }

    if(!mounted) return;
    Navigator.pop(context);
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
        child: const Text('Update')
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: FormBuilder(
          key: _formKey,
          initialValue: {
            'name' : widget.user.name,
            'username' : widget.user.username,
            'email' : widget.user.email,
            'yearsOfExperience' : widget.user.yearsOfExperience.toString(),
            'averageScore' : widget.user.averageScore.toString(),
            'practiceFrequency' : widget.user.practiceFrequency.toString(),
            'scoreGoal' : widget.user.scoreGoal.toString(),
            'puttingGoal' : widget.user.puttingGoal.toString(),
            'approachGoal' : widget.user.approachGoal,

          },
          child: Column(
            children: [
              FormBuilderTextField(
                name: 'name',
                decoration: const InputDecoration(labelText: 'Name'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ],),
              ),

              const SizedBox(
                height: 10,
              ),
              FormBuilderTextField(
                name: 'username',
                decoration: const InputDecoration(labelText: 'username'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ],),
              ),

              const SizedBox(
                height: 10,
              ),
              FormBuilderTextField(
                name: 'email',
                decoration: const InputDecoration(labelText: 'email'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ],),
              ),

              const SizedBox(
                height: 10,
              ),
              FormBuilderTextField(
                name: 'yearsOfExperience',
                decoration: const InputDecoration(labelText: 'yearsOfExperience'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ],),
              ),

              const SizedBox(
                height: 10,
              ),
              FormBuilderTextField(
                name: 'averageScore',
                decoration: const InputDecoration(labelText: 'averageScore'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ],),
              ),

              const SizedBox(
                height: 10,
              ),
              FormBuilderTextField(
                name: 'practiceFrequency',
                decoration: const InputDecoration(labelText: 'practiceFrequency'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ],),
              ),

              const SizedBox(
                height: 10,
              ),
              FormBuilderTextField(
                name: 'scoreGoal',
                decoration: const InputDecoration(labelText: 'scoreGoal'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ],),
              ),

              const SizedBox(
                height: 10,
              ),
              FormBuilderTextField(
                name: 'puttingGoal',
                decoration: const InputDecoration(labelText: 'puttingGoal'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ],),
              ),

              const SizedBox(
                height: 10,
              ),
              FormBuilderTextField(
                name: 'approachGoal',
                decoration: const InputDecoration(labelText: 'approachGoal'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ],),
              ),
            ],
          ),
        ),
      ),
    );
  }
}