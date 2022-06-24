import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import './forgot_password.dart';
import '../animation/fadeanimation.dart';
import '../cust_functions/cust_fuction.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback showSignUpScreen;
  const LoginScreen({Key? key, required this.showSignUpScreen})
      : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /////////////////////////////////////
  //@CodeWithFlexz on Instagram
  //
  //AmirBayat0 on Github
  //Programming with Flexz on Youtube
  /////////////////////////////////////
  /// TextFields Controller
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  FocusNode nodeOne = FocusNode();
  FocusNode nodeTwo = FocusNode();

  /// Email & Password Empty
  // var fSnackBar = const SnackBar(
  //   content: Text('The Email & Password fields are empty!!!'),
  // );

  var fSnackBar = Func.snackBar_func(
      '${"The Email & Password fields are empty. \n Please entet a valid Email & Password"}');

  /// Email Fill & Password Empty
  var sSnackBar = Func.snackBar_func(
      '${"The Password field is empty. \n Please entet a valid Password"}');

  /// Email Empty & Password Fill
  var tSnackBar = Func.snackBar_func(
      '${"The Email field is empty. \n Please entet a valid Email ID"}');

  /// SIGNIN METHOD TO FIREBASE
  Future signIn() async {
    try {
      /// In the below, with if statement we have some simple validate
      if (_emailController.text.isNotEmpty &
          _passwordController.text.isNotEmpty) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else if (_emailController.text.isNotEmpty &
          _passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(sSnackBar);
      } else if (_emailController.text.isEmpty &
          _passwordController.text.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(tSnackBar);
      } else if (_emailController.text.isEmpty &
          _passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(fSnackBar);
      }
    } catch (e) {
      /// Showing Error with AlertDialog if the user enter the wrong Email and Password
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Warning'),
            content: const SingleChildScrollView(
              child: Text(
                  "The Email and Password that you entered is not valid, Please Enter a valid Email and Password."),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Got it'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _emailController.clear();
                  _passwordController.clear();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// currrent Width and Height
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    ///
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        /// APP BAR
        appBar: AppBar(
          title: const Text("SIGN IN"),
          centerTitle: true,
        ),

        /// Body
        body: Container(
          margin: const EdgeInsets.all(17),
          width: w,
          height: h,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                /// FLUTTER IMAGE
                FadeAnimation(
                  delay: 1,
                  child: Container(
                    margin: const EdgeInsets.only(),
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/images/logo1.png")),
                    ),
                    height: h / 4,
                    width: w / 1.5,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),

                /// TOP TEXT
                FadeAnimation(
                  delay: 1.5,
                  child: const Text(
                    "Log In To the App",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),

                /// Email TextField
                FadeAnimation(
                  delay: 2.0,
                  child: TextField(
                    focusNode: nodeOne,
                    onSubmitted: (_) {
                      FocusScope.of(context).requestFocus(nodeTwo);
                    },
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Email',
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),

                /// Password TextField
                FadeAnimation(
                  delay: 2.5,
                  child: TextField(
                    // onSubmitted: (_) {
                    //   signIn();
                    // },
                    focusNode: nodeTwo,
                    onSubmitted: (_) {
                      signIn();
                    },
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Password',
                    ),
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                /// Forgot Password TEXT
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                        onTap: () => Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordScreen(),
                              ),
                            ),
                        child: FadeAnimation(
                          delay: 3,
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        )),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),

                /// LOG IN BUTTON
                FadeAnimation(
                  delay: 3.5,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(w / 1.1, h / 15)),
                    onPressed: signIn,
                    child: const Text("Log In"),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),

                /// REGISTER TEXT
                // GestureDetector(
                //   onTap: widget.showSignUpScreen,
                //   child: FadeAnimation(
                //     delay: 4,
                //     child: RichText(
                //       text: TextSpan(
                //           text: "Don't have an account?",
                //           style: const TextStyle(
                //             color: Colors.black,
                //             fontSize: 17,
                //             fontWeight: FontWeight.w400,
                //           ),
                //           children: [
                //             TextSpan(
                //                 text: " Register",
                //                 style: TextStyle(
                //                     color: Theme.of(context).primaryColor))
                //           ]),
                //     ),
                //   ),
                // ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
