import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const kBearerToken = 'kBearerToken';
const kRememberMe = "kRememberMe";
const kIsFacebookLogin = 'kIsFacebookLogin';
const kIsGmailLogin = 'kIsGmailLogin';
const kUserName = "kUserName";
const kUserImage = "kUserImage";
const kUserEmail = "kUserEmail";
const kUserId = "kUserId";
const kUserFirstName = "kUserFirstName";
const kUserLastName = "kUserLastName";
const kRecentSearchList = "kRecentSearchList";
const kUserList = "kUserList";

class SpController {
  //* save Bearer Token
  Future<void> saveBearerToken(token) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(kBearerToken, token.toString());
  }

  Future<String?> getBearerToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(kBearerToken);
  }

  //* save user list
  Future<void> saveUserList(userInfo) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List userList = await getUserList();
    for (int i = 0; i < userList.length; i++) {
      if (userList[i]['email'] == userInfo['email']) {
        userList.removeAt(i);
        break;
      }
    }
    userList.add(userInfo);
    String encodeData = json.encode(userList);
    await preferences.setString(kUserList, encodeData);
  }

  Future<dynamic> getUserList() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? data = preferences.getString(kUserList);
    List userList = (data == null) ? [] : json.decode(data);
    return userList;
  }

  Future<dynamic> getUserData(token) async {
    List userList = await getUserList();
    for (int i = 0; i < userList.length; i++) {
      if (userList[i]['token'] == token) {
        return userList[i];
      }
    }
    return null;
  }

  Future<void> removeUser(userInfo) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? data = preferences.getString(kUserList);
    List userList = (data == null) ? [] : json.decode(data);
    for (int i = 0; i < userList.length; i++) {
      if (userList[i]['email'] == userInfo['email']) {
        userList.removeAt(i);
        String encodeData = json.encode(userList);
        await preferences.setString(kUserList, encodeData);
        break;
      }
    }
  }

  //* Remember me status
  Future<void> saveRememberMe(value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool(kRememberMe, value);
  }

  Future<bool?> getRememberMe() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool(kRememberMe);
  }

  Future<void> saveIsFacebookLogin(value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool(kIsFacebookLogin, value);
  }

  Future<bool?> getIsFacebookLogin() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool(kIsFacebookLogin);
  }

  Future<void> saveIsGmailLogin(value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool(kIsGmailLogin, value);
  }

  Future<bool?> getIsGmailLogin() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool(kIsGmailLogin);
  }

  //* save user name
  Future<void> saveUserName(name) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(kUserName, name.toString());
  }

  Future<String?> getUserName() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(kUserName);
  }

  //* save user name
  Future<void> saveUserFirstName(name) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(kUserFirstName, name.toString());
  }

  Future<String?> getUserFirstName() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(kUserFirstName);
  }

  //* save user name
  Future<void> saveUserLastName(name) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(kUserLastName, name.toString());
  }

  Future<String?> getUserLastName() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(kUserLastName);
  }

  //* save user Image
  Future<void> saveUserImage(imageUrl) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(kUserImage, imageUrl.toString());
  }

  Future<String?> getUserImage() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(kUserImage);
  }

  //* save user email
  Future<void> saveUserEmail(email) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(kUserEmail, email.toString());
  }

  Future<String?> getUserEmail() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(kUserEmail);
  }

    //* save user email
  Future<void> saveUserId(id) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setInt(kUserId, id);
  }

  Future<int?> getUserId() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getInt(kUserId);
  }

  //* recent  search list
  Future<void> saveRecentSearchList(recentSearchList) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var data = recentSearchList;
    String encodeData = json.encode(data);
    await preferences.setString(kRecentSearchList, encodeData);
  }

  Future<dynamic> getRecentSearchList() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? data = preferences.getString(kRecentSearchList);
    var recentSearchList = (data == null) ? [] : json.decode(data);
    return recentSearchList;
  }

  //* on logout
  Future<void> onLogout() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove(kBearerToken);
    await preferences.remove(kRememberMe);
    await preferences.remove(kUserName);
    await preferences.remove(kUserImage);
    await preferences.remove(kUserEmail);
    await preferences.remove(kUserFirstName);
    await preferences.remove(kUserLastName);
    await preferences.remove(kIsFacebookLogin);
    await preferences.remove(kIsGmailLogin);
  }
}
