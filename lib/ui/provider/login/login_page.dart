import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_homework_25_2/ui/provider/login/login_model.dart';
import 'package:validators/validators.dart' as validators;
import 'package:provider/provider.dart';

class LoginPageProvider extends StatefulWidget {
  const LoginPageProvider({super.key});

  @override
  State<LoginPageProvider> createState() => _LoginPageProviderState();
}

class _LoginPageProviderState extends State<LoginPageProvider> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _isPasswordObscured = true;

  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _initializePage());
    _emailController.addListener(_clearEmailError);
    _passwordController.addListener(_clearPasswordError);
  }

  void _clearEmailError() {
    if (_emailError != null) {
      setState(() {
        _emailError = null;
      });
    }
  }

  void _clearPasswordError() {
    if (_passwordError != null) {
      setState(() {
        _passwordError = null;
      });
    }
  }

  //TODO: Try auto-login on model
  void _initializePage() async {
    final loginModel = context.read<LoginModel>();
    final bool isLoggedIn = await loginModel.tryAutoLogin();

    if (isLoggedIn) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/list');
      }
    }
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    bool isValid = true;
    String? tempEmailError;
    String? tempPasswordError;

    if (email.isEmpty || !validators.isEmail(email)) {
      tempEmailError = 'Kérjük, érvényes email címet adjon meg.';
      isValid = false;
    }

    if (password.isEmpty || password.length < 6) {
      tempPasswordError = 'A jelszónak legalább 6 karakternek kell lennie.';
      isValid = false;
    }

    setState(() {
      _emailError = tempEmailError;
      _passwordError = tempPasswordError;
    });

    if (isValid) {
      print('Bejelentkezés folyamatban...');
      print('Email: $email');
      print('Jelszó: $password');
      print('Jegyezz meg: $_rememberMe');
      final loginModel = context.read<LoginModel>();
      try {
        await loginModel.login(email, password, _rememberMe);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sikeres bejelentkezés!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/list');
      } on LoginException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ismeretlen hiba történt.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginModel = context.watch<LoginModel>();
    final bool isLoading = loginModel.isLoading;
    return Scaffold(
        body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 80),
                  Icon(
                    Icons.lock_outline,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Üdvözöljük!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Jelentkezzen be a folytatáshoz',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          enabled: !isLoading,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email cím',
                            hintText: 'nev@email.com',
                            prefixIcon: const Icon(Icons.email_outlined),
                            errorText: _emailError,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        TextFormField(
                          enabled: !isLoading,
                          controller: _passwordController,
                          obscureText: _isPasswordObscured,
                          decoration: InputDecoration(
                            labelText: 'Jelszó',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            errorText: _passwordError,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isPasswordObscured = !_isPasswordObscured;
                                });
                              },
                              child: Icon(
                                _isPasswordObscured
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        CheckboxListTile(
                          title: const Text('Emlékezz rám'),
                          value: _rememberMe,
                          onChanged: isLoading
                              ? null
                              : (newValue) {
                            setState(() {
                              _rememberMe = newValue ?? false;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 24),

                        ElevatedButton(
                          onPressed: isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: const Text(
                            'Bejelentkezés',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        )
    );
  }

  @override
  void dispose() {
    _emailController.removeListener(_clearEmailError);
    _passwordController.removeListener(_clearPasswordError);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
