import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_web_api/Mains/api_handler.dart';
import 'package:flutter_web_api/Models/hole_model.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class AddHole extends StatefulWidget {
  final int courseId;

  const AddHole({Key? key, required this.courseId}) : super(key: key);

  @override
  State<AddHole> createState() => _AddHoleState();
}

class _AddHoleState extends State<AddHole> {
  final _formKey = GlobalKey<FormBuilderState>();
  ApiHandler apiHandler = ApiHandler();
  bool isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ホール追加"),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: MaterialButton(
        color: Colors.green,
        textColor: Colors.white,
        padding: const EdgeInsets.all(20),
        onPressed: isSubmitting ? null : addHole,
        child: isSubmitting
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : const Text('ホールを追加'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              FormBuilderTextField(
                name: 'holeNumber',
                decoration: const InputDecoration(labelText: 'ホール番号'),
                keyboardType: TextInputType.number,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'ホール番号を入力してください'),
                  FormBuilderValidators.numeric(errorText: '数値を入力してください'),
                  FormBuilderValidators.min(1, errorText: '1以上の数値を入力してください'),
                  FormBuilderValidators.max(18, errorText: '18以下の数値を入力してください'),
                ]),
              ),
              FormBuilderTextField(
                name: 'par',
                decoration: const InputDecoration(labelText: 'パー'),
                keyboardType: TextInputType.number,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'パーを入力してください'),
                  FormBuilderValidators.numeric(errorText: '数値を入力してください'),
                ]),
              ),
              FormBuilderTextField(
                name: 'yardage',
                decoration: const InputDecoration(labelText: 'ヤーデージ'),
                keyboardType: TextInputType.number,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'ヤーデージを入力してください'),
                  FormBuilderValidators.numeric(errorText: '数値を入力してください'),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addHole() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        isSubmitting = true;
      });

      final data = _formKey.currentState!.value;

      // 新しいホールを作成
      final hole = Hole(
        holeId: 0, // 新規のため0を設定
        courseId: widget.courseId,
        holeNumber: int.parse(data['holeNumber']),
        par: int.parse(data['par']),
        yardage: int.parse(data['yardage']),
      );

      // API リクエストを実行
      try {
        final response = await apiHandler.addHoleForCourse(widget.courseId, hole); // 修正

        if (response.statusCode >= 200 && response.statusCode <= 299) {
          // 成功
          print("Hole added successfully");
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ホールが追加されました')),
          );
          Navigator.pop(context);
        } else {
          // エラーが発生した場合
          print("Failed to add hole: ${response.statusCode}");
          print("Error body: ${response.body}");
          _showErrorDialog("ホールの追加に失敗しました。再度お試しください。");
        }
      } catch (e) {
        // ネットワークエラーなどをキャッチ
        print("Error adding hole: $e");
        _showErrorDialog("ホールの追加中にエラーが発生しました。接続を確認して再度お試しください。");
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
}
