import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'dart:convert';
import 'dart:io';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  String staffId = '';
  String firstName = '';
  String lastName = '';
  String email = '';
  String password = '';
  String errorMessage = '';
  bool _isLoading = false; // Loader state

  Future<void> register() async {
    setState(() {
      _isLoading = true; // Start loading
      errorMessage = ''; // Reset error message
    });

    try {
      var res = await http.post(
        Uri.parse("http://192.168.102.81:8080/api/auth/register"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'staffId': staffId,
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
        }),
      );

      if (res.statusCode == 201) {
        // Store staffId locally using shared_preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('staffId', staffId);

        setState(() {
          errorMessage = 'User registered successfully. Please sign in.';
        });
        Navigator.pop(context);
      } else if (res.statusCode == 400) {
        // Check for specific messages in the response body
        var responseBody = jsonDecode(res.body);
        String message = responseBody['message'] ??
            'User already exists or staffId not found.';
        setState(() {
          errorMessage = message;
        });
      } else if (res.statusCode == 404) {
        // Check for specific messages in the response body
        var responseBody = jsonDecode(res.body);
        String message = responseBody['message'] ??
            'Server endpoint not found (404). Please check the server configuration.';
        setState(() {
          errorMessage = message;
        });
      } else {
        setState(() {
          errorMessage =
              'Unexpected error: ${res.statusCode}. Please try again later.';
        });
      }
    } on SocketException {
      setState(() {
        errorMessage =
            'No internet connection. Please check your network and try again.';
      });
    } on HttpException {
      setState(() {
        errorMessage = 'Server unreachable. Please try again later.';
      });
    } on FormatException {
      setState(() {
        errorMessage = 'Bad response format. Please try again later.';
      });
    } catch (e) {
      setState(() {
        errorMessage =
            'An unexpected error occurred: $e. Please try again later.';
      });
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context)
          .unfocus(), // Dismiss keyboard when tapping outside
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  child: SvgPicture.asset(
                    'images/top.svg',
                    width: 400,
                    height: 150,
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 150),
                        Text(
                          "Register",
                          style: GoogleFonts.pacifico(
                            fontWeight: FontWeight.bold,
                            fontSize: 50,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 25),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextFormField(
                            onChanged: (value) {
                              setState(() {
                                staffId = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter your staff ID';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              icon: Icon(
                                Icons.badge,
                                color: Colors.blue,
                              ),
                              hintText: 'Enter Staff ID',
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextFormField(
                            onChanged: (value) {
                              setState(() {
                                firstName = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter your first name';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              icon: Icon(
                                Icons.person,
                                color: Colors.blue,
                              ),
                              hintText: 'Enter First Name',
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextFormField(
                            onChanged: (value) {
                              setState(() {
                                lastName = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter your last name';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              icon: Icon(
                                Icons.person_outline,
                                color: Colors.blue,
                              ),
                              hintText: 'Enter Last Name',
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextFormField(
                            onChanged: (value) {
                              setState(() {
                                email = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter your email';
                              } else if (RegExp(
                                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(value)) {
                                return null;
                              } else {
                                return 'Enter valid email';
                              }
                            },
                            decoration: InputDecoration(
                              icon: Icon(
                                Icons.email,
                                color: Colors.blue,
                              ),
                              hintText: 'Enter Email Address',
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextFormField(
                            onChanged: (value) {
                              setState(() {
                                password = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter your password';
                              }
                              return null;
                            },
                            obscureText: true,
                            decoration: InputDecoration(
                              icon: Icon(
                                Icons.vpn_key,
                                color: Colors.blue,
                              ),
                              hintText: 'Enter Password',
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                        ),
                        if (errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              errorMessage,
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(55, 16, 16, 0),
                          child: Container(
                            height: 50,
                            width: 400,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0)),
                              ),
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      if (_formKey.currentState?.validate() ??
                                          false) {
                                        register();
                                      } else {
                                        setState(() {
                                          errorMessage =
                                              "Please fill in all fields correctly.";
                                        });
                                      }
                                    },
                              child: _isLoading
                                  ? CircularProgressIndicator(
                                      color: Colors.white)
                                  : Text("Register",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20)),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Already have an account? Sign in",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
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
}
