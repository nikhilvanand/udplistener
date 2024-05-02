import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static const _ucpIncomePortKey = 'incomePort';
  static const _udpOutcomePortKey = 'outcomePort';
  static const _tcpServerKey = 'tcpServerKey';
  static const _tcpPortKey = 'tcpPortKey'; //_sendMsgKey
  static const _sendMsgKey = 'msgKey'; //
  static const _themeKey = 'thememode';
  static late final SharedPreferences _sharedPrefs;
  factory SharedPrefs() => SharedPrefs._internal();

  SharedPrefs._internal();
  static Future<void> init() async {
    _sharedPrefs = await SharedPreferences.getInstance();
  }

  String get incomePort => _sharedPrefs.getString(_ucpIncomePortKey) ?? "8889";
  set incomePort(String value) {
    _sharedPrefs.setString(_ucpIncomePortKey, value);
  }

  String get outcomePort =>
      _sharedPrefs.getString(_udpOutcomePortKey) ?? "8890";
  set outcomePort(String value) {
    _sharedPrefs.setString(_udpOutcomePortKey, value);
  }

  String get tcpServerIp => _sharedPrefs.getString(_tcpServerKey) ?? "8889";
  set tcpServerIp(String value) {
    _sharedPrefs.setString(_tcpServerKey, value);
  }

  String get tcpPort => _sharedPrefs.getString(_tcpPortKey) ?? "8890";
  set tcpPort(String value) {
    _sharedPrefs.setString(_tcpPortKey, value);
  }

  String get sendMsg => _sharedPrefs.getString(_sendMsgKey) ?? "{data:8890}";
  set sendMsg(String value) {
    _sharedPrefs.setString(_sendMsgKey, value);
  }

  bool get themeMode => _sharedPrefs.getBool(_themeKey) ?? false;
  set themeMode(bool value) {
    _sharedPrefs.setBool(_themeKey, value);
  }

  removeValues() {
    //can use _sharedPrefs.clear(); for clearing shared preferences altogether
    _sharedPrefs.remove(_ucpIncomePortKey);
  }
}
