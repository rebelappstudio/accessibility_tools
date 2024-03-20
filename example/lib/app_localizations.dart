import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String get greetings {
    switch (locale.languageCode.toLowerCase()) {
      case 'fi':
        return 'Moi! Tervetuloa kauppaamme!';
      case 'en':
      default:
        return 'Hello! Welcome to our shop!';
    }
  }

  String get secondPage {
    switch (locale.languageCode.toLowerCase()) {
      case 'fi':
        return 'Toinen sivu';
      case 'en':
      default:
        return 'Other page';
    }
  }

  String get shopName {
    switch (locale.languageCode.toLowerCase()) {
      case 'fi':
        return 'Ruokakauppa';
      case 'en':
      default:
        return 'Grocery store';
    }
  }

  String get email {
    switch (locale.languageCode.toLowerCase()) {
      case 'fi':
        return 'Sähköposti:';
      case 'en':
      default:
        return 'Email:';
    }
  }

  String get password {
    return switch (locale.languageCode.toLowerCase()) {
      'fi' => 'Salasana:',
      _ => 'Password:'
    };
  }

  String get productNameCucumber {
    return switch (locale.languageCode.toLowerCase()) {
      "fi" => 'Kurkku',
      _ => 'Cucumber'
    };
  }

  String get productNameTomato {
    return switch (locale.languageCode.toLowerCase()) {
      "fi" => 'Tomaatti',
      _ => 'Tomato'
    };
  }

  String get productNameApple {
    return switch (locale.languageCode.toLowerCase()) {
      "fi" => 'Omena',
      _ => 'Apple'
    };
  }

  String get productNameBanana {
    return switch (locale.languageCode.toLowerCase()) {
      "fi" => 'Banaani',
      _ => 'Banana'
    };
  }

  String get productNamePineapple {
    return switch (locale.languageCode.toLowerCase()) {
      "fi" => 'Ananas',
      _ => 'Pineapple'
    };
  }

  String get productNameOrange {
    return switch (locale.languageCode.toLowerCase()) {
      "fi" => 'Appelsiini',
      _ => 'Orange'
    };
  }

  String get productNameGrapes {
    return switch (locale.languageCode.toLowerCase()) {
      "fi" => 'Viinirypäleet',
      _ => 'Grapes'
    };
  }

  String get productNameWatermelon {
    return switch (locale.languageCode.toLowerCase()) {
      "fi" => 'Vesimeloni',
      _ => 'Watermelon'
    };
  }

  String get productNameStrawberry {
    return switch (locale.languageCode.toLowerCase()) {
      "fi" => 'Mansikka',
      _ => 'Strawberry'
    };
  }

  String get productNameMango {
    return switch (locale.languageCode.toLowerCase()) {
      "fi" => 'Mango',
      _ => 'Mango'
    };
  }

  String get productNamePeach {
    return switch (locale.languageCode.toLowerCase()) {
      "fi" => 'Persikka',
      _ => 'Peach'
    };
  }

  String get productNamePear {
    return switch (locale.languageCode.toLowerCase()) {
      "fi" => 'Päärynä',
      _ => 'Pear'
    };
  }

  String get productNameLemon {
    return switch (locale.languageCode.toLowerCase()) {
      "fi" => 'Sitruuna',
      _ => 'Lemon'
    };
  }

  String get productNameBlueberry {
    return switch (locale.languageCode.toLowerCase()) {
      "fi" => 'Mustikka',
      _ => 'Blueberry'
    };
  }

  String get productNameRaspberry {
    return switch (locale.languageCode.toLowerCase()) {
      "fi" => 'Vadelma',
      _ => 'Raspberry'
    };
  }

  String get signInTitle {
    return switch (locale.languageCode.toLowerCase()) {
      'fi' => 'Kirjaudu sisään',
      _ => 'Sign in to see your previous purchases',
    };
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalizations> {
  @override
  bool isSupported(Locale locale) =>
      ['fi', 'en'].contains(locale.languageCode.toLowerCase());

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
