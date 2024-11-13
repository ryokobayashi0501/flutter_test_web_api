import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_web_api/Mains/api_handler.dart';
import 'package:flutter_web_api/Models/hole_model.dart';
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
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: MaterialButton(
        color: Colors.green,
        textColor: Colors.white,
        padding: const EdgeInsets.all(20),
        onPressed: isSubmitting ? null : updateHole,
        child: isSubmitting
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : const Text('ホールを更新'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: FormBuilder(
          key: _formKey,
          initialValue: {
            'holeNumber': widget.hole.holeNumber.toString(),
            'par': widget.hole.par.toString(),
            'yardage': widget.hole.yardage.toString(),
          },
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

  void updateHole() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        isSubmitting = true;
      });

      final data = _formKey.currentState!.value;

      // 更新されたホールを作成
      final updatedHole = Hole(
        holeId: widget.hole.holeId,
        courseId: widget.hole.courseId,
        holeNumber: int.parse(data['holeNumber']),
        par: int.parse(data['par']),
        yardage: int.parse(data['yardage']),
      );

      // API リクエストを実行
      try {
        final response = await apiHandler.updateHole(updatedHole);

        if (response.statusCode >= 200 && response.statusCode <= 299) {
          // 成功
          print("Hole updated successfully");
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ホールが更新されました')),
          );
          Navigator.pop(context);
        } else {
          // エラーが発生した場合
          print("Failed to update hole: ${response.statusCode}");
          print("Error body: ${response.body}");
          _showErrorDialog("ホールの更新に失敗しました。再度お試しください。");
        }
      } catch (e) {
        // ネットワークエラーなどをキャッチ
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
