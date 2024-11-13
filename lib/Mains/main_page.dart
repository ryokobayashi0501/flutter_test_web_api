import 'package:flutter/material.dart';
import 'package:flutter_web_api/Users/add_user.dart';
import 'package:flutter_web_api/Mains/api_handler.dart';
import 'package:flutter_web_api/Users/find_user.dart';
import 'package:flutter_web_api/Models/user_model.dart';
import 'package:flutter_web_api/Models/users_model.dart';
import 'package:flutter_web_api/Mains/user_page.dart';

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
                          builder: (context) => UserPage(user: data[index]), // UserPageに遷移
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      child: Text(data[index].userId.toString()),
                    ),
                    title: Text(data[index].username), // ユーザー名を表示
                    subtitle: Text(data[index].email), // メールアドレスを表示
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
