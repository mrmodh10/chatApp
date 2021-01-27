

import 'package:shared_preferences/shared_preferences.dart';

Future<String> getCurrentUserName() async{
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getString('name');
}

Future<String> getCurrentUserImage() async{
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getString('userImage');
}