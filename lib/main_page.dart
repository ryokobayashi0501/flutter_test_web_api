import 'package:flutter/material.dart';
import 'package:flutter_web_api/add_user.dart';
import 'package:flutter_web_api/api_handler.dart';
import 'package:flutter_web_api/edit_page.dart';
import 'package:flutter_web_api/find_user.dart';
import 'package:flutter_web_api/model.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  ApiHandler apiHandler = ApiHandler();
  late List<User> data = [];

  void getData() async {
    data = await apiHandler.getUserData();
    setState(() {});
  }

  void deleteUser(int userId) async {
    await apiHandler.deleteUser(userId: userId);
    getData(); // Update Data
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FlutterApi"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 11, 11, 11),
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: MaterialButton(
        color: Colors.teal,
        textColor: Colors.white,
        padding: const EdgeInsets.all(20),
        onPressed: getData,
        child: const Text('Refresh'),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 1,
            backgroundColor: const Color.fromARGB(255, 11, 11, 11),
            foregroundColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: ((context) => const FindUser()),
                ),
              );
            },
            child: const Icon(Icons.search),
          ),
          const SizedBox(
            height: 10,
          ),
          FloatingActionButton(
            heroTag: 2,
            backgroundColor: const Color.fromARGB(255, 11, 11, 11),
            foregroundColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddUser(),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: data.isEmpty
    ? const Center(
        child: CircularProgressIndicator(),
      )
    : ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: data.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 3,
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPage(user: data[index]),
                  ),
                );
              },
              leading: CircleAvatar(
                child: Text(data[index].userId.toString()),
              ),
              title: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Name: ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: data[index].name,
                    ),
                  ],
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'User Name: ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Text(data[index].username),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Email: ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Text(data[index].email),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Years of Experience: ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(data[index].yearsOfExperience.toString()),
                    ],
                  ),

                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Average Score: ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Text(data[index].averageScore.toString()),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Practice Frequency: ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(data[index].practiceFrequency.toString()),
                    ],
                  ),

                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Score Goal: ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(data[index].scoreGoal.toString()),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Putting Goal: ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(data[index].puttingGoal.toString()),
                    ],
                  ),

                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'approachGoal: ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Text(data[index].approachGoal),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'shotGoal: ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Text(data[index].shotGoal),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'password: ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Text(data[index].passwordHash),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  deleteUser(data[index].userId);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
