import 'package:lets_mail/model/email_model.dart';

class ContentHelper {
  // Private constructor to prevent external instantiation.
  ContentHelper._();

  // The single instance of the class.
  static final ContentHelper _instance = ContentHelper._();

  // Factory constructor to provide access to the singleton instance.
  factory ContentHelper() {
    return _instance;
  }

  String buildContent(EmailModel emailModel) {
    String htmlContent = '''
<h1>Hallo ${emailModel.signature} </h1>
Misschien heb je deze mail al eerder ontvangen, maar omdat bij veel mensen deze in de spam box is terecht gekomen, 
(Waarschijnlijk omdat er een klikbare link naar mijn website stond), stuur ik deze aangepaste mail nogmaals.<br>
<br>
<h2>Save-the-date: zaterdag 9 november, inloop vanaf 16.00 uur</h2>
Dan nodig ik je (en je partner) uit voor de Pasta- & Silent Disco party in de 
<font color="red">R</font> <font color="green">G</font> <font color="blue">B</font> Silent Disco Bar, Stratumseind 34a in Eindhoven.
<br>
In verband met catering graag r.s.v.p. voor 1 november of en zo ja met hoeveel je komt.
<br><br>
Voor veel meer info en de poster zie onderstaande url naar mijnwebsite (copy/paste deze naar een browser)
<br>
<font color="blue">robin70-bbe50.web.app</font>
<br><br>
<i>Hopelijk zie ik je dan, Robin</i>


''';

    return htmlContent;
  }
}
