import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String _text = '';
  String _summary = '';
  int _total = 0;
  int _success = 0;
  int _failed = 0;

  final _textCtlrs = List<TextEditingController>.generate(6, (index) {
    return TextEditingController();
  });

  final _subjectIndex = 0;
  final _fromUserIndex = 1;
  final _mailingListIndex = 2;
  final _htmlIndex = 3;
  final _bccCountIndex = 4;
  final _waitNSecondsCountIndex = 5;

  bool _dryRun = true;
  bool _execEnabled = false;
  File? _excelFile;

  @override
  void initState() {
    super.initState();
    _textCtlrs[_bccCountIndex].text = '0';
    _textCtlrs[_waitNSecondsCountIndex].text = '3';

    for (TextEditingController ctrl in _textCtlrs) {
      ctrl.addListener(() {
        setState(() {
          _checkExecEnabled();
        });
      });
    }
  }

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
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _subjectInput('Subject', _subjectIndex),
              _htmlInput('Body html', _htmlIndex),
              _fromUserInput('From user', _fromUserIndex),
              _emailListInput("Mailing list", _mailingListIndex),
              _runOptions(),
              SizedBox(height: 20),
              _executeButton(),
              Text(_summary),
              // _testWebButton(),
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
      ],
    );
  }

//----------------------------------------------------------
  Widget _runOptions() {
    return Row(
      children: [
        SizedBox(width: 150, child: Text('Bcc count')),
        SizedBox(
          width: 40,
          child: TextField(
              enabled: !_hasSignature,
              controller: _textCtlrs[_bccCountIndex],
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ]),
        ),
        SizedBox(
          width: 100,
          child: Container(),
        ),
        SizedBox(width: 150, child: Text('Wait n seconds')),
        SizedBox(
          width: 40,
          child: TextField(
              controller: _textCtlrs[_waitNSecondsCountIndex],
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ]),
        ),
        SizedBox(
          width: 150,
          child: Container(),
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
      _textCtlrs[_mailingListIndex].text = _excelFile!.path;
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
                _text = 'Aantal = $_total';
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
      mainAxisAlignment: MainAxisAlignment.center,
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
    if (_mailWithBcc()) {
      List<String> allToEmails = emailList
          .map((e) => _parseEmailAdress(e.emailAdress))
          .where((element) => element.isNotEmpty)
          .toList();

      int bccCount = int.parse(_textCtlrs[_bccCountIndex].text);

      var list = allToEmails.take(bccCount).toList();
      var rest = allToEmails.skip(bccCount).toList();
      while (list.isNotEmpty) {
        _sendMailsWithBcc(list);
        await Future.delayed(Duration(seconds: _waitNseconds));
        list = rest.take(bccCount).toList();
        rest = rest.skip(bccCount).toList();
      }
    } else {
      await _sendAllMailsIndividually(emailList);
    }
  }

//--------------------------------
  Future<void> _sendAllMailsIndividually(List<EmailModel> emailList) async {
    for (EmailModel emailModel in emailList) {
      String address = _parseEmailAdress(emailModel.emailAdress);
      if (address.isNotEmpty) {
        EmailModel useModel =
            EmailModel(emailAdress: address, signature: emailModel.signature);
        _sendMail(useModel);
        await Future.delayed(Duration(seconds: _waitNseconds));
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
        fromUser: _textCtlrs[_fromUserIndex].text,
        subject: _textCtlrs[_subjectIndex].text,
        toEmail: emailModel.emailAdress,
        signature: emailModel.signature,
        html: ContentHelper()
            .buildContent(emailModel, _textCtlrs[_htmlIndex].text));

    setState(() {
      _buildTexts('Fout tijdens versturen naar', result, emailModel);
    });
  }

  //---------------------------
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

  //---------------------------
  void _sendMailsWithBcc(List<String> toEmails) async {
    String result = await EmailHelper().sendEmailsWithBcc(
        toEmails: toEmails,
        fromUser: _textCtlrs[_fromUserIndex].text,
        subject: _textCtlrs[_subjectIndex].text,
        html: _textCtlrs[_htmlIndex].text);

    setState(() {
      _buildTextsBcc('Fout tijdens versturen naar', result);
    });
  }

  //---------------------------
  void _buildTextsBcc(String prefix, String result) {
    if (result.isEmpty) {
      _success = _success + int.parse(_textCtlrs[_bccCountIndex].text);
      _text = 'Met succes naar meerdere adressen verstuurd verstuurd';
    } else {
      _failed++;
      _text = result;
      _summary += '\n$_text';
    }

    // _summary = '$_success van $_total verstuurd, failed: $_failed';
    _text = '$_success van $_total verstuurd, failed: $_failed';
  }

  //---------------------------
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
  bool _mailWithBcc() {
    int bccCount = int.parse(_textCtlrs[_bccCountIndex].text);
    return bccCount > 0;
  }

  //--------------------------------------------------------------
  int get _waitNseconds {
    return int.parse(_textCtlrs[_waitNSecondsCountIndex].text);
  }

  //--------------------------------------------------------------
  bool get _hasSignature {
    return _textCtlrs[_htmlIndex].text.contains("%naam%");
  }

  //----------------------------------------------------------
  // Widget _testWebButton() {
  //   return ElevatedButton(
  //       onPressed: _onTestWebClicked, child: const Text('Test web'));
  // }

  // void _onTestWebClicked() {
  //   EmailHelper().sendEmail(
  //     fromUser: 'robin',
  //     subject: 'Test mail',
  //     toEmail: 'robin.bakkerus@gmail.com',
  //     signature: 'robin',
  //     html: '<h1>Test mail</h1><p>Test mail</p>',
  //   );
  // }
}
