import 'package:activity_tracker/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:activity_tracker/generated/l10n.dart'; // Import the localization class

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // Key for the form

  // Focus nodes for each field
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final FocusNode _weightFocus = FocusNode();
  final FocusNode _heightFocus = FocusNode();

  String _selectedYearOfBirth = '1990'; // Default value
  bool _selectedGender = true; // Default gender: 'true' for Male
  bool _isFirstStep = true; // Flag to track the step

  @override
  void dispose() {
    // Dispose controllers and focus nodes
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _weightFocus.dispose();
    _heightFocus.dispose();
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
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                SizedBox(
                    height: MediaQuery.of(context).size.height *
                        0.1), // 10% space from the top
                Align(
                  alignment: _isFirstStep
                      ? Alignment.center
                      : Alignment
                          .centerLeft, // Center the title for the first step
                  child: Text(
                    _isFirstStep
                        ? S.of(context).createAccount
                        : S.of(context).biometricProfile,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold), // Increase font size
                  ),
                ),
                SizedBox(height: 20),
                _isFirstStep
                    ? _buildFirstStep()
                    : _buildSecondStep(), // Toggle between steps
                SizedBox(height: 20),
                // Sign In text - Include it only once here
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Go back to the login screen
                  },
                  child: Align(
                    alignment: Alignment.center,
                    child: Text.rich(
                      TextSpan(
                        text: S.of(context).haveAccount, // Localized text
                        style: TextStyle(color: Colors.grey),
                        children: [
                          TextSpan(
                            text: S.of(context).signIn,
                            style: TextStyle(
                              color: Color(0xFF3477A7),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFirstStep() {
    return Form(
      key: _formKey, // Assign the form key
      child: Column(
        children: [
          _buildInputField(
            S.of(context).name,
            _nameController,
            focusNode: _nameFocus,
            nextFocusNode: _emailFocus,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return S
                    .of(context)
                    .fieldRequired; // Error message for empty field
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          _buildInputField(
            S.of(context).email,
            _emailController,
            focusNode: _emailFocus,
            nextFocusNode: _passwordFocus,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return S
                    .of(context)
                    .fieldRequired; // Error message for empty field
              } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return S
                    .of(context)
                    .invalidEmail; // Error message for invalid email
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          _buildInputField(
            S.of(context).password,
            _passwordController,
            focusNode: _passwordFocus,
            nextFocusNode: _confirmPasswordFocus,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return S
                    .of(context)
                    .fieldRequired; // Error message for empty field
              } else if (value.length < 6) {
                return S
                    .of(context)
                    .passwordTooShort; // Error message for short password
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          _buildInputField(
            S.of(context).confirmPassword,
            _confirmPasswordController,
            focusNode: _confirmPasswordFocus,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return S
                    .of(context)
                    .fieldRequired; // Error message for empty field
              } else if (value != _passwordController.text) {
                return S
                    .of(context)
                    .passwordMismatch; // Error message for password mismatch
              }
              return null;
            },
          ),
          SizedBox(height: 40), // Increased space before button
          // Continue Button
          SizedBox(
            width: MediaQuery.of(context).size.width *
                0.85, // Button width set to 80% of the screen
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _isFirstStep =
                        false; // Move to the next step only if validation is successful
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF3477A7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                S.of(context).continueButton,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondStep() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildInputField(
            S.of(context).weight,
            _weightController,
            focusNode: _weightFocus,
            nextFocusNode: _heightFocus,
            suffix: 'kg',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return S
                    .of(context)
                    .fieldRequired; // Error message for empty field
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          _buildInputField(
            S.of(context).height,
            _heightController,
            focusNode: _heightFocus,
            suffix: 'cm',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return S
                    .of(context)
                    .fieldRequired; // Error message for empty field
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          _buildGenderDropdownField(
            S.of(context).gender,
            _selectedGender,
            (value) {
              setState(() {
                _selectedGender = value!;
              });
            },
          ),
          SizedBox(height: 20),
          _buildDropdownField(
            S.of(context).yearOfBirth,
            List.generate(
                100, (index) => (DateTime.now().year - index).toString()),
            _selectedYearOfBirth,
            (value) {
              setState(() {
                _selectedYearOfBirth = value!;
              });
            },
          ),
          SizedBox(height: 40), // Increased space before button
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            child: ElevatedButton(
              onPressed:
                  _handleRegistration, // Call API with all the collected data
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF3477A7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                S.of(context).confirmButton,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
    String? suffix,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        SizedBox(height: 5),
        SizedBox(
          width: MediaQuery.of(context).size.width *
              0.85, // Set width to 80% of the screen
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            focusNode: focusNode,
            onEditingComplete: () {
              if (nextFocusNode != null) {
                FocusScope.of(context).requestFocus(nextFocusNode);
              }
            },
            validator: validator,
            decoration: InputDecoration(
              filled: true,
              fillColor: Color(0xFFE0E0E0), // Slightly darker fill color
              hintText: label,
              hintStyle: TextStyle(color: Color(0xFF888888)),
              suffixText: suffix,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                  vertical: 20, horizontal: 10), // Adjust padding as needed
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdownField(
      String label, bool selectedGender, ValueChanged<bool?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        SizedBox(height: 5),
        SizedBox(
          width: MediaQuery.of(context).size.width *
              0.85, // Set width to 80% of the screen
          child: DropdownButtonFormField<bool>(
            value: selectedGender,
            items: [
              DropdownMenuItem(
                value: true, // 'true' represents Male
                child: Text(S.of(context).male), // Translated "Male"
              ),
              DropdownMenuItem(
                value: false, // 'false' represents Female
                child: Text(S.of(context).female), // Translated "Female"
              ),
            ],
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: Color(0xFFE0E0E0), // Slightly darker fill color
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                  vertical: 20, horizontal: 10), // Adjust padding as needed
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> items,
      String selectedItem, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        SizedBox(height: 5),
        SizedBox(
          width: MediaQuery.of(context).size.width *
              0.85, // Set width to 80% of the screen
          child: DropdownButtonFormField<String>(
            value: selectedItem,
            items: items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: Color(0xFFE0E0E0), // Slightly darker fill color
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                  vertical: 20, horizontal: 10), // Adjust padding as needed
            ),
          ),
        ),
      ],
    );
  }

  void _handleRegistration() async {
    Map<String, dynamic> registrationData = {
      'Username': _emailController.text,
      'Name': _nameController.text,
      'Email': _emailController.text,
      'Password': _passwordController.text,
      'ConfirmPassword': _confirmPasswordController.text,
      'Weight': _weightController.text,
      'Height': _heightController.text,
      'YearOfBirth': _selectedYearOfBirth,
      'Gender': _selectedGender,
    };

    bool isRegistered = await AuthService.register(registrationData, context);

    if (isRegistered) {
      Navigator.pop(context); // Go back to the login screen
    }
  }
}
