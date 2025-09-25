import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleStorageKey = '__locale_key__';

class FFLocalizations {
  FFLocalizations(this.locale);

  final Locale locale;

  static FFLocalizations of(BuildContext context) =>
      Localizations.of<FFLocalizations>(context, FFLocalizations)!;

  static List<String> languages() => ['en', 'pt', 'de', 'fr', 'es'];

  static late SharedPreferences _prefs;
  static Future initialize() async =>
      _prefs = await SharedPreferences.getInstance();
  static Future storeLocale(String locale) =>
      _prefs.setString(_kLocaleStorageKey, locale);
  static Locale? getStoredLocale() {
    final locale = _prefs.getString(_kLocaleStorageKey);
    return locale != null && locale.isNotEmpty ? createLocale(locale) : null;
  }

  String get languageCode => locale.toString();
  String? get languageShortCode =>
      _languagesWithShortCode.contains(locale.toString())
          ? '${locale.toString()}_short'
          : null;
  int get languageIndex => languages().contains(languageCode)
      ? languages().indexOf(languageCode)
      : 0;

  String getText(String key) =>
      (kTranslationsMap[key] ?? {})[locale.toString()] ?? '';

  String getVariableText({
    String? enText = '',
    String? ptText = '',
    String? deText = '',
    String? frText = '',
    String? esText = '',
  }) =>
      [enText, ptText, deText, frText, esText][languageIndex] ?? '';

  static const Set<String> _languagesWithShortCode = {
    'ar',
    'az',
    'ca',
    'cs',
    'da',
    'de',
    'dv',
    'en',
    'es',
    'et',
    'fi',
    'fr',
    'gr',
    'he',
    'hi',
    'hu',
    'it',
    'km',
    'ku',
    'mn',
    'ms',
    'no',
    'pt',
    'ro',
    'ru',
    'rw',
    'sv',
    'th',
    'uk',
    'vi',
  };
}

/// Used if the locale is not supported by GlobalMaterialLocalizations.
class FallbackMaterialLocalizationDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<MaterialLocalizations> load(Locale locale) async =>
      SynchronousFuture<MaterialLocalizations>(
        const DefaultMaterialLocalizations(),
      );

  @override
  bool shouldReload(FallbackMaterialLocalizationDelegate old) => false;
}

/// Used if the locale is not supported by GlobalCupertinoLocalizations.
class FallbackCupertinoLocalizationDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      SynchronousFuture<CupertinoLocalizations>(
        const DefaultCupertinoLocalizations(),
      );

  @override
  bool shouldReload(FallbackCupertinoLocalizationDelegate old) => false;
}

class FFLocalizationsDelegate extends LocalizationsDelegate<FFLocalizations> {
  const FFLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<FFLocalizations> load(Locale locale) =>
      SynchronousFuture<FFLocalizations>(FFLocalizations(locale));

  @override
  bool shouldReload(FFLocalizationsDelegate old) => false;
}

Locale createLocale(String language) => language.contains('_')
    ? Locale.fromSubtags(
        languageCode: language.split('_').first,
        scriptCode: language.split('_').last,
      )
    : Locale(language);

bool _isSupportedLocale(Locale locale) {
  final language = locale.toString();
  return FFLocalizations.languages().contains(
    language.endsWith('_')
        ? language.substring(0, language.length - 1)
        : language,
  );
}

