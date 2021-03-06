import 'package:eventful_app/customshapeClipper.dart';
import 'package:eventful_app/pages/home.dart';
import 'package:eventful_app/pages/register.dart';
import 'package:eventful_app/providers/auth.dart';
import 'package:flutter/material.dart';
import 'package:print_color/print_color.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/loginPage';
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var _togggleVisiabilty = false;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  //build Stack logo
  Widget _buildStackLogo() {
    return Stack(
      children: <Widget>[
        ClipPath(
          clipper: CustomShapeClipper(),
          child: Container(
            height: 260,
            width: double.infinity,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Positioned(
          top: 25,
          left: MediaQuery.of(context).size.width / 4 + 5,
          child: CircleAvatar(
            radius: 85,
            backgroundImage: AssetImage('assets/images/logo.jpg'),
          ),
        ),
      ],
    );
  }

  //build email textfield
  Widget _buildEmailTextField() {
    return Container(
      width: MediaQuery.of(context).size.width - 50,
      child: TextFormField(
        style: TextStyle(color: Colors.black),
        controller: _emailController,
        validator: (val) {
          if (val.isEmpty ||
              val.trim().length == 0 ||
              val.trim().length <= 3 ||
              !val.contains('@')) {
            return 'value is not valid';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: 'Email',
          fillColor: Colors.white,
          prefixIcon: Icon(
            Icons.email,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(50.0)),
          ),
        ),
      ),
    );
  }
  //build passwordTextField

  Widget _buildPasswordTextField() {
    return Container(
      width: MediaQuery.of(context).size.width - 50,
      child: TextFormField(
        style: TextStyle(color: Colors.black),
        controller: _passwordController,
        validator: (val) {
          if (val.isEmpty || val.trim().length == 0 || val.trim().length <= 3) {
            return 'value is not valid';
          }
          return null;
        },
        obscureText: !_togggleVisiabilty,
        decoration: InputDecoration(
          hintText: 'Password',
          fillColor: Colors.white,
          prefixIcon: Icon(Icons.lock),
          suffixIcon: IconButton(
            icon: !_togggleVisiabilty
                ? Icon(Icons.visibility_off)
                : Icon(Icons.visibility),
            onPressed: () {
              setState(() {
                _togggleVisiabilty = !_togggleVisiabilty;
              });
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(50.0)),
          ),
        ),
      ),
    );
  }

//build formAction
  Widget _buildFormAction() {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Column(
        children: <Widget>[
          _isLoading
              ? CircularProgressIndicator()
              : Container(
                  width: MediaQuery.of(context).size.width - 120,
                  child: MaterialButton(
                    shape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30)),
                    color: Theme.of(context).primaryColor,
                    splashColor: Colors.grey,
                    onPressed: () => _submitForm(),
                    minWidth: 200.0,
                    height: 42.0,
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                      ),
                    ),
                  ),
                ),
          SizedBox(height: 5),
          FlatButton(
            child: RichText(
              text: TextSpan(
                text: "Don't have an Account ? ",
                style: TextStyle(
                  color: Colors.black45,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: 'Sign Up',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onPressed: () => Navigator.of(context)
                .pushReplacementNamed(RegisterPage.routeName),
          )
        ],
      ),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    } else {
      _formKey.currentState.save();
      setState(() {
        _isLoading = true;
      });
      try {
        await Provider.of<Auth>(context, listen: false).singIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
        Navigator.of(context).pushNamed(HomePage.routeName);
      } catch (error) {
        Print.yellow('Error is $error');
        var errorMessge = 'Authintication Faild';
        if (error.toString().contains('EMAIL_EXISTS')) {
          errorMessge =
              'The email address is already in use by another account.';
        } else if (error.toString().contains('INVALID_EMAIL')) {
          errorMessge = 'The email address is badly formatted.';
        } else if (error.toString().contains('WEAK_PASSWORD')) {
          errorMessge = 'The password is too weak';
        } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
          errorMessge = 'Email Not Found';
        } else if (error.toString().contains('INVALID_PASSWORD')) {
          errorMessge = 'Invalid Password';
        }

        _showDialogError(errorMessge);
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _showDialogError(String message) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Something Went Wrong!'),
              content: Text(message.toString()),
              actions: <Widget>[
                FlatButton(
                  child: Text('okey'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                _buildStackLogo(),
                SizedBox(
                  height: 30,
                ),
                _buildEmailTextField(),
                SizedBox(
                  height: 30,
                ),
                _buildPasswordTextField(),
                SizedBox(
                  height: 8,
                ),
                _buildFormAction()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
