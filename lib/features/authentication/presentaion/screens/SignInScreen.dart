import 'dart:developer';

import 'package:flutter/material.dart';
import '../../../../common/constants/MyColors.dart';
import '../widgets/form.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final TextEditingController _rePwdController = TextEditingController();

  bool checked = false;

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      log("succes\n email: ${_emailController.text}, pwd: ${_pwdController.text}");
    }else{
      Navigator.pushNamedAndRemoveUntil(context, "/lobby",(Route<dynamic> route) => false );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.3,
                width: MediaQuery.of(context).size.width * 0.7,
                child: Image.asset(
                  "assets/logos/image.png",
                  color: MyColors.primeryColor,
                ),
              ),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Container(
                        height: MediaQuery.of(context).size.height * 0.8,
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: fromSignIn(
                            context,
                            _nameController,
                            _lastNameController,
                            _emailController,
                            _pwdController,
                            _rePwdController,
                            _login,
                            'Sign In')),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  
}