final kTranslationsMap = <Map<String, Map<String, String>>>[
  // GetStarted00
  {
    'fut5gxq5': {
      'en': 'Help',
      'de': 'Helfen',
      'es': 'Ayuda',
      'fr': 'Aide',
      'pt': 'Ajuda',
    },
    '1md17r3l': {
      'en': 'Get Started',
      'de': 'Erste Schritte',
      'es': 'Empezar',
      'fr': 'Commencer',
      'pt': 'Começar',
    },
    '0268rezm': {
      'en': 'Log in',
      'de': 'Einloggen',
      'es': 'Acceso',
      'fr': 'Se connecter',
      'pt': 'Conecte-se',
    },
    'kfv3agpt': {
      'en': 'Registration via social network',
      'de': 'Registrierung über soziales Netzwerk',
      'es': 'Registro a través de redes sociales',
      'fr': 'Inscription via les réseaux sociaux',
      'pt': 'Cadastro via rede social',
    },
    'geghvfbw': {
      'en': 'Home',
      'de': 'Heim',
      'es': 'Hogar',
      'fr': 'Maison',
      'pt': 'Lar',
    },
  },
  // ContinueAs1
  {
    'qgowcvqw': {
      'en': 'Help',
      'de': 'Helfen',
      'es': 'Ayuda',
      'fr': 'Aide',
      'pt': 'Ajuda',
    },
    'cl1yn8nt': {
      'en': 'Continue as',
      'de': 'Weiter als',
      'es': 'Continuar como',
      'fr': 'Continuer comme',
      'pt': 'Continuar como',
    },
    '0sa3l3hv': {
      'en': 'I´m Visiting',
      'de': 'Ich besuche',
      'es': 'Estoy de visita',
      'fr': 'Je suis en visite',
      'pt': 'Estou visitando',
    },
    '961k70uw': {
      'en': 'I do not have A bahamian ID or Passport',
      'de': 'Ich habe keinen bahamaischen Ausweis oder Reisepass',
      'es': 'No tengo identificación ni pasaporte bahameño.',
      'fr': 'Je n\'ai pas de carte d\'identité ni de passeport bahaméen.',
      'pt': 'Não tenho documento de identidade ou passaporte das Bahamas',
    },
    'nfgti4ce': {
      'en': 'I´m Bahamian',
      'de': 'Ich bin Bahamaer',
      'es': 'Soy bahameño',
      'fr': 'Je suis bahaméen',
      'pt': 'Eu sou das Bahamas',
    },
    'nes976dz': {
      'en': 'I do have A bahamian ID or Passport',
      'de': 'Ich habe einen bahamaischen Ausweis oder Reisepass',
      'es': 'Tengo una identificación o pasaporte bahameño',
      'fr': 'J\'ai une carte d\'identité ou un passeport bahaméen',
      'pt': 'Eu tenho uma identidade ou passaporte das Bahamas',
    },
    '6rfpe6ba': {
      'en':
          'In The Bahamas, the taxi market for tourists is protected by regulation. To comply, that is why we devided riders into two roups: tourists, who can locais, who can ride with any available driver.',
      'de':
          'Auf den Bahamas ist der Taximarkt für Touristen durch Vorschriften geschützt. Um diesen Vorschriften nachzukommen, haben wir die Fahrgäste in zwei Gruppen unterteilt: Touristen, die sich vor Ort aufhalten können, die mit jedem verfügbaren Fahrer mitfahren können.',
      'es':
          'En las Bahamas, el mercado de taxis para turistas está regulado. Para cumplir con las regulaciones, dividimos a los pasajeros en dos grupos: turistas, locales y cualquier conductor disponible.',
      'fr':
          'Aux Bahamas, le marché du taxi touristique est réglementé. Pour s\'y conformer, nous avons divisé les usagers en deux groupes : les touristes, qui peuvent se déplacer et ceux qui peuvent utiliser n\'importe quel chauffeur disponible.',
      'pt':
          'Nas Bahamas, o mercado de táxis para turistas é protegido por regulamentação. Para cumprir, dividimos os passageiros em dois grupos: turistas, que podem viajar com qualquer motorista disponível.',
    },
    'cdie3eab': {
      'en': 'Next',
      'de': 'Nächste',
      'es': 'Próximo',
      'fr': 'Suivant',
      'pt': 'Próximo',
    },
    '9gg55fxc': {
      'en': 'Home',
      'de': 'Heim',
      'es': 'Hogar',
      'fr': 'Maison',
      'pt': 'Lar',
    },
  },
  // CreateProfile2
  {
    '281ap27a': {
      'en': 'Profile',
      'de': 'Profil',
      'es': 'Perfil',
      'fr': 'Profil',
      'pt': 'Perfil',
    },
    'k6fyomae': {
      'en': ' Insert a Photo of you here',
      'de': 'Fügen Sie hier ein Foto von Ihnen ein',
      'es': 'Inserta una foto tuya aquí',
      'fr': 'Insérez une photo de vous ici',
      'pt': 'Insira uma foto sua aqui',
    },
    'xmjtm5y7': {
      'en': ' Type your name here',
      'de': 'Geben Sie hier Ihren Namen ein',
      'es': 'Escribe tu nombre aquí',
      'fr': 'Tapez votre nom ici',
      'pt': 'Digite seu nome aqui',
    },
    'ouan8yhw': {
      'en': 'Give it your best shot at spelling it right',
      'de': 'Geben Sie Ihr Bestes, um es richtig zu buchstabieren',
      'es': 'Haz tu mejor esfuerzo para escribirlo correctamente.',
      'fr': 'Faites de votre mieux pour l\'épeler correctement',
      'pt': 'Dê o seu melhor para soletrar corretamente',
    },
    'e2cj412a': {
      'en': ' Type your surname here',
      'de': 'Geben Sie hier Ihren Nachnamen ein',
      'es': 'Escribe tu apellido aquí',
      'fr': 'Tapez votre nom de famille ici',
      'pt': 'Digite seu sobrenome aqui',
    },
    '5dk4xz52': {
      'en': 'Just a Formality',
      'de': 'Nur eine Formalität',
      'es': 'Sólo una formalidad',
      'fr': 'Juste une formalité',
      'pt': 'Apenas uma formalidade',
    },
    'ohn197g1': {
      'en': ' Type your email here',
      'de': 'Geben Sie hier Ihre E-Mail-Adresse ein',
      'es': 'Escribe tu correo electrónico aquí',
      'fr': 'Tapez votre email ici',
      'pt': 'Digite seu e-mail aqui',
    },
    '2306q68b': {
      'en': 'Your best email so we can verify it is you',
      'de':
          'Ihre beste E-Mail-Adresse, damit wir Ihre Identität bestätigen können',
      'es':
          'Tu mejor correo electrónico para que podamos verificar que eres tú',
      'fr':
          'Votre meilleur email afin que nous puissions vérifier qu\'il s\'agit bien de vous',
      'pt': 'Seu melhor e-mail para que possamos verificar se é você',
    },
    't0w80jvo': {
      'en': ' Insert a password\n',
      'de': 'Geben Sie ein Passwort ein',
      'es': 'Insertar una contraseña',
      'fr': 'Insérer un mot de passe',
      'pt': 'Insira uma senha',
    },
    'm69itacc': {
      'en':
          'Don´t worry if you forget, we´ll be here to \nremind you  when you do.',
      'de':
          'Keine Sorge, falls Sie es vergessen, wir erinnern Sie gerne daran.',
      'es':
          'No te preocupes si lo olvidas, estaremos aquí para recordártelo cuando lo olvides.',
      'fr':
          'Si vous oubliez, ne vous inquiétez pas, nous serons là pour vous le rappeler.',
      'pt':
          'Não se preocupe se você esquecer, estaremos aqui para \nlembrá-lo quando isso acontecer.',
    },
    'fnljor9g': {
      'en': 'Choose your nationality',
      'de': 'Wählen Sie Ihre Nationalität',
      'es': 'Elige tu nacionalidad',
      'fr': 'Choisissez votre nationalité',
      'pt': 'Escolha sua nacionalidade',
    },
    'g1b41gpr': {
      'en': 'Search...',
      'de': 'Suchen...',
      'es': 'Buscar...',
      'fr': 'Recherche...',
      'pt': 'Procurar...',
    },
    'jph117uw': {
      'en': 'Option 1',
      'de': 'Option 1',
      'es': 'Opción 1',
      'fr': 'Option 1',
      'pt': 'Opção 1',
    },
    '5rcvqghx': {
      'en': 'Option 2',
      'de': 'Option 2',
      'es': 'Opción 2',
      'fr': 'Option 2',
      'pt': 'Opção 2',
    },
    '35vt87qn': {
      'en': 'Option 3',
      'de': 'Option 3',
      'es': 'Opción 3',
      'fr': 'Option 3',
      'pt': 'Opção 3',
    },
    '7ueonljt': {
      'en': 'Let us know where your accent is from!',
      'de': 'Lassen Sie uns wissen, woher Ihr Akzent kommt!',
      'es': '¡Cuéntanos de dónde viene tu acento!',
      'fr': 'Dites-nous d’où vient votre accent !',
      'pt': 'Conte-nos de onde vem seu sotaque!',
    },
    'mzsqbo70': {
      'en': ' Select your U.S State',
      'de': 'Wählen Sie Ihren US-Bundesstaat',
      'es': 'Seleccione su estado de EE. UU.',
      'fr': 'Sélectionnez votre État américain',
      'pt': 'Selecione seu estado dos EUA',
    },
    '0yxaivfu': {
      'en': 'Search...',
      'de': 'Suchen...',
      'es': 'Buscar...',
      'fr': 'Recherche...',
      'pt': 'Procurar...',
    },
    '9tql64p9': {
      'en': 'Option 1',
      'de': 'Option 1',
      'es': 'Opción 1',
      'fr': 'Option 1',
      'pt': 'Opção 1',
    },
    'mw8knns9': {
      'en': 'Option 2',
      'de': 'Option 2',
      'es': 'Opción 2',
      'fr': 'Option 2',
      'pt': 'Opção 2',
    },
    'wwzt5avu': {
      'en': 'Option 3',
      'de': 'Option 3',
      'es': 'Opción 3',
      'fr': 'Option 3',
      'pt': 'Opção 3',
    },
    'hlykglhq': {
      'en': 'Ignore this step if you are not American.',
      'de': 'Ignorieren Sie diesen Schritt, wenn Sie kein Amerikaner sind.',
      'es': 'Ignore este paso si no es estadounidense.',
      'fr': 'Ignorez cette étape si vous n’êtes pas américain.',
      'pt': 'Ignore esta etapa se você não for americano.',
    },
    'p5hihdt4': {
      'en': 'Next',
      'de': 'Nächste',
      'es': 'Próximo',
      'fr': 'Suivant',
      'pt': 'Próximo',
    },
    'rpsd8a8c': {
      'en': 'Home',
      'de': 'Heim',
      'es': 'Hogar',
      'fr': 'Maison',
      'pt': 'Lar',
    },
  },
  // VerifyAccount3
  {
    'ghn677x0': {
      'en': 'Verify Your \nAccount',
      'de': 'Verifizieren Sie Ihr\nKonto',
      'es': 'Verifica tu cuenta',
      'fr': 'Vérifiez votre compte',
      'pt': 'Verifique sua\nconta',
    },
    '5g27hqw3': {
      'en': 'An email was sent to',
      'de': 'Eine E-Mail wurde gesendet an',
      'es': 'Se envió un correo electrónico a',
      'fr': 'Un e-mail a été envoyé à',
      'pt': 'Um e-mail foi enviado para',
    },
    'u0ctzyu7': {
      'en':
          'Please confirm by clicking on the email we sent to the email address provided.',
      'de':
          'Bitte bestätigen Sie dies durch Anklicken der E-Mail, die wir an die angegebene E-Mail-Adresse gesendet haben.',
      'es':
          'Por favor, confirme haciendo clic en el correo electrónico que le enviamos a la dirección de correo electrónico proporcionada.',
      'fr':
          'Veuillez confirmer en cliquant sur l\'e-mail que nous avons envoyé à l\'adresse e-mail fournie.',
      'pt':
          'Por favor, confirme clicando no e-mail que enviamos para o endereço de e-mail fornecido.',
    },
    'd1wov68j': {
      'en': 'Hang thight we´re almost there.....',
      'de': 'Haltet durch, wir sind fast da.....',
      'es': 'Agárrate fuerte, ya casi llegamos...',
      'fr': 'Accrochez-vous bien, nous y sommes presque...',
      'pt': 'Aguente firme, estamos quase lá.....',
    },
    'ni71euqk': {
      'en': 'Next',
      'de': 'Nächste',
      'es': 'Próximo',
      'fr': 'Suivant',
      'pt': 'Próximo',
    },
    '94xjto8g': {
      'en': 'Home',
      'de': 'Heim',
      'es': 'Hogar',
      'fr': 'Maison',
      'pt': 'Lar',
    },
  },
  // Home5
  {
    'xvxg7iay': {
      'en': 'Bahamar',
      'de': 'Bahamas',
      'es': 'Bahamas',
      'fr': 'Bahamar',
      'pt': 'Bahamas',
    },
    'sc5z9sde': {
      'en': 'Airport',
      'de': 'Flughafen',
      'es': 'Aeropuerto',
      'fr': 'Aéroport',
      'pt': 'Aeroporto',
    },
    'ybwe42qc': {
      'en': 'Ride Estimative',
      'de': 'Fahrtenschätzung',
      'es': 'Estimación de viaje',
      'fr': 'Estimation du trajet',
      'pt': 'Estimativa de viagem',
    },
    '76w8fz75': {
      'en': 'Time',
      'de': 'Zeit',
      'es': 'Tiempo',
      'fr': 'Temps',
      'pt': 'Tempo',
    },
    '6xonkgu6': {
      'en': 'Ride ',
      'de': 'Ride',
      'es': 'Ride',
      'fr': 'Ride',
      'pt': 'Ride',
    },
    'hp82na6c': {
      'en': '3 min',
      'de': '3 Minuten',
      'es': '3 minutos',
      'fr': '3 minutes',
      'pt': '3 minutos',
    },
    'h5ahsyfq': {
      'en': 'XL',
      'de': 'XL',
      'es': 'XL',
      'fr': 'XL',
      'pt': 'XL',
    },
    'tr0g6iky': {
      'en': '6 min',
      'de': '6 Minuten',
      'es': '6 minutos',
      'fr': '6 minutes',
      'pt': '6 minutos',
    },
    'drdui58r': {
      'en': 'Luxury',
      'de': 'Luxus',
      'es': 'Lujo',
      'fr': 'Luxe',
      'pt': 'Luxo',
    },
    'zkgb4g4y': {
      'en': '10 min',
      'de': '10 Minuten',
      'es': '10 minutos',
      'fr': '10 minutes',
      'pt': '10 minutos',
    },
    'iv1ii278': {
      'en': 'Confirm Ride  ',
      'de': 'Fahrt bestätigen',
      'es': 'Confirmar viaje',
      'fr': 'Confirmer',
      'pt': 'Confirmar',
    },
    'nzvn5ujp': {
      'en': 'Ride Share',
      'de': 'Mitfahrgelegenheit',
      'es': 'Viaje compartido',
      'fr': 'Covoiturage',
      'pt': 'Compartilhar',
    },
    '0tmlssyf': {
      'en': 'Home',
      'de': 'Heim',
      'es': 'Hogar',
      'fr': 'Maison',
      'pt': 'Lar',
    },
  },
  // ChoosePass4
  {
    '62n8c2s0': {
      'en': 'Choose your pass',
      'de': 'Wählen Sie Ihren Pass',
      'es': 'Elige tu pase',
      'fr': 'Choisissez votre pass',
      'pt': 'Escolha seu passe',
    },
    'aztno95n': {
      'en': 'Day Pass',
      'de': 'Tageskarte',
      'es': 'Pase de día',
      'fr': 'Pass journalier',
      'pt': 'Passe de um dia',
    },
    'ap2qguhl': {
      'en': 'Select',
      'de': 'Wählen',
      'es': 'Seleccionar',
      'fr': 'Sélectionner',
      'pt': 'Selecione',
    },
    '2c7511xj': {
      'en': '\$5',
      'de': '5 \$',
      'es': '\$5',
      'fr': '5 \$',
      'pt': '\$ 5',
    },
    '85t1uv66': {
      'en': 'Unlimited rides today + \$3 per ride fuel fee',
      'de': 'Unbegrenzte Fahrten heute + 3 \$ Treibstoffgebühr pro Fahrt',
      'es': 'Viajes ilimitados hoy + \$3 de tarifa de combustible por viaje',
      'fr':
          'Trajets illimités aujourd\'hui + 3 \$ de frais de carburant par trajet',
      'pt':
          'Passeios ilimitados hoje + taxa de combustível de US\$ 3 por passeio',
    },
    'ybtz024k': {
      'en': 'Week Pass',
      'de': 'Wochenkarte',
      'es': 'Pase semanal',
      'fr': 'Passe hebdomadaire',
      'pt': 'Passe semanal',
    },
    'xo1ob6ng': {
      'en': '\$8',
      'de': '8 \$',
      'es': '\$8',
      'fr': '8 \$',
      'pt': '\$ 8',
    },
    'fzf0vq27': {
      'en': 'Unlimited rides today + \$7 per ride fuel fee',
      'de': 'Unbegrenzte Fahrten heute + 7 \$ Treibstoffgebühr pro Fahrt',
      'es': 'Viajes ilimitados hoy + \$7 de tarifa de combustible por viaje',
      'fr':
          'Trajets illimités aujourd\'hui + 7 \$ de frais de carburant par trajet',
      'pt':
          'Viagens ilimitadas hoje + taxa de combustível de US\$ 7 por viagem',
    },
    'dsbnwvxg': {
      'en': 'Recommended',
      'de': 'Empfohlen',
      'es': 'Recomendado',
      'fr': 'Recommandé',
      'pt': 'Recomendado',
    },
    'ss88el5s': {
      'en': 'Select',
      'de': 'Wählen',
      'es': 'Seleccionar',
      'fr': 'Sélectionner',
      'pt': 'Selecione',
    },
    'x4d1o852': {
      'en': 'Month Pass',
      'de': 'Monatskarte',
      'es': 'Pase mensual',
      'fr': 'Pass mensuel',
      'pt': 'Passe mensal',
    },
    'yh52ifb4': {
      'en': 'Select',
      'de': 'Wählen',
      'es': 'Seleccionar',
      'fr': 'Sélectionner',
      'pt': 'Selecione',
    },
    'fzc219qz': {
      'en': '\$10',
      'de': '10 US-Dollar',
      'es': '\$10',
      'fr': '10 \$',
      'pt': '\$ 10',
    },
    'owjc7pvd': {
      'en': 'Unlimited rides for 30 days + \$3 fuel fee',
      'de': 'Unbegrenzte Fahrten für 30 Tage + 3 \$ Treibstoffgebühr',
      'es': 'Viajes ilimitados por 30 días + tarifa de combustible de \$3',
      'fr': 'Trajets illimités pendant 30 jours + 3 \$ de frais de carburant',
      'pt': 'Viagens ilimitadas por 30 dias + taxa de combustível de US\$ 3',
    },
    'e56s6ui2': {
      'en': 'Click here to try it for free for 1 day',
      'de': 'Klicken Sie hier, um es 1 Tag lang kostenlos zu testen',
      'es': 'Haga clic aquí para probarlo gratis durante 1 día',
      'fr': 'Cliquez ici pour l\'essayer gratuitement pendant 1 jour',
      'pt': 'Clique aqui para experimentar gratuitamente por 1 dia',
    },
    'prrhxcs8': {
      'en': 'Auto-renew',
      'de': 'Automatische Verlängerung',
      'es': 'Renovación automática',
      'fr': 'Renouvellement automatique',
      'pt': 'Renovação automática',
    },
    'm3whqe67': {
      'en': 'Applies to Week/Month passes',
      'de': 'Gilt für Wochen-/Monatskarten',
      'es': 'Aplica para pases Semanales/Meses',
      'fr': 'S\'applique aux forfaits semaine/mois',
      'pt': 'Aplica-se a passes semanais/mensais',
    },
    'o92dxp15': {
      'en': 'What is included?',
      'de': 'Was ist im Lieferumfang enthalten?',
      'es': '¿Qué incluye?',
      'fr': 'Qu\'est-ce qui est inclus ?',
      'pt': 'O que está incluído?',
    },
    'gmh5ry67': {
      'en': 'Unlimited rides with an active pass',
      'de': 'Unbegrenzte Fahrten mit einem Aktivpass',
      'es': 'Viajes ilimitados con un pase activo',
      'fr': 'Trajets illimités avec un pass actif',
      'pt': 'Passeios ilimitados com um passe ativo',
    },
    'jhkq5kpo': {
      'en': 'Each ride has a \$3 fuel fee',
      'de': 'Für jede Fahrt fällt eine Treibstoffgebühr von 3 \$ an.',
      'es': 'Cada viaje tiene una tarifa de combustible de \$3.',
      'fr': 'Chaque trajet comporte des frais de carburant de 3 \$',
      'pt': 'Cada viagem tem uma taxa de combustível de US\$ 3',
    },
    '3n3wfprk': {
      'en': 'Cancel anytime (prorate on Month only).',
      'de': 'Jederzeit kündbar (nur anteilig für den Monat).',
      'es': 'Cancelar en cualquier momento (prorrateo por mes solamente).',
      'fr': 'Annulez à tout moment (au prorata du mois seulement).',
      'pt': 'Cancele a qualquer momento (somente no mês proporcional).',
    },
    'qnne6q0t': {
      'en': 'Help',
      'de': 'Helfen',
      'es': 'Ayuda',
      'fr': 'Aide',
      'pt': 'Ajuda',
    },
    'j4x9hd45': {
      'en': 'Continue',
      'de': 'Weitermachen',
      'es': 'Continuar',
      'fr': 'Continuer',
      'pt': 'Continuar',
    },
    '6aopbiol': {
      'en': 'Home',
      'de': 'Heim',
      'es': 'Hogar',
      'fr': 'Maison',
      'pt': 'Lar',
    },
  },
  // RideShare6
  {
    'c2ku81ov': {
      'en': 'Ride Share',
      'de': 'Mitfahrgelegenheit',
      'es': 'Viaje compartido',
      'fr': 'Covoiturage',
      'pt': 'Compartilhamento de viagens',
    },
    'vd485i7w': {
      'en':
          'Invite riders to split the fare or let us auto-match nearby riders.',
      'de':
          'Laden Sie Fahrgäste ein, den Fahrpreis zu teilen, oder lassen Sie uns automatisch Fahrgäste in der Nähe zuordnen.',
      'es':
          'Invite a los pasajeros a dividir la tarifa o permítanos emparejar automáticamente a los pasajeros cercanos.',
      'fr':
          'Invitez les passagers à partager le tarif ou laissez-nous faire correspondre automatiquement les passagers à proximité.',
      'pt':
          'Convide os passageiros a dividir a tarifa ou deixe que façamos a correspondência automática com passageiros próximos.',
    },
    '5dxw36ml': {
      'en': 'Invite friends',
      'de': 'Freunde einladen',
      'es': 'Invitar amigos',
      'fr': 'Inviter des amis',
      'pt': 'Convidar amigos',
    },
    '9ensgtkt': {
      'en': 'QR',
      'de': 'QR',
      'es': 'Código QR',
      'fr': 'QR',
      'pt': 'QR',
    },
    'yglrvlqu': {
      'en': 'Link',
      'de': 'Link',
      'es': 'Enlace',
      'fr': 'Lien',
      'pt': 'Link',
    },
    'wme97if5': {
      'en': 'Auto-match nearby riders',
      'de': 'Automatische Zuordnung zu Fahrern in der Nähe',
      'es': 'Emparejamiento automático de pasajeros cercanos',
      'fr': 'Associer automatiquement les coureurs à proximité',
      'pt': 'Correspondência automática de passageiros próximos',
    },
    'ax3wm89h': {
      'en': 'Participants',
      'de': 'Teilnehmer',
      'es': 'Participantes',
      'fr': 'Participants',
      'pt': 'Participantes',
    },
    'niwa8eid': {
      'en': 'Tab to remove • “- -“ are open spots',
      'de': 'Tab zum Entfernen • „- -“ sind offene Plätze',
      'es': 'Pestaña para eliminar • “- -“ son espacios abiertos',
      'fr': 'Onglet à supprimer • « - - » sont des espaces ouverts',
      'pt': 'Tab para remover • “- -“ são pontos abertos',
    },
    'us6osckg': {
      'en': 'Riders splitting',
      'de': 'Reiter teilen sich',
      'es': 'Jinetes dividiéndose',
      'fr': 'Les coureurs se séparent',
      'pt': 'Cavaleiros se dividindo',
    },
    'wpvhw4cs': {
      'en': 'Equal split',
      'de': 'Gleiche Aufteilung',
      'es': 'División equitativa',
      'fr': 'Partage égal',
      'pt': 'Divisão igual',
    },
    'enexrc8j': {
      'en': 'Custom %',
      'de': 'Brauch %',
      'es': 'Costumbre %',
      'fr': 'Coutume %',
      'pt': 'Personalizado %',
    },
    'nvqck3af': {
      'en': 'Hold 1 extra seat for your friend',
      'de': 'Reservieren Sie 1 zusätzlichen Sitzplatz für Ihren Freund',
      'es': 'Reserva 1 asiento extra para tu amigo',
      'fr': 'Réservez 1 siège supplémentaire pour votre ami',
      'pt': 'Reserve 1 assento extra para seu amigo',
    },
    'qycpjvd7': {
      'en': 'Your share',
      'de': 'Ihr Anteil',
      'es': 'Tu parte',
      'fr': 'Votre part',
      'pt': 'Sua parte',
    },
    'a0l4grqi': {
      'en': '+3 min detour',
      'de': '+3 Minuten Umweg',
      'es': '+3 min de desvío',
      'fr': '+3 min de détour',
      'pt': '+3 min de desvio',
    },
    'm8s3ygc5': {
      'en': '\$6.50',
      'de': '6,50 \$',
      'es': '\$6.50',
      'fr': '6,50 \$',
      'pt': '\$ 6,50',
    },
    's3y7hgro': {
      'en': 'Price updates if route or riders change before pickuo.',
      'de':
          'Preisaktualisierungen, wenn sich Route oder Fahrer vor der Abholung ändern.',
      'es':
          'Actualizaciones de precios si la ruta o los pasajeros cambian antes de la recogida.',
      'fr':
          'Mises à jour des prix si l\'itinéraire ou les passagers changent avant le ramassage.',
      'pt':
          'Atualizações de preços caso a rota ou os passageiros mudem antes do embarque.',
    },
    'y5mje1pu': {
      'en': 'Privacy',
      'de': 'Datenschutz',
      'es': 'Privacidad',
      'fr': 'Confidentialité',
      'pt': 'Privacidade',
    },
    '031obrr6': {
      'en': 'Invite link only',
      'de': 'Nur Einladungslink',
      'es': 'Solo enlace de invitación',
      'fr': 'Lien d\'invitation uniquement',
      'pt': 'Somente link de convite',
    },
    'kqvwz04w': {
      'en': 'Open to nearby',
      'de': 'Offen für die Umgebung',
      'es': 'Abierto a los cercanos',
      'fr': 'Ouvert à proximité',
      'pt': 'Aberto para pessoas próximas',
    },
    'ntglhxb6': {
      'en': 'Confirm Ride Share',
      'de': 'Mitfahrgelegenheit bestätigen',
      'es': 'Confirmar viaje compartido',
      'fr': 'Confirmer le partage de trajet',
      'pt': 'Confirmar compartilhamento de viagem',
    },
    '4br05fcj': {
      'en': 'Skip for now',
      'de': 'Vorerst überspringen',
      'es': 'Saltar por ahora',
      'fr': 'Passer pour l\'instant',
      'pt': 'Pular por enquanto',
    },
    'ltqpaty4': {
      'en': 'Next: Matching - Get picked up faster',
      'de': 'Weiter: Matching – Schneller gefunden werden',
      'es': 'Siguiente: Emparejamiento - Consigue que te recojan más rápido',
      'fr': 'Suivant : Matching - Soyez pris en charge plus rapidement',
      'pt': 'Próximo: Correspondência - Seja escolhido mais rápido',
    },
    'xmyritfr': {
      'en': 'Home',
      'de': 'Heim',
      'es': 'Hogar',
      'fr': 'Maison',
      'pt': 'Lar',
    },
  },
  // PaymentRide7
  {
    '48il5165': {
      'en': 'Payment for this ride',
      'de': 'Bezahlung für diese Fahrt',
      'es': 'Pago por este viaje',
      'fr': 'Paiement pour ce trajet',
      'pt': 'Pagamento por esta viagem',
    },
    'p8t3hsvx': {
      'en': 'Tourist pass: Week (\$8)',
      'de': 'Touristenpass: Woche (8 \$)',
      'es': 'Pase turístico: Semana (\$8)',
      'fr': 'Pass touristique : Semaine (8 \$)',
      'pt': 'Passe turístico: Semana (US\$ 8)',
    },
    'p6e8yole': {
      'en': 'Valid: Aug 20',
      'de': 'Gültig: 20. August',
      'es': 'Válido: agosto de 2020',
      'fr': 'Valable jusqu\'au 20 août',
      'pt': 'Válido: 20 de agosto',
    },
    'axid08n7': {
      'en': 'Fuel fee: 3 per ride',
      'de': 'Kraftstoffgebühr: 3 pro Fahrt',
      'es': 'Tarifa de combustible: 3 por viaje',
      'fr': 'Frais de carburant : 3 par trajet',
      'pt': 'Taxa de combustível: 3 por viagem',
    },
    'l5w20jdh': {
      'en': 'Charged on Visa *****4343',
      'de': 'Belastung von Visa *****4343',
      'es': 'Cargado con Visa *****4343',
      'fr': 'Facturé sur Visa *****4343',
      'pt': 'Cobrado no Visa *****4343',
    },
    '5f5qcm62': {
      'en': 'Time Riding',
      'de': 'Zeitreiten',
      'es': 'Montar en el tiempo',
      'fr': 'Le temps à cheval',
      'pt': 'Cavalgando no Tempo',
    },
    'lpcumiyr': {
      'en': 'Pay in app (Recommendad)',
      'de': 'Bezahlen in der App (Empfohlen)',
      'es': 'Pagar en la aplicación (Recomendado)',
      'fr': 'Payer dans l\'application (Recommandé)',
      'pt': 'Pagar no aplicativo (recomendado)',
    },
    'ow1d3q6k': {
      'en': 'Pay driver directly',
      'de': 'Fahrer direkt bezahlen',
      'es': 'Pagar directamente al conductor',
      'fr': 'Payer directement le chauffeur',
      'pt': 'Pague o motorista diretamente',
    },
    'je5nvpjw': {
      'en': 'Notes for drive (optional)',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'vse9hbic': {
      'en': 'e.g., meet at Hotel lobby',
      'de': 'Treffen Sie sich beispielsweise in der Hotellobby',
      'es': 'Por ejemplo, reunirse en el vestíbulo del hotel.',
      'fr': 'par exemple, rendez-vous dans le hall de l\'hôtel',
      'pt': 'por exemplo, encontrar-se no lobby do hotel',
    },
    'q0r0r5ua': {
      'en': 'This Default ',
      'de': 'Dieser Standard',
      'es': 'Este valor predeterminado',
      'fr': 'Ce défaut',
      'pt': 'Este padrão',
    },
    'nxuhtebu': {
      'en': 'Optinal tip (at pickup)',
      'de': 'Optionales Trinkgeld (bei Abholung)',
      'es': 'Punta opcional (al recoger)',
      'fr': 'Pourboire optionnel (au moment du retrait)',
      'pt': 'Gorjeta opcional (na retirada)',
    },
    'gd3kce3k': {
      'en': '\$1',
      'de': '\$1',
      'es': '\$1',
      'fr': '1 \$',
      'pt': '\$ 1',
    },
    '994bahd0': {
      'en': '\$2',
      'de': '2 \$',
      'es': '\$2',
      'fr': '2 \$',
      'pt': '\$ 2',
    },
    'esljy9on': {
      'en': '\$3',
      'de': '3 \$',
      'es': '\$3',
      'fr': '3 \$',
      'pt': '\$ 3',
    },
    'm9wj15bb': {
      'en': 'No tip',
      'de': 'Kein Trinkgeld',
      'es': 'Sin propina',
      'fr': 'Pas de pourboire',
      'pt': 'Sem gorjeta',
    },
    '6r67s6mb': {
      'en': 'Confirm & Pay',
      'de': 'Bestätigen & Bezahlen',
      'es': 'Confirmar y pagar',
      'fr': 'Confirmer et payer',
      'pt': 'Confirmar e pagar',
    },
    'n1vblhdo': {
      'en': 'You´ll be charged after ride',
      'de': 'Die Kosten werden Ihnen nach der Fahrt in Rechnung gestellt.',
      'es': 'Se le cobrará después del viaje.',
      'fr': 'Vous serez facturé après le trajet',
      'pt': 'Você será cobrado após o passeio',
    },
    'zdfdyn5j': {
      'en': 'After this step -> Matching',
      'de': 'Nach diesem Schritt -> Matching',
      'es': 'Después de este paso -> Coincidencia',
      'fr': 'Après cette étape -> Correspondance',
      'pt': 'Após esta etapa -> Correspondência',
    },
    'lirtvu7q': {
      'en': 'Home',
      'de': 'Heim',
      'es': 'Hogar',
      'fr': 'Maison',
      'pt': 'Lar',
    },
  },
  // FindingDrive8
  {
    '6t1vj4fp': {
      'en': '?',
      'de': '?',
      'es': '?',
      'fr': '?',
      'pt': '?',
    },
    'fvekpq8i': {
      'en': 'Help',
      'de': 'Helfen',
      'es': 'Ayuda',
      'fr': 'Aide',
      'pt': 'Ajuda',
    },
    'dzgg1k15': {
      'en': 'Finding your drive',
      'de': 'Finden Sie Ihren Antrieb',
      'es': 'Encontrar tu impulso',
      'fr': 'Trouver votre motivation',
      'pt': 'Encontrando sua motivação',
    },
    '1ws76v5h': {
      'en': '7 free cars avaliable in your area',
      'de': '7 kostenlose Autos in Ihrer Nähe verfügbar',
      'es': '7 coches gratis disponibles en tu zona',
      'fr': '7 voitures gratuites disponibles dans votre région',
      'pt': '7 carros gratuitos disponíveis na sua área',
    },
    'yh8ymsh0': {
      'en': 'Matching...',
      'de': 'Passend dazu...',
      'es': 'Pareo...',
      'fr': 'Correspondance...',
      'pt': 'Combinando...',
    },
    'qfyfz06g': {
      'en': 'Looking for the closest drive',
      'de': 'Suche nach dem nächstgelegenen Laufwerk',
      'es': 'Buscando la unidad más cercana',
      'fr': 'À la recherche du trajet le plus proche',
      'pt': 'Procurando o caminho mais próximo',
    },
    'ju9weu1g': {
      'en': 'Get picked up faster',
      'de': 'Schneller abgeholt werden',
      'es': 'Que te recojan más rápido',
      'fr': 'Soyez pris en charge plus rapidement',
      'pt': 'Seja pego mais rápido',
    },
    'ylwofv54': {
      'en': '+ \$10',
      'de': '+ 10 \$',
      'es': '+ \$10',
      'fr': '+ 10 \$',
      'pt': '+ \$ 10',
    },
    '554nwd7h': {
      'en': 'in 2 min',
      'de': 'in 2 Minuten',
      'es': 'en 2 minutos',
      'fr': 'dans 2 min',
      'pt': 'em 2 minutos',
    },
    's5ftc24v': {
      'en': 'Cancel',
      'de': 'Stornieren',
      'es': 'Cancelar',
      'fr': 'Annuler',
      'pt': 'Cancelar',
    },
    'nolak4es': {
      'en': 'Home',
      'de': 'Heim',
      'es': 'Hogar',
      'fr': 'Maison',
      'pt': 'Lar',
    },
  },
  // PickingYou9
  {
    'jq444zfv': {
      'en': 'will be Pickign you up!',
      'de': 'werde dich abholen!',
      'es': '¡Te recogeré!',
      'fr': 'Je viendrai te chercher !',
      'pt': 'vou buscá-lo!',
    },
    'y1vsihrp': {
      'en': 'The car is Black',
      'de': 'Das Auto ist schwarz',
      'es': 'El coche es negro',
      'fr': 'La voiture est noire',
      'pt': 'O carro é preto',
    },
    '1t8w1ugq': {
      'en': 'see the exact photo of the car',
      'de': 'siehe das genaue Foto des Autos',
      'es': 'ver la foto exacta del coche',
      'fr': 'voir la photo exacte de la voiture',
      'pt': 'veja a foto exata do carro',
    },
    '2fe69r0j': {
      'en': 'Price:',
      'de': 'Preis:',
      'es': 'Precio:',
      'fr': 'Prix:',
      'pt': 'Preço:',
    },
    'lt7cbmp9': {
      'en': 'Approximate time',
      'de': 'Ungefähre Zeit',
      'es': 'Tiempo aproximado',
      'fr': 'Durée approximative',
      'pt': 'Tempo aproximado',
    },
    '0s98a81g': {
      'en': 'Approximate ETA',
      'de': 'Ungefähre voraussichtliche Ankunftszeit',
      'es': 'ETA aproximada',
      'fr': 'ETA approximatif',
      'pt': 'ETA aproximado',
    },
    '8ln043c8': {
      'en': 'Add  Stop',
      'de': 'Stopp hinzufügen',
      'es': 'Agregar parada',
      'fr': 'Ajouter un arrêt',
      'pt': 'Adicionar Parada',
    },
    'oullosfc': {
      'en': 'Price:',
      'de': 'Preis:',
      'es': 'Precio:',
      'fr': 'Prix:',
      'pt': 'Preço:',
    },
    'h082ajlx': {
      'en': 'Driver level:',
      'de': 'Treiberebene:',
      'es': 'Nivel de conductor:',
      'fr': 'Niveau du conducteur :',
      'pt': 'Nível do motorista:',
    },
    'n7c9xyom': {
      'en': 'Approximate time\nfor pickup',
      'de': 'Ungefähre Zeit\nfür die Abholung',
      'es': 'Hora aproximada de recogida',
      'fr': 'Heure approximative de prise en charge',
      'pt': 'Horário aproximado\npara retirada',
    },
    'j2gp4piq': {
      'en': 'Cancel Ride',
      'de': 'Fahrt abbrechen',
      'es': 'Cancelar viaje',
      'fr': 'Annuler le trajet',
      'pt': 'Cancelar viagem',
    },
    'eyuyzrjp': {
      'en': '(car 12)',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'o72gwvza': {
      'en': 'Premium car',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'e5er2tlj': {
      'en': 'VIEW ALL',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'iwl7rz1y': {
      'en': 'Schedule Pickup',
      'de': 'Fahrt abbrechen',
      'es': 'Cancelar viaje',
      'fr': 'Annuler le trajet',
      'pt': 'Cancelar viagem',
    },
    'zb68ezes': {
      'en': 'Tip Driver',
      'de': 'Fahrt abbrechen',
      'es': 'Cancelar viaje',
      'fr': 'Annuler le trajet',
      'pt': 'Cancelar viagem',
    },
    'nomzd5aj': {
      'en': 'Finish Ride',
      'de': 'Fahrt abbrechen',
      'es': 'Cancelar viaje',
      'fr': 'Annuler le trajet',
      'pt': 'Cancelar viagem',
    },
    '184e8z8s': {
      'en': 'Ride in Progress',
      'de': 'Fahrt läuft',
      'es': 'Paseo en progreso',
      'fr': 'Balade en cours',
      'pt': 'Passeio em andamento',
    },
    'nqvdlzvo': {
      'en': 'Home',
      'de': 'Heim',
      'es': 'Hogar',
      'fr': 'Maison',
      'pt': 'Lar',
    },
  },
  // Login0
  {
    'm895k4ns': {
      'en': 'Help',
      'de': 'Helfen',
      'es': 'Ayuda',
      'fr': 'Aide',
      'pt': 'Ajuda',
    },
    'tj04hhzt': {
      'en': 'Email address',
      'de': 'E-Mail-Adresse',
      'es': 'Dirección de correo electrónico',
      'fr': 'Adresse email',
      'pt': 'Endereço de email',
    },
    '5oebsvgd': {
      'en': 'Password',
      'de': 'Passwort',
      'es': 'Contraseña',
      'fr': 'Mot de passe',
      'pt': 'Senha',
    },
    'h8805fpm': {
      'en': 'Log in',
      'de': 'Einloggen',
      'es': 'Acceso',
      'fr': 'Se connecter',
      'pt': 'Conecte-se',
    },
    'e5wx6dwp': {
      'en': 'Don´t have an account?',
      'de': 'Sie haben noch kein Konto?',
      'es': '¿No tienes una cuenta?',
      'fr': 'Vous n\'avez pas de compte ?',
      'pt': 'Não tem uma conta?',
    },
    'jymms9a4': {
      'en': 'Sign up',
      'de': 'Melden Sie sich an',
      'es': 'Inscribirse',
      'fr': 'S\'inscrire',
      'pt': 'Inscrever-se',
    },
    'zmih9mai': {
      'en': 'Home',
      'de': 'Heim',
      'es': 'Hogar',
      'fr': 'Maison',
      'pt': 'Lar',
    },
  },
  // RideProgress10
  {
    'p4hpd3m1': {
      'en': 'Ride in Progress',
      'de': 'Fahrt läuft',
      'es': 'Paseo en progreso',
      'fr': 'Balade en cours',
      'pt': 'Passeio em andamento',
    },
    'lgdwcl2z': {
      'en': 'Price:',
      'de': 'Preis:',
      'es': 'Precio:',
      'fr': 'Prix:',
      'pt': 'Preço:',
    },
    '118h1wq1': {
      'en': '\$ 14',
      'de': '14 \$',
      'es': '\$14',
      'fr': '14 \$',
      'pt': '\$ 14',
    },
    'z3i8b715': {
      'en': 'Enisson',
      'de': 'Enisson',
      'es': 'Enisson',
      'fr': 'Enisson',
      'pt': 'Enisson',
    },
    'oqlvom82': {
      'en': 'Godoy',
      'de': 'Godoy',
      'es': 'Godoy',
      'fr': 'Godoy',
      'pt': 'Godoy',
    },
    'u88w243v': {
      'en': 'Approximate time',
      'de': 'Ungefähre Zeit',
      'es': 'Tiempo aproximado',
      'fr': 'Durée approximative',
      'pt': 'Tempo aproximado',
    },
    'o3oghw8x': {
      'en': '7 min',
      'de': '7 Minuten',
      'es': '7 minutos',
      'fr': '7 minutes',
      'pt': '7 minutos',
    },
    'lx5nbmnk': {
      'en': 'Approximate ETA',
      'de': 'Ungefähre voraussichtliche Ankunftszeit',
      'es': 'ETA aproximada',
      'fr': 'ETA approximatif',
      'pt': 'ETA aproximado',
    },
    '4p6fz6fh': {
      'en': '4:30pm',
      'de': '16:30 Uhr',
      'es': '4:30 p. m.',
      'fr': '16h30',
      'pt': '16h30',
    },
    '1zcn7whm': {
      'en': 'Add  Stop',
      'de': 'Stopp hinzufügen',
      'es': 'Agregar parada',
      'fr': 'Ajouter un arrêt',
      'pt': 'Adicionar Parada',
    },
    'n19u7i5o': {
      'en': 'Home',
      'de': 'Heim',
      'es': 'Hogar',
      'fr': 'Maison',
      'pt': 'Lar',
    },
  },
  // RideProgressCopy11
  {
    'eaie6vqv': {
      'en': 'You Arrived at',
      'de': 'Sie sind angekommen bei',
      'es': 'Llegaste a',
      'fr': 'Vous êtes arrivé à',
      'pt': 'Você chegou em',
    },
    'cnfdqzgs': {
      'en': 'Prince Charles #27',
      'de': 'Prinz Charles #27',
      'es': 'Príncipe Carlos #27',
      'fr': 'Prince Charles #27',
      'pt': 'Príncipe Charles #27',
    },
    'waj0jmib': {
      'en': 'Home',
      'de': 'Heim',
      'es': 'Hogar',
      'fr': 'Maison',
      'pt': 'Lar',
    },
  },
  // HowDriveDo12
  {
    '8l20vnp8': {
      'en': 'Home',
      'de': 'Heim',
      'es': 'Hogar',
      'fr': 'Maison',
      'pt': 'Lar',
    },
  },
  // Rewards13
  {
    'su7qf2zb': {
      'en': 'Rewards',
      'de': 'Belohnungen',
      'es': 'Recompensas',
      'fr': 'Récompenses',
      'pt': 'Recompensas',
    },
    'wbr3phxt': {
      'en': 'Your points',
      'de': 'Ihre Punkte',
      'es': 'Tus puntos',
      'fr': 'Vos points',
      'pt': 'Seus pontos',
    },
    'ilp1lgby': {
      'en': 'pts',
      'de': 'Punkte',
      'es': 'puntos',
      'fr': 'points',
      'pt': 'pontos',
    },
    'bh6hcwa2': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'zqt4hblc': {
      'en': 'Redeem',
      'de': 'Tilgen',
      'es': 'Canjear',
      'fr': 'Racheter',
      'pt': 'Resgatar',
    },
    '5mq8zqpu': {
      'en': 'Ways to earn',
      'de': 'Möglichkeiten zu verdienen',
      'es': 'Formas de ganar dinero',
      'fr': 'Façons de gagner',
      'pt': 'Maneiras de ganhar',
    },
    'tvbaxszw': {
      'en': 'All',
      'de': 'Alle',
      'es': 'Todo',
      'fr': 'Tous',
      'pt': 'Todos',
    },
    '8dszkbh1': {
      'en': 'Perks',
      'de': 'Vergünstigungen',
      'es': 'Beneficios',
      'fr': 'Avantages',
      'pt': 'Vantagens',
    },
    '3uex1c8l': {
      'en': 'Boosts',
      'de': 'Stiefel',
      'es': 'Botas',
      'fr': 'Bottes',
      'pt': 'Boosts',
    },
    '96bzsfhg': {
      'en': 'History',
      'de': 'Geschichte',
      'es': 'Historia',
      'fr': 'Histoire',
      'pt': 'História',
    },
    '2e574kgd': {
      'en': 'Featured perks',
      'de': 'Besondere Vorteile',
      'es': 'Beneficios destacados',
      'fr': 'Avantages en vedette',
      'pt': 'Vantagens em destaque',
    },
    '3ti2j4mr': {
      'en': 'Select',
      'de': 'Wählen',
      'es': 'Seleccionar',
      'fr': 'Sélectionner',
      'pt': 'Selecione',
    },
    '1bqtmbqv': {
      'en': 'Ways to earn',
      'de': 'Möglichkeiten zu verdienen',
      'es': 'Formas de ganar dinero',
      'fr': 'Façons de gagner',
      'pt': 'Maneiras de ganhar',
    },
    'dsmzg6rv': {
      'en': 'Invite a friend (+500 pts)',
      'de': 'Lade einen Freund ein (+500 Punkte)',
      'es': 'Invita a un amigo (+500 pts)',
      'fr': 'Inviter un ami (+500 pts)',
      'pt': 'Convide um amigo (+500 pts)',
    },
    '1273n14s': {
      'en': 'View',
      'de': 'Sicht',
      'es': 'Vista',
      'fr': 'Voir',
      'pt': 'Visualizar',
    },
    '10sy7axv': {
      'en': 'Share your cade QCKY-72',
      'de': 'Teilen Sie Ihren Cade QCKY-72',
      'es': 'Comparte tu cade QCKY-72',
      'fr': 'Partagez votre cade QCKY-72',
      'pt': 'Compartilhe seu cade QCKY-72',
    },
    'kzrg8q93': {
      'en': 'Daily chec-in (+10 pts)',
      'de': 'Tägliches Einchecken (+10 Punkte)',
      'es': 'Check-in diario (+10 pts)',
      'fr': 'Enregistrement quotidien (+10 pts)',
      'pt': 'Check-in diário (+10 pts)',
    },
    '6uw2h1uq': {
      'en': 'Select',
      'de': 'Wählen',
      'es': 'Seleccionar',
      'fr': 'Sélectionner',
      'pt': 'Selecione',
    },
    '3bbdyb63': {
      'en': 'Come back tomorrow',
      'de': 'Komm morgen wieder',
      'es': 'Vuelve mañana',
      'fr': 'Reviens demain',
      'pt': 'Volte amanhã',
    },
    'a0cnh7a8': {
      'en': 'Recent activity',
      'de': 'Letzte Aktivität',
      'es': 'Actividad reciente',
      'fr': 'Activité récente',
      'pt': 'Atividade recente',
    },
    '2z63ycqb': {
      'en': 'Home',
      'de': 'Heim',
      'es': 'Hogar',
      'fr': 'Maison',
      'pt': 'Lar',
    },
  },
  // ScheduleRider
  {
    'h2xsi528': {
      'en': 'Home',
      'de': 'Heim',
      'es': 'Hogar',
      'fr': 'Maison',
      'pt': 'Lar',
    },
  },
  // Profile15
  {
    'ty0dxium': {
      'en': 'Zone: Nassau',
      'de': 'Zone: Nassau',
      'es': 'Zona: Nassau',
      'fr': 'Zone : Nassau',
      'pt': 'Zona: Nassau',
    },
    'm7hx9uxx': {
      'en': 'P',
      'de': 'P',
      'es': 'PAG',
      'fr': 'P',
      'pt': 'P',
    },
    'j8inhljm': {
      'en': 'Payment methods',
      'de': 'Zahlungsarten',
      'es': 'Métodos de pago',
      'fr': 'Modes de paiement',
      'pt': 'Métodos de pagamento',
    },
    'fof2w31u': {
      'en': 'Card on file: Visa 4343',
      'de': 'Karteikarte: Visa 4343',
      'es': 'Tarjeta registrada: Visa 4343',
      'fr': 'Carte enregistrée : Visa 4343',
      'pt': 'Cartão em arquivo: Visa 4343',
    },
    'x43zkuef': {
      'en': 'R',
      'de': 'R',
      'es': 'R',
      'fr': 'R',
      'pt': 'R',
    },
    '5vaa9l88': {
      'en': 'Rewards',
      'de': 'Belohnungen',
      'es': 'Recompensas',
      'fr': 'Récompenses',
      'pt': 'Recompensas',
    },
    'i6q9uqth': {
      'en': 'A',
      'de': 'A',
      'es': 'A',
      'fr': 'UN',
      'pt': 'UM',
    },
    'bf8junkg': {
      'en': 'Activity',
      'de': 'Aktivität',
      'es': 'Actividad',
      'fr': 'Activité',
      'pt': 'Atividade',
    },
    'cp8sp621': {
      'en': 'Trips and receipts',
      'de': 'Fahrten und Quittungen',
      'es': 'Viajes y recibos',
      'fr': 'Voyages et reçus',
      'pt': 'Viagens e recibos',
    },
    'qhm7lt4p': {
      'en': 'P',
      'de': 'P',
      'es': 'PAG',
      'fr': 'P',
      'pt': 'P',
    },
    'toqqidie': {
      'en': 'Preferences',
      'de': 'Einstellungen',
      'es': 'Preferencias',
      'fr': 'Préférences',
      'pt': 'Preferências',
    },
    'lto0jo84': {
      'en': 'Language, accessibility, notifications',
      'de': 'Sprache, Zugänglichkeit, Benachrichtigungen',
      'es': 'Idioma, accesibilidad, notificaciones',
      'fr': 'Langue, accessibilité, notifications',
      'pt': 'Idioma, acessibilidade, notificações',
    },
    'buh7qs0p': {
      'en': 'T',
      'de': 'T',
      'es': 'T',
      'fr': 'T',
      'pt': 'T',
    },
    'fo2feead': {
      'en': 'Safety Toolkit',
      'de': 'Sicherheits-Toolkit',
      'es': 'Kit de herramientas de seguridad',
      'fr': 'Boîte à outils de sécurité',
      'pt': 'Kit de ferramentas de segurança',
    },
    '5wjcdyl2': {
      'en': 'Trusted contacts, share ETA defaults',
      'de': 'Vertrauenswürdige Kontakte, teilen Sie ETA-Standards',
      'es': 'Contactos de confianza, compartir valores predeterminados de ETA',
      'fr': 'Contacts de confiance, partage des valeurs ETA par défaut',
      'pt': 'Contatos confiáveis, compartilhe padrões de ETA',
    },
    'zd7pkc5q': {
      'en': 'S',
      'de': 'S',
      'es': 'S',
      'fr': 'S',
      'pt': 'S',
    },
    'y0k4zyj0': {
      'en': 'Support',
      'de': 'Unterstützung',
      'es': 'Apoyo',
      'fr': 'Soutien',
      'pt': 'Apoiar',
    },
    '6dgl5sxs': {
      'en': 'FAQs and contact support',
      'de': 'FAQs und Support kontaktieren',
      'es': 'Preguntas frecuentes y contacto de soporte',
      'fr': 'FAQ et support de contact',
      'pt': 'Perguntas frequentes e contato com o suporte',
    },
    '5ccwvf7m': {
      'en': 'L',
      'de': 'L',
      'es': 'L',
      'fr': 'L',
      'pt': 'eu',
    },
    'mu19yv2j': {
      'en': 'Legal',
      'de': 'Rechtliches',
      'es': 'Legal',
      'fr': 'Légal',
      'pt': 'Jurídico',
    },
    'c7123jp4': {
      'en': 'FAQs and contact support',
      'de': 'FAQs und Support kontaktieren',
      'es': 'Preguntas frecuentes y contacto de soporte',
      'fr': 'FAQ et support de contact',
      'pt': 'Perguntas frequentes e contato com o suporte',
    },
    'd61haj9w': {
      'en': 'M',
      'de': 'M',
      'es': 'METRO',
      'fr': 'M',
      'pt': 'M',
    },
    'o9mkn436': {
      'en': 'My Passes',
      'de': 'Meine Pässe',
      'es': 'Mis pases',
      'fr': 'Mes passes',
      'pt': 'Meus Passes',
    },
    'k5oxfzxg': {
      'en': 'Click here to mansge or cancel your Pass',
      'de': 'Klicken Sie hier, um Ihren Pass zu verwalten oder zu stornieren',
      'es': 'Haga clic aquí para gestionar o cancelar su Pase',
      'fr': 'Cliquez ici pour gérer ou annuler votre Pass',
      'pt': 'Clique aqui para gerenciar ou cancelar seu passe',
    },
    'ni6ifi3e': {
      'en': 'M',
      'de': 'M',
      'es': 'METRO',
      'fr': 'M',
      'pt': 'M',
    },
    'i3c4x0y3': {
      'en': 'My Passes',
      'de': 'Meine Pässe',
      'es': 'Mis pases',
      'fr': 'Mes passes',
      'pt': 'Meus Passes',
    },
    'ce9vh550': {
      'en': 'Click here to mansge or cancel your Pass',
      'de': 'Klicken Sie hier, um Ihren Pass zu verwalten oder zu stornieren',
      'es': 'Haga clic aquí para gestionar o cancelar su Pase',
      'fr': 'Cliquez ici pour gérer ou annuler votre Pass',
      'pt': 'Clique aqui para gerenciar ou cancelar seu passe',
    },
    '7ou1tpcp': {
      'en': 'Log out',
      'de': 'Ausloggen',
      'es': 'Finalizar la sesión',
      'fr': 'Se déconnecter',
      'pt': 'Sair',
    },
    'nljjirj7': {
      'en': 'Home',
      'de': 'Heim',
      'es': 'Hogar',
      'fr': 'Maison',
      'pt': 'Lar',
    },
  },
  // PaymentMothods16
  {
    'vcm0xkg1': {
      'en': 'Payment methods',
      'de': 'Zahlungsarten',
      'es': 'Métodos de pago',
      'fr': 'Modes de paiement',
      'pt': 'Métodos de pagamento',
    },
    'l3m2kc2f': {
      'en': 'Default',
      'de': 'Standard',
      'es': 'Por defecto',
      'fr': 'Défaut',
      'pt': 'Padrão',
    },
    'ieajvxxe': {
      'en': 'Add new payment method',
      'de': 'Neue Zahlungsmethode hinzufügen',
      'es': 'Agregar nuevo método de pago',
      'fr': 'Ajouter un nouveau mode de paiement',
      'pt': 'Adicionar novo método de pagamento',
    },
    'g7mhbrw9': {
      'en': 'Home',
      'de': 'Heim',
      'es': 'Hogar',
      'fr': 'Maison',
      'pt': 'Lar',
    },
  },
  // Rewards17
  {
    '36a24d9o': {
      'en': 'Rewards',
      'de': 'Belohnungen',
      'es': 'Recompensas',
      'fr': 'Récompenses',
      'pt': 'Recompensas',
    },
    'ltmftlab': {
      'en': 'Points',
      'de': 'Punkte',
      'es': 'Agujas',
      'fr': 'Points',
      'pt': 'Pontos',
    },
    'h8mcjhpe': {
      'en': 'Tier',
      'de': 'Stufe',
      'es': 'Nivel',
      'fr': 'Étage',
      'pt': 'Nível',
    },
    'qldyld0o': {
      'en': 'Airport pickuo lane',
      'de': 'Flughafen-Pickuo-Spur',
      'es': 'Carril de recogida del aeropuerto',
      'fr': 'Voie de ramassage à l\'aéroport',
      'pt': 'Faixa de embarque do aeroporto',
    },
    'gj6ttsve': {
      'en': '1 voucher',
      'de': '1 Gutschein',
      'es': '1 cupón',
      'fr': '1 bon',
      'pt': '1 voucher',
    },
    '704kgt3d': {
      'en': '\$5 off next ride',
      'de': '5 \$ Rabatt auf die nächste Fahrt',
      'es': '\$5 de descuento en el próximo viaje',
      'fr': '5 \$ de réduction sur votre prochain trajet',
      'pt': '\$ 5 de desconto na próxima viagem',
    },
    'e6h4q86o': {
      'en': 'Auto-applies',
      'de': 'Automatische Anwendung',
      'es': 'Se aplica automáticamente',
      'fr': 'S\'applique automatiquement',
      'pt': 'Aplica-se automaticamente',
    },
    'jkj1b21w': {
      'en': 'Redeem points',
      'de': 'Punkte einlösen',
      'es': 'Canjear puntos',
      'fr': 'Échanger des points',
      'pt': 'Resgatar pontos',
    },
    'm1iciazc': {
      'en': 'Home',
      'de': 'Heim',
      'es': 'Hogar',
      'fr': 'Maison',
      'pt': 'Lar',
    },
  },
  // Activity18
  {
    '17bq7v90': {
      'en': 'Activity',
      'de': 'Aktivität',
      'es': 'Actividad',
      'fr': 'Activité',
      'pt': 'Atividade',
    },
    'bg48o9jg': {
      'en': 'Upcoming',
      'de': 'Demnächst',
      'es': 'Próximamente',
      'fr': 'Prochain',
      'pt': 'Por vir',
    },
    '0pgr1i1t': {
      'en': 'Aug 9 • 7:02 PM',
      'de': '9. Aug. • 19:02 Uhr',
      'es': '9 de agosto • 19:02',
      'fr': '9 août • 19h02',
      'pt': '9 de agosto • 19h02',
    },
    'sqqusrt2': {
      'en': '\$22.10',
      'de': '22,10 €',
      'es': '\$22.10',
      'fr': '22,10 \$',
      'pt': '\$ 22,10',
    },
    'jk1da09m': {
      'en': 'Aug 8 • 1:20 PM',
      'de': '8. Aug. • 13:20 Uhr',
      'es': '8 de agosto • 13:20',
      'fr': '8 août • 13h20',
      'pt': '8 de agosto • 13h20',
    },
    'lt374c88': {
      'en': '\$9.85',
      'de': '9,85 €',
      'es': '\$9.85',
      'fr': '9,85 \$',
      'pt': '\$ 9,85',
    },
    'g0szdg95': {
      'en': 'Aug 6• 8:45 PM',
      'de': '6. August, 20:45 Uhr',
      'es': '6 de agosto • 20:45',
      'fr': '6 août • 20 h 45',
      'pt': '6 de agosto • 20h45',
    },
    '6m14pv9v': {
      'en': '\$16.00',
      'de': '16,00 €',
      'es': '\$16.00',
      'fr': '16,00 \$',
      'pt': '\$ 16,00',
    },
    'f6xc6etn': {
      'en': 'Home',
      'de': 'Heim',
      'es': 'Hogar',
      'fr': 'Maison',
      'pt': 'Lar',
    },
  },
  // Preferences19
  {
    'f1e7nb6y': {
      'en': 'Preferences',
      'de': 'Einstellungen',
      'es': 'Preferencias',
      'fr': 'Préférences',
      'pt': 'Preferências',
    },
    'znurfslv': {
      'en': 'Language',
      'de': 'Sprache',
      'es': 'Idioma',
      'fr': 'Langue',
      'pt': 'Linguagem',
    },
    'ssumpo16': {
      'en': 'Accessibility',
      'de': 'Zugänglichkeit',
      'es': 'Accesibilidad',
      'fr': 'Accessibilité',
      'pt': 'Acessibilidade',
    },
    'albrqlqn': {
      'en': 'Large text: Off  • High contrast: On',
      'de': 'Großer Text: Aus • Hoher Kontrast: Ein',
      'es': 'Texto grande: Desactivado • Contraste alto: Activado',
      'fr': 'Grand texte : désactivé • Contraste élevé : activé',
      'pt': 'Texto grande: Desligado • Alto contraste: Ligado',
    },
    'h45rl6um': {
      'en': 'Notifications',
      'de': 'Benachrichtigungen',
      'es': 'Notificaciones',
      'fr': 'Notifications',
      'pt': 'Notificações',
    },
    'hg8vhhmv': {
      'en': 'Trips< Promotions',
      'de': 'Reisen< Aktionen',
      'es': 'Viajes< Promociones',
      'fr': 'Voyages< Promotions',
      'pt': 'Viagens< Promoções',
    },
    's3kw1rrh': {
      'en': 'Home',
      'de': 'Heim',
      'es': 'Hogar',
      'fr': 'Maison',
      'pt': 'Lar',
    },
  },
  // Activity20
  {
    '65mjue8s': {
      'en': 'Activity',
      'de': 'Aktivität',
      'es': 'Actividad',
      'fr': 'Activité',
      'pt': 'Atividade',
    },
    'korhfw3u': {
      'en': 'Rides this month',
      'de': 'Fahrten diesen Monat',
      'es': 'Paseos este mes',
      'fr': 'Balades ce mois-ci',
      'pt': 'Passeios deste mês',
    },
    '5zo3l5ee': {
      'en': 'Spend this month',
      'de': 'Verbringen Sie diesen Monat',
      'es': 'Pasar este mes',
      'fr': 'Dépensez ce mois-ci',
      'pt': 'Passe este mês',
    },
    '6n062rjg': {
      'en': 'All',
      'de': 'Alle',
      'es': 'Todo',
      'fr': 'Tous',
      'pt': 'Todos',
    },
    '0vu2v8bi': {
      'en': 'Upcoming',
      'de': 'Demnächst',
      'es': 'Próximamente',
      'fr': 'Prochain',
      'pt': 'Por vir',
    },
    'sz6ef2cr': {
      'en': 'Completed',
      'de': 'Vollendet',
      'es': 'Terminado',
      'fr': 'Complété',
      'pt': 'Concluído',
    },
    '1g6e8am2': {
      'en': 'Cancelled',
      'de': 'Abgesagt',
      'es': 'Cancelado',
      'fr': 'Annulé',
      'pt': 'Cancelado',
    },
    'bzeoj1e7': {
      'en': 'Upcoming ride',
      'de': 'Nächste Fahrt',
      'es': 'Próximo viaje',
      'fr': 'Prochaine balade',
      'pt': 'Próximo passeio',
    },
    'e9ctu0o5': {
      'en': 'Edit',
      'de': 'Bearbeiten',
      'es': 'Editar',
      'fr': 'Modifier',
      'pt': 'Editar',
    },
    'mlfbk1ox': {
      'en': 'Details',
      'de': 'Details',
      'es': 'Detalles',
      'fr': 'Détails',
      'pt': 'Detalhes',
    },
    'hyvc2aw5': {
      'en': 'Recent trips',
      'de': 'Letzte Reisen',
      'es': 'Viajes recientes',
      'fr': 'Voyages récents',
      'pt': 'Viagens recentes',
    },
    'yli9ckqz': {
      'en': 'Home',
      'de': 'Heim',
      'es': 'Hogar',
      'fr': 'Maison',
      'pt': 'Lar',
    },
  },
  // SafetyToolkit21
  {
    'jngjtzbz': {
      'en': 'Safety Toolkit',
      'de': 'Sicherheits-Toolkit',
      'es': 'Kit de herramientas de seguridad',
      'fr': 'Boîte à outils de sécurité',
      'pt': 'Kit de ferramentas de segurança',
    },
    's4uicmrm': {
      'en': 'Trusted contacts',
      'de': 'Vertrauenswürdige Kontakte',
      'es': 'Contactos de confianza',
      'fr': 'Contacts de confiance',
      'pt': 'Contatos confiáveis',
    },
    'ql2n2e35': {
      'en': 'People who can get your live ETA and trip alerts.',
      'de':
          'Personen, die Ihre voraussichtliche Ankunftszeit und Reisebenachrichtigungen live erhalten können.',
      'es':
          'Personas que pueden obtener su tiempo estimado de llegada (ETA) en vivo y alertas de viaje.',
      'fr':
          'Les personnes qui peuvent obtenir votre ETA en direct et vos alertes de voyage.',
      'pt':
          'Pessoas que podem obter seu ETA em tempo real e alertas de viagem.',
    },
    'gvv0vhl6': {
      'en': 'Add contact',
      'de': 'Kontakt hinzufügen',
      'es': 'Añadir contacto',
      'fr': 'Ajouter un contact',
      'pt': 'Adicionar contato',
    },
    'lcpevj41': {
      'en': 'Share ETA defaults',
      'de': 'ETA-Standardwerte teilen',
      'es': 'Compartir valores predeterminados de ETA',
      'fr': 'Partager les valeurs par défaut de l\'ETA',
      'pt': 'Compartilhar padrões de ETA',
    },
    'ln84fa5q': {
      'en': 'Automaticaly share on every trip.',
      'de': 'Bei jeder Fahrt automatisch teilen.',
      'es': 'Compartir automáticamente en cada viaje.',
      'fr': 'Partager automatiquement à chaque voyage.',
      'pt': 'Compartilhe automaticamente em cada viagem.',
    },
    'xshsh38w': {
      'en': 'Share with trusted contacts',
      'de': 'Mit vertrauenswürdigen Kontakten teilen',
      'es': 'Compartir con contactos de confianza',
      'fr': 'Partager avec des contacts de confiance',
      'pt': 'Compartilhe com contatos confiáveis',
    },
    'e7s5y36r': {
      'en': 'Share with emergency contact',
      'de': 'Mit Notfallkontakt teilen',
      'es': 'Compartir con contacto de emergencia',
      'fr': 'Partager avec un contact d\'urgence',
      'pt': 'Compartilhe com contato de emergência',
    },
    '9irhu2te': {
      'en': 'Emergency information',
      'de': 'Notfallinformationen',
      'es': 'Información de emergencia',
      'fr': 'Informations d\'urgence',
      'pt': 'Informações de emergência',
    },
    '72twndx6': {
      'en': 'Only used in case of an emergency',
      'de': 'Wird nur im Notfall verwendet',
      'es': 'Sólo se utiliza en caso de emergencia.',
      'fr': 'Utilisé uniquement en cas d\'urgence',
      'pt': 'Usado somente em caso de emergência',
    },
    'd1w74ruw': {
      'en': 'Save',
      'de': 'Speichern',
      'es': 'Ahorrar',
      'fr': 'Sauvegarder',
      'pt': 'Salvar',
    },
    'nb9rc4s8': {
      'en': 'Emergency contact name',
      'de': 'Name des Notfallkontakts',
      'es': 'Nombre del contacto de emergencia',
      'fr': 'Nom du contact d\'urgence',
      'pt': 'Nome do contato de emergência',
    },
    'o4lsplzm': {
      'en': 'Phone number',
      'de': 'Telefonnummer',
      'es': 'Número de teléfono',
      'fr': 'Numéro de téléphone',
      'pt': 'Número de telefone',
    },
    'k5puq8fp': {
      'en': 'Privacy information',
      'de': 'Datenschutzinformationen',
      'es': 'Información de privacidad',
      'fr': 'Informations sur la confidentialité',
      'pt': 'Informações de privacidade',
    },
    '8b82z4zp': {
      'en': 'Manage location and data settings',
      'de': 'Standort- und Dateneinstellungen verwalten',
      'es': 'Administrar la configuración de ubicación y datos',
      'fr': 'Gérer les paramètres de localisation et de données',
      'pt': 'Gerenciar configurações de localização e dados',
    },
    'lkc1tsvh': {
      'en': 'L',
      'de': 'L',
      'es': 'L',
      'fr': 'L',
      'pt': 'eu',
    },
    'ikjz5p87': {
      'en': 'Location services',
      'de': 'Standortdienste',
      'es': 'Servicios de localización',
      'fr': 'Services de localisation',
      'pt': 'Serviços de localização',
    },
    '0qfv00ai': {
      'en': 'Allow while using the app',
      'de': 'Während der Verwendung der App zulassen',
      'es': 'Permitir mientras se usa la aplicación',
      'fr': 'Autoriser lors de l\'utilisation de l\'application',
      'pt': 'Permitir durante o uso do aplicativo',
    },
    'rbtosb0o': {
      'en': 'D',
      'de': 'D',
      'es': 'D',
      'fr': 'D',
      'pt': 'D',
    },
    'bd79p8gc': {
      'en': 'Data sharing',
      'de': 'Datenweitergabe',
      'es': 'Intercambio de datos',
      'fr': 'Partage de données',
      'pt': 'Compartilhamento de dados',
    },
    'txtf2uze': {
      'en': 'Home',
      'de': 'Heim',
      'es': 'Hogar',
      'fr': 'Maison',
      'pt': 'Lar',
    },
  },
  // Support22
  {
    'kqm6j0hk': {
      'en': 'Support',
      'de': 'Unterstützung',
      'es': 'Apoyo',
      'fr': 'Soutien',
      'pt': 'Apoiar',
    },
    '2vzif50n': {
      'en': 'FAQs',
      'de': 'FAQs',
      'es': 'Preguntas frecuentes',
      'fr': 'FAQ',
      'pt': 'Perguntas frequentes',
    },
    '1uhzt6s2': {
      'en': 'Payments, trips, safety',
      'de': 'Zahlungen, Reisen, Sicherheit',
      'es': 'Pagos, viajes, seguridad',
      'fr': 'Paiements, voyages, sécurité',
      'pt': 'Pagamentos, viagens, segurança',
    },
    '9e88djne': {
      'en': 'Contact support',
      'de': 'Support kontaktieren',
      'es': 'Contactar con soporte técnico',
      'fr': 'Contacter le support',
      'pt': 'Entre em contato com o suporte',
    },
    '8ogawjnk': {
      'en': 'Chat or email',
      'de': 'Chat oder E-Mail',
      'es': 'Chat o correo electrónico',
      'fr': 'Chat ou email',
      'pt': 'Bate-papo ou e-mail',
    },
    'jw1umjwk': {
      'en': 'Report a problem',
      'de': 'Problem melden',
      'es': 'Informar un problema',
      'fr': 'Signaler un problème',
      'pt': 'Reportar um problema',
    },
    'kakc9sbx': {
      'en': 'Trip or app issues',
      'de': 'Reise- oder App-Probleme',
      'es': 'Problemas con el viaje o la aplicación',
      'fr': 'Problèmes de voyage ou d\'application',
      'pt': 'Problemas de viagem ou aplicativo',
    },
    'blghjnr6': {
      'en': 'Receipts',
      'de': 'Quittungen',
      'es': 'Ingresos',
      'fr': 'Recettes',
      'pt': 'Recibos',
    },
    'hjcz7ec1': {
      'en': 'Download monthly receipts',
      'de': 'Monatliche Belege herunterladen',
      'es': 'Descargar recibos mensuales',
      'fr': 'Télécharger les reçus mensuels',
      'pt': 'Baixar recibos mensais',
    },
    'fl6cnokw': {
      'en': 'Home',
      'de': 'Heim',
      'es': 'Hogar',
      'fr': 'Maison',
      'pt': 'Lar',
    },
  },
  // Legal23
  {
    'hhw0z19p': {
      'en': 'Legal',
      'de': 'Rechtliches',
      'es': 'Legal',
      'fr': 'Légal',
      'pt': 'Jurídico',
    },
    'jsidnl6t': {
      'en': 'Terms of Service',
      'de': 'Servicebedingungen',
      'es': 'Condiciones de servicio',
      'fr': 'Conditions d\'utilisation',
      'pt': 'Termos de Serviço',
    },
    'pwqhmift': {
      'en': 'Last update Aug 2025',
      'de': 'Letzte Aktualisierung Aug. 2025',
      'es': 'Última actualización: agosto de 2025',
      'fr': 'Dernière mise à jour août 2025',
      'pt': 'Última atualização em agosto de 2025',
    },
    'vkgu3h3p': {
      'en': 'Privacy Policy',
      'de': 'Datenschutzrichtlinie',
      'es': 'política de privacidad',
      'fr': 'politique de confidentialité',
      'pt': 'política de Privacidade',
    },
    'ies7u0dn': {
      'en': 'Data, permissions, retention',
      'de': 'Daten, Berechtigungen, Aufbewahrung',
      'es': 'Datos, permisos, retención',
      'fr': 'Données, autorisations, conservation',
      'pt': 'Dados, permissões, retenção',
    },
    'xtmleio1': {
      'en': 'Licenses',
      'de': 'Lizenzen',
      'es': 'Licencias',
      'fr': 'Licences',
      'pt': 'Licenças',
    },
    'qpuvteeq': {
      'en': 'Open-souce attributions',
      'de': 'Open-Source-Zuschreibungen',
      'es': 'Atribuciones de código abierto',
      'fr': 'Attributions open source',
      'pt': 'Atribuições de código aberto',
    },
    'kj7lg0hh': {
      'en': 'Home',
      'de': 'Heim',
      'es': 'Hogar',
      'fr': 'Maison',
      'pt': 'Lar',
    },
  },
  // MyPass24
  {
    'uib448s6': {
      'en': 'My Pass',
      'de': 'Mein Pass',
      'es': 'Mi pase',
      'fr': 'Mon Pass',
      'pt': 'Meu Passe',
    },
    'wxxitr4a': {
      'en': 'Current pass',
      'de': 'Aktueller Pass',
      'es': 'Pase actual',
      'fr': 'Passe actuelle',
      'pt': 'Passe atual',
    },
    'pzp7olg7': {
      'en': 'Renews in 4 days',
      'de': 'Erneuert sich in 4 Tagen',
      'es': 'Se renueva en 4 días',
      'fr': 'Renouvellement dans 4 jours',
      'pt': 'Renova em 4 dias',
    },
    'fowq72un': {
      'en': 'Week Pass',
      'de': 'Wochenkarte',
      'es': 'Pase semanal',
      'fr': 'Passe hebdomadaire',
      'pt': 'Passe semanal',
    },
    '72o093g6': {
      'en': '\$8',
      'de': '8 \$',
      'es': '\$8',
      'fr': '8 \$',
      'pt': '\$ 8',
    },
    'f5zikyh4': {
      'en': 'Upgarde',
      'de': 'Upgrade',
      'es': 'Actualización',
      'fr': 'Mise à niveau',
      'pt': 'Atualizar',
    },
    'w7o0iil6': {
      'en': 'Cancel',
      'de': 'Stornieren',
      'es': 'Cancelar',
      'fr': 'Annuler',
      'pt': 'Cancelar',
    },
    '4uvo83zt': {
      'en': 'Recent charges',
      'de': 'Aktuelle Gebühren',
      'es': 'Cargos recientes',
      'fr': 'Frais récents',
      'pt': 'Cobranças recentes',
    },
    '3hi9mb26': {
      'en': 'Week Pass',
      'de': 'Wochenkarte',
      'es': 'Pase semanal',
      'fr': 'Passe hebdomadaire',
      'pt': 'Passe semanal',
    },
    'ozzk62hx': {
      'en': 'Aug 14',
      'de': '14. August',
      'es': '14 de agosto',
      'fr': '14 août',
      'pt': '14 de agosto',
    },
    'nr5yyifm': {
      'en': '\$8',
      'de': '8 \$',
      'es': '\$8',
      'fr': '8 \$',
      'pt': '\$ 8',
    },
    'z992rxdy': {
      'en': 'Ride fuel fee',
      'de': 'Fahrtkraftstoffgebühr',
      'es': 'Tarifa de combustible para viajes',
      'fr': 'Frais de carburant pour les trajets',
      'pt': 'Taxa de combustível da viagem',
    },
    '9bk1aovq': {
      'en': 'Aug 13',
      'de': '13. August',
      'es': '13 de agosto',
      'fr': '13 août',
      'pt': '13 de agosto',
    },
    '0doc2pj2': {
      'en': '\$3',
      'de': '3 \$',
      'es': '\$3',
      'fr': '3 \$',
      'pt': '\$ 3',
    },
    '66bb7n84': {
      'en': 'Ride fuel fee',
      'de': 'Fahrtkraftstoffgebühr',
      'es': 'Tarifa de combustible para viajes',
      'fr': 'Frais de carburant pour les trajets',
      'pt': 'Taxa de combustível da viagem',
    },
    '2ucud5zz': {
      'en': 'Aug 12',
      'de': '12. August',
      'es': '12 de agosto',
      'fr': '12 août',
      'pt': '12 de agosto',
    },
    'r632cxuw': {
      'en': '\$3',
      'de': '3 \$',
      'es': '\$3',
      'fr': '3 \$',
      'pt': '\$ 3',
    },
    'cgsiqzdh': {
      'en': 'Pass details',
      'de': 'Passdetails',
      'es': 'Detalles del pase',
      'fr': 'Détails du pass',
      'pt': 'Detalhes do passe',
    },
    'sw46jeqd': {
      'en': 'Unlimited rides with an active pass.',
      'de': 'Unbegrenzte Fahrten mit einem Aktivpass.',
      'es': 'Viajes ilimitados con un pase activo.',
      'fr': 'Trajets illimités avec un pass actif.',
      'pt': 'Viagens ilimitadas com um passe ativo.',
    },
    '5yavjdgg': {
      'en': 'Fuel fee: \$3 per ride.',
      'de': 'Kraftstoffgebühr: 3 \$ pro Fahrt.',
      'es': 'Tarifa de combustible: \$3 por viaje.',
      'fr': 'Frais de carburant : 3 \$ par trajet.',
      'pt': 'Taxa de combustível: US\$ 3 por viagem.',
    },
    'pzzzzj20': {
      'en': 'Auto-renew optional on Week/Month.',
      'de': 'Automatische Verlängerung optional wöchentlich/monatlich.',
      'es': 'Renovación automática opcional por semana/mes.',
      'fr': 'Renouvellement automatique facultatif sur semaine/mois.',
      'pt': 'Renovação automática opcional na semana/mês.',
    },
    'wo8ckfat': {
      'en': 'No surge princing: limited to standand vehicles.',
      'de': 'Keine Preiserhöhung: beschränkt auf Standardfahrzeuge.',
      'es': 'Sin aumento de precios: limitado a vehículos estándar.',
      'fr': 'Pas de tarification majorée : limité aux véhicules de série.',
      'pt': 'Sem aumento de preço: limitado a veículos comuns.',
    },
    '9to0c6rc': {
      'en': 'Done',
      'de': 'Erledigt',
      'es': 'Hecho',
      'fr': 'Fait',
      'pt': 'Feito',
    },
    'm2e7mh34': {
      'en': 'Home',
      'de': 'Heim',
      'es': 'Hogar',
      'fr': 'Maison',
      'pt': 'Lar',
    },
  },
  // CreateProfile2Copy
  {
    'ax91qqgd': {
      'en': 'Profile',
      'de': 'Profil',
      'es': 'Perfil',
      'fr': 'Profil',
      'pt': 'Perfil',
    },
    'cqlk16nf': {
      'en': ' Insert a Photo of you here',
      'de': 'Fügen Sie hier ein Foto von Ihnen ein',
      'es': 'Inserta una foto tuya aquí',
      'fr': 'Insérez une photo de vous ici',
      'pt': 'Insira uma foto sua aqui',
    },
    'km88iw07': {
      'en': ' Type your name here',
      'de': 'Geben Sie hier Ihren Namen ein',
      'es': 'Escribe tu nombre aquí',
      'fr': 'Tapez votre nom ici',
      'pt': 'Digite seu nome aqui',
    },
    'pxniyo6o': {
      'en': 'Give it your best shot at spelling it right',
      'de': 'Geben Sie Ihr Bestes, um es richtig zu buchstabieren',
      'es': 'Haz tu mejor esfuerzo para escribirlo correctamente.',
      'fr': 'Faites de votre mieux pour l\'épeler correctement',
      'pt': 'Dê o seu melhor para soletrar corretamente',
    },
    'rnriatbp': {
      'en': ' Type your surname here',
      'de': 'Geben Sie hier Ihren Nachnamen ein',
      'es': 'Escribe tu apellido aquí',
      'fr': 'Tapez votre nom de famille ici',
      'pt': 'Digite seu sobrenome aqui',
    },
    'r4ck9a3f': {
      'en': 'Just a Formality',
      'de': 'Nur eine Formalität',
      'es': 'Sólo una formalidad',
      'fr': 'Juste une formalité',
      'pt': 'Apenas uma formalidade',
    },
    'gdxpiltb': {
      'en': ' Type your email here',
      'de': 'Geben Sie hier Ihre E-Mail-Adresse ein',
      'es': 'Escribe tu correo electrónico aquí',
      'fr': 'Tapez votre email ici',
      'pt': 'Digite seu e-mail aqui',
    },
    'ngpztzel': {
      'en': 'Your best email so we can verify it is you',
      'de':
          'Ihre beste E-Mail-Adresse, damit wir Ihre Identität bestätigen können',
      'es':
          'Tu mejor correo electrónico para que podamos verificar que eres tú',
      'fr':
          'Votre meilleur email afin que nous puissions vérifier qu\'il s\'agit bien de vous',
      'pt': 'Seu melhor e-mail para que possamos verificar se é você',
    },
    '3ty7nvod': {
      'en': ' Insert a password\n',
      'de': 'Geben Sie ein Passwort ein',
      'es': 'Insertar una contraseña',
      'fr': 'Insérer un mot de passe',
      'pt': 'Insira uma senha',
    },
    'eu23ys5x': {
      'en':
          'Don´t worry if you forget, we´ll be here to remind you  when \nyou do.',
      'de':
          'Keine Sorge, falls Sie es vergessen, wir erinnern Sie gerne daran.',
      'es':
          'No te preocupes si lo olvidas, estaremos aquí para recordártelo cuando lo olvides.',
      'fr':
          'Si vous oubliez, ne vous inquiétez pas, nous serons là pour vous le rappeler.',
      'pt':
          'Não se preocupe se você esquecer, estaremos aqui para lembrá-lo quando isso acontecer.',
    },
    '30wuyuwo': {
      'en': 'Upload a Photo of your ID',
      'de': 'Laden Sie ein Foto Ihres Ausweises hoch',
      'es': 'Sube una foto de tu identificación',
      'fr': 'Téléchargez une photo de votre pièce d\'identité',
      'pt': 'Carregue uma foto do seu documento de identidade',
    },
    '0o76z2zr': {
      'en': 'Bahaman Passport, Driver\'s license or Resident Card.',
      'de': 'Bahamaischer Reisepass, Führerschein oder Aufenthaltskarte.',
      'es': 'Pasaporte bahameño, licencia de conducir o tarjeta de residente.',
      'fr': 'Passeport, permis de conduire ou carte de résident des Bahamas.',
      'pt':
          'Passaporte das Bahamas, carteira de motorista ou cartão de residente.',
    },
    'chuireog': {
      'en': ' Select Your Nassau Zone',
      'de': 'Wählen Sie Ihre Nassau-Zone',
      'es': 'Seleccione su zona de Nassau',
      'fr': 'Sélectionnez votre zone de Nassau',
      'pt': 'Selecione sua zona de Nassau',
    },
    'akax8nd1': {
      'en': 'Search...',
      'de': 'Suchen...',
      'es': 'Buscar...',
      'fr': 'Recherche...',
      'pt': 'Procurar...',
    },
    'b19dh4ub': {
      'en': 'Option 1',
      'de': 'Option 1',
      'es': 'Opción 1',
      'fr': 'Option 1',
      'pt': 'Opção 1',
    },
    'df8mdxzu': {
      'en': 'Option 2',
      'de': 'Option 2',
      'es': 'Opción 2',
      'fr': 'Option 2',
      'pt': 'Opção 2',
    },
    'e4zyn0o5': {
      'en': 'Option 3',
      'de': 'Option 3',
      'es': 'Opción 3',
      'fr': 'Option 3',
      'pt': 'Opção 3',
    },
    'tidzlbeg': {
      'en': 'East, Middle or West',
      'de': 'Osten, Mitte oder Westen',
      'es': 'Este, Medio u Oeste',
      'fr': 'Est, Moyen ou Ouest',
      'pt': 'Leste, Centro ou Oeste',
    },
    'adtc7pns': {
      'en': 'Next',
      'de': 'Nächste',
      'es': 'Próximo',
      'fr': 'Suivant',
      'pt': 'Próximo',
    },
    't5e4cit1': {
      'en': 'Home',
      'de': 'Heim',
      'es': 'Hogar',
      'fr': 'Maison',
      'pt': 'Lar',
    },
  },
  // viewDetalhes
  {
    '4yu7sj41': {
      'en': 'Ride Details',
      'de': 'Fahrtdetails',
      'es': 'Detalles del viaje',
      'fr': 'Détails du trajet',
      'pt': 'Detalhes do passeio',
    },
    'iz2j389z': {
      'en': 'Hello World',
      'de': 'Hallo Welt',
      'es': 'Hola Mundo',
      'fr': 'Bonjour le monde',
      'pt': 'Olá Mundo',
    },
    'jdpmld2g': {
      'en': 'Hello World',
      'de': 'Hallo Welt',
      'es': 'Hola Mundo',
      'fr': 'Bonjour le monde',
      'pt': 'Olá Mundo',
    },
    'ebfq3cwb': {
      'en': '3 Passengers',
      'de': '3 Passagiere',
      'es': '3 pasajeros',
      'fr': '3 passagers',
      'pt': '3 passageiros',
    },
    '8sawn9sw': {
      'en': 'Waiting Driver',
      'de': 'Wartender Fahrer',
      'es': 'Conductor en espera',
      'fr': 'Conducteur en attente',
      'pt': 'Motorista esperando',
    },
    'wbiofvcr': {
      'en': 'Ride ',
      'de': 'Fahrt',
      'es': 'Conducir',
      'fr': 'Monter',
      'pt': 'Andar de',
    },
    'uwhlgefd': {
      'en': '3 min',
      'de': '3 Minuten',
      'es': '3 minutos',
      'fr': '3 minutes',
      'pt': '3 minutos',
    },
    'pgnwl373': {
      'en': 'XL',
      'de': 'XL',
      'es': 'SG',
      'fr': 'XL',
      'pt': 'GG',
    },
    'j4xqnnjt': {
      'en': '6 min',
      'de': '6 Minuten',
      'es': '6 minutos',
      'fr': '6 minutes',
      'pt': '6 minutos',
    },
    'mjc14hof': {
      'en': 'Luxury',
      'de': 'Luxus',
      'es': 'Lujo',
      'fr': 'Luxe',
      'pt': 'Luxo',
    },
    '5w3pklo1': {
      'en': '10 min',
      'de': '10 Minuten',
      'es': '10 minutos',
      'fr': '10 minutes',
      'pt': '10 minutos',
    },
    'lr3r69z2': {
      'en': 'Home',
      'de': 'Heim',
      'es': 'Hogar',
      'fr': 'Maison',
      'pt': 'Lar',
    },
  },
  // Support22Copy
  {
    'ku4dleug': {
      'en': 'Support',
      'de': 'Unterstützung',
      'es': 'Apoyo',
      'fr': 'Soutien',
      'pt': 'Apoiar',
    },
    'korpc4sl': {
      'en': 'FAQs',
      'de': 'FAQs',
      'es': 'Preguntas frecuentes',
      'fr': 'FAQ',
      'pt': 'Perguntas frequentes',
    },
    'ftyo57i6': {
      'en': 'Payments, trips, safety',
      'de': 'Zahlungen, Reisen, Sicherheit',
      'es': 'Pagos, viajes, seguridad',
      'fr': 'Paiements, voyages, sécurité',
      'pt': 'Pagamentos, viagens, segurança',
    },
    'k914s6gs': {
      'en': 'Contact support',
      'de': 'Support kontaktieren',
      'es': 'Contactar con soporte técnico',
      'fr': 'Contacter le support',
      'pt': 'Entre em contato com o suporte',
    },
    'c32lyra5': {
      'en': 'Chat or email',
      'de': 'Chat oder E-Mail',
      'es': 'Chat o correo electrónico',
      'fr': 'Chat ou email',
      'pt': 'Bate-papo ou e-mail',
    },
    'uqzjxeor': {
      'en': 'Report a problem',
      'de': 'Problem melden',
      'es': 'Informar un problema',
      'fr': 'Signaler un problème',
      'pt': 'Reportar um problema',
    },
    'iydue966': {
      'en': 'Trip or app issues',
      'de': 'Reise- oder App-Probleme',
      'es': 'Problemas con el viaje o la aplicación',
      'fr': 'Problèmes de voyage ou d\'application',
      'pt': 'Problemas de viagem ou aplicativo',
    },
    'sm0gqgui': {
      'en': 'Receipts',
      'de': 'Quittungen',
      'es': 'Ingresos',
      'fr': 'Recettes',
      'pt': 'Recibos',
    },
    'pzmnf12t': {
      'en': 'Download monthly receipts',
      'de': 'Monatliche Belege herunterladen',
      'es': 'Descargar recibos mensuales',
      'fr': 'Télécharger les reçus mensuels',
      'pt': 'Baixar recibos mensais',
    },
    '64nwsvr7': {
      'en': 'Home',
      'de': 'Heim',
      'es': 'Hogar',
      'fr': 'Maison',
      'pt': 'Lar',
    },
  },
  // Notification27
  {
    '3gr64o6p': {
      'en': 'Notification',
      'de': 'Benachrichtigung',
      'es': 'Notificación',
      'fr': 'Notification',
      'pt': 'Notificação',
    },
    'tt0vfi6x': {
      'en': 'Viagem concluída',
      'de': 'Viagem concluída',
      'es': 'Viagem concluída',
      'fr': 'Voyage conclu',
      'pt': 'Viagem concluída',
    },
    '3bi5zmya': {
      'en':
          'Sua viagem para Shopping Iguatemi foi concluída com sucesso. Obrigado por usar o Ride!',
      'de':
          'Ihre Reise nach Iguatemi wurde mit Erfolg abgeschlossen. Obrigado por usar o Ride!',
      'es':
          'Su viaje a Shopping Iguatemi fue concluido con éxito. ¡Obrigado por usar o Ride!',
      'fr':
          'Votre voyage pour Shopping Iguatemi a été conclu avec succès. Obligé d\'utiliser Ride !',
      'pt':
          'Sua viagem ao Shopping Iguatemi foi concluída com sucesso. Obrigado por usar o Ride!',
    },
    'j30u5604': {
      'en': 'há 2 minutos',
      'de': 'há 2 minuteos',
      'es': 'há 2 minutos',
      'fr': 'il y a 2 minutes',
      'pt': 'há 2 minutos',
    },
  },
  // help
  {
    'po3zlfdx': {
      'en': 'How can we help you?',
      'de': 'Wie können wir Ihnen helfen?',
      'es': '¿Cómo podemos ayudarle?',
      'fr': 'Comment pouvons-nous vous aider?',
      'pt': 'Como podemos ajudar você?',
    },
    'gntn79i0': {
      'en': 'Search for help topics...',
      'de': 'Nach Hilfethemen suchen ...',
      'es': 'Buscar temas de ayuda...',
      'fr': 'Rechercher des rubriques d\'aide...',
      'pt': 'Pesquisar tópicos de ajuda...',
    },
    'cbka3gzv': {
      'en': 'Popular Topics',
      'de': 'Beliebte Themen',
      'es': 'Temas populares',
      'fr': 'Sujets populaires',
      'pt': 'Tópicos populares',
    },
    'xpkno286': {
      'en': 'Account & Profile',
      'de': 'Konto und Profil',
      'es': 'Cuenta y perfil',
      'fr': 'Compte et profil',
      'pt': 'Conta e Perfil',
    },
    'aavb8zen': {
      'en': 'Manage your account settings and profile information',
      'de': 'Verwalten Sie Ihre Kontoeinstellungen und Profilinformationen',
      'es':
          'Administrar la configuración de su cuenta y la información de su perfil',
      'fr':
          'Gérez les paramètres de votre compte et les informations de votre profil',
      'pt': 'Gerencie as configurações da sua conta e informações do perfil',
    },
    'ruoxatsv': {
      'en': 'Billing & Payments',
      'de': 'Abrechnung und Zahlungen',
      'es': 'Facturación y pagos',
      'fr': 'Facturation et paiements',
      'pt': 'Faturamento e Pagamentos',
    },
    'ovp4hj0v': {
      'en': 'Questions about subscriptions, payments, and billing',
      'de': 'Fragen zu Abonnements, Zahlungen und Abrechnung',
      'es': 'Preguntas sobre suscripciones, pagos y facturación',
      'fr': 'Questions sur les abonnements, les paiements et la facturation',
      'pt': 'Perguntas sobre assinaturas, pagamentos e cobranças',
    },
    'vswtoyoz': {
      'en': 'Privacy & Security',
      'de': 'Privatsphäre & Sicherheit',
      'es': 'Privacidad y seguridad',
      'fr': 'Confidentialité et sécurité',
      'pt': 'Privacidade e Segurança',
    },
    '1kt72qns': {
      'en': 'Learn about data protection and security features',
      'de': 'Informieren Sie sich über Datenschutz und Sicherheitsfunktionen',
      'es':
          'Obtenga más información sobre las funciones de seguridad y protección de datos',
      'fr':
          'En savoir plus sur la protection des données et les fonctionnalités de sécurité',
      'pt': 'Saiba mais sobre proteção de dados e recursos de segurança',
    },
    'ozzpa0c1': {
      'en': 'Technical Issues',
      'de': 'Technische Probleme',
      'es': 'Problemas técnicos',
      'fr': 'Problèmes techniques',
      'pt': 'Problemas técnicos',
    },
    'p0tfu4xb': {
      'en': 'Troubleshoot app problems and technical difficulties',
      'de': 'Beheben Sie App-Probleme und technische Schwierigkeiten',
      'es': 'Solucionar problemas de aplicaciones y dificultades técnicas',
      'fr':
          'Résoudre les problèmes d\'application et les difficultés techniques',
      'pt': 'Solucionar problemas de aplicativos e dificuldades técnicas',
    },
    'dc0zkaz4': {
      'en': 'Need More Help?',
      'de': 'Sie benötigen weitere Hilfe?',
      'es': '¿Necesitas más ayuda?',
      'fr': 'Besoin d\'aide supplémentaire?',
      'pt': 'Precisa de mais ajuda?',
    },
    '1og1lf1v': {
      'en': 'Live Chat Support',
      'de': 'Live-Chat-Support',
      'es': 'Soporte de chat en vivo',
      'fr': 'Assistance par chat en direct',
      'pt': 'Suporte por chat ao vivo',
    },
    'vsqhlpdx': {
      'en': 'Chat with our support team in real-time',
      'de': 'Chatten Sie in Echtzeit mit unserem Support-Team',
      'es': 'Chatea con nuestro equipo de soporte en tiempo real',
      'fr': 'Discutez avec notre équipe d\'assistance en temps réel',
      'pt': 'Converse com nossa equipe de suporte em tempo real',
    },
    '5b2zeubh': {
      'en': 'Start Chat',
      'de': 'Chat starten',
      'es': 'Iniciar chat',
      'fr': 'Démarrer le chat',
      'pt': 'Iniciar bate-papo',
    },
    'bp8298bg': {
      'en': 'Email Support',
      'de': 'E-Mail-Support',
      'es': 'Soporte por correo electrónico',
      'fr': 'Assistance par e-mail',
      'pt': 'Suporte por e-mail',
    },
    'z8320h95': {
      'en': 'Send us a detailed message about your issue',
      'de': 'Senden Sie uns eine detaillierte Nachricht zu Ihrem Problem',
      'es': 'Envíenos un mensaje detallado sobre su problema.',
      'fr': 'Envoyez-nous un message détaillé sur votre problème',
      'pt': 'Envie-nos uma mensagem detalhada sobre o seu problema',
    },
    'tk38d1ux': {
      'en': 'Send Email',
      'de': 'E-Mail senden',
      'es': 'Enviar correo electrónico',
      'fr': 'Envoyer un e-mail',
      'pt': 'Enviar e-mail',
    },
    'l1thmm98': {
      'en': 'Support Hours',
      'de': 'Supportzeiten',
      'es': 'Horario de soporte',
      'fr': 'Heures d\'assistance',
      'pt': 'Horário de atendimento',
    },
    'ehqwdiey': {
      'en':
          'Monday - Friday: 9:00 AM - 6:00 PM EST\nWeekends: 10:00 AM - 4:00 PM EST',
      'de':
          'Montag–Freitag: 9:00–18:00 Uhr EST\nWochenenden: 10:00–16:00 Uhr EST',
      'es':
          'Lunes a viernes: 9:00 a. m. - 6:00 p. m. EST\nFines de semana: 10:00 a. m. - 4:00 p. m. EST',
      'fr':
          'Lundi - Vendredi : 9 h 00 - 18 h 00 HNE\nWeek-ends : 10 h 00 - 16 h 00 HNE',
      'pt':
          'Segunda a sexta: 9h às 18h (horário do leste dos EUA)\nFins de semana: 10h às 16h (horário do leste dos EUA)',
    },
    'yc1m7cp8': {
      'en': 'Help & Support',
      'de': 'Hilfe & Support',
      'es': 'Ayuda y soporte',
      'fr': 'Aide et support',
      'pt': 'Ajuda e Suporte',
    },
  },
  // CustomerSupport26
  {
    'lv1xvs0f': {
      'en': 'Customer Support',
      'de': 'Kundenservice',
      'es': 'Atención al cliente',
      'fr': 'Assistance clientèle',
      'pt': 'Suporte ao cliente',
    },
    'wrj9vpsd': {
      'en': 'Our support',
      'de': 'Unsere Unterstützung',
      'es': 'Nuestro apoyo',
      'fr': 'Notre soutien',
      'pt': 'Nosso suporte',
    },
    'mmy0on8n': {
      'en': 'Our team is ready to help you with any questions or problems.',
      'de':
          'Bei Fragen und Problemen steht Ihnen unser Team gerne zur Verfügung.',
      'es':
          'Nuestro equipo está listo para ayudarle con cualquier pregunta o problema.',
      'fr':
          'Notre équipe est prête à vous aider pour toutes questions ou problèmes.',
      'pt':
          'Nossa equipe está pronta para ajudar você com qualquer dúvida ou problema.',
    },
    '195hd8or': {
      'en': 'Contact Forms',
      'de': 'Kontaktformulare',
      'es': 'Formularios de contacto',
      'fr': 'Formulaires de contact',
      'pt': 'Formulários de contato',
    },
    'nr86rssb': {
      'en': 'Email',
      'de': 'E-Mail',
      'es': 'Correo electrónico',
      'fr': 'E-mail',
      'pt': 'E-mail',
    },
    '9lwt7ou3': {
      'en': 'Info@quickyy.life',
      'de': 'Info@quickyy.life',
      'es': 'Información@quickyy.life',
      'fr': 'Info@quickyy.life',
      'pt': 'Info@quickyy.life',
    },
    'l2cxuurb': {
      'en': 'Response within 24 hours',
      'de': 'Antwort innerhalb von 24 Stunden',
      'es': 'Respuesta en 24 horas',
      'fr': 'Réponse dans les 24 heures',
      'pt': 'Resposta em 24 horas',
    },
    '7cy172hi': {
      'en': 'Telefone',
      'de': 'Telefone',
      'es': 'Teléfono',
      'fr': 'Téléphone',
      'pt': 'Telefone',
    },
    'cyc9v8gc': {
      'en': '(305) 850-5042',
      'de': '(305) 850-5042',
      'es': '(305) 850-5042',
      'fr': '(305) 850-5042',
      'pt': '(305) 850-5042',
    },
    'qz5zqnhf': {
      'en': 'Mon-Fri: 9am to 6pm',
      'de': 'Mo-Fr: 9 bis 18 Uhr',
      'es': 'Lunes a viernes: de 9 a 18 horas',
      'fr': 'Lun-Ven : 9h à 18h',
      'pt': 'Seg-Sex: 9h às 18h',
    },
    '8c6640j3': {
      'en': 'Chat Online',
      'de': 'Online-Chat',
      'es': 'Chat en línea',
      'fr': 'Chat en ligne',
      'pt': 'Bate-papo on-line',
    },
    'p1pmv278': {
      'en': 'Instant service',
      'de': 'Sofortiger Service',
      'es': 'Servicio instantáneo',
      'fr': 'Service instantané',
      'pt': 'Serviço instantâneo',
    },
    'l0cnc9b1': {
      'en': 'Available now',
      'de': 'Jetzt verfügbar',
      'es': 'Disponible ahora',
      'fr': 'Disponible maintenant',
      'pt': 'Disponível agora',
    },
    'fzgc536x': {
      'en': 'Send your Message',
      'de': 'Senden Sie Ihre Nachricht',
      'es': 'Envía tu mensaje',
      'fr': 'Envoyez votre message',
      'pt': 'Envie sua mensagem',
    },
    '7dp8uw6k': {
      'en': 'Full name',
      'de': 'Vollständiger Name',
      'es': 'Nombre completo',
      'fr': 'Nom et prénom',
      'pt': 'Nome completo',
    },
    '8joqz6ej': {
      'en': 'Enter your full name',
      'de': 'Geben Sie Ihren vollständigen Namen ein',
      'es': 'Ingrese su nombre completo',
      'fr': 'Entrez votre nom complet',
      'pt': 'Digite seu nome completo',
    },
    'u31e3vyh': {
      'en': 'Email',
      'de': 'E-Mail',
      'es': 'Correo electrónico',
      'fr': 'E-mail',
      'pt': 'E-mail',
    },
    'qyqgzfe3': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    '23bna73j': {
      'en': 'your@email.com',
      'de': 'Ihre@E-Mail-Adresse.com',
      'es': 'tu@correoelectrónico.com',
      'fr': 'votre@email.com',
      'pt': 'seu@email.com',
    },
    'ujnsfx0b': {
      'en': 'Subject',
      'de': 'Thema',
      'es': 'Sujeto',
      'fr': 'Sujet',
      'pt': 'Assunto',
    },
    '9x7q7hz4': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'lwk1i3w1': {
      'en': 'Select the subject',
      'de': 'Wählen Sie das Thema',
      'es': 'Seleccione el tema',
      'fr': 'Sélectionnez le sujet',
      'pt': 'Selecione o assunto',
    },
    'toi2zpr6': {
      'en': 'Technical problems',
      'de': 'Technische Probleme',
      'es': 'Problemas técnicos',
      'fr': 'Problèmes techniques',
      'pt': 'Problemas técnicos',
    },
    'e4d29uqo': {
      'en': 'Payment Issues & Refunds',
      'de': 'Zahlungsprobleme und Rückerstattungen',
      'es': 'Problemas de pago y reembolsos',
      'fr': 'Problèmes de paiement et remboursements',
      'pt': 'Problemas de pagamento e reembolsos',
    },
    'vqmmdwy0': {
      'en': 'Complaint',
      'de': 'Beschwerde',
      'es': 'Queja',
      'fr': 'Plainte',
      'pt': 'Reclamação',
    },
    'qe1jv7t7': {
      'en': 'Others',
      'de': 'Sonstige',
      'es': 'Otros',
      'fr': 'Autres',
      'pt': 'Outros',
    },
    '3ztawmse': {
      'en': 'Message',
      'de': 'Nachricht',
      'es': 'Mensaje',
      'fr': 'Message',
      'pt': 'Mensagem',
    },
    '374q2d25': {
      'en': 'Please describe your request in detail...',
      'de': 'Bitte beschreiben Sie Ihr Anliegen detailliert...',
      'es': 'Por favor describa su solicitud en detalle...',
      'fr': 'Veuillez décrire votre demande en détail...',
      'pt': 'Por favor, descreva sua solicitação em detalhes...',
    },
    'nts8vr5q': {
      'en': 'Send Message',
      'de': 'Nachricht senden',
      'es': 'Enviar mensaje',
      'fr': 'Envoyer un message',
      'pt': 'Enviar mensagem',
    },
    'q0jymupb': {
      'en': 'Response Time',
      'de': 'Ansprechzeit',
      'es': 'Tiempo de respuesta',
      'fr': 'Temps de réponse',
      'pt': 'Tempo de resposta',
    },
    'hvtsr364': {
      'en': 'Our average response time is 2-4 hours during business hours.',
      'de':
          'Unsere durchschnittliche Reaktionszeit beträgt während der Geschäftszeiten 2–4 Stunden.',
      'es':
          'Nuestro tiempo de respuesta promedio es de 2 a 4 horas durante el horario comercial.',
      'fr':
          'Notre délai de réponse moyen est de 2 à 4 heures pendant les heures ouvrables.',
      'pt':
          'Nosso tempo médio de resposta é de 2 a 4 horas durante o horário comercial.',
    },
  },
  // FrequentlyAskedQuestions25
  {
    '7jr17pv1': {
      'en': 'FAQ',
      'de': 'Häufig gestellte Fragen',
      'es': 'Preguntas frecuentes',
      'fr': 'Questions fréquemment posées',
      'pt': 'Perguntas frequentes',
    },
    'h954zxq2': {
      'en': 'Find answers to the most common questions about our services',
      'de':
          'Hier finden Sie Antworten auf die häufigsten Fragen zu unseren Dienstleistungen',
      'es':
          'Encuentre respuestas a las preguntas más frecuentes sobre nuestros servicios',
      'fr':
          'Trouvez des réponses aux questions les plus courantes sur nos services',
      'pt':
          'Encontre respostas para as perguntas mais comuns sobre nossos serviços',
    },
    'wz66lacp': {
      'en': 'Payments',
      'de': 'Zahlungen',
      'es': 'Pagos',
      'fr': 'Paiements',
      'pt': 'Pagamentos',
    },
    'vdt8x0ls': {
      'en': 'What payment methods are accepted?',
      'de': 'Welche Zahlungsmethoden werden akzeptiert?',
      'es': '¿Qué métodos de pago se aceptan?',
      'fr': 'Quels modes de paiement sont acceptés ?',
      'pt': 'Quais métodos de pagamento são aceitos?',
    },
    'ro087tg4': {
      'en':
          'We accept credit cards (Visa, Mastercard, American Express).\nDepending on your device, Apple Pay or Google Pay may also be available when enabled.',
      'de':
          'Wir akzeptieren Kreditkarten (Visa, Mastercard, American Express).\nJe nach Gerät sind möglicherweise auch Apple Pay oder Google Pay verfügbar, sofern aktiviert.',
      'es':
          'Aceptamos tarjetas de crédito (Visa, Mastercard, American Express).\nDependiendo de tu dispositivo, Apple Pay o Google Pay también podrían estar disponibles si están habilitados.',
      'fr':
          'Nous acceptons les cartes de crédit (Visa, Mastercard, American Express).\nSelon votre appareil, Apple Pay ou Google Pay peuvent également être disponibles lorsqu\'ils sont activés.',
      'pt':
          'Aceitamos cartões de crédito (Visa, Mastercard, American Express).\nDependendo do seu dispositivo, o Apple Pay ou o Google Pay também podem estar disponíveis quando ativados.',
    },
    'oqusjmn4': {
      'en': 'How does the refund work?',
      'de': 'Wie funktioniert die Rückerstattung?',
      'es': '¿Cómo funciona el reembolso?',
      'fr': 'Comment fonctionne le remboursement ?',
      'pt': 'Como funciona o reembolso?',
    },
    'wghwzhgz': {
      'en':
          'If a ride is canceled or adjusted according to our policy, we issue a refund to the same credit card used at checkout.\nThe time to appear on your statement depends on your bank, but it usually takes 5–10 business days after we process it. Once we send the refund, settlement speed is controlled by your card issuer.\nIf you need help, contact support in the app with your ride ID.',
      'de':
          'Wenn eine Fahrt gemäß unseren Richtlinien storniert oder geändert wird, erstatten wir den Betrag auf die beim Bezahlvorgang verwendete Kreditkarte.\n\nWie lange der Betrag auf Ihrer Abrechnung erscheint, hängt von Ihrer Bank ab. In der Regel dauert es 5–10 Werktage nach der Bearbeitung. Sobald wir die Rückerstattung veranlassen, wird die Bearbeitungsgeschwindigkeit von Ihrem Kartenaussteller bestimmt.\n\nWenn Sie Hilfe benötigen, kontaktieren Sie den Support in der App mit Ihrer Fahrt-ID.',
      'es':
          'Si un viaje se cancela o se ajusta según nuestra política, emitiremos un reembolso a la misma tarjeta de crédito utilizada al pagar.\nEl tiempo que tarda en aparecer en tu estado de cuenta depende de tu banco, pero suele tardar entre 5 y 10 días hábiles desde que lo procesamos. Una vez enviado el reembolso, la velocidad de procesamiento la controla el emisor de tu tarjeta.\nSi necesitas ayuda, contacta con el soporte técnico en la app con tu ID de viaje.',
      'fr':
          'Si une course est annulée ou modifiée conformément à notre politique, nous effectuons un remboursement sur la carte de crédit utilisée lors du paiement.\nLe délai d\'apparition sur votre relevé dépend de votre banque, mais il faut généralement compter 5 à 10 jours ouvrés après traitement. Une fois le remboursement effectué, le délai de règlement est déterminé par l\'émetteur de votre carte.\nEn cas de besoin, contactez l\'assistance dans l\'application avec votre identifiant de course.',
      'pt':
          'Se uma viagem for cancelada ou ajustada de acordo com nossa política, emitiremos um reembolso para o mesmo cartão de crédito utilizado na finalização da compra.\nO prazo para aparecer no seu extrato depende do seu banco, mas geralmente leva de 5 a 10 dias úteis após o processamento. Após o envio do reembolso, a velocidade da liquidação é controlada pela administradora do seu cartão.\nSe precisar de ajuda, entre em contato com o suporte no aplicativo e informe o ID da sua viagem.',
    },
    'bnix2cjw': {
      'en': 'Can I pay in installments for my race?',
      'de': 'Kann ich mein Rennen in Raten bezahlen?',
      'es': '¿Puedo pagar mi carrera a plazos?',
      'fr': 'Puis-je payer ma course en plusieurs fois ?',
      'pt': 'Posso pagar minha corrida em parcelas?',
    },
    'rbmdmqtz': {
      'en':
          'At the moment, installments aren’t available. We charge one single transaction to your credit card after the ride. We’re evaluating installments for the future.',
      'de':
          'Ratenzahlungen sind derzeit nicht möglich. Wir belasten Ihre Kreditkarte nach der Fahrt mit einer einmaligen Transaktion. Wir prüfen die Möglichkeit einer Ratenzahlung für die Zukunft.',
      'es':
          'Por el momento, no ofrecemos pagos a plazos. Se cargará una sola transacción a su tarjeta de crédito después del viaje. Estamos evaluando la posibilidad de ofrecer pagos a plazos en el futuro.',
      'fr':
          'Pour le moment, les paiements en plusieurs fois ne sont pas disponibles. Nous débitons votre carte de crédit une seule fois après la course. Nous étudions actuellement la possibilité de paiements en plusieurs fois.',
      'pt':
          'No momento, não estamos disponíveis parcelamentos. Cobraremos uma única transação no seu cartão de crédito após a viagem. Estamos avaliando a possibilidade de parcelamento para futuras viagens.',
    },
    'pcp4zyho': {
      'en': 'Races',
      'de': 'Rennen',
      'es': 'Razas',
      'fr': 'Courses',
      'pt': 'Corridas',
    },
    '1sp7dqw1': {
      'en': 'Can I change the destination or make stops during the race?',
      'de':
          'Kann ich das Ziel ändern oder während des Rennens Zwischenstopps einlegen?',
      'es': '¿Puedo cambiar el destino o hacer paradas durante la carrera?',
      'fr':
          'Puis-je changer de destination ou faire des arrêts pendant la course ?',
      'pt': 'Posso alterar o destino ou fazer paradas durante a corrida?',
    },
    'tgkzsiti': {
      'en':
          'Yes. Use Edit destination/Add stop in the app. The fare updates based on time and distance.',
      'de':
          'Ja. Verwenden Sie in der App die Option „Ziel bearbeiten/Haltestelle hinzufügen“. Der Fahrpreis wird basierend auf Zeit und Entfernung aktualisiert.',
      'es':
          'Sí. Usa la opción Editar destino/Añadir parada en la app. La tarifa se actualiza según el tiempo y la distancia.',
      'fr':
          'Oui. Utilisez l\'option « Modifier la destination » ou « Ajouter un arrêt » dans l\'application. Le tarif est mis à jour en fonction du temps et de la distance.',
      'pt':
          'Sim. Use Editar destino/Adicionar parada no aplicativo. A tarifa é atualizada com base no tempo e na distância.',
    },
    '1bhqj6fj': {
      'en': 'How are prices and estimates calculated?',
      'de': 'Wie werden Preise und Kostenvoranschläge berechnet?',
      'es': '¿Cómo se calculan los precios y las estimaciones?',
      'fr': 'Comment sont calculés les prix et les devis ?',
      'pt': 'Como os preços e orçamentos são calculados?',
    },
    '3h99tqiu': {
      'en':
          'You get a fare estimate before confirming. Final price may change with traffic, route, wait time, and tolls (when applicable).',
      'de':
          'Sie erhalten vor der Bestätigung einen Fahrpreisvoranschlag. Der Endpreis kann sich je nach Verkehr, Route, Wartezeit und Mautgebühren (falls zutreffend) ändern.',
      'es':
          'Recibirá una estimación de la tarifa antes de confirmar. El precio final puede variar según el tráfico, la ruta, el tiempo de espera y los peajes (si corresponde).',
      'fr':
          'Vous recevrez une estimation du tarif avant de confirmer votre trajet. Le prix final peut varier en fonction de la circulation, de l\'itinéraire, du temps d\'attente et des péages (le cas échéant).',
      'pt':
          'Você recebe uma estimativa da tarifa antes da confirmação. O preço final pode variar dependendo do trânsito, da rota, do tempo de espera e dos pedágios (quando aplicável).',
    },
    '4khb0u5x': {
      'en': 'The driver is late or I can’t find them. What should I do?',
      'de':
          'Der Fahrer ist zu spät oder ich kann ihn nicht finden. Was soll ich tun?',
      'es': 'El conductor llega tarde o no lo encuentro. ¿Qué hago?',
      'fr': 'Le chauffeur est en retard ou je ne le trouve pas. Que faire ?',
      'pt':
          'O motorista está atrasado ou não consigo encontrá-lo. O que devo fazer?',
    },
    'zqiis4u7': {
      'en':
          'Check the plate and live location, use the in-app chat/call. If the delay is excessive, you can cancel or contact support.',
      'de':
          'Überprüfen Sie das Kennzeichen und den Live-Standort und nutzen Sie den In-App-Chat/Anruf. Bei übermäßiger Verzögerung können Sie abbrechen oder den Support kontaktieren.',
      'es':
          'Consulta la matrícula y la ubicación en tiempo real mediante el chat o la llamada de la app. Si la demora es excesiva, puedes cancelar o contactar con soporte.',
      'fr':
          'Vérifiez la plaque d\'immatriculation et la localisation en temps réel, utilisez le chat/appel intégré à l\'application. Si le délai est excessif, vous pouvez annuler ou contacter l\'assistance.',
      'pt':
          'Verifique a placa e a localização em tempo real, use o chat/chamada no aplicativo. Se o atraso for excessivo, você pode cancelar ou entrar em contato com o suporte.',
    },
    '33a2jxbc': {
      'en': 'Is there a cancellation fee?',
      'de': 'Gibt es eine Stornierungsgebühr?',
      'es': '¿Hay algún cargo por cancelación?',
      'fr': 'Y a-t-il des frais d\'annulation ?',
      'pt': 'Existe alguma taxa de cancelamento?',
    },
    'fkju1zzc': {
      'en':
          'A fee may apply once the driver is on the way or has arrived. The app shows the conditions before you confirm the cancellation.',
      'de':
          'Sobald der Fahrer unterwegs oder angekommen ist, kann eine Gebühr anfallen. Die App zeigt die Bedingungen an, bevor Sie die Stornierung bestätigen.',
      'es':
          'Se podría aplicar una tarifa una vez que el conductor esté en camino o haya llegado. La aplicación muestra las condiciones antes de confirmar la cancelación.',
      'fr':
          'Des frais peuvent s\'appliquer une fois le chauffeur en route ou arrivé. L\'application vous en informe avant de confirmer l\'annulation.',
      'pt':
          'Uma taxa pode ser aplicada quando o motorista estiver a caminho ou já tiver chegado. O aplicativo mostra as condições antes de você confirmar o cancelamento.',
    },
    '83rkpdet': {
      'en': 'I left something in the car. How do I get it back?',
      'de': 'Ich habe etwas im Auto vergessen. Wie bekomme ich es zurück?',
      'es': 'Dejé algo en el coche. ¿Cómo lo recupero?',
      'fr':
          'J\'ai oublié quelque chose dans la voiture. Comment puis-je le récupérer ?',
      'pt': 'Esqueci algo no carro. Como faço para recuperá-lo?',
    },
    'z10do02y': {
      'en': 'Contact Support directly with the race ID',
      'de': 'Kontaktieren Sie den Support direkt mit der Renn-ID',
      'es': 'Contacta con Soporte directamente con el ID de la carrera',
      'fr': 'Contactez directement le support avec l\'ID de course',
      'pt': 'Entre em contato com o suporte diretamente com o ID da corrida',
    },
    'ddxas1pq': {
      'en': 'Security',
      'de': 'Sicherheit',
      'es': 'Seguridad',
      'fr': 'Sécurité',
      'pt': 'Segurança',
    },
    'rulcu14k': {
      'en': 'How do you keep vehicles/trips safe?',
      'de': 'Wie sorgen Sie für die Sicherheit von Fahrzeugen/Fahrten?',
      'es': '¿Cómo mantener seguros los vehículos y viajes?',
      'fr':
          'Comment assurez-vous la sécurité des véhicules et des déplacements ?',
      'pt': 'Como você mantém veículos/viagens seguros?',
    },
    'h5jt9mtm': {
      'en':
          'Verified drivers, car details in the app (plate/model), GPS tracking, live sharing, Safety Button, and 24/7 support. If anything feels off, cancel and report.',
      'de':
          'Verifizierte Fahrer, Fahrzeugdetails in der App (Kennzeichen/Modell), GPS-Tracking, Live-Sharing, Sicherheitsknopf und 24/7-Support. Wenn Ihnen etwas nicht passt, kündigen und melden Sie es.',
      'es':
          'Conductores verificados, detalles del auto en la app (matrícula/modelo), rastreo GPS, transmisión en vivo, Botón de Seguridad y soporte 24/7. Si encuentras algo extraño, cancela y reporta.',
      'fr':
          'Conducteurs vérifiés, informations sur le véhicule dans l\'application (plaque d\'immatriculation/modèle), suivi GPS, partage en direct, bouton de sécurité et assistance 24h/24 et 7j/7. En cas d\'anomalie, annulez et signalez.',
      'pt':
          'Motoristas verificados, detalhes do carro no aplicativo (placa/modelo), rastreamento por GPS, compartilhamento em tempo real, Botão de Segurança e suporte 24 horas por dia, 7 dias por semana. Se algo parecer estranho, cancele e denuncie.',
    },
    'lxm4l29i': {
      'en': 'What should I do in an accident?',
      'de': 'Was muss ich bei einem Unfall tun?',
      'es': '¿Qué debo hacer en caso de accidente?',
      'fr': 'Que dois-je faire en cas d’accident ?',
      'pt': 'O que devo fazer em caso de acidente?',
    },
    'kjchkgms': {
      'en':
          'Put safety first and use the Safety Button to reach emergency services and 24/7 support. We log the case, guide next steps, and fix any incorrect charges.',
      'de':
          'Sicherheit steht an erster Stelle. Nutzen Sie den Sicherheitsknopf, um Notdienste und Support rund um die Uhr zu erreichen. Wir protokollieren den Fall, leiten Sie die nächsten Schritte an und korrigieren etwaige fehlerhafte Gebühren.',
      'es':
          'Priorice la seguridad y use el Botón de Seguridad para comunicarse con servicios de emergencia y soporte 24/7. Registramos el caso, le indicamos los pasos a seguir y corregimos cualquier cargo incorrecto.',
      'fr':
          'Privilégiez la sécurité et utilisez le bouton de sécurité pour contacter les services d\'urgence et bénéficier d\'une assistance 24h/24 et 7j/7. Nous enregistrons le cas, vous guidons et corrigeons les frais facturés incorrectement.',
      'pt':
          'Coloque a segurança em primeiro lugar e use o Botão de Segurança para entrar em contato com serviços de emergência e suporte 24 horas por dia, 7 dias por semana. Registramos o caso, orientamos os próximos passos e corrigimos quaisquer cobranças indevidas.',
    },
    '5h0ezqtb': {
      'en': 'Are my personal data protected?',
      'de': 'Sind meine persönlichen Daten geschützt?',
      'es': '¿Están protegidos mis datos personales?',
      'fr': 'Mes données personnelles sont-elles protégées ?',
      'pt': 'Meus dados pessoais estão protegidos?',
    },
    'v4fogsay': {
      'en':
          'Yes. Limited internal access and a clear policy. Payments via Braintree; we don’t store your full card number. In the app, you can view/edit/delete your data.',
      'de':
          'Ja. Eingeschränkter interner Zugriff und klare Richtlinien. Zahlungen erfolgen über Braintree; wir speichern Ihre vollständige Kartennummer nicht. In der App können Sie Ihre Daten einsehen, bearbeiten und löschen.',
      'es':
          'Sí. Acceso interno limitado y una política clara. Pagos a través de Braintree; no almacenamos el número completo de tu tarjeta. En la app, puedes ver, editar y eliminar tus datos.',
      'fr':
          'Oui. Accès interne limité et politique claire. Paiements via Braintree ; nous ne conservons pas votre numéro de carte complet. Dans l\'application, vous pouvez consulter, modifier et supprimer vos données.',
      'pt':
          'Sim. Acesso interno limitado e uma política clara. Pagamentos via Braintree; não armazenamos o número completo do seu cartão. No aplicativo, você pode visualizar/editar/excluir seus dados.',
    },
    '6p9e2d38': {
      'en': 'Can I share my trip in real time?',
      'de': 'Kann ich meine Reise in Echtzeit teilen?',
      'es': '¿Puedo compartir mi viaje en tiempo real?',
      'fr': 'Puis-je partager mon voyage en temps réel ?',
      'pt': 'Posso compartilhar minha viagem em tempo real?',
    },
    'tm2exrnk': {
      'en':
          'Yes. In the app, use Share trip to send a live link with route, car/plate, and ETA; you can stop anytime.',
      'de':
          'Ja. Verwenden Sie in der App „Reise teilen“, um einen Live-Link mit Route, Auto/Kennzeichen und voraussichtlicher Ankunftszeit zu senden. Sie können jederzeit anhalten.',
      'es':
          'Sí. En la aplicación, usa Compartir viaje para enviar un enlace en vivo con la ruta, el auto/matrícula y el tiempo estimado de llegada (ETA); puedes detenerte en cualquier momento.',
      'fr':
          'Oui. Dans l\'application, utilisez Partager un trajet pour envoyer un lien en direct avec l\'itinéraire, le véhicule, la plaque d\'immatriculation et l\'heure d\'arrivée prévue ; vous pouvez vous arrêter à tout moment.',
      'pt':
          'Sim. No aplicativo, use o Compartilhar viagem para enviar um link ao vivo com a rota, carro/placa e ETA; você pode parar a qualquer momento.',
    },
    'oey1slxl': {
      'en': 'Is there an emergency button or 24-hour support?',
      'de': 'Gibt es einen Notfallknopf oder einen 24-Stunden-Support?',
      'es': '¿Hay un botón de emergencia o soporte las 24 horas?',
      'fr':
          'Existe-t-il un bouton d’urgence ou une assistance 24 heures sur 24 ?',
      'pt': 'Existe um botão de emergência ou suporte 24 horas?',
    },
    '6uhcwp8q': {
      'en':
          'Yes. In the app, you’ll find the Safety Button, which connects you to local emergency services and our 24/7 support, available throughout your trip.',
      'de':
          'Ja. In der App finden Sie den Sicherheitsknopf, der Sie mit den örtlichen Notdiensten und unserem 24/7-Support verbindet, der Ihnen während Ihrer gesamten Reise zur Verfügung steht.',
      'es':
          'Sí. En la aplicación, encontrarás el Botón de Seguridad, que te conecta con los servicios de emergencia locales y nuestro soporte 24/7, disponible durante todo tu viaje.',
      'fr':
          'Oui. Dans l\'application, vous trouverez le bouton de sécurité, qui vous met en contact avec les services d\'urgence locaux et notre assistance 24h/24 et 7j/7, disponible tout au long de votre voyage.',
      'pt':
          'Sim. No aplicativo, você encontrará o Botão de Segurança, que o conecta aos serviços de emergência locais e ao nosso suporte 24 horas por dia, 7 dias por semana, disponível durante toda a sua viagem.',
    },
    'pwt2n40k': {
      'en': 'Still have questions?',
      'de': 'Sie haben noch Fragen?',
      'es': '¿Aún tienes preguntas?',
      'fr': 'Vous avez encore des questions ?',
      'pt': 'Ainda tem dúvidas?',
    },
    '4zz17fh2': {
      'en': 'Our support team is available 24/7 to help you',
      'de': 'Unser Support-Team steht Ihnen rund um die Uhr zur Verfügung',
      'es':
          'Nuestro equipo de soporte está disponible las 24 horas, los 7 días de la semana para ayudarle.',
      'fr':
          'Notre équipe d\'assistance est disponible 24h/24 et 7j/7 pour vous aider',
      'pt':
          'Nossa equipe de suporte está disponível 24 horas por dia, 7 dias por semana para ajudar você',
    },
    'st4umfn8': {
      'en': 'Chat Online',
      'de': 'Online-Chat',
      'es': 'Chat en línea',
      'fr': 'Chat en ligne',
      'pt': 'Bate-papo on-line',
    },
    'gkj8n7js': {
      'en': 'Call',
      'de': 'Anruf',
      'es': 'Llamar',
      'fr': 'Appel',
      'pt': 'Chamar',
    },
  },
  // Reportaproblem28
  {
    '9svvq5rn': {
      'en': 'Report a problem',
      'de': 'Problem melden',
      'es': 'Informar un problema',
      'fr': 'Signaler un problème',
      'pt': 'Reportar um problema',
    },
    'ya398usm': {
      'en': 'What’s the issue?',
      'de': 'Was ist das Problem?',
      'es': '¿Cuál es el problema?',
      'fr': 'Quel est le problème?',
      'pt': 'Qual é o problema?',
    },
    'cz0e7hgr': {
      'en': 'Bug in the App',
      'de': 'Fehler in der App',
      'es': 'Error en la aplicación',
      'fr': 'Bug dans l\'application',
      'pt': 'Bug no aplicativo',
    },
    '9g0gsmnq': {
      'en': 'Login Error',
      'de': 'Anmeldefehler',
      'es': 'Error de inicio de sesión',
      'fr': 'Erreur de connexion',
      'pt': 'Erro de login',
    },
    'ybeqqxqa': {
      'en': 'Payment Problem',
      'de': 'Zahlungsproblem',
      'es': 'Problema de pago',
      'fr': 'Problème de paiement',
      'pt': 'Problema de pagamento',
    },
    'ddyao3za': {
      'en': 'Other',
      'de': 'Andere',
      'es': 'Otro',
      'fr': 'Autre',
      'pt': 'Outro',
    },
    'wyxjr51g': {
      'en': 'Describe the Problem',
      'de': 'Beschreiben Sie das Problem',
      'es': 'Describe el problema',
      'fr': 'Décrivez le problème',
      'pt': 'Descreva o problema',
    },
    'ioe0qe1s': {
      'en': 'Describe in detail the problem you are facing...',
      'de':
          'Beschreiben Sie detailliert das Problem, mit dem Sie konfrontiert sind ...',
      'es': 'Describe detalladamente el problema al que te enfrentas...',
      'fr': 'Décrivez en détail le problème auquel vous êtes confronté...',
      'pt': 'Descreva em detalhes o problema que você está enfrentando...',
    },
    'hsgtgffw': {
      'en': 'Attach Screenshot (Optional)',
      'de': 'Screenshot anhängen (optional)',
      'es': 'Adjuntar captura de pantalla (opcional)',
      'fr': 'Joindre une capture d\'écran (facultatif)',
      'pt': 'Anexar captura de tela (opcional)',
    },
    '4bzqefri': {
      'en': 'Tap to add image',
      'de': 'Tippen, um Bild hinzuzufügen',
      'es': 'Toque para agregar imagen',
      'fr': 'Appuyez pour ajouter une image',
      'pt': 'Toque para adicionar imagem',
    },
    'lyijx39w': {
      'en': 'Your Email (for Response)',
      'de': 'Ihre E-Mail (für die Antwort)',
      'es': 'Su correo electrónico (para respuesta)',
      'fr': 'Votre e-mail (pour réponse)',
      'pt': 'Seu e-mail (para resposta)',
    },
    '2ny2madx': {
      'en': 'seu.email@exemplo.com',
      'de': 'seu.email@exemplo.com',
      'es': 'su.correo electrónico@exemplo.com',
      'fr': 'seu.email@exemplo.com',
      'pt': 'seu.email@exemplo.com',
    },
    '6s6l6myx': {
      'en':
          'Our team will review your report and get in touch within 24 hours.',
      'de':
          'Unser Team wird Ihren Bericht prüfen und sich innerhalb von 24 Stunden bei Ihnen melden.',
      'es':
          'Nuestro equipo revisará su informe y se pondrá en contacto con usted dentro de las 24 horas.',
      'fr':
          'Notre équipe examinera votre rapport et vous contactera dans les 24 heures.',
      'pt':
          'Nossa equipe analisará seu relatório e entrará em contato em até 24 horas.',
    },
    'ayn286k3': {
      'en': 'Send feedback',
      'de': 'Feedback senden',
      'es': 'Enviar comentarios',
      'fr': 'Envoyer des commentaires',
      'pt': 'Enviar feedback',
    },
  },
  // chatSupport
  {
    'yx0nkz64': {
      'en': 'Ride Support',
      'de': 'Fahrunterstützung',
      'es': 'Soporte de viaje',
      'fr': 'Assistance à la conduite',
      'pt': 'Suporte de viagem',
    },
    '6vj19dt1': {
      'en': 'Always active',
      'de': 'Immer aktiv',
      'es': 'Siempre activo',
      'fr': 'Toujours actif',
      'pt': 'Sempre ativo',
    },
    '8njxit05': {
      'en': 'Digite uma mensagem...',
      'de': 'Digite uma mensagem...',
      'es': 'Digite uma mensagem...',
      'fr': 'Digite uma mensagem...',
      'pt': 'Digite uma mensagem...',
    },
  },
  // PrivacyPolicy29
  {
    'g69z6fbe': {
      'en': 'Privacy Policy',
      'de': 'Datenschutzrichtlinie',
      'es': 'política de privacidad',
      'fr': 'politique de confidentialité',
      'pt': 'política de Privacidade',
    },
    'dfbmb3np': {
      'en': 'Your privacy comes first',
      'de': 'Ihre Privatsphäre steht an erster Stelle',
      'es': 'Tu privacidad es lo primero',
      'fr': 'Votre vie privée est notre priorité',
      'pt': 'Sua privacidade vem em primeiro lugar',
    },
    'i4qjctrd': {
      'en':
          'We’re committed to protecting your information. Below we explain what we collect, how we use it, and your choices.',
      'de':
          'Wir verpflichten uns, Ihre Daten zu schützen. Im Folgenden erklären wir, welche Daten wir erfassen, wie wir sie verwenden und welche Wahlmöglichkeiten Sie haben.',
      'es':
          'Nos comprometemos a proteger su información. A continuación, le explicamos qué recopilamos, cómo la usamos y sus opciones.',
      'fr':
          'Nous nous engageons à protéger vos informations. Vous trouverez ci-dessous des explications sur ce que nous collectons, comment nous les utilisons et vos choix.',
      'pt':
          'Estamos comprometidos em proteger suas informações. Abaixo, explicamos o que coletamos, como usamos e suas escolhas.',
    },
    'u9lda80p': {
      'en': 'Information We Collect',
      'de': 'Von uns erfasste Daten',
      'es': 'Información que recopilamos',
      'fr': 'Informations que nous collectons',
      'pt': 'Informações que coletamos',
    },
    'eazo7a5p': {
      'en':
          '• Account details: name, email, phone number.\n\n• App usage: screens/features used and performance.\n\n• Device info: model, OS, language.\n\n• Location data (only with your permission).\n\n• Communication records (support and feedback).\n\n• Payments: processed by Braintree; we do not store your full card number.',
      'de':
          '• Kontodaten: Name, E-Mail-Adresse, Telefonnummer.\n\n• App-Nutzung: verwendete Bildschirme/Funktionen und Leistung.\n\n• Geräteinformationen: Modell, Betriebssystem, Sprache.\n\n• Standortdaten (nur mit Ihrer Zustimmung).\n\n• Kommunikationsaufzeichnungen (Support und Feedback).\n\n• Zahlungen: werden von Braintree verarbeitet; wir speichern nicht Ihre vollständige Kartennummer.',
      'es':
          '• Datos de la cuenta: nombre, correo electrónico, número de teléfono.\n\n• Uso de la aplicación: pantallas/funciones utilizadas y rendimiento.\n\n• Información del dispositivo: modelo, sistema operativo, idioma.\n\n• Datos de ubicación (solo con su permiso).\n\n• Registros de comunicación (soporte y comentarios).\n\n• Pagos: procesados por Braintree; no almacenamos el número completo de su tarjeta.',
      'fr':
          '• Informations du compte : nom, adresse e-mail, numéro de téléphone.\n\n• Utilisation de l\'application : écrans/fonctionnalités utilisés et performances.\n\n• Informations sur l\'appareil : modèle, système d\'exploitation, langue.\n\n• Données de localisation (uniquement avec votre autorisation).\n\n• Historique des communications (assistance et commentaires).\n\n• Paiements : traités par Braintree ; nous ne conservons pas votre numéro de carte complet.',
      'pt':
          '• Dados da conta: nome, e-mail, número de telefone.\n\n• Uso do aplicativo: telas/recursos utilizados e desempenho.\n\n• Informações do dispositivo: modelo, sistema operacional, idioma.\n\n• Dados de localização (somente com a sua permissão).\n\n• Registros de comunicação (suporte e feedback).\n\n• Pagamentos: processados pela Braintree; não armazenamos o número completo do seu cartão.',
    },
    'ad97tunv': {
      'en': 'How We Use Your Information',
      'de': 'Wie wir Ihre Daten verwenden',
      'es': 'Cómo usamos su información',
      'fr': 'Comment nous utilisons vos informations',
      'pt': 'Como usamos suas informações',
    },
    'eyo83g4r': {
      'en':
          '• To operate and improve the app and features.\n\n• To personalize experience and prevent fraud/abuse.\n\n• To send important notices (e.g., confirmations and updates).\n\n• Customer support and safety.\n\n• Aggregated analytics to understand usage.',
      'de':
          '• Zur Bedienung und Verbesserung der App und ihrer Funktionen.\n\n• Zur Personalisierung des Erlebnisses und zur Verhinderung von Betrug/Missbrauch.\n\n• Zum Senden wichtiger Mitteilungen (z. B. Bestätigungen und Aktualisierungen).\n\n• Kundensupport und Sicherheit.\n\n• Aggregierte Analysen zum Verständnis der Nutzung.',
      'es':
          '• Para operar y mejorar la aplicación y sus funciones.\n\n• Para personalizar la experiencia y prevenir fraudes y abusos.\n\n• Para enviar avisos importantes (por ejemplo, confirmaciones y actualizaciones).\n\n• Atención al cliente y seguridad.\n\n• Análisis agregados para comprender el uso.',
      'fr':
          '• Pour exploiter et améliorer l\'application et ses fonctionnalités.\n\n• Pour personnaliser l\'expérience et prévenir la fraude et les abus.\n\n• Pour envoyer des notifications importantes (par exemple, des confirmations et des mises à jour).\n\n• Assistance et sécurité client.\n\n• Analyses agrégées pour comprendre l\'utilisation.',
      'pt':
          '• Para operar e aprimorar o aplicativo e seus recursos.\n\n• Para personalizar a experiência e prevenir fraudes/abuso.\n\n• Para enviar avisos importantes (por exemplo, confirmações e atualizações).\n\n• Suporte e segurança ao cliente.\n\n• Análises agregadas para entender o uso.',
    },
    'p3ddl69z': {
      'en': 'Data Security',
      'de': 'Datensicherheit',
      'es': 'Seguridad de datos',
      'fr': 'Sécurité des données',
      'pt': 'Segurança de dados',
    },
    'n2osdvtu': {
      'en':
          '• Only authorized people can access your data.\n\n• We monitor and improve security all the time.\n\n• If something goes wrong, we notify you and act fast.\n\n• We keep data only as long as needed.',
      'de':
          '• Nur autorisierte Personen haben Zugriff auf Ihre Daten.\n\n• Wir überwachen und verbessern die Sicherheit kontinuierlich.\n\n• Sollte etwas schiefgehen, benachrichtigen wir Sie und reagieren schnell.\n\n• Wir speichern Daten nur so lange wie nötig.',
      'es':
          '• Solo las personas autorizadas pueden acceder a sus datos.\n\n• Monitoreamos y mejoramos la seguridad constantemente.\n\n• Si algo sale mal, le notificamos y actuamos con rapidez.\n\n• Conservamos los datos solo el tiempo necesario.',
      'fr':
          '• Seules les personnes autorisées peuvent accéder à vos données.\n\n• Nous surveillons et améliorons la sécurité en permanence.\n\n• En cas de problème, nous vous avertissons et intervenons rapidement.\n\n• Nous conservons les données uniquement le temps nécessaire.',
      'pt':
          '• Somente pessoas autorizadas podem acessar seus dados.\n\n• Monitoramos e aprimoramos a segurança constantemente.\n\n• Se algo der errado, notificamos você e agimos rapidamente.\n\n• Mantemos os dados apenas pelo tempo necessário.',
    },
    'e2oyobdq': {
      'en': 'Third-Party Services',
      'de': 'Dienste von Drittanbietern',
      'es': 'Servicios de terceros',
      'fr': 'Services tiers',
      'pt': 'Serviços de terceiros',
    },
    'ojr87ifd': {
      'en':
          '• The app may use maps, payments, and other services.\n\n• Each has its own policy — please check it.\n\n• We share data only when needed to run the app or with your permission.',
      'de':
          '• Die App kann Karten, Zahlungen und andere Dienste nutzen.\n\n• Jeder Dienst hat seine eigenen Richtlinien – bitte überprüfen Sie diese.\n\n• Wir geben Daten nur weiter, wenn dies zum Ausführen der App erforderlich ist oder wenn Sie uns Ihre Zustimmung dazu geben.',
      'es':
          'La aplicación puede usar mapas, pagos y otros servicios.\n\nCada servicio tiene su propia política; consúltela.\n\nCompartimos datos solo cuando es necesario para el funcionamiento de la aplicación o con su permiso.',
      'fr':
          '• L\'application peut utiliser des cartes, des paiements et d\'autres services.\n\n• Chaque service possède sa propre politique ; veuillez la consulter.\n\n• Nous partageons les données uniquement lorsque cela est nécessaire au fonctionnement de l\'application ou avec votre autorisation.',
      'pt':
          '• O aplicativo pode usar mapas, pagamentos e outros serviços.\n\n• Cada um tem sua própria política — consulte-a.\n\n• Compartilhamos dados apenas quando necessário para executar o aplicativo ou com sua permissão.',
    },
    'cnplhd5p': {
      'en': 'Your Rights',
      'de': 'Ihre Rechte',
      'es': 'Sus derechos',
      'fr': 'Vos droits',
      'pt': 'Seus direitos',
    },
    'ynwc1mzv': {
      'en':
          '• See and correct your data.\n\n• Delete your data or request a copy.\n\n• Manage device permissions and opt out of marketing.',
      'de':
          '• Ihre Daten einsehen und korrigieren.\n\n• Ihre Daten löschen oder eine Kopie anfordern.\n\n• Geräteberechtigungen verwalten und Marketing deaktivieren.',
      'es':
          '• Ver y corregir sus datos.\n\n• Eliminar sus datos o solicitar una copia.\n\n• Gestionar los permisos del dispositivo y darse de baja del marketing.',
      'fr':
          '• Consultez et corrigez vos données.\n\n• Supprimez vos données ou demandez-en une copie.\n\n• Gérez les autorisations de votre appareil et désactivez les communications marketing.',
      'pt':
          '• Visualizar e corrigir seus dados.\n\n• Excluir seus dados ou solicitar uma cópia.\n\n• Gerenciar permissões do dispositivo e cancelar o recebimento de marketing.',
    },
    'o6220pi9': {
      'en': 'Contact Us',
      'de': 'Kontaktieren Sie uns',
      'es': 'Contáctenos',
      'fr': 'Contactez-nous',
      'pt': 'Contate-nos',
    },
    '4qlhmmd6': {
      'en':
          'Questions about privacy?\n\nEmail: info@quickyy.life\nIn-app: Profile → Support\n\nLast updated: December 2024',
      'de':
          'Fragen zum Datenschutz?\n\nE-Mail: info@quickyy.life\nIn-App: Profil → Support\n\nLetzte Aktualisierung: Dezember 2024',
      'es':
          '¿Preguntas sobre privacidad?\n\nCorreo electrónico: info@quickyy.life\nEn la app: Perfil → Soporte\n\nÚltima actualización: diciembre de 2024',
      'fr':
          'Des questions sur la confidentialité ?\n\nE-mail : info@quickyy.life\nDans l\'application : Profil → Assistance\n\nDernière mise à jour : décembre 2024',
      'pt':
          'Dúvidas sobre privacidade?\n\nE-mail: info@quickyy.life\nNo aplicativo: Perfil → Suporte\n\nÚltima atualização: dezembro de 2024',
    },
    'gc6z696t': {
      'en':
          'This policy may be updated from time to time. We will notify you of any significant changes.',
      'de':
          'Diese Richtlinie kann von Zeit zu Zeit aktualisiert werden. Wir werden Sie über alle wesentlichen Änderungen informieren.',
      'es':
          'Esta política puede actualizarse periódicamente. Le notificaremos cualquier cambio significativo.',
      'fr':
          'Cette politique peut être mise à jour périodiquement. Nous vous informerons de tout changement important.',
      'pt':
          'Esta política pode ser atualizada periodicamente. Notificaremos você sobre quaisquer alterações significativas.',
    },
  },
  // TermsofService30
  {
    'ra6hewkk': {
      'en': 'Terms of Service',
      'de': 'Servicebedingungen',
      'es': 'Condiciones de servicio',
      'fr': 'Conditions d\'utilisation',
      'pt': 'Termos de Serviço',
    },
    'ssubq09y': {
      'en': 'App Use',
      'de': 'App-Nutzung',
      'es': 'Uso de la aplicación',
      'fr': 'Utilisation de l\'application',
      'pt': 'Uso do aplicativo',
    },
    'l3rbgns8': {
      'en':
          'Use the app to request rides with your own account. Don’t use it for illegal or abusive activity — we may suspend accounts that violate the rules.',
      'de':
          'Nutze die App, um Fahrten mit deinem eigenen Konto anzufordern. Nutze sie nicht für illegale oder missbräuchliche Aktivitäten – wir können Konten sperren, die gegen die Regeln verstoßen.',
      'es':
          'Usa la app para solicitar viajes con tu propia cuenta. No la uses para actividades ilegales o abusivas; podríamos suspender las cuentas que infrinjan las normas.',
      'fr':
          'Utilisez l\'application pour commander des courses avec votre compte. Ne l\'utilisez pas pour des activités illégales ou abusives ; nous pourrions suspendre les comptes qui enfreignent les règles.',
      'pt':
          'Use o aplicativo para solicitar viagens com sua própria conta. Não o utilize para atividades ilegais ou abusivas — podemos suspender contas que violem as regras.',
    },
    'hyneyff1': {
      'en': 'Account & Eligibility',
      'de': 'Konto und Berechtigung',
      'es': 'Cuenta y elegibilidad',
      'fr': 'Compte et éligibilité',
      'pt': 'Conta e Elegibilidade',
    },
    'xz7q5oqy': {
      'en':
          'You must be 18+, provide accurate info, and keep your account secure. One account per person; we may close accounts for non-compliance.',
      'de':
          'Sie müssen mindestens 18 Jahre alt sein, korrekte Angaben machen und Ihr Konto sicher aufbewahren. Pro Person ist nur ein Konto zulässig. Bei Nichteinhaltung behalten wir uns das Recht vor, Konten zu schließen.',
      'es':
          'Debes ser mayor de 18 años, proporcionar información veraz y mantener tu cuenta segura. Solo se permite una cuenta por persona; podríamos cerrar cuentas por incumplimiento.',
      'fr':
          'Vous devez avoir plus de 18 ans, fournir des informations exactes et sécuriser votre compte. Un compte par personne ; nous pouvons fermer tout compte en cas de non-conformité.',
      'pt':
          'Você deve ter mais de 18 anos, fornecer informações precisas e manter sua conta segura. Uma conta por pessoa; podemos encerrar contas em caso de descumprimento.',
    },
    'o49590hu': {
      'en': 'Rides & Fares',
      'de': 'Fahrten & Preise',
      'es': 'Viajes y tarifas',
      'fr': 'Trajets et tarifs',
      'pt': 'Passeios e tarifas',
    },
    'iq3q0eua': {
      'en':
          'We show a fare estimate before you confirm. Final price can change due to traffic, route, wait time, and tolls. Your receipt is in the app.',
      'de':
          'Wir zeigen Ihnen vor der Bestätigung einen Fahrpreisvoranschlag an. Der Endpreis kann sich je nach Verkehr, Route, Wartezeit und Mautgebühren ändern. Ihre Quittung finden Sie in der App.',
      'es':
          'Te mostramos una estimación de la tarifa antes de confirmar. El precio final puede variar según el tráfico, la ruta, el tiempo de espera y los peajes. Tu recibo está en la app.',
      'fr':
          'Nous vous affichons une estimation du tarif avant votre confirmation. Le prix final peut varier en fonction de la circulation, de l\'itinéraire, du temps d\'attente et des péages. Votre reçu est disponible dans l\'application.',
      'pt':
          'Mostramos uma estimativa da tarifa antes da sua confirmação. O preço final pode variar devido ao trânsito, rota, tempo de espera e pedágios. Seu recibo está no aplicativo.',
    },
    'hd9a2nxr': {
      'en': 'Payments (Braintree)',
      'de': 'Zahlungen (Braintree)',
      'es': 'Pagos (Braintree)',
      'fr': 'Paiements (Braintree)',
      'pt': 'Pagamentos (Braintree)',
    },
    'e0hx8opo': {
      'en':
          'We charge credit cards (Apple/Google Pay may be available). We do not accept debit cards, Pix, or bank transfers. Processed by Braintree; we don’t store your full card number.',
      'de':
          'Wir belasten Kreditkarten (Apple/Google Pay ist möglicherweise verfügbar). Wir akzeptieren keine Debitkarten, Pix oder Banküberweisungen. Die Bearbeitung erfolgt durch Braintree; wir speichern Ihre vollständige Kartennummer nicht.',
      'es':
          'Aceptamos tarjetas de crédito (Apple/Google Pay puede estar disponible). No aceptamos tarjetas de débito, Pix ni transferencias bancarias. Procesado por Braintree; no almacenamos el número completo de su tarjeta.',
      'fr':
          'Nous acceptons les cartes de crédit (Apple/Google Pay peut être disponible). Nous n\'acceptons pas les cartes de débit, les cartes Pix ni les virements bancaires. Traitement par Braintree ; nous ne conservons pas votre numéro de carte complet.',
      'pt':
          'Cobramos em cartões de crédito (Apple/Google Pay podem estar disponíveis). Não aceitamos cartões de débito, Pix ou transferências bancárias. Processado pela Braintree; não armazenamos o número completo do seu cartão.',
    },
    '1j9ju4dv': {
      'en': 'Cancellations & Refunds',
      'de': 'Stornierungen und Rückerstattungen',
      'es': 'Cancelaciones y reembolsos',
      'fr': 'Annulations et remboursements',
      'pt': 'Cancelamentos e Reembolsos',
    },
    '01ra7oy8': {
      'en':
          'A fee may apply if the driver is on the way. Refunds go to the same card; timing depends on your bank. Request it in the app.',
      'de':
          'Wenn der Fahrer unterwegs ist, kann eine Gebühr anfallen. Rückerstattungen werden auf dieselbe Karte gebucht; der Zeitpunkt hängt von Ihrer Bank ab. Fordern Sie die Rückerstattung in der App an.',
      'es':
          'Se podría aplicar una tarifa si el conductor está en camino. Los reembolsos se realizan a la misma tarjeta; el plazo depende de tu banco. Solicítalo en la app.',
      'fr':
          'Des frais peuvent s\'appliquer si le chauffeur est en route. Les remboursements sont effectués sur la même carte ; le délai dépend de votre banque. Demandez-le dans l\'application.',
      'pt':
          'Poderá ser cobrada uma taxa se o motorista estiver a caminho. Os reembolsos são feitos no mesmo cartão; o prazo depende do seu banco. Solicite no aplicativo.',
    },
    '1co4586b': {
      'en': 'Safety & Conduct',
      'de': 'Sicherheit & Verhalten',
      'es': 'Seguridad y conducta',
      'fr': 'Sécurité et conduite',
      'pt': 'Segurança e Conduta',
    },
    'faa0m7y4': {
      'en':
          'Trips have GPS tracking, a Safety Button, and 24/7 support. Respect drivers and the law; risky behavior can lead to ban.',
      'de':
          'Fahrten werden mit GPS-Tracking, einem Sicherheitsknopf und 24/7-Support durchgeführt. Respektieren Sie Fahrer und Gesetze; riskantes Verhalten kann zum Fahrverbot führen.',
      'es':
          'Los viajes cuentan con rastreo GPS, botón de seguridad y soporte 24/7. Respete a los conductores y la ley; cualquier comportamiento arriesgado puede resultar en una suspensión.',
      'fr':
          'Les trajets sont suivis par GPS, dotés d\'un bouton de sécurité et d\'une assistance 24h/24 et 7j/7. Respectez les conducteurs et la loi ; tout comportement à risque peut entraîner une interdiction de conduire.',
      'pt':
          'As viagens contam com rastreamento por GPS, um Botão de Segurança e suporte 24 horas por dia, 7 dias por semana. Respeite os motoristas e a lei; comportamento de risco pode levar à proibição.',
    },
    '49how4av': {
      'en': 'Data & Privacy',
      'de': 'Daten & Datenschutz',
      'es': 'Datos y privacidad',
      'fr': 'Données et confidentialité',
      'pt': 'Dados e Privacidade',
    },
    'arxd0mls': {
      'en':
          'We use your data to run the app, provide support, and prevent fraud. You can view/edit/delete your data and manage permissions. We don’t sell your data.',
      'de':
          'Wir verwenden Ihre Daten, um die App zu betreiben, Support zu leisten und Betrug zu verhindern. Sie können Ihre Daten einsehen, bearbeiten und löschen sowie Berechtigungen verwalten. Wir verkaufen Ihre Daten nicht.',
      'es':
          'Usamos tus datos para ejecutar la aplicación, brindar soporte y prevenir fraudes. Puedes ver, editar y eliminar tus datos, así como administrar permisos. No vendemos tus datos.',
      'fr':
          'Nous utilisons vos données pour faire fonctionner l\'application, fournir une assistance et prévenir la fraude. Vous pouvez consulter, modifier et supprimer vos données, ainsi que gérer vos autorisations. Nous ne vendons pas vos données.',
      'pt':
          'Usamos seus dados para executar o aplicativo, fornecer suporte e prevenir fraudes. Você pode visualizar/editar/excluir seus dados e gerenciar permissões. Não vendemos seus dados.',
    },
    'yhjazte1': {
      'en': 'Liability',
      'de': 'Haftung',
      'es': 'Responsabilidad',
      'fr': 'Responsabilité',
      'pt': 'Responsabilidade',
    },
    'e5vhmpdf': {
      'en':
          'We’re not responsible for traffic delays or other external factors. Our liability is limited by law and by the app’s policies.',
      'de':
          'Wir sind nicht für Verkehrsverzögerungen oder andere externe Faktoren verantwortlich. Unsere Haftung ist gesetzlich und durch die Richtlinien der App beschränkt.',
      'es':
          'No nos responsabilizamos de retrasos en el tráfico ni de otros factores externos. Nuestra responsabilidad está limitada por la ley y las políticas de la aplicación.',
      'fr':
          'Nous ne sommes pas responsables des retards de circulation ni d\'autres facteurs externes. Notre responsabilité est limitée par la loi et les politiques de l\'application.',
      'pt':
          'Não nos responsabilizamos por atrasos no trânsito ou outros fatores externos. Nossa responsabilidade é limitada por lei e pelas políticas do aplicativo.',
    },
  },
  // Licenses31
  {
    'd0bmlf5j': {
      'en': 'Licenses',
      'de': 'Lizenzen',
      'es': 'Licencias',
      'fr': 'Licences',
      'pt': 'Licenças',
    },
    'bfxeohhr': {
      'en': 'By Quicky Solutions',
      'de': 'Von Quicky Solutions',
      'es': 'Por Quicky Solutions',
      'fr': 'Par Quicky Solutions',
      'pt': 'Por Quicky Solutions',
    },
    'lizqlyb8': {
      'en':
          'This application uses the following open source libraries and components:',
      'de':
          'Diese Anwendung verwendet die folgenden Open Source-Bibliotheken und -Komponenten:',
      'es':
          'Esta aplicación utiliza las siguientes bibliotecas y componentes de código abierto:',
      'fr':
          'Cette application utilise les bibliothèques et composants open source suivants :',
      'pt':
          'Este aplicativo usa as seguintes bibliotecas e componentes de código aberto:',
    },
    'pyj8e4z2': {
      'en': 'Flutter SDK (v3.32.4)',
      'de': 'Flutter SDK (v3.32.4)',
      'es': 'Kit de desarrollo de software de Flutter (v3.32.4)',
      'fr': 'Kit de développement logiciel (SDK) Flutter (v3.32.4)',
      'pt': 'SDK Flutter (v3.32.4)',
    },
    '1hw8ew0h': {
      'en': 'Cross-platform app foundation.\nAuthor: Flutter contributors',
      'de': 'Plattformübergreifende App-Grundlage.\nAutor: Flutter-Mitwirkende',
      'es':
          'Fundamento de la aplicación multiplataforma.\nAutor: Colaboradores de Flutter',
      'fr':
          'Fondation d\'application multiplateforme.\nAuteur : Contributeurs Flutter',
      'pt':
          'Base para aplicativos multiplataforma.\nAutor: Colaboradores do Flutter',
    },
    '21x9f71b': {
      'en': 'BSD 3-Clause License',
      'de': 'BSD 3-Klausel-Lizenz',
      'es': 'Licencia BSD de 3 cláusulas',
      'fr': 'Licence BSD à 3 clauses',
      'pt': 'Licença BSD de 3 cláusulas',
    },
    'sol3x3mu': {
      'en': 'Dart (v3.7.2)',
      'de': 'Dart (v3.7.2)',
      'es': 'Dardo (v3.7.2)',
      'fr': 'Dart (v3.7.2)',
      'pt': 'Dardo (v3.7.2)',
    },
    'mnll0ehv': {
      'en': 'Language and runtime.\nAuthor: Dart team.',
      'de': 'Sprache und Laufzeit.\nAutor: Dart-Team.',
      'es': 'Lenguaje y tiempo de ejecución. Autor: Equipo Dart.',
      'fr': 'Langage et environnement d\'exécution.\nAuteur : Équipe Dart.',
      'pt': 'Linguagem e tempo de execução.\nAutor: Equipe Dart.',
    },
    'si72hibu': {
      'en': 'BSD 3-Clause License',
      'de': 'BSD 3-Klausel-Lizenz',
      'es': 'Licencia BSD de 3 cláusulas',
      'fr': 'Licence BSD à 3 clauses',
      'pt': 'Licença BSD de 3 cláusulas',
    },
    '5tewmpty': {
      'en': 'HTTP (v1.4.0)',
      'de': 'HTTP (v1.4.0)',
      'es': 'HTTP (versión 1.4.0)',
      'fr': 'HTTP (v1.4.0)',
      'pt': 'HTTP (v1.4.0)',
    },
    'x5mho8ys': {
      'en': 'Web/API requests.\nAuthor: Dart project authors.',
      'de': 'Web-/API-Anfragen.\nAutor: Autoren des Dart-Projekts.',
      'es': 'Solicitudes web/API.\nAutor: Autores del proyecto Dart.',
      'fr': 'Requêtes Web/API.\nAuteur : Auteurs du projet Dart.',
      'pt': 'Solicitações Web/API.\nAutor: Autores do projeto Dart.',
    },
    'bbm1mv6m': {
      'en': 'BSD 3-Clause License',
      'de': 'BSD 3-Klausel-Lizenz',
      'es': 'Licencia BSD de 3 cláusulas',
      'fr': 'Licence BSD à 3 clauses',
      'pt': 'Licença BSD de 3 cláusulas',
    },
    'pqj0brpn': {
      'en': 'Shared Preferences (v2.5.3)',
      'de': 'Gemeinsame Einstellungen (v2.5.3)',
      'es': 'Preferencias compartidas (v2.5.3)',
      'fr': 'Préférences partagées (v2.5.3)',
      'pt': 'Preferências compartilhadas (v2.5.3)',
    },
    '97zuhrqn': {
      'en': 'Simple key-value storage.\nAuthor: Flutter team.',
      'de': 'Einfacher Schlüssel-Wert-Speicher.\nAutor: Flutter-Team.',
      'es': 'Almacenamiento simple de clave-valor. Autor: Equipo Flutter.',
      'fr': 'Stockage simple de clés et de valeurs.\nAuteur : Équipe Flutter.',
      'pt': 'Armazenamento simples de chave-valor.\nAutor: Equipe Flutter.',
    },
    'qd86znqv': {
      'en': 'BSD 3-Clause License',
      'de': 'BSD 3-Klausel-Lizenz',
      'es': 'Licencia BSD de 3 cláusulas',
      'fr': 'Licence BSD à 3 clauses',
      'pt': 'Licença BSD de 3 cláusulas',
    },
    'c5b32dt6': {
      'en': 'Path Provider (v2.1.4)',
      'de': 'Pfadanbieter (v2.1.4)',
      'es': 'Proveedor de rutas (v2.1.4)',
      'fr': 'Fournisseur de chemin (v2.1.4)',
      'pt': 'Provedor de Caminho (v2.1.4)',
    },
    'ww73vi5w': {
      'en': 'Access to system directories.\nAuthor: Flutter team.',
      'de': 'Zugriff auf Systemverzeichnisse.\nAutor: Flutter-Team.',
      'es': 'Acceso a los directorios del sistema.\nAutor: Equipo Flutter.',
      'fr': 'Accès aux répertoires système.\nAuteur : Équipe Flutter.',
      'pt': 'Acesso aos diretórios do sistema.\nAutor: Equipe Flutter.',
    },
    '22jswh9f': {
      'en': 'BSD 3-Clause License',
      'de': 'BSD 3-Klausel-Lizenz',
      'es': 'Licencia BSD de 3 cláusulas',
      'fr': 'Licence BSD à 3 clauses',
      'pt': 'Licença BSD de 3 cláusulas',
    },
    'c0h6nsdf': {
      'en': 'Geolocator (v9.0.2)',
      'de': 'Geolocator (v9.0.2)',
      'es': 'Geolocalizador (v9.0.2)',
      'fr': 'Géolocalisateur (v9.0.2)',
      'pt': 'Geolocalizador (v9.0.2)',
    },
    'mn1rsx3t': {
      'en': 'Device location.\nAuthor: Baseflow.',
      'de': 'Gerätestandort.\nAutor: Baseflow.',
      'es': 'Ubicación del dispositivo. Autor: Baseflow.',
      'fr': 'Localisation de l\'appareil.\nAuteur : Baseflow.',
      'pt': 'Localização do dispositivo.\nAutor: Baseflow.',
    },
    'yqev98bu': {
      'en': 'BSD 3-Clause License',
      'de': 'BSD 3-Klausel-Lizenz',
      'es': 'Licencia BSD de 3 cláusulas',
      'fr': 'Licence BSD à 3 clauses',
      'pt': 'Licença BSD de 3 cláusulas',
    },
    '579hreac': {
      'en': 'Google Maps Native SDK (v0.7.0)',
      'de': 'Google Maps Native SDK (v0.7.0)',
      'es': 'SDK nativo de Google Maps (v0.7.0)',
      'fr': 'SDK natif de Google Maps (v0.7.0)',
      'pt': 'SDK nativo do Google Maps (v0.7.0)',
    },
    'g7hb8l2q': {
      'en':
          'Maps and pins in the app.\nAuthor: Quicky Solution/Nagazaki Software.',
      'de':
          'Karten und Pins in der App.\nAutor: Quicky Solution/Nagazaki Software.',
      'es':
          'Mapas y marcadores en la aplicación.\nAutor: Quicky Solution/Nagazaki Software.',
      'fr':
          'Cartes et repères dans l\'application.\nAuteur : Quicky Solution/Nagazaki Software.',
      'pt':
          'Mapas e marcadores no aplicativo.\nAutor: Quicky Solution/Nagazaki Software.',
    },
    'e9wrli4n': {
      'en': 'BSD 3-Clause License',
      'de': 'BSD 3-Klausel-Lizenz',
      'es': 'Licencia BSD de 3 cláusulas',
      'fr': 'Licence BSD à 3 clauses',
      'pt': 'Licença BSD de 3 cláusulas',
    },
    'ux98u86n': {
      'en': 'URL Launcher (v6.3.1)',
      'de': 'URL-Starter (v6.3.1)',
      'es': 'Lanzador de URL (v6.3.1)',
      'fr': 'Lanceur d\'URL (v6.3.1)',
      'pt': 'Iniciador de URL (v6.3.1)',
    },
    'g21sfe2v': {
      'en': 'Open links/calls/emails.\nAuthor: Flutter team.',
      'de': 'Öffnen Sie Links/Anrufe/E-Mails.\nAutor: Flutter-Team.',
      'es':
          'Abrir enlaces, llamadas y correos electrónicos.\nAutor: Equipo Flutter.',
      'fr': 'Liens/appels/e-mails ouverts.\nAuteur : Équipe Flutter.',
      'pt': 'Abrir links/chamadas/e-mails.\nAutor: Equipe Flutter.',
    },
    'gbcpuwmi': {
      'en': 'BSD 3-Clause License',
      'de': 'BSD 3-Klausel-Lizenz',
      'es': 'Licencia BSD de 3 cláusulas',
      'fr': 'Licence BSD à 3 clauses',
      'pt': 'Licença BSD de 3 cláusulas',
    },
    '6ihkgp1b': {
      'en': 'intl (v0.20.2)',
      'de': 'intl (v0.20.2)',
      'es': 'internacional (v0.20.2)',
      'fr': 'intl (v0.20.2)',
      'pt': 'intl (v0.20.2)',
    },
    'ob1qv12f': {
      'en': 'Dates, numbers, and locale formatting.\nAuthor: Dart team.',
      'de':
          'Datums-, Zahlen- und Gebietsschemaformatierung.\nAutor: Dart-Team.',
      'es': 'Fechas, números y formato regional. Autor: Equipo Dart.',
      'fr': 'Dates, nombres et formatage local.\nAuteur : Équipe Dart.',
      'pt': 'Datas, números e formatação de localidade.\nAutor: Equipe Dart.',
    },
    'wqdowqa1': {
      'en': 'BSD 3-Clause License',
      'de': 'BSD 3-Klausel-Lizenz',
      'es': 'Licencia BSD de 3 cláusulas',
      'fr': 'Licence BSD à 3 clauses',
      'pt': 'Licença BSD de 3 cláusulas',
    },
    'p1ahtxu3': {
      'en': 'Braintree Native UI (v0.4.0)',
      'de': 'Native Benutzeroberfläche von Braintree (v0.4.0)',
      'es': 'Interfaz de usuario nativa de Braintree (v0.4.0)',
      'fr': 'Interface utilisateur native Braintree (v0.4.0)',
      'pt': 'Interface de usuário nativa do Braintree (v0.4.0)',
    },
    'wo6vidne': {
      'en': 'Payments.\nAuthor: Quicky Solutions/Nagazaki Software.',
      'de': 'Zahlungen.\nAutor: Quicky Solutions/Nagazaki Software.',
      'es': 'Pagos. Autor: Quicky Solutions/Nagazaki Software.',
      'fr': 'Paiements.\nAuteur : Quicky Solutions/Nagazaki Software.',
      'pt': 'Pagamentos.\nAutor: Quicky Solutions/Nagazaki Software.',
    },
    'vga103ah': {
      'en': 'BSD 3-Clause License',
      'de': 'BSD 3-Klausel-Lizenz',
      'es': 'Licencia BSD de 3 cláusulas',
      'fr': 'Licence BSD à 3 clauses',
      'pt': 'Licença BSD de 3 cláusulas',
    },
  },
  // a1
  {
    '77apgdkx': {
      'en': 'Recibos',
      'de': 'Rezepte',
      'es': 'Recibos',
      'fr': 'Recettes',
      'pt': 'Receitas',
    },
    'ytv19n2u': {
      'en': 'Valor da corrida',
      'de': 'Valor da corrida',
      'es': 'Valor da corrida',
      'fr': 'Valor da corrida',
      'pt': 'Valor da corrida',
    },
    '065212ul': {
      'en': 'Pago',
      'de': 'Pago',
      'es': 'Pago',
      'fr': 'Paiement',
      'pt': 'Pago',
    },
    'prdsa145': {
      'en': '\$ 12',
      'de': '12 \$',
      'es': '\$12',
      'fr': '12 \$',
      'pt': '\$ 12',
    },
    'tac7rzoo': {
      'en': 'Hello World',
      'de': 'Hallo Welt',
      'es': 'Hola Mundo',
      'fr': 'Bonjour le monde',
      'pt': 'Olá Mundo',
    },
    'h3i3fp80': {
      'en': 'Apartamento Centro - Janeiro 2024',
      'de': 'Apartment Centro - Janeiro 2024',
      'es': 'Apartamento Centro - Janeiro 2024',
      'fr': 'Appartement Centro - Janvier 2024',
      'pt': 'Apartamento Centro - Janeiro 2024',
    },
    '3ppcipw3': {
      'en': '15 Jan 2024 • 14:30',
      'de': '15. Januar 2024 • 14:30',
      'es': '15 de enero de 2024 • 14:30',
      'fr': '15 janv. 2024 • 14:30',
      'pt': '15 de janeiro de 2024 • 14:30',
    },
    'nmtlwhwx': {
      'en': 'Visualizar',
      'de': 'Visualisieren',
      'es': 'Visualizar',
      'fr': 'Visualiser',
      'pt': 'Visualizar',
    },
    '9dfawdqr': {
      'en': 'Baixar PDF',
      'de': 'Baixar PDF',
      'es': 'Descargar PDF',
      'fr': 'Télécharger le PDF',
      'pt': 'Baixar PDF',
    },
    'qgfy51z0': {
      'en': '30 ago.,',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    '9ewve1y7': {
      'en': '15:23',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'c0smk2ag': {
      'en': 'R\$8,90',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'qy7a1z7o': {
      'en': 'Hello World',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'e9nm3r7q': {
      'en': 'Hello World',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
  },
  // DriverReviews32
  {
    'egp9nl0e': {
      'en': 'Driver Reviews',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'k29jbse0': {
      'en': 'Rides',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'p7utovr9': {
      'en': 'with Ride',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'qu0wxewk': {
      'en': 'Rating',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    '4zws0jel': {
      'en': 'Checks completed',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'cp9vard8': {
      'en': 'Top Reviews',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'xwi88br9': {
      'en': '•',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
  },
  // continuecom
  {
    'j0lphagc': {
      'en': 'Continue with',
      'de': 'Weiter mit',
      'es': 'Continuar con',
      'fr': 'Continuer avec',
      'pt': 'Continuar com',
    },
  },
  // cardPayment
  {
    'p8t6d1h2': {
      'en': 'Payment Method',
      'de': 'Zahlungsmethode',
      'es': 'Método de pago',
      'fr': 'Mode de paiement',
      'pt': 'Método de pagamento',
    },
    'a008km1g': {
      'en': 'Choose your preferred payment option',
      'de': 'Wählen Sie Ihre bevorzugte Zahlungsoption',
      'es': 'Elige tu opción de pago preferida',
      'fr': 'Choisissez votre option de paiement préférée',
      'pt': 'Escolha sua opção de pagamento preferida',
    },
    '0skbwu9o': {
      'en': 'Pay with Google Pay',
      'de': 'Bezahlen mit Google Pay',
      'es': 'Pagar con Google Pay',
      'fr': 'Payer avec Google Pay',
      'pt': 'Pague com o Google Pay',
    },
    '0cdaev13': {
      'en': 'Pay with Apple Pay',
      'de': 'Bezahlen mit Apple Pay',
      'es': 'Pagar con Apple Pay',
      'fr': 'Payer avec Apple Pay',
      'pt': 'Pague com Apple Pay',
    },
    '9j9a154z': {
      'en': 'Credit Card Information',
      'de': 'Kreditkarteninformationen',
      'es': 'Información de la tarjeta de crédito',
      'fr': 'Informations sur la carte de crédit',
      'pt': 'Informações do cartão de crédito',
    },
    'hxpv6ouk': {
      'en': 'Confirm',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
  },
  // erronopagamento
  {
    '14yzkw68': {
      'en': 'Payment error',
      'de': 'Zahlungsfehler',
      'es': 'Error de pago',
      'fr': 'Erreur de paiement',
      'pt': 'Erro de pagamento',
    },
    'd2jpav0r': {
      'en':
          'We couldn\'t process your payment. Please check your card details and try again.',
      'de':
          'Wir konnten Ihre Zahlung nicht verarbeiten. Bitte überprüfen Sie Ihre Kartendetails und versuchen Sie es erneut.',
      'es':
          'No pudimos procesar tu pago. Revisa los datos de tu tarjeta y vuelve a intentarlo.',
      'fr':
          'Nous n\'avons pas pu traiter votre paiement. Veuillez vérifier les informations de votre carte et réessayer.',
      'pt':
          'Não foi possível processar seu pagamento. Verifique os dados do seu cartão e tente novamente.',
    },
    'l3q1bael': {
      'en': 'Try again',
      'de': 'Versuchen Sie es erneut',
      'es': 'Intentar otra vez',
      'fr': 'Essayer à nouveau',
      'pt': 'Tente novamente',
    },
    '8zf35a1x': {
      'en': 'Cancel',
      'de': 'Stornieren',
      'es': 'Cancelar',
      'fr': 'Annuler',
      'pt': 'Cancelar',
    },
  },
  // passecomprado
  {
    '4kxujjm3': {
      'en': 'Purchase made!',
      'de': 'Kauf getätigt!',
      'es': '¡Compra realizada!',
      'fr': 'Achat effectué !',
      'pt': 'Compra efetuada!',
    },
    '0ec3dum2': {
      'en': 'Start traveling',
      'de': 'Beginnen Sie Ihre Reise',
      'es': 'Empieza a viajar',
      'fr': 'Commencez à voyager',
      'pt': 'Comece a viajar',
    },
  },
  // rideScheduleSucess
  {
    '8y5h9zq6': {
      'en': 'Ride Scheduled Successfully!',
      'de': 'Fahrt erfolgreich geplant!',
      'es': '¡Viaje programado exitosamente!',
      'fr': 'Course planifiée avec succès !',
      'pt': 'Passeio agendado com sucesso!',
    },
    'chvb97s2': {
      'en':
          'Your ride has been confirmed and the driver will arrive at the scheduled time.',
      'de':
          'Ihre Fahrt wurde bestätigt und der Fahrer wird zur geplanten Zeit eintreffen.',
      'es':
          'Su viaje ha sido confirmado y el conductor llegará a la hora programada.',
      'fr':
          'Votre course a été confirmée et le chauffeur arrivera à l\'heure prévue.',
      'pt':
          'Sua viagem foi confirmada e o motorista chegará no horário agendado.',
    },
    'r7qclgc3': {
      'en': 'View Details',
      'de': 'Details anzeigen',
      'es': 'Ver detalles',
      'fr': 'Voir les détails',
      'pt': 'Ver detalhes',
    },
    'n2ek8gmc': {
      'en': 'Done',
      'de': 'Erledigt',
      'es': 'Hecho',
      'fr': 'Fait',
      'pt': 'Feito',
    },
  },
  // shareQRCode
  {
    'e24qs45k': {
      'en': 'Share QR Code',
      'de': 'QR-Code teilen',
      'es': 'Compartir código QR',
      'fr': 'Partager le code QR',
      'pt': 'Compartilhar código QR',
    },
    'iebu9yur': {
      'en': 'Scan this code to connect',
      'de': 'Scannen Sie diesen Code, um eine Verbindung herzustellen',
      'es': 'Escanea este código para conectarte',
      'fr': 'Scannez ce code pour vous connecter',
      'pt': 'Escaneie este código para conectar',
    },
    '55ffv6b0': {
      'en': 'Share QR Code',
      'de': 'QR-Code teilen',
      'es': 'Compartir código QR',
      'fr': 'Partager le code QR',
      'pt': 'Compartilhar código QR',
    },
  },
  // reedeemCode
  {
    's1uomlvm': {
      'en': 'Redeem Code',
      'de': 'Code einlösen',
      'es': 'Canjear código',
      'fr': 'Utiliser le code',
      'pt': 'Resgatar código',
    },
    'nltifqqs': {
      'en': 'Enter your promo code to unlock rewards',
      'de': 'Geben Sie Ihren Promo-Code ein, um Prämien freizuschalten',
      'es': 'Introduce tu código promocional para desbloquear recompensas',
      'fr': 'Entrez votre code promotionnel pour débloquer des récompenses',
      'pt': 'Insira seu código promocional para desbloquear recompensas',
    },
    'rzb08l6k': {
      'en': 'Enter Code',
      'de': 'Code eingeben',
      'es': 'Introducir código',
      'fr': 'Entrez le code',
      'pt': 'Digite o código',
    },
    'ne7nv3wl': {
      'en': 'Redeem Now',
      'de': 'Jetzt einlösen',
      'es': 'Canjear ahora',
      'fr': 'Échangez maintenant',
      'pt': 'Resgatar agora',
    },
    'qw2otgy2': {
      'en': 'Codes are case-sensitive',
      'de': 'Bei Codes wird zwischen Groß- und Kleinschreibung unterschieden',
      'es': 'Los códigos distinguen entre mayúsculas y minúsculas',
      'fr': 'Les codes sont sensibles à la casse',
      'pt': 'Os códigos diferenciam maiúsculas de minúsculas',
    },
  },
  // addPaymentMethod
  {
    '31sjcapr': {
      'en': 'Add Payment Method',
      'de': 'Zahlungsmethode hinzufügen',
      'es': 'Agregar método de pago',
      'fr': 'Ajouter un mode de paiement',
      'pt': 'Adicionar método de pagamento',
    },
  },
  // componentLanguageXXX
  {
    'wngiyp5s': {
      'en': 'Language Settings',
      'de': 'Spracheinstellungen',
      'es': 'Configuración de idioma',
      'fr': 'Paramètres de langue',
      'pt': 'Configurações de idioma',
    },
    '9k5edv8a': {
      'en': 'Choose your preferred language',
      'de': 'Wählen Sie Ihre bevorzugte Sprache',
      'es': 'Elige tu idioma preferido',
      'fr': 'Choisissez votre langue préférée',
      'pt': 'Escolha seu idioma preferido',
    },
    '49244idk': {
      'en': 'English',
      'de': 'Englisch',
      'es': 'Inglés',
      'fr': 'Anglais',
      'pt': 'Inglês',
    },
    'wo2q5dnj': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'da2pnf2d': {
      'en': 'Portuguese',
      'de': 'Portugiesisch',
      'es': 'portugués',
      'fr': 'portugais',
      'pt': 'Português',
    },
    '9w76kfvx': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'rhc1hhh7': {
      'en': 'French',
      'de': 'Französisch',
      'es': 'Francés',
      'fr': 'Français',
      'pt': 'Francês',
    },
    'n3frkk2l': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'z3ko4cln': {
      'en': 'Spanish',
      'de': 'Spanisch',
      'es': 'Español',
      'fr': 'Espagnol',
      'pt': 'Espanhol',
    },
    'w69qofuk': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    '79tu4svk': {
      'en': 'German',
      'de': 'Deutsch',
      'es': 'Alemán',
      'fr': 'Allemand',
      'pt': 'Alemão',
    },
    'adoyxl61': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    '836ylazf': {
      'en': 'Confirm',
      'de': 'Bestätigen',
      'es': 'Confirmar',
      'fr': 'Confirmer',
      'pt': 'Confirmar',
    },
  },
  // componentAccessibility
  {
    'g78mxgxn': {
      'en': 'Accessibility Settings',
      'de': 'Eingabehilfen-Einstellungen',
      'es': 'Configuración de accesibilidad',
      'fr': 'Paramètres d\'accessibilité',
      'pt': 'Configurações de acessibilidade',
    },
    'n3bcuhfe': {
      'en': 'Low Stimulation Mode',
      'de': 'Modus mit geringer Stimulation',
      'es': 'Modo de baja estimulación',
      'fr': 'Mode de faible stimulation',
      'pt': 'Modo de baixa estimulação',
    },
    'xgi9yobg': {
      'en':
          'Reduce animations, flashing elements, and intense colors for a calmer experience.',
      'de':
          'Reduzieren Sie Animationen, blinkende Elemente und intensive Farben für ein ruhigeres Erlebnis.',
      'es':
          'Reduce las animaciones, los elementos parpadeantes y los colores intensos para una experiencia más tranquila.',
      'fr':
          'Réduisez les animations, les éléments clignotants et les couleurs intenses pour une expérience plus calme.',
      'pt':
          'Reduza animações, elementos piscantes e cores intensas para uma experiência mais tranquila.',
    },
    'adcixq9l': {
      'en': 'Street Names in Audio',
      'de': 'Straßennamen im Audio',
      'es': 'Nombres de calles en audio',
      'fr': 'Noms de rue en audio',
      'pt': 'Nomes de ruas em áudio',
    },
    'hcrz87yr': {
      'en':
          'Announce pickup and destination street names out loud for easier navigation.',
      'de':
          'Geben Sie die Straßennamen für Abholung und Ziel laut bekannt, um die Navigation zu erleichtern.',
      'es':
          'Anuncie en voz alta los nombres de las calles de recogida y destino para facilitar la navegación.',
      'fr':
          'Annoncez à voix haute les noms des rues de prise en charge et de destination pour faciliter la navigation.',
      'pt':
          'Anuncie em voz alta os nomes das ruas de embarque e desembarque para facilitar a navegação.',
    },
    '7ipthfmh': {
      'en': 'Haptic & Sound Feedback',
      'de': 'Haptisches und akustisches Feedback',
      'es': 'Retroalimentación háptica y sonora',
      'fr': 'Retour haptique et sonore',
      'pt': 'Feedback tátil e sonoro',
    },
    'gvv1b50c': {
      'en':
          'Provide vibration or sound alerts when confirming rides, driver arrival, or trip start.',
      'de':
          'Geben Sie Vibrations- oder Tonwarnungen aus, wenn Sie Fahrten, die Ankunft des Fahrers oder den Fahrtbeginn bestätigen.',
      'es':
          'Proporciona alertas de vibración o sonido al confirmar viajes, la llegada del conductor o el inicio del viaje.',
      'fr':
          'Fournit des alertes vibrantes ou sonores lors de la confirmation des courses, de l\'arrivée du chauffeur ou du début du voyage.',
      'pt':
          'Forneça alertas sonoros ou de vibração ao confirmar viagens, chegada do motorista ou início da viagem.',
    },
    'pm63xjdk': {
      'en': 'Request Ride by Voice',
      'de': 'Fahrt per Sprachbefehl anfordern',
      'es': 'Solicitar viaje por voz',
      'fr': 'Demander un trajet par la voix',
      'pt': 'Solicitar viagem por voz',
    },
    'hdtoo0vh': {
      'en':
          'Allows users to request a car by speaking their destination, without needing to type or use the map.',
      'de':
          'Ermöglicht Benutzern, ein Auto anzufordern, indem sie ihr Ziel aussprechen, ohne etwas eintippen oder die Karte verwenden zu müssen.',
      'es':
          'Permite a los usuarios solicitar un coche diciendo su destino, sin necesidad de escribir o utilizar el mapa.',
      'fr':
          'Permet aux utilisateurs de demander une voiture en indiquant leur destination, sans avoir besoin de taper ou d\'utiliser la carte.',
      'pt':
          'Permite que os usuários solicitem um carro falando seu destino, sem precisar digitar ou usar o mapa.',
    },
    '0vrkyi4m': {
      'en': 'Confirm',
      'de': 'Bestätigen',
      'es': 'Confirmar',
      'fr': 'Confirmer',
      'pt': 'Confirmar',
    },
  },
  // componentScheduleAction
  {
    '856t18lj': {
      'en': 'Pickup',
      'de': 'Abholen',
      'es': 'Levantar',
      'fr': 'Ramasser',
      'pt': 'Escolher',
    },
    'no2shcld': {
      'en': 'Dropoff',
      'de': 'Abgabe',
      'es': 'Dejar',
      'fr': 'Dépôt',
      'pt': 'Desistência',
    },
    'jamhybvq': {
      'en': 'Vehicle',
      'de': 'Fahrzeug',
      'es': 'Vehículo',
      'fr': 'Véhicule',
      'pt': 'Veículo',
    },
    '43r7ws5u': {
      'en': 'Ride',
      'de': 'Fahrt',
      'es': 'Conducir',
      'fr': 'Monter',
      'pt': 'Andar de',
    },
    '35k8wmyh': {
      'en': 'XL',
      'de': 'XL',
      'es': 'SG',
      'fr': 'XL',
      'pt': 'GG',
    },
    'pxgch01i': {
      'en': 'Luxury',
      'de': 'Luxus',
      'es': 'Lujo',
      'fr': 'Luxe',
      'pt': 'Luxo',
    },
    'iqml58mw': {
      'en': 'Repeat',
      'de': 'Wiederholen',
      'es': 'Repetir',
      'fr': 'Répéter',
      'pt': 'Repita',
    },
    'wpj5tgnr': {
      'en': 'One-time',
      'de': 'Einmalig',
      'es': 'Una sola vez',
      'fr': 'Une fois',
      'pt': 'Uma vez',
    },
    'quw1f8h7': {
      'en': 'Weekdays',
      'de': 'Wochentage',
      'es': 'Días laborables',
      'fr': 'Jours de la semaine',
      'pt': 'Dias da semana',
    },
    '7cei3svq': {
      'en': 'Custom',
      'de': 'Brauch',
      'es': 'Costumbre',
      'fr': 'Coutume',
      'pt': 'Personalizado',
    },
    '0mtvp1iq': {
      'en': 'Estimate',
      'de': 'Schätzen',
      'es': 'Estimar',
      'fr': 'Estimation',
      'pt': 'Estimativa',
    },
    'atbe9izh': {
      'en': '\$18 • pickup recalculated at trip time',
      'de': '18 \$ • Abholung zum Zeitpunkt der Fahrt neu berechnet',
      'es': '\$18 • la recogida se recalcula al momento del viaje',
      'fr': '18 \$ • prise en charge recalculée au moment du voyage',
      'pt': '\$ 18 • retirada recalculada no momento da viagem',
    },
    'v3644x1m': {
      'en': 'Notes (optional)',
      'de': 'Notizen (optional)',
      'es': 'Notas (opcional)',
      'fr': 'Remarques (facultatif)',
      'pt': 'Notas (opcional)',
    },
    'irm5g15g': {
      'en': 'Shedule ride',
      'de': 'Fahrplanfahrt',
      'es': 'Horario de viaje',
      'fr': 'Horaire du trajet',
      'pt': 'Passeio programado',
    },
    '49itxhbn': {
      'en': 'Schedule Ride Share',
      'de': 'Fahrgemeinschaft planen',
      'es': 'Programar viaje compartido',
      'fr': 'Planifier un covoiturage',
      'pt': 'Agendar Compartilhamento de Viagem',
    },
    'jqfg3zeg': {
      'en': 'Save to canlendar',
      'de': 'Im Kalender speichern',
      'es': 'Guardar en calendario',
      'fr': 'Enregistrer dans Canlendar',
      'pt': 'Salvar no canlendar',
    },
  },
  // erroAoCriarConta
  {
    '1bthb301': {
      'en': 'Error creating your account',
      'de': 'Fehler beim Erstellen Ihres Kontos',
      'es': 'Error al crear su cuenta',
      'fr': 'Erreur lors de la création de votre compte',
      'pt': 'Erro ao criar sua conta',
    },
    '4v5yohmn': {
      'en': 'An error occurred while creating your account, please try again.',
      'de':
          'Beim Erstellen Ihres Kontos ist ein Fehler aufgetreten. Bitte versuchen Sie es erneut.',
      'es':
          'Se produjo un error al crear su cuenta, por favor inténtelo nuevamente.',
      'fr':
          'Une erreur s\'est produite lors de la création de votre compte, veuillez réessayer.',
      'pt': 'Ocorreu um erro ao criar sua conta, tente novamente.',
    },
    'oy2qxef8': {
      'en': 'Try again',
      'de': 'Versuchen Sie es erneut',
      'es': 'Intentar otra vez',
      'fr': 'Essayer à nouveau',
      'pt': 'Tente novamente',
    },
  },
  // componentLanguage
  {
    'ktjluzpd': {
      'en': 'Language Settings',
      'de': 'Spracheinstellungen',
      'es': 'Configuración de idioma',
      'fr': 'Paramètres de langue',
      'pt': 'Configurações de idioma',
    },
    '8fc4xj3e': {
      'en': 'Choose your preferred language',
      'de': 'Wählen Sie Ihre bevorzugte Sprache',
      'es': 'Elige tu idioma preferido',
      'fr': 'Choisissez votre langue préférée',
      'pt': 'Escolha seu idioma preferido',
    },
    'p00lg82r': {
      'en': 'English',
      'de': 'Englisch',
      'es': 'Inglés',
      'fr': 'Anglais',
      'pt': 'Inglês',
    },
    'j99f4j2b': {
      'en': 'French',
      'de': 'Französisch',
      'es': 'Francés',
      'fr': 'Français',
      'pt': 'Francês',
    },
    '0w0l688r': {
      'en': 'German',
      'de': 'Deutsch',
      'es': 'Alemán',
      'fr': 'Allemand',
      'pt': 'Alemão',
    },
    '91lj3fd8': {
      'en': 'Portuguese',
      'de': 'Portugiesisch',
      'es': 'portugués',
      'fr': 'portugais',
      'pt': 'Português',
    },
    'ryu3fgou': {
      'en': 'Spanish',
      'de': 'Spanisch',
      'es': 'Español',
      'fr': 'Espagnol',
      'pt': 'Espanhol',
    },
    '8objo8t2': {
      'en': 'Confirm',
      'de': 'Bestätigen',
      'es': 'Confirmar',
      'fr': 'Confirmer',
      'pt': 'Confirmar',
    },
  },
  // whyCancelThisRide
  {
    'l88o43xh': {
      'en': 'Why do you want to cancel this ride?',
      'de': 'Warum möchten Sie diese Fahrt absagen?',
      'es': '¿Por qué quieres cancelar este viaje?',
      'fr': 'Pourquoi voulez-vous annuler ce trajet ?',
      'pt': 'Por que você quer cancelar esta viagem?',
    },
    'wewzqocc': {
      'en': 'I need to change destination',
      'de': 'Ich muss das Ziel ändern',
      'es': 'Necesito cambiar de destino',
      'fr': 'Je dois changer de destination',
      'pt': 'Preciso mudar de destino',
    },
    'uss7y04c': {
      'en': 'The driver isn’t moving',
      'de': 'Der Fahrer bewegt sich nicht',
      'es': 'El conductor no se mueve',
      'fr': 'Le conducteur ne bouge pas',
      'pt': 'O motorista não está se movendo',
    },
    'kpemoo7o': {
      'en': 'The driver asked me to cancel',
      'de': 'Der Fahrer hat mich gebeten, abzusagen',
      'es': 'El conductor me pidió que cancelara.',
      'fr': 'Le chauffeur m\'a demandé d\'annuler',
      'pt': 'O motorista me pediu para cancelar',
    },
    'q2ag5jvt': {
      'en': 'I can’t find the driver',
      'de': 'Ich kann den Treiber nicht finden',
      'es': 'No puedo encontrar el controlador',
      'fr': 'Je ne trouve pas le pilote',
      'pt': 'Não consigo encontrar o driver',
    },
    'qfd1pgf9': {
      'en': 'I no longer need this ride',
      'de': 'Ich brauche diese Fahrt nicht mehr',
      'es': 'Ya no necesito este viaje',
      'fr': 'Je n\'ai plus besoin de ce trajet',
      'pt': 'Eu não preciso mais desse passeio',
    },
    'biymab2t': {
      'en': 'Help Now',
      'de': 'Jetzt helfen',
      'es': 'Ayuda ahora',
      'fr': 'Aidez-moi maintenant',
      'pt': 'Ajuda agora',
    },
    '58sxiip3': {
      'en': 'Cancel Ride',
      'de': 'Fahrt abbrechen',
      'es': 'Cancelar viaje',
      'fr': 'Annuler le trajet',
      'pt': 'Cancelar viagem',
    },
  },
  // emailSupport
  {
    '9ffhhw22': {
      'en': 'Send your Message',
      'de': 'Senden Sie Ihre Nachricht',
      'es': 'Envía tu mensaje',
      'fr': 'Envoyez votre message',
      'pt': 'Envie sua mensagem',
    },
    '32ldxog8': {
      'en': 'Full name',
      'de': 'Vollständiger Name',
      'es': 'Nombre completo',
      'fr': 'Nom et prénom',
      'pt': 'Nome completo',
    },
    's8chekvp': {
      'en': 'Enter your full name',
      'de': 'Geben Sie Ihren vollständigen Namen ein',
      'es': 'Ingrese su nombre completo',
      'fr': 'Entrez votre nom complet',
      'pt': 'Digite seu nome completo',
    },
    'woz2p50q': {
      'en': 'Email',
      'de': 'E-Mail',
      'es': 'Correo electrónico',
      'fr': 'E-mail',
      'pt': 'E-mail',
    },
    'f0at0nuw': {
      'en': 'your@email.com',
      'de': 'Ihre@E-Mail-Adresse.com',
      'es': 'tu@correoelectrónico.com',
      'fr': 'votre@email.com',
      'pt': 'seu@email.com',
    },
    '0kit5lu4': {
      'en': 'Subject',
      'de': 'Thema',
      'es': 'Sujeto',
      'fr': 'Sujet',
      'pt': 'Assunto',
    },
    'g8z8zlv6': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    't22uy1h1': {
      'en': 'Select the subject',
      'de': 'Wählen Sie das Thema',
      'es': 'Seleccione el tema',
      'fr': 'Sélectionnez le sujet',
      'pt': 'Selecione o assunto',
    },
    '8viql6dn': {
      'en': 'Technical problems',
      'de': 'Technische Probleme',
      'es': 'Problemas técnicos',
      'fr': 'Problèmes techniques',
      'pt': 'Problemas técnicos',
    },
    'yycbigmu': {
      'en': 'Payment Issues & Refunds',
      'de': 'Zahlungsprobleme und Rückerstattungen',
      'es': 'Problemas de pago y reembolsos',
      'fr': 'Problèmes de paiement et remboursements',
      'pt': 'Problemas de pagamento e reembolsos',
    },
    '15lhfi9v': {
      'en': 'Complaint',
      'de': 'Beschwerde',
      'es': 'Queja',
      'fr': 'Plainte',
      'pt': 'Reclamação',
    },
    '4wiuitn4': {
      'en': 'Others',
      'de': 'Sonstige',
      'es': 'Otros',
      'fr': 'Autres',
      'pt': 'Outros',
    },
    'czbkso9k': {
      'en': 'Message',
      'de': 'Nachricht',
      'es': 'Mensaje',
      'fr': 'Message',
      'pt': 'Mensagem',
    },
    'vprspwx8': {
      'en': 'Please describe your request in detail...',
      'de': 'Bitte beschreiben Sie Ihr Anliegen detailliert...',
      'es': 'Por favor describa su solicitud en detalle...',
      'fr': 'Veuillez décrire votre demande en détail...',
      'pt': 'Por favor, descreva sua solicitação em detalhes...',
    },
    'uowrdv6x': {
      'en': 'Send Message',
      'de': 'Nachricht senden',
      'es': 'Enviar mensaje',
      'fr': 'Envoyer un message',
      'pt': 'Enviar mensagem',
    },
  },
  // emailsupportsuccess
  {
    'pj6fecz4': {
      'en': 'Email Sent Successfully!',
      'de': 'E-Mail erfolgreich gesendet!',
      'es': '¡Correo electrónico enviado exitosamente!',
      'fr': 'E-mail envoyé avec succès!',
      'pt': 'E-mail enviado com sucesso!',
    },
    'vyuy00n9': {
      'en':
          'Your support request has been submitted. Our team will review your message and respond within 24-48 hours.',
      'de':
          'Ihre Supportanfrage wurde übermittelt. Unser Team wird Ihre Nachricht prüfen und innerhalb von 24–48 Stunden antworten.',
      'es':
          'Su solicitud de asistencia ha sido enviada. Nuestro equipo revisará su mensaje y le responderá en un plazo de 24 a 48 horas.',
      'fr':
          'Votre demande d\'assistance a été envoyée. Notre équipe examinera votre message et vous répondra sous 24 à 48 heures.',
      'pt':
          'Sua solicitação de suporte foi enviada. Nossa equipe analisará sua mensagem e responderá em até 24 a 48 horas.',
    },
  },
  // addEmergencyContact
  {
    'mfwq3ofd': {
      'en': 'Add Emergency Contact',
      'de': 'Notfallkontakt hinzufügen',
      'es': 'Agregar contacto de emergencia',
      'fr': 'Ajouter un contact d\'urgence',
      'pt': 'Adicionar contato de emergência',
    },
    'atbj1o5h': {
      'en': 'Contact Name',
      'de': 'Kontaktname',
      'es': 'Nombre del contacto',
      'fr': 'Nom du contact',
      'pt': 'Nome do contato',
    },
    'mt8z25p9': {
      'en': 'Enter full name',
      'de': 'Geben Sie den vollständigen Namen ein',
      'es': 'Ingrese el nombre completo',
      'fr': 'Entrez le nom complet',
      'pt': 'Digite o nome completo',
    },
    'wgd10fwp': {
      'en': 'Phone Number',
      'de': 'Telefonnummer',
      'es': 'Número de teléfono',
      'fr': 'Numéro de téléphone',
      'pt': 'Número de telefone',
    },
    'd8795j49': {
      'en': 'Enter phone number',
      'de': 'Telefonnummer eingeben',
      'es': 'Introduzca el número de teléfono',
      'fr': 'Entrez le numéro de téléphone',
      'pt': 'Digite o número de telefone',
    },
    '0ahipprs': {
      'en': 'Relationship',
      'de': 'Beziehung',
      'es': 'Relación',
      'fr': 'Relation',
      'pt': 'Relação',
    },
    'hmhmwnnn': {
      'en': 'e.g., Spouse, Parent, Sibling',
      'de': 'z. B. Ehepartner, Elternteil, Geschwister',
      'es': 'p. ej., cónyuge, padre, hermano',
      'fr': 'par exemple, conjoint, parent, frère ou sœur',
      'pt': 'por exemplo, cônjuge, pai, irmão',
    },
    '3ekpfb1c': {
      'en': 'Cancel',
      'de': 'Stornieren',
      'es': 'Cancelar',
      'fr': 'Annuler',
      'pt': 'Cancelar',
    },
    'n8enip4b': {
      'en': 'Add Contact',
      'de': 'Kontakt hinzufügen',
      'es': 'Agregar contacto',
      'fr': 'Ajouter un contact',
      'pt': 'Adicionar contato',
    },
  },
  // componentScheduleActionCopy
  {
    'ij2hcwcb': {
      'en': 'Edit Upcoming Ride',
      'de': 'Nächste Fahrt bearbeiten',
      'es': 'Editar próximo viaje',
      'fr': 'Modifier la prochaine course',
      'pt': 'Editar próximo passeio',
    },
    'mpraj2et': {
      'en': 'Pickup',
      'de': 'Abholen',
      'es': 'Levantar',
      'fr': 'Ramasser',
      'pt': 'Escolher',
    },
    '88x37m4y': {
      'en': 'Dropoff',
      'de': 'Abgabe',
      'es': 'Dejar',
      'fr': 'Dépôt',
      'pt': 'Desistência',
    },
    'r84cwhyt': {
      'en': 'Date',
      'de': 'Datum',
      'es': 'Fecha',
      'fr': 'Date',
      'pt': 'Data',
    },
    'lwnsyshh': {
      'en': 'Vehicle',
      'de': 'Fahrzeug',
      'es': 'Vehículo',
      'fr': 'Véhicule',
      'pt': 'Veículo',
    },
    'jursmwli': {
      'en': 'Ride',
      'de': 'Fahrt',
      'es': 'Conducir',
      'fr': 'Monter',
      'pt': 'Andar de',
    },
    '8wmx2w3o': {
      'en': 'XL',
      'de': 'XL',
      'es': 'SG',
      'fr': 'XL',
      'pt': 'GG',
    },
    'ch4nhczz': {
      'en': 'Luxury',
      'de': 'Luxus',
      'es': 'Lujo',
      'fr': 'Luxe',
      'pt': 'Luxo',
    },
    'f2g4etm4': {
      'en': 'Repeat',
      'de': 'Wiederholen',
      'es': 'Repetir',
      'fr': 'Répéter',
      'pt': 'Repita',
    },
    'ty6cc6kz': {
      'en': 'One-time',
      'de': 'Einmalig',
      'es': 'Una sola vez',
      'fr': 'Une fois',
      'pt': 'Uma vez',
    },
    '2fxdirm3': {
      'en': 'Weekdays',
      'de': 'Wochentage',
      'es': 'Días laborables',
      'fr': 'Jours de la semaine',
      'pt': 'Dias da semana',
    },
    'vm1ojjhn': {
      'en': 'Custom',
      'de': 'Brauch',
      'es': 'Costumbre',
      'fr': 'Coutume',
      'pt': 'Personalizado',
    },
    'dpqktgjp': {
      'en': 'Notes (optional)',
      'de': 'Notizen (optional)',
      'es': 'Notas (opcional)',
      'fr': 'Remarques (facultatif)',
      'pt': 'Notas (opcional)',
    },
    '1i1fpgpm': {
      'en': 'Save edit',
      'de': 'Bearbeitung speichern',
      'es': 'Guardar edición',
      'fr': 'Enregistrer la modification',
      'pt': 'Salvar edição',
    },
  },
  // waystoearninformation
  {
    'petfkzmg': {
      'en': 'Ways to Earn',
      'de': 'Möglichkeiten zum Verdienen',
      'es': 'Formas de ganar dinero',
      'fr': 'Façons de gagner',
      'pt': 'Maneiras de ganhar',
    },
    'icuokifq': {
      'en': 'Daily Tasks',
      'de': 'Tägliche Aufgaben',
      'es': 'Tareas diarias',
      'fr': 'Tâches quotidiennes',
      'pt': 'Tarefas diárias',
    },
    '5fxi5gr2': {
      'en': 'Refer Friends',
      'de': 'Freunde werben',
      'es': 'Recomienda a tus amigos',
      'fr': 'Parrainer des amis',
      'pt': 'Indique amigos',
    },
    'bqj28oiz': {
      'en': 'Running races',
      'de': 'Laufrennen',
      'es': 'carreras de carrera',
      'fr': 'Courses à pied',
      'pt': 'Corridas de corrida',
    },
  },
  // saveCardPayment
  {
    '0pw9zd4r': {
      'en': 'Save Payment Method',
      'de': 'Zahlungsmethode',
      'es': 'Método de pago',
      'fr': 'Mode de paiement',
      'pt': 'Método de pagamento',
    },
    'yossibud': {
      'en': 'Choose your preferred payment option',
      'de': 'Wählen Sie Ihre bevorzugte Zahlungsoption',
      'es': 'Elige tu opción de pago preferida',
      'fr': 'Choisissez votre option de paiement préférée',
      'pt': 'Escolha sua opção de pagamento preferida',
    },
    '3hwrt0xn': {
      'en': 'Pay with Google Pay',
      'de': 'Bezahlen mit Google Pay',
      'es': 'Pagar con Google Pay',
      'fr': 'Payer avec Google Pay',
      'pt': 'Pague com o Google Pay',
    },
    'q3lwkya8': {
      'en': 'Pay with Apple Pay',
      'de': 'Bezahlen mit Apple Pay',
      'es': 'Pagar con Apple Pay',
      'fr': 'Payer avec Apple Pay',
      'pt': 'Pague com Apple Pay',
    },
    'sb1xr1ba': {
      'en': 'Credit Card Information',
      'de': 'Kreditkarteninformationen',
      'es': 'Información de la tarjeta de crédito',
      'fr': 'Informations sur la carte de crédit',
      'pt': 'Informações do cartão de crédito',
    },
    '88csuyfb': {
      'en': 'Save Credit Card',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
  },
  // emergency
  {
    'fapa7gav': {
      'en': 'I need urgent help',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    '3soe1qzm': {
      'en':
          'This action directly connects local emergency services to intervene in your ride. Do you really want to call emergency services? This action cannot be undone.',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'gu1xazdw': {
      'en': 'URGENT HELP',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'bnebvxl6': {
      'en': 'Contact 2',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'dqhd00jr': {
      'en': 'Contact 3',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    '6xk8jesh': {
      'en': 'Your location will be shared automatically',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
  },
  // raceemergency
  {
    '37s6p2xk': {
      'en': 'RACE EMERGENCY',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'anafttiw': {
      'en': 'Emergency Protocol Activated',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'bm7v5qrt': {
      'en':
          'Emergency activated, we are already assigning an emergency service to go to your location, please wait.',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
  },
  // avalieDriver
  {
    'mkh5oych': {
      'en': 'Toyota Blue',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'al7ekmzm': {
      'en': 'Ride #001',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    '557sqank': {
      'en': 'Time Riding',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    '9icojxgu': {
      'en': '\$ 18',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'g25nxnqw': {
      'en': '3 min',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'exy72zzt': {
      'en': 'Time Riding',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'p9tfo2x7': {
      'en': '3 min',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'ya73w5lw': {
      'en': 'How did your Drive do?',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'scfprqjh': {
      'en': 'Name',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'ie0e61gy': {
      'en': 'What stood out?',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'gmi7ob51': {
      'en': 'Clean car',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'ioih9jqd': {
      'en': 'Friendly',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    '9j99w98x': {
      'en': 'Safe driving',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'jah7vr1l': {
      'en': 'Good Comminication',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'i2h85vcy': {
      'en': 'Smells Good',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'tcpnsp6f': {
      'en': 'Smooth Route',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'gwpd29qj': {
      'en': 'Anything to improve (optional)',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'zgk6eyhm': {
      'en': 'Driving style',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    '8spra2qf': {
      'en': 'Communication',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'vx1lkyry': {
      'en': 'Navigation',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'ak8twhod': {
      'en': 'Car cleanliness',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    't61rh2ll': {
      'en': 'Punctuality',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'qdk7h7l4': {
      'en': 'Type text...',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    '55s0ll6t': {
      'en': 'Rate',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
  },
  // componentVerificaty
  {
    '2416a1zn': {
      'en': 'What we check',
      'de': 'Eingabehilfen-Einstellungen',
      'es': 'Configuración de accesibilidad',
      'fr': 'Paramètres d\'accessibilité',
      'pt': 'Configurações de acessibilidade',
    },
    '266c3t0l': {
      'en': 'SOS at the races',
      'de': 'Modus mit geringer Stimulation',
      'es': 'Modo de baja estimulación',
      'fr': 'Mode de faible stimulation',
      'pt': 'Modo de baixa estimulação',
    },
    'j5aumfcd': {
      'en':
          'In a risk situation, the app\'s SOS makes a direct call to the police.',
      'de':
          'Reduzieren Sie Animationen, blinkende Elemente und intensive Farben für ein ruhigeres Erlebnis.',
      'es':
          'Reduce las animaciones, los elementos parpadeantes y los colores intensos para una experiencia más tranquila.',
      'fr':
          'Réduisez les animations, les éléments clignotants et les couleurs intenses pour une expérience plus calme.',
      'pt':
          'Reduza animações, elementos piscantes e cores intensas para uma experiência mais tranquila.',
    },
    'ozwb39tx': {
      'en': 'Driving license',
      'de': 'Modus mit geringer Stimulation',
      'es': 'Modo de baja estimulación',
      'fr': 'Mode de faible stimulation',
      'pt': 'Modo de baixa estimulação',
    },
    'r3jmn6gm': {
      'en':
          'The document must be valid and meet our driving experience requirements',
      'de':
          'Reduzieren Sie Animationen, blinkende Elemente und intensive Farben für ein ruhigeres Erlebnis.',
      'es':
          'Reduce las animaciones, los elementos parpadeantes y los colores intensos para una experiencia más tranquila.',
      'fr':
          'Réduisez les animations, les éléments clignotants et les couleurs intenses pour une expérience plus calme.',
      'pt':
          'Reduza animações, elementos piscantes e cores intensas para uma experiência mais tranquila.',
    },
    '1zuzomrc': {
      'en': 'Photocontrol',
      'de': 'Modus mit geringer Stimulation',
      'es': 'Modo de baja estimulación',
      'fr': 'Mode de faible stimulation',
      'pt': 'Modo de baixa estimulação',
    },
    '33rt7naj': {
      'en':
          'The driver takes photos of himself and the vehicle regularly, starting with registration',
      'de':
          'Reduzieren Sie Animationen, blinkende Elemente und intensive Farben für ein ruhigeres Erlebnis.',
      'es':
          'Reduce las animaciones, los elementos parpadeantes y los colores intensos para una experiencia más tranquila.',
      'fr':
          'Réduisez les animations, les éléments clignotants et les couleurs intenses pour une expérience plus calme.',
      'pt':
          'Reduza animações, elementos piscantes e cores intensas para uma experiência mais tranquila.',
    },
    'ig71m6hc': {
      'en': 'Vehicle registration certificate',
      'de': 'Modus mit geringer Stimulation',
      'es': 'Modo de baja estimulación',
      'fr': 'Mode de faible stimulation',
      'pt': 'Modo de baixa estimulação',
    },
    'ayle8zoy': {
      'en': 'The vehicle must be owned by the driver and meet our standards',
      'de':
          'Reduzieren Sie Animationen, blinkende Elemente und intensive Farben für ein ruhigeres Erlebnis.',
      'es':
          'Reduce las animaciones, los elementos parpadeantes y los colores intensos para una experiencia más tranquila.',
      'fr':
          'Réduisez les animations, les éléments clignotants et les couleurs intenses pour une expérience plus calme.',
      'pt':
          'Reduza animações, elementos piscantes e cores intensas para uma experiência mais tranquila.',
    },
    'q41kws8q': {
      'en': 'Identity',
      'de': 'Modus mit geringer Stimulation',
      'es': 'Modo de baja estimulación',
      'fr': 'Mode de faible stimulation',
      'pt': 'Modo de baixa estimulação',
    },
    '8npfmdxw': {
      'en':
          'The driver must present personal documents to confirm his identity',
      'de':
          'Reduzieren Sie Animationen, blinkende Elemente und intensive Farben für ein ruhigeres Erlebnis.',
      'es':
          'Reduce las animaciones, los elementos parpadeantes y los colores intensos para una experiencia más tranquila.',
      'fr':
          'Réduisez les animations, les éléments clignotants et les couleurs intenses pour une expérience plus calme.',
      'pt':
          'Reduza animações, elementos piscantes e cores intensas para uma experiência mais tranquila.',
    },
  },
  // tipDriver
  {
    'cl3iadp6': {
      'en': 'Send Tip',
      'de': 'Zahlungsmethode',
      'es': 'Método de pago',
      'fr': 'Mode de paiement',
      'pt': 'Método de pagamento',
    },
    'czjjroaf': {
      'en': 'Choose the tip amount and send it to the driver.',
      'de': 'Wählen Sie Ihre bevorzugte Zahlungsoption',
      'es': 'Elige tu opción de pago preferida',
      'fr': 'Choisissez votre option de paiement préférée',
      'pt': 'Escolha sua opção de pagamento preferida',
    },
    'kiicqhnl': {
      'en': '\$1',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'zw64bkt5': {
      'en': '\$2',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'yhlsmyka': {
      'en': '\$3',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'io5dv5lt': {
      'en': '\$4',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'b6celvnh': {
      'en': '\$5',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    '7xf6nb9w': {
      'en': '\$1',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'tq8jv7eh': {
      'en': 'Payment Method',
      'de': 'Kreditkarteninformationen',
      'es': 'Información de la tarjeta de crédito',
      'fr': 'Informations sur la carte de crédit',
      'pt': 'Informações do cartão de crédito',
    },
    'lfbv2i6u': {
      'en': 'This Default ',
      'de': 'Dieser Standard',
      'es': 'Este valor predeterminado',
      'fr': 'Ce défaut',
      'pt': 'Este padrão',
    },
    'a0bzzeke': {
      'en': 'Confirm',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
  },
  // schedulePickuUp
  {
    'w0u7bqkr': {
      'en': 'Schedule Pickup',
      'de': 'Nächste Fahrt bearbeiten',
      'es': 'Editar próximo viaje',
      'fr': 'Modifier la prochaine course',
      'pt': 'Editar próximo passeio',
    },
    '4fvoeal1': {
      'en': 'Pickup',
      'de': 'Abholen',
      'es': 'Levantar',
      'fr': 'Ramasser',
      'pt': 'Escolher',
    },
    'wcdbs5fg': {
      'en': 'Dropoff',
      'de': 'Abgabe',
      'es': 'Dejar',
      'fr': 'Dépôt',
      'pt': 'Desistência',
    },
    'q68ukv21': {
      'en': 'Date',
      'de': 'Datum',
      'es': 'Fecha',
      'fr': 'Date',
      'pt': 'Data',
    },
    '3usdhe18': {
      'en': 'Vehicle',
      'de': 'Fahrzeug',
      'es': 'Vehículo',
      'fr': 'Véhicule',
      'pt': 'Veículo',
    },
    'fcwq3ubh': {
      'en': 'Ride',
      'de': 'Fahrt',
      'es': 'Conducir',
      'fr': 'Monter',
      'pt': 'Andar de',
    },
    'i2h37o56': {
      'en': 'XL',
      'de': 'XL',
      'es': 'SG',
      'fr': 'XL',
      'pt': 'GG',
    },
    'bty2m5u3': {
      'en': 'Luxury',
      'de': 'Luxus',
      'es': 'Lujo',
      'fr': 'Luxe',
      'pt': 'Luxo',
    },
    'yhw91pyp': {
      'en': 'Repeat',
      'de': 'Wiederholen',
      'es': 'Repetir',
      'fr': 'Répéter',
      'pt': 'Repita',
    },
    'h4d3uj9f': {
      'en': 'One-time',
      'de': 'Einmalig',
      'es': 'Una sola vez',
      'fr': 'Une fois',
      'pt': 'Uma vez',
    },
    'simj912b': {
      'en': 'Weekdays',
      'de': 'Wochentage',
      'es': 'Días laborables',
      'fr': 'Jours de la semaine',
      'pt': 'Dias da semana',
    },
    'uuf6olc6': {
      'en': 'Custom',
      'de': 'Brauch',
      'es': 'Costumbre',
      'fr': 'Coutume',
      'pt': 'Personalizado',
    },
    '3myclplm': {
      'en': 'Notes (optional)',
      'de': 'Notizen (optional)',
      'es': 'Notas (opcional)',
      'fr': 'Remarques (facultatif)',
      'pt': 'Notas (opcional)',
    },
    '9en68510': {
      'en': 'Schedule',
      'de': 'Bearbeitung speichern',
      'es': 'Guardar edición',
      'fr': 'Enregistrer la modification',
      'pt': 'Salvar edição',
    },
  },
  // Miscellaneous
  {
    'x1jd4989': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'hgyc3qt5': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'fn6u0l09': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'hcgqmwhh': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt':
          'Precisamos da sua localização para mostrar corridas e estimativas em tempo real enquanto você usa o app.',
    },
    'o6i79v6p': {
      'en': 'Add mycrofiome',
      'de': 'Mycrofiome hinzufügen',
      'es': 'Añadir microfioma',
      'fr': 'Ajouter du mycrofiome',
      'pt': 'Adicionar microfioma',
    },
    'mx2j0fjc': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'h56u74wk': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'pkbgkny7': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    't5wbxhnw': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    '5dlblchh': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'xxjsfnbz': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'tao4069v': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    '9qxdx02w': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'llksifxg': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'fkrhwt18': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'v2ioqb92': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'foveq4qi': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'zfqc5v89': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    '9pykic1c': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'xmf7v8u1': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'oqecg83i': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'dn7e3ryr': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'k2qdlhr0': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    '9u0w1vxl': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'mzh9vnqn': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'f2orz5dy': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    '2192wmnx': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    'w40rq6vy': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    '9umw37rd': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
    '5clo0oaf': {
      'en': '',
      'de': '',
      'es': '',
      'fr': '',
      'pt': '',
    },
  },
].reduce((a, b) => a..addAll(b));
