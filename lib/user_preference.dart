import 'dart:convert';
import 'dart:io';

class UserPreference {
  static final _instance = UserPreference._();

  factory UserPreference() {
    return _instance;
  }

  UserPreference._() {
    final dir = Directory('./user');
    final file = File('./user/preference.json');

    if (!dir.existsSync()) {
      dir.createSync();
    }

    if (file.existsSync()) {
      if (file.readAsStringSync() == '') {
        save();
      }

      read();
    } else {
      File('./user/preference.json').createSync();
    }
  }

  String _darkMode = 'System Default';
  String get darkMode => _darkMode;
  set darkMode(String value) {
    _darkMode = value;
    save();
  }

  String _theme = 'System';
  String get theme => _theme;
  set theme(String value) {
    _theme = value;
    save();
  }

  String _sort = 'A-Z';
  String get sort => _sort;
  set sort(String value) {
    _sort = value;
    save();
  }

  Map<String, bool?> _filter = {
    'Completed': false,
    'Unread': false,
    'Downloaded': false,
    'Started': false,
  };
  Map<String, bool?> get filter => _filter;
  set filter(Map<String, bool?> value) {
    _filter = value;
    save();
  }

  bool _updateLibraryOnStart = true;
  bool get updateLibraryOnStart => _updateLibraryOnStart;
  set updateLibraryOnStart(bool value) {
    _updateLibraryOnStart = value;
    save();
  }

  Map<String, dynamic> toJson() => {
        'sort': _sort,
        'filter': _filter,
        'darkMode': _darkMode,
        'theme': _theme,
      };

  void init() {
    UserPreference();
  }

  void save() {
    File('./user/preference.json').writeAsStringSync(jsonEncode(toJson()));
  }

  void read() {
    try {
      final json = jsonDecode(File('./user/preference.json').readAsStringSync())
          as Map<String, dynamic>;
      _filter['Completed'] = json['filter']['Completed'];
      _filter['Unread'] = json['filter']['Unread'];
      _filter['Downloaded'] = json['filter']['Downloaded'];
      _filter['Started'] = json['filter']['Started'];
      _sort = json['sort'];
      _darkMode = json['darkMode'];
      _theme = json['theme'];
    } catch (e) {
      save();
      read();
    }
  }
}
