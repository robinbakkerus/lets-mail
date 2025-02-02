import 'dart:async';
import 'dart:developer';
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
  final int waitNseconds = 3;

  String _text = '';
  String _summary = '';
  int _total = 0;
  int _success = 0;
  int _failed = 0;

  final _textCtlrs = List<TextEditingController>.generate(4, (index) {
    return TextEditingController();
  });
  final subjectIndex = 0;
  final fromUserIndex = 1;
  final mailingListIndex = 2;
  final htmlIndex = 3;

  bool _dryRun = true;
  bool _execEnabled = false;
  File? _excelFile;

  //----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _subjectInput('Subject', subjectIndex),
              const Spacer(),
              _htmlInput('Body html', htmlIndex),
              const Spacer(),
              _fromUserInput('From user', fromUserIndex),
              const Spacer(),
              _emailListInput("Mailing list", mailingListIndex),
              const Spacer(),
              _executeButton(),
              const Spacer(),
              Text(_summary),
              _testWebButton(),
            ],
          ),
        ),
      ),
    );
  }

  //----------------------------------------------------------
  Widget _subjectInput(String label, int index) {
    return Row(
      children: [
        SizedBox(width: 150, child: Text(label)),
        SizedBox(
          width: 400,
          child: TextField(controller: _textCtlrs[index]),
        ),
      ],
    );
  }

  //----------------------------------------------------------
  Widget _htmlInput(String label, int index) {
    return Row(
      children: [
        SizedBox(width: 150, child: Text(label)),
        SizedBox(
          width: 600,
          height: 150,
          child: TextField(
            controller: _textCtlrs[index],
            keyboardType: TextInputType.multiline,
            maxLines: null,
          ),
        ),
      ],
    );
  }

  //----------------------------------------------------------
  Widget _fromUserInput(String label, int index) {
    return Row(children: [
      SizedBox(width: 150, child: Text(label)),
      SizedBox(
        width: 400,
        child: TextField(controller: _textCtlrs[index]),
      ),
      DropdownMenu(
          onSelected: (value) {
            if (value != null) {
              _textCtlrs[index].text = value;
              setState(() {
                _checkExecEnabled();
              });
            }
          },
          dropdownMenuEntries: const [
            DropdownMenuEntry(value: 'robin', label: 'robin'),
            DropdownMenuEntry(value: 'lonu', label: 'lonu'),
            DropdownMenuEntry(value: 'hobbycentrum', label: 'hobbycentrum')
          ])
    ]);
  }

  //----------------------------------------------------------
  Widget _emailListInput(String label, int index) {
    return Row(
      children: [
        SizedBox(width: 150, child: Text(label)),
        SizedBox(
          width: 400,
          child: TextField(controller: _textCtlrs[index]),
        ),
        ElevatedButton(
            onPressed: _onSelectFileClicked,
            child: const Text('Select mailing list')),
        Container(
          width: 20,
        ),
        _dryRunCheckbox(),
      ],
    );
  }

  //--------------------------------------------------------------
  void _onSelectFileClicked() async {
    _excelFile = await FileHelper().pickFile();

    if (_excelFile != null) {
      List<EmailModel> emailList = ExcelHelper().parseFile(_excelFile!);
      _textCtlrs[mailingListIndex].text = _excelFile!.path;
      _total = emailList.length;
      setState(() {
        _checkExecEnabled();
        _text = 'Aantal = $_total';
        _success = 0;
        _failed = 0;
        _summary = '';
      });
    }
  }

  //-----------------------------------------------------------
  Widget _dryRunCheckbox() {
    return Row(
      children: [
        const SizedBox(width: 100, child: Text('Dry run')),
        Checkbox(
          value: _dryRun,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _dryRun = value;
              });
            }
          },
        ),
      ],
    );
  }

  //------------------------------------------------------
  void _checkExecEnabled() {
    _execEnabled = true;
    for (TextEditingController ctrl in _textCtlrs) {
      if (ctrl.text.isEmpty) {
        _execEnabled = false;
        break;
      }
    }
  }

  //---------------------------------------------------------
  Widget _executeButton() {
    String label = _dryRun ? 'Send only first mail' : 'Send all $_total mails';
    return Row(
      children: [
        ElevatedButton(
            onPressed: _execEnabled ? _onExecuteClicked : null,
            child: Text(label)),
        Container(
          width: 50,
        ),
        Text(_text),
      ],
    );
  }

  //--------------------------------------------------------------
  void _onExecuteClicked() async {
    setState(() {
      _summary = '';
      _failed = 0;
    });
    _processExcelFile(context);
  }

  //-----------------------------------------------------------
  void _processExcelFile(BuildContext context) async {
    if (_excelFile != null) {
      List<EmailModel> emailList = ExcelHelper().parseFile(_excelFile!);
      _total = emailList.length;
      if (_dryRun) {
        _sendOnlyFirstMail(emailList);
        _checkAllMailAdresses(emailList);
      } else {
        await _sendAllMails(emailList);
      }
    }

    setState(() {});
  }

  //---------------------------
  void _sendOnlyFirstMail(List<EmailModel> emailList) {
    EmailModel emailModel = emailList[0];
    String address = _parseEmailAdress(emailModel.emailAdress);
    EmailModel useModel =
        EmailModel(emailAdress: address, signature: emailModel.signature);
    _sendMail(useModel);
  }

  //---------------------------
  Future<void> _sendAllMails(List<EmailModel> emailList) async {
    for (EmailModel emailModel in emailList) {
      String address = _parseEmailAdress(emailModel.emailAdress);
      if (address.isNotEmpty) {
        EmailModel useModel =
            EmailModel(emailAdress: address, signature: emailModel.signature);
        _sendMail(useModel);
        await Future.delayed(Duration(seconds: waitNseconds));
      } else {
        _buildTexts(
            'Fout tijdensversturen naar', 'Invalid mail address', emailModel);
      }
    }
  }

  //---------------------------
  Future<void> _checkAllMailAdresses(List<EmailModel> emailList) async {
    for (EmailModel emailModel in emailList) {
      String address = _parseEmailAdress(emailModel.emailAdress);
      if (address.isEmpty) {
        _buildTexts(
            'Omgeldig emailadres : ', 'Invalid mail address', emailModel);
        setState(() {});
      }
    }
  }

  //---------------------------
  void _sendMail(EmailModel emailModel) async {
    String result = await EmailHelper().sendEmail(
        fromUser: _textCtlrs[fromUserIndex].text,
        subject: _textCtlrs[subjectIndex].text,
        toEmail: emailModel.emailAdress,
        signature: emailModel.signature,
        html: ContentHelper()
            .buildContent(emailModel, _textCtlrs[htmlIndex].text));

    setState(() {
      _buildTexts('Fout tijdens versturen naar', result, emailModel);
    });
  }

  void _buildTexts(String prefix, String result, EmailModel emailModel) {
    if (result.isEmpty) {
      _success++;
      _text =
          'Met succes naar ${emailModel.emailAdress} ${emailModel.signature} verstuurd';
    } else {
      _failed++;
      _text = '$prefix ${emailModel.emailAdress}';
      _summary += '\n$_text';
      log('$prefix ${emailModel.emailAdress} ');
    }

    // _summary = '$_success van $_total verstuurd, failed: $_failed';
    _text = '$_success van $_total verstuurd, failed: $_failed';
  }

  String _parseEmailAdress(String value) {
    String emailAddress = value;
    if (value.contains('<')) {
      String s = value.substring(value.indexOf('<') + 1);
      emailAddress = s.substring(0, s.indexOf('>'));
    }

    if (emailAddress.endsWith(",")) {
      emailAddress = emailAddress.substring(0, emailAddress.length - 1);
    }

    bool emailValid = RegExp(
            r"^[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,6}$")
        .hasMatch(emailAddress);

    if (emailValid) {
      return emailAddress;
    } else {
      log('$emailAddress is not valid');
      return '';
    }
  }

  //----------------------------------------------------------
  Widget _testWebButton() {
    return ElevatedButton(
        onPressed: _onTestWebClicked, child: const Text('Test web'));
  }

  void _onTestWebClicked() {
    EmailHelper().sendEmail(
      fromUser: 'robin',
      subject: 'Test mail',
      toEmail: 'robin.bakkerus@gmail.com',
      signature: 'robin',
      html: '<h1>Test mail</h1><p>Test mail</p>',
    );
  }
}
