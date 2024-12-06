// lib/Pages/course_detail.dart
import 'package:flutter/material.dart';
import 'package:flutter_web_api/Mains/api_handler.dart';
import 'package:flutter_web_api/Models/course_model.dart';
import 'package:flutter_web_api/Models/hole_model.dart';
import 'package:flutter_web_api/Course/add_hole.dart'; // 修正
import 'package:flutter_web_api/Course/edit_hole.dart'; // 修正

class CourseDetail extends StatefulWidget {
  final Course course;

  const CourseDetail({Key? key, required this.course}) : super(key: key);

  @override
  State<CourseDetail> createState() => _CourseDetailState();
}

class _CourseDetailState extends State<CourseDetail> {
  ApiHandler apiHandler = ApiHandler();
  List<Hole> holes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHoles();
  }

  void fetchHoles() async {
    setState(() {
      isLoading = true;
    });
    holes = await apiHandler.getHolesByCourseId(widget.course.courseId!);
    setState(() {
      isLoading = false;
    });
  }

  void navigateToAddHole() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddHole(
          courseId: widget.course.courseId!,
        ),
      ),
    );
    fetchHoles();
  }

  void navigateToEditHole(Hole hole) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditHole(hole: hole),
      ),
    );
    fetchHoles();
  }

  void deleteHole(int holeId) async {
    final response = await apiHandler.deleteHole(widget.course.courseId!, holeId);
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ホールが削除されました')),
      );
      fetchHoles();
    } else {
      print("Failed to delete hole: ${response.statusCode}");
      _showErrorDialog("ホールの削除に失敗しました。再度お試しください。");
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return; // ウィジェットがマウントされているか確認
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("エラー"),
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
        title: Text(widget.course.courseName),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 11, 11, 11),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToAddHole,
        child: const Icon(Icons.add),
        backgroundColor: Colors.green, // ボタンの色を設定
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : holes.isEmpty
              ? const Center(child: Text("ホールが見つかりません"))
              : ListView.builder(
                  itemCount: holes.length,
                  itemBuilder: (context, index) {
                    final hole = holes[index];
                    return Card(
                      child: ListTile(
                        title: Text('ホール ${hole.holeNumber}'),
                        subtitle: Text('パー ${hole.par}, ${hole.yardage} ヤード'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => navigateToEditHole(hole),
                              color: Colors.blue,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                if (hole.holeId != null) {
                                  deleteHole(hole.holeId!); // 非nullableに変換
                                } else {
                                  _showErrorDialog("ホールIDが存在しません。");
                                }
                              },
                                color: const Color.fromARGB(255, 10, 10, 10),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
