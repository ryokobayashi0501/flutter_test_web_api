// lib/Course/edit_course_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_web_api/Mains/api_handler.dart';
import 'package:flutter_web_api/Models/course_model.dart';
import 'package:flutter_web_api/Models/hole_model.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class EditCoursePage extends StatefulWidget {
  final Course course;

  const EditCoursePage({Key? key, required this.course}) : super(key: key);

  @override
  State<EditCoursePage> createState() => _EditCoursePageState();
}

class _EditCoursePageState extends State<EditCoursePage> {
  final _formKey = GlobalKey<FormBuilderState>();
  ApiHandler apiHandler = ApiHandler();
  bool isSubmitting = false;
  List<Hole> holes = [];

  @override
  void initState() {
    super.initState();
    fetchHoles();
  }

  void fetchHoles() async {
    holes = await apiHandler.getHolesByCourseId(widget.course.courseId!);
    setState(() {});
  }

  void updateCourse() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        isSubmitting = true;
      });

      final formData = _formKey.currentState!.value;
      final courseName = formData['courseName'];

      try {
        // コース名を更新
        widget.course.courseName = courseName;
        final courseResponse = await apiHandler.updateCourse(widget.course);

        if (courseResponse.statusCode >= 200 && courseResponse.statusCode <= 299) {
          // 各ホールを更新
          for (int i = 0; i < holes.length; i++) {
            final par = int.parse(formData['par_$i']);
            final yardage = int.parse(formData['yardage_$i']);

            holes[i].par = par;
            holes[i].yardage = yardage;

            await apiHandler.updateHole(holes[i]);
          }

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('コースが更新されました')),
          );
          Navigator.pop(context);
        } else {
          print("Failed to update course: ${courseResponse.statusCode}");
          print("Response body: ${courseResponse.body}");
          _showErrorDialog("コースの更新に失敗しました。再度お試しください。");
        }
      } catch (e) {
        print("Error updating course: $e");
        _showErrorDialog("コースの更新中にエラーが発生しました。接続を確認して再度お試しください。");
      } finally {
        setState(() {
          isSubmitting = false;
        });
      }
    } else {
      _showErrorDialog("フォームのエラーを修正してください。");
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("入力エラー"),
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

  Widget buildHoleForm(int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              "ホール ${holes[index].holeNumber}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FormBuilderTextField(
                    name: 'par_$index',
                    initialValue: holes[index].par.toString(),
                    decoration: const InputDecoration(
                      labelText: 'パー',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(errorText: 'パーを入力してください'),
                      FormBuilderValidators.integer(errorText: '整数を入力してください'),
                      FormBuilderValidators.min(3, errorText: '最低パーは3です'),
                      FormBuilderValidators.max(5, errorText: '最高パーは5です'),
                    ]),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FormBuilderTextField(
                    name: 'yardage_$index',
                    initialValue: holes[index].yardage.toString(),
                    decoration: const InputDecoration(
                      labelText: 'ヤーデージ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(errorText: 'ヤーデージを入力してください'),
                      FormBuilderValidators.integer(errorText: '整数を入力してください'),
                      FormBuilderValidators.min(100, errorText: 'ヤーデージは100以上です'),
                    ]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("コース編集"),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: isSubmitting ? null : updateCourse,
          child: isSubmitting
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : const Text('コースを更新'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: holes.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : FormBuilder(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FormBuilderTextField(
                      name: 'courseName',
                      initialValue: widget.course.courseName,
                      decoration: const InputDecoration(
                        labelText: 'コース名',
                        border: OutlineInputBorder(),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: 'コース名を入力してください'),
                        FormBuilderValidators.minLength(3, errorText: '3文字以上で入力してください'),
                      ]),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "ホール情報",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: holes.length,
                      itemBuilder: (context, index) {
                        return buildHoleForm(index);
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
