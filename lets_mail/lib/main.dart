import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lets_mail/helper/content_helper.dart';
import 'package:lets_mail/helper/excel_helper.dart';
import 'package:lets_mail/helper/file_helper.dart';
import 'package:lets_mail/helper/email_helper.dart';
import 'package:lets_mail/model/email_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Stuur gepersonaliseerde emails'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

//------------------------------------------------------------

class _MyHomePageState extends State<MyHomePage> {
  final String fromUser = 'Robin Bakkerus';
  final String subject = 'Save the date: zaterdag 9 november';
  final int waitNseconds = 3;

  String _text = 'Click op de Send button om Excel file te selecteren';
  String _summary = '';
  int _total = 0;
  int _success = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_text),
            Text(_summary),
          ],
        ),
      ),
      floatingActionButton: _total == 0
          ? FloatingActionButton(
              onPressed: () {
                _processExcelFile(context);
              },
              child: const Icon(Icons.send),
            )
          : null, // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _processExcelFile(BuildContext context) async {
    File? file = await FileHelper().pickFile();

    if (file != null) {
      List<EmailModel> emailList = ExcelHelper().parseFile(file);
      _total = emailList.length;
      for (EmailModel emailModel in emailList) {
        _sendMail(emailModel);
        await Future.delayed(Duration(seconds: waitNseconds));
      }
    }

    setState(() {});
  }

  //---------------------------
  void _sendMail(EmailModel emailModel) async {
    String result = await EmailHelper().sendEmail(
        fromUser: fromUser,
        subject: subject,
        toEmail: emailModel.emailAdress,
        signature: emailModel.signature,
        html: ContentHelper().buildContent(emailModel));

    setState(() {
      _buildTexts(result, emailModel);
    });
  }

  void _buildTexts(String result, EmailModel emailModel) {
    if (result.isEmpty) {
      _success++;
      _text =
          'Met succes naar ${emailModel.emailAdress} ${emailModel.signature} verstuurd';
    } else {
      _text = 'Fout tijdens versturen naar ${emailModel.emailAdress} : $result';
    }

    _summary = '$_success van $_total verstuurd';
  }
}
