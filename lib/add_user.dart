import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_web_api/api_handler.dart';
import 'package:flutter_web_api/model.dart';
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
late http.Response response; //dosen't break

void addUser() async{
  if(_formKey.currentState!.saveAndValidate()){
    final data = _formKey.currentState!.value;

    final user = User(
      userId: 0, 
      name: data['name'], 
      email: data['email'],
      );

      await apiHandler.addUser(user); //User: user(is also ok)
  } //end of if statement

  if(!mounted) return;
  Navigator.pop(context);
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
        child: const Text('Add')
      ),
      body: Padding(
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
            ],
          ),
        ),
      ),
    );
  }
}