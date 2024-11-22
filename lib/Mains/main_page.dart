// lib/Pages/main_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_web_api/Users/add_user.dart';
import 'package:flutter_web_api/Mains/api_handler.dart';
import 'package:flutter_web_api/Users/find_user.dart';
import 'package:flutter_web_api/Models/user_model.dart';
import 'package:flutter_web_api/Mains/user_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  ApiHandler apiHandler = ApiHandler();
  List<User> data = [];
  bool isLoading = true;

  void getData() async {
    setState(() {
      isLoading = true;
    });
    data = await apiHandler.getUserData();
    setState(() {
      isLoading = false;
    });
  }

  void deleteUser(int userId) async {
    try {
      await apiHandler.deleteUser(userId: userId);
      getData(); // データを更新
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ユーザーが削除されました')),
      );
    } catch (e) {
      print("Error deleting user: $e");
      _showErrorDialog("ユーザーの削除に失敗しました。再度お試しください。");
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  void navigateToUserPage(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserPage(user: user),
      ),
    ).then((_) {
      // ユーザー情報が更新された場合にリストを再取得
      getData();
    });
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("削除エラー"),
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
        title: const Text("ユーザー一覧"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 11, 11, 11),
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: getData,
          child: const Text('更新'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'findUser',
            backgroundColor: const Color.fromARGB(255, 11, 11, 11),
            foregroundColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: ((context) => const FindUser()),
                ),
              ).then((_) {
                getData(); // 検索後にデータを更新
              });
            },
            child: const Icon(Icons.search),
          ),
          const SizedBox(
            height: 10,
          ),
          FloatingActionButton(
            heroTag: 'addUser',
            backgroundColor: const Color.fromARGB(255, 11, 11, 11),
            foregroundColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddUser(),
                ),
              ).then((_) {
                getData(); // 追加後にデータを更新
              });
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : data.isEmpty
              ? const Center(
                  child: Text("ユーザーが見つかりません"),
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
                          navigateToUserPage(data[index]); // UserPageに遷移
                        },
                        leading: CircleAvatar(
                          child: Text(data[index].userId.toString()),
                        ),
                        title: Text(data[index].username), // ユーザー名を表示
                        subtitle: Text(data[index].email), // メールアドレスを表示
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            // 確認ダイアログを表示してから削除
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("削除確認"),
                                  content: const Text("このユーザーを削除してもよろしいですか？"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("キャンセル"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        deleteUser(data[index].userId);
                                      },
                                      child: const Text(
                                        "削除",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
