import 'package:flutter/material.dart';
import 'package:flutter_web_api/api_handler.dart';
import 'package:flutter_web_api/model.dart';

class FindUser extends StatefulWidget {
  const FindUser({super.key});

  @override
  State<FindUser> createState() => _FindUserState();
}

class _FindUserState extends State<FindUser> {
  ApiHandler apiHandler = ApiHandler();
  User user = const User.empty();

  // Create controllers for entering ID and name
  TextEditingController idController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  

// Method to search for a user by ID
void getUserById(int userId) async {
  User? foundUser = await apiHandler.getUserById(userId: userId); // Receive User?

  if (foundUser != null) {
    user = foundUser; // Assign if not null
    setState(() {}); // Update UI
  } else {
    // Add handling when the user is not found
    print('User not found');
  }
}

// Method to search for a user by name
void getUserByName(String name) async {
  User? foundUser = await apiHandler.getUserByName(name: name); // Receive User?

  if (foundUser != null) {
    user = foundUser; // Assign if not null
    setState(() {}); // Update UI
  } else {
    // Add handling when the user is not found
    print('User not found');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find User"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 11, 11, 11),
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Button to search by ID
          MaterialButton(
            color: Colors.teal,
            textColor: Colors.white,
            padding: const EdgeInsets.all(20),
            onPressed: () {
              getUserById(int.parse(idController.text));
            },
            child: const Text('Find by ID'),
          ),
          // Button to search by name
          MaterialButton(
            color: Colors.blue,
            textColor: Colors.white,
            padding: const EdgeInsets.all(20),
            onPressed: () {
              getUserByName(nameController.text);
            },
            child: const Text('Find by Name'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // Input field to search by ID
            TextField(
              controller: idController,
              decoration: const InputDecoration(
                labelText: 'ID',
              ),
            ),
            const SizedBox(height: 10),
            // Input field to search by name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',  // Field to search by name
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: Text("${user.userId}"),
              title: Text(user.name),
              subtitle: Text(user.email),
            ),
          ],
        ),
      ),
    );
  }
}
