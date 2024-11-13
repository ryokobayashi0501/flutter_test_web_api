import 'package:flutter/material.dart';
import 'package:flutter_web_api/Models/user_model.dart';
import 'package:flutter_web_api/Models/course_model.dart';
import 'package:flutter_web_api/Users/edit_page.dart';
import 'package:flutter_web_api/Mains/api_handler.dart';
import 'package:flutter_web_api/Course/course_detail.dart'; // CourseDetailをインポート
import 'package:flutter_web_api/Round/add_round.dart'; // コース追加ページをインポート
import 'package:flutter_web_api/Round/edit_course_page.dart'; // コース編集ページをインポート

class UserPage extends StatefulWidget {
  final User user;

  const UserPage({Key? key, required this.user}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  ApiHandler apiHandler = ApiHandler();
  late List<Course> data = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getCourses();
  }

  void getCourses() async {
    setState(() {
      isLoading = true; // データ取得中にローディングを表示
    });
    data = await apiHandler.getCoursesByUserId(widget.user.userId);
    setState(() {
      isLoading = false;
    });
  }

  void deleteCourse(int courseId) async {
    final response = await apiHandler.deleteCourse(courseId);
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      // 成功時にリストを再取得
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course deleted successfully!')),
      );
      getCourses(); // コースのリストを再取得して更新
    } else {
      // エラーメッセージの表示
      print("Failed to delete course: ${response.statusCode}");
      _showErrorDialog("Failed to delete course. Please try again.");
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return; // 追加: mountedチェック
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
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

  void navigateToAddCourse() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCourse(userId: widget.user.userId),
      ),
    );
    getCourses(); // コース追加後にリストを再取得
  }

  void navigateToEditCourse(Course course) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCoursePage(course: course),
      ),
    );
    getCourses(); // コース編集後にリストを再取得
  }

  void navigateToCourseDetail(Course course) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CourseDetail(course: course),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.username), // 上部にユーザー名を表示
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 11, 11, 11),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // データを取得中はローディングインジケーターを表示
          : Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // EditPageへ遷移しユーザー情報を編集可能に
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditPage(user: widget.user),
                      ),
                    ).then((_) {
                      // 編集から戻ってきたときにコースリストを再取得
                      getCourses();
                    });
                  },
                  child: const Text('User Info'),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: data.isEmpty
                      ? const Center(
                          child: Text("No courses found."),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              elevation: 3,
                              child: ListTile(
                                title: Text(data[index].courseName),
                                onTap: () => navigateToCourseDetail(data[index]), // コースをタップすると詳細へ
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () {
                                        // EditCoursePageへ遷移してコース情報を編集可能に
                                        navigateToEditCourse(data[index]);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        // 確認ダイアログを表示してから削除
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text("Confirm Delete"),
                                              content: const Text("Are you sure you want to delete this course?"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text("Cancel"),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    deleteCourse(data[index].courseId);
                                                  },
                                                  child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 11, 11, 11),
        foregroundColor: Colors.white,
        onPressed: navigateToAddCourse, // コース追加ページへ遷移
        child: const Icon(Icons.add),
      ),
    );
  }
}
