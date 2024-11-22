// lib/Course/edit_hole.dart
import 'dart:convert'; // json を使用するために追加
import 'package:flutter/material.dart';
import 'package:flutter_web_api/Mains/api_handler.dart';
import 'package:flutter_web_api/Models/hole_model.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class EditHole extends StatefulWidget {
  final Hole hole;

  const EditHole({Key? key, required this.hole}) : super(key: key);

  @override
  State<EditHole> createState() => _EditHoleState();
}

class _EditHoleState extends State<EditHole> {
  final _formKey = GlobalKey<FormBuilderState>();
  ApiHandler apiHandler = ApiHandler();
  bool isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ホール編集"),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: isSubmitting ? null : updateHole,
          child: isSubmitting
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : const Text('ホールを更新'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange, // ボタンの背景色
            foregroundColor: Colors.white, // ボタンのテキスト色
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "ホール ${widget.hole.holeNumber}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              FormBuilderTextField(
                name: 'par',
                decoration: const InputDecoration(
                  labelText: 'パー',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                initialValue: widget.hole.par.toString(),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'パーを入力してください'),
                  FormBuilderValidators.integer(errorText: '整数を入力してください'),
                  FormBuilderValidators.min(3, errorText: '最低パーは3です'),
                  FormBuilderValidators.max(5, errorText: '最高パーは5です'),
                ]),
              ),
              const SizedBox(height: 20),
              FormBuilderTextField(
                name: 'yardage',
                decoration: const InputDecoration(
                  labelText: 'ヤーデージ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                initialValue: widget.hole.yardage.toString(),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'ヤーデージを入力してください'),
                  FormBuilderValidators.integer(errorText: '整数を入力してください'),
                  FormBuilderValidators.min(100, errorText: 'ヤーデージは100以上です'),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updateHole() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        isSubmitting = true;
      });

      final formData = _formKey.currentState!.value;
      final par = int.parse(formData['par']);
      final yardage = int.parse(formData['yardage']);

      // Holeオブジェクトを更新
      Hole updatedHole = Hole(
        holeId: widget.hole.holeId,
        courseId: widget.hole.courseId,
        holeNumber: widget.hole.holeNumber,
        par: par,
        yardage: yardage,
      );

      try {
        final response = await apiHandler.updateHole(updatedHole);
        if (response.statusCode >= 200 && response.statusCode <= 299) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ホールが更新されました')),
          );
          Navigator.pop(context);
        } else {
          print("Failed to update hole: ${response.statusCode}");
          print("Response body: ${response.body}");
          _showErrorDialog("ホールの更新に失敗しました。再度お試しください。");
        }
      } catch (e) {
        print("Error updating hole: $e");
        _showErrorDialog("ホールの更新中にエラーが発生しました。接続を確認して再度お試しください。");
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
