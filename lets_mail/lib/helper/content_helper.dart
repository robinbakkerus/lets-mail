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
    String htmlContentRemindRSVP = '''
<html>
<body>
<h2>Reminder: Zaterdag 9 november</h2>
<h1>Hallo ${emailModel.signature} </h1>
Dan ben ik jarig en daarom nodig ik je uit voor de Pasta- & Silent Disco party in de 
<font color="red">R</font> <font color="green">G</font> <font color="blue">B</font> Silent Disco Bar, Stratumseind 34a in Eindhoven.
<br>
In verband met catering graag r.s.v.p. <b>uiterlijk dit weekend</b> of, en zo ja met hoeveel je komt.
<br><br>
Voor veel meer info zie mijn <a href="robin70-bbe50.web.app">website</a>
<br><br>
<i>Hopelijk zie ik je op het feest, Robin</i>
<br><br>
<img src="https://lonu.loopgroepnuenen.nl/wp-content/uploads/2024/10/Robin70-feest.png" >
<h3> Kadotip </h3>
In plaats van een kado vraag ik of je mij wilt sponsoren voor de Alpe-du-Zes 2025<br>
zie mijn <a href="https://www.opgevenisgeenoptie.nl/fundraisers/robinbakkerus/alpe-dhuzes">sponsor pagina</a>
</body>
</html>
''';

    String htmlContent = '''
<html>
<body>
<h3>Hallo ${emailModel.signature} </h3>
Volgende week zaterdag 9 november is het zover: de Pasta- & Silent Disco party in de 
<font color="red">R</font> <font color="green">G</font> <font color="blue">B</font> Silent Disco Bar, Stratumseind 34a in Eindhoven.
<br>
Hierbij nog wat laatste info
<h3> Kadotip </h3>
In plaats van een kado, vraag ik of je mij wilt sponsoren voor de Alpe-du-Zes 2025<br>
zie mijn <a href="https://www.opgevenisgeenoptie.nl/fundraisers/robinbakkerus/alpe-dhuzes">sponsor pagina</a>
<br>
<h3> Parkeren </h3>
Een goede, makkelijk bereikbare en goedkope parkeerplaats is het TU terein. Dat is wel ruim een kwartier lopen naar het Stratumseind, <br>maar het lichtroute aan de Glow route!
Zie ook <a href="https://gloweindhoven.nl/praktisch/">gloweindhoven.nl/praktisch</a>
<br>
<h3> Meer Info </h3>
Zie mijn <a href="robin70-bbe50.web.app">Robin70 website</a>
<br>
<h3> Reply je favoriete nummer </h3>
Als je wilt, stuur je favoriete swing nummer. Deze zetten we dan op één van de drie kanalen.
</body>
</html>
''';

    return htmlContent;
  }
}
