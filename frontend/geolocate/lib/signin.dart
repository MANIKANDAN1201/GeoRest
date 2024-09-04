import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'homepage.dart';
import 'register_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class Signin extends StatefulWidget {
  Signin({Key? key}) : super(key: key);

  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String errorMessage = '';
  bool _isLoading = false;

  Future<void> login() async {
    setState(() {
      _isLoading = true;
      errorMessage = '';
    });

    try {
      var res = await http.post(
        Uri.parse("http://192.168.102.81:8080/api/auth/signin"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (res.statusCode == 200) {
        var responseBody = jsonDecode(res.body);
        String? token = responseBody['token'];
        String? staffId = responseBody['staff_id'];

        if (token == null || staffId == null) {
          throw Exception('Token or Staff ID not found in response');
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('staff_id', staffId);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(staffId: staffId),
          ),
        );
      } else if (res.statusCode == 401) {
        setState(() {
          errorMessage = 'Invalid credentials. Please try again.';
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
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
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
                          "Signin",
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
                                email = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter something';
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
                              hintText: 'Enter Email',
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
                                return 'Enter something';
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
                                        login();
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
                                  : Text("Signin",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20)),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisterPage(),
                              ),
                            );
                          },
                          child: Text(
                            "Don't have an account? Register",
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
