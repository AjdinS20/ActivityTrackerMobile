import 'package:activity_tracker/generated/l10n.dart';
import 'package:activity_tracker/models/login_model.dart';
import 'package:activity_tracker/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Color(0xFF3477A7),
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  Future<void> _handleLogin() async {
    String email = _emailController.text;
    String password = _passwordController.text;
    LoginModel loginModel = LoginModel(email: email, password: password);
    final result = await AuthService.login(loginModel, context);

    if (result != null) {
      Navigator.pushNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevent overflow when the keyboard opens
      body: SafeArea(
        child: SingleChildScrollView(
          reverse: true, // Ensures that the screen scrolls to the focused field
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0),
            child: Column(
              children: [
                // Top third with background, logo, and sign-in text
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25.0),
                    bottomRight: Radius.circular(25.0),
                  ),
                  child: Container(
                    height: MediaQuery.of(context).size.height / 2.5,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/background_image.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Color(0xFF3477A7),
                                  Color(0xFF3477A7).withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 20,
                          child: Text(
                            S.of(context).signIn,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/logo.png',
                                height: MediaQuery.of(context).size.height / 6,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                // Email and Password Input Fields
                Column(
                  children: [
                    _buildInputField(S.of(context).email, _emailController,
                        focusNode: _emailFocus, nextFocusNode: _passwordFocus),
                    SizedBox(height: 20),
                    _buildInputField(
                        S.of(context).password, _passwordController,
                        focusNode: _passwordFocus, obscureText: true),
                    SizedBox(height: 40),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFF3477A7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: Text(
                          S.of(context).signInButton,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text.rich(
                        TextSpan(
                          text: S.of(context).noAccount + " ",
                          style: TextStyle(color: Colors.grey),
                          children: [
                            TextSpan(
                              text: S.of(context).signUp,
                              style: TextStyle(
                                color: Color(0xFF3477A7),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {FocusNode? focusNode,
      FocusNode? nextFocusNode,
      bool obscureText = false,
      TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        SizedBox(height: 5),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            focusNode: focusNode,
            onEditingComplete: () {
              if (nextFocusNode != null) {
                FocusScope.of(context).requestFocus(nextFocusNode);
              }
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Color(0xFFE0E0E0),
              hintText: label,
              hintStyle: TextStyle(color: Color(0xFF888888)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            ),
          ),
        ),
      ],
    );
  }
}
