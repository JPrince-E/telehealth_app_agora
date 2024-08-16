import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:telehealth_app/app/helpers/sharedprefs.dart';
import 'package:telehealth_app/app/resources/app.logger.dart';
import 'package:telehealth_app/ui/features/create_account/create_account_model/user_model.dart';
import 'package:telehealth_app/ui/shared/global_variables.dart';

final log = getLogger('CreateUserController');

class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final roleController = TextEditingController();

  var isSignUp = false.obs;
  var errMessage = ''.obs;
  var showLoading = false.obs;
  var imageFile = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    log.d('Checking if user is logged in...');

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await _checkSavedUser(Get.context);

        final ref = FirebaseDatabase.instance.ref();
        final username = GlobalVariables.myUsername;
        final snapshot = await ref.child('users/$username').get();

        if (snapshot.exists) {
          log.d("User exists: ${snapshot.value}");
          final userData = UserModel.fromJson(jsonDecode(jsonEncode(snapshot.value)));

          if (userData.password == GlobalVariables.myPassword.trim()) {
            showLoading.value = false;
            log.d("GlobalVariables Username: ${GlobalVariables.myUsername}");
            await saveSharedPrefsStringValue("myUsername", GlobalVariables.myUsername.trim());
            await saveSharedPrefsStringValue("myPassword", userData.password!.trim());
            await saveSharedPrefsStringValue("myRole", userData.role!.trim());
            if (Get.context != null) {
              gotoHomepage(Get.context!);
            }
          } else {
            log.d('Password does not match.');
            errMessage.value = "Error! Username or password incorrect";
            showLoading.value = false;
          }
        } else {
          log.d('User data does not exist.');
          errMessage.value = "Error! User ${GlobalVariables.myUsername} not found";
          showLoading.value = false;
        }
      } catch (e) {
        log.e("Error in onInit: $e");
      }
    });
  }


  Future<void> _checkSavedUser(BuildContext? context) async {
    final ref = FirebaseDatabase.instance.ref();
    final savedUsername = await getSharedPrefsSavedString("myUsername");
    final savedPassword = await getSharedPrefsSavedString("myPassword");
    final savedRole = await getSharedPrefsSavedString("myRole");

    if (savedUsername.isNotEmpty && savedPassword.isNotEmpty) {
      GlobalVariables.myUsername = savedUsername;
      GlobalVariables.myPassword = savedPassword;
      GlobalVariables.myRole = savedRole;
      log.d("User already signed in: $savedUsername");
      log.d("User already signed in: $savedPassword");
      log.d("User already signed in: $savedRole");

      final snapshot = await ref.child('users/$savedUsername').get();

      if (snapshot.exists) {
        final userData = UserModel.fromJson(jsonDecode(jsonEncode(snapshot.value)));

        if (userData.password == savedPassword) {
          Future.delayed(Duration.zero, () {
            if (context != null) {
              gotoHomepage(context);
            }
          });
        } else {
          log.d("Saved user data does not match. Clearing saved credentials.");
          await saveSharedPrefsStringValue("myUsername", '');
          await saveSharedPrefsStringValue("myPassword", '');
          // await saveSharedPrefsStringValue("myRole", '');
        }
      }
    }
  }


  void toggleSignUpSignIn() {
    isSignUp.value = !isSignUp.value;
  }

  void resetValues() {
    errMessage.value = '';
    showLoading.value = false;
  }

  void gotoSignInUserPage(BuildContext context) {
    log.d('Going to sign in user page');
    resetValues();
    context.push('/signInView');
  }

  void gotoHomepage(BuildContext context) {
    log.d('Going to home screen');
    resetValues();
    context.go('/homeScreen');
  }

  void attemptToSignInUser(BuildContext context) {
    log.d('Attempting to sign in user...');
    errMessage.value = '';

    String username;

    if (GlobalVariables.myUsername.isNotEmpty) {
      username = GlobalVariables.myUsername;
      signInUser(context);
    } else {
      username = usernameController.text.trim();
    }

    final password = passwordController.text.trim();

    if(GlobalVariables.myPassword.isNotEmpty){
      log.d('User is logged in...');
      showLoading.value = true;
      errMessage.value = '';
      signInUser(context);
    }

    if (_validateCredentials(username, password)) {
      log.d('Signing in user...');
      showLoading.value = true;
      errMessage.value = '';
      signInUser(context);
    } else {
      errMessage.value = 'All fields must be filled, and with no spaces';
      log.d("Error message: $errMessage");
      showLoading.value = false;
    }
  }

  bool _validateCredentials(String username, String password) {
    return username.isNotEmpty && !username.contains(' ') &&
        password.isNotEmpty && !password.contains(' ');
  }

  void _handleError(String message) {
    log.d(message);
    errMessage.value = "Error! $message";
    showLoading.value = false;
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
        source: source, maxWidth: 1800, maxHeight: 1800);
    if (pickedFile != null) {
      imageFile.value = File(pickedFile.path);
    }
  }

  Future<void> signInUser(BuildContext context) async {
    log.d('Checking if user exists...');
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('users/${usernameController.text.trim()}')
        .get();

    if (snapshot.exists) {
      log.d("User exists: ${snapshot.value}");
      final userData = UserModel.fromJson(
          jsonDecode(jsonEncode(snapshot.value)));


      if (userData.password == passwordController.text.trim()) {
        showLoading.value = false;
        GlobalVariables.myUsername = usernameController.text.trim();
        GlobalVariables.myFullName = userData.fullName ?? '';
        GlobalVariables.myRole = userData.role ?? 'patient'; // Add this line
        log.d("GlobalVariables Username: ${GlobalVariables.myUsername}");
        await saveSharedPrefsStringValue(
            "myUsername", usernameController.text.trim());
        await saveSharedPrefsStringValue(
            "myPassword", passwordController.text.trim());
        await saveSharedPrefsStringValue(
            "myRole", userData.role ?? 'patient');
        gotoHomepage(context);
      } else {
        log.d('Password does not match.');

        await saveSharedPrefsStringValue(
            "myUsername", usernameController.text.trim());
        await saveSharedPrefsStringValue(
            "myRole", userData.role ?? 'patient');
        errMessage.value = "Error! Username or password incorrect";
        showLoading.value = false;
      }
    } else {
      log.d('User data does not exist.');
      errMessage.value =
      "Error! User ${usernameController.text.trim()} not found";
      showLoading.value = false;
    }
  }

  Future<void> signUpUser(BuildContext context) async {
    log.d('Attempting to sign up user...');

    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      errMessage.value = 'All fields must be filled out.';
      log.d('Error: $errMessage');
      return;
    }

    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('users/$username').get();

    if (snapshot.exists) {
      errMessage.value = 'User $username already exists.';
      log.d('Error: ${errMessage.value}');
      return;
    }

    final newUser = UserModel(
      username: username,
      password: password,
      role: 'patient', // Default role to patient
    );

    await ref.child('users/$username').set(newUser.toJson());
    log.d('User $username successfully signed up.');

    attemptToSignInUser(context);
  }
}