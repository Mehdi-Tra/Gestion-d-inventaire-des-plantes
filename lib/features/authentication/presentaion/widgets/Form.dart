import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:rakcha/common/constants/Admin.dart';

import '../../../../common/widgets/Buttons.dart';
import '../../../../common/widgets/Fields.dart';
import 'RemebmerMe.dart';

Widget fromAuth(context,emailController, pwdController, login, text) {
  return Column(
    children: [
      TextFeildDynamic(
        label: "N°employer",
        textEditingController: emailController,
        validator:(value) {
          if(value!.isEmpty){
            return "must not be null";
          }
          if(value != Admin.identifiant){
            return "identifiant inccorect";
          }
          return null;
        },
      ),
      const SizedBox(height: 8),
      TextFeildDynamic(
        label: "password",
        textEditingController: pwdController,
        validator:(value) {
          if(value!.isEmpty){
            return "must not be null";
          }
          if(value != Admin.password){
            return "password inccorect";
          }
          return null;
        },
      ),
      const SizedBox(height: 12),
      remeberMe_forgetpwd(context),
      const SizedBox(height: 12),
      submitButton(login, text),
      const SizedBox(height: 24),
      // createNewAccountText(context)
    ],
  );
}

// remember me option



Widget remeberMe_forgetpwd(context) {
  return Row(
    mainAxisSize: MainAxisSize.max,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [const RememberMe()],
  );
}

Widget forgetPwd(context) {
  return TextButton(
      onPressed: () {
        log('password');
      },
      child: Text(
        'Forget Password',
        style: Theme.of(context).textTheme.bodyLarge,
      ));
}

Widget createNewAccountText(context) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text("Dont have an account?",
          style: Theme.of(context).textTheme.bodyMedium),
      TextButton(
        onPressed: () {
          log('new account');
          Navigator.pushReplacementNamed(context, '/signIn');
        },
        child: Text('Create one',
            style: Theme.of(context).textTheme.bodyLarge),
      ),
    ],
  );
}

// sign in

Widget fromSignIn(context, nameController, lastNameController, emailController,
    pwdController, rePwdController, login, text) {
  return Column(
    children: [
      TextFeildDynamic(
        label: "Name",
        textEditingController: nameController,
      ),
      const SizedBox(height: 8),
      TextFeildDynamic(
        label: "Last Name",
        textEditingController: lastNameController,
      ),
      const SizedBox(height: 8),
      TextFeildDynamic(
        label: "N°employer",
        textEditingController: emailController,
      ),
      const SizedBox(height: 8),
      TextFeildDynamic(
        label: "password",
        textEditingController: pwdController,
      ),
      const SizedBox(height: 8),
      TextFeildDynamic(
        label: "confirmer password",
        textEditingController: rePwdController,
      ),
      const SizedBox(height: 32),
      submitButton(login, text),
      const SizedBox(height: 12),
      haveAnAccountText(context)
    ],
  );
}

Widget haveAnAccountText(context) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text("You have an account?",
          style: Theme.of(context).textTheme.bodyMedium),
      TextButton(
        onPressed: () {
          log('new account');
          Navigator.pushReplacementNamed(context, '/login');
        },
        child:
             Text('LogIn', style: Theme.of(context).textTheme.bodyLarge),
      ),
    ],
  );
}
