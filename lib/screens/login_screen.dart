// ignore_for_file: avoid_print, unused_field

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rive/rive.dart' as rive;
import '../controllers/auth_controller.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode usernameFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  // Add error states
  final RxString usernameError = ''.obs;
  final RxString passwordError = ''.obs;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var animationLink = 'assets/animations/animated_login_character.riv';
  rive.SMIInput<bool>? isChecking;
  rive.SMIInput<bool>? isHandsUp;
  rive.SMIInput<bool>? trigSuccess;
  rive.SMIInput<bool>? trigFail;
  rive.StateMachineController? stateMachineController;
  rive.RiveFile? _file;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    stateMachineController = null; // مقدار اولیه
    preload();
  }

  Future<void> preload() async {
    rootBundle.load('assets/animations/animated_login_character.riv').then((
      data,
    ) async {
      // Load the RiveFile from the binary data.
      _file = rive.RiveFile.import(data);
      setState(() {});
    });
  }

  void _onRiveInit(rive.Artboard artBoard) {
    stateMachineController = rive.StateMachineController.fromArtboard(
      artBoard,
      'Login Machine',
    );
    if (stateMachineController != null) {
      artBoard.addController(stateMachineController!);
      isChecking = stateMachineController!.findInput<bool>('isChecking');
      isHandsUp = stateMachineController!.findInput<bool>('isHandsUp');
      trigSuccess = stateMachineController!.findInput<bool>('trigSuccess');
      trigFail = stateMachineController!.findInput<bool>('trigFail');
      setState(() {}); // تغییرات رو اعمال کن

      // Add listeners to text controllers
      usernameController.addListener(_onUsernameChanged);
      passwordController.addListener(_onPasswordChanged);
    }
  }

  void _onUsernameChanged() {
    if (stateMachineController != null && isChecking != null) {
      // Reset other animations first
      isHandsUp?.value = false;
      trigSuccess?.value = false;
      trigFail?.value = false;
      // Set the new animation state
      isChecking!.value = usernameController.text.isNotEmpty;
    }
  }

  void _onPasswordChanged() {
    if (stateMachineController != null && isHandsUp != null) {
      // Reset other animations first
      isChecking?.value = false;
      trigSuccess?.value = false;
      trigFail?.value = false;
      // Set the new animation state
      isHandsUp!.value = passwordController.text.isNotEmpty;
    }
  }

  // Clear errors when text changes
  void _clearErrors() {
    usernameError.value = '';
    passwordError.value = '';
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      _clearErrors(); // Clear previous errors

      // Only try to animate if the controller is initialized
      if (stateMachineController != null) {
        // Reset all animation states
        isChecking?.value = false;
        isHandsUp?.value = false;
        trigSuccess?.value = false;
        trigFail?.value = false;

        // Wait for a short moment to ensure animations are reset
        await Future.delayed(const Duration(milliseconds: 100));
      }

      await authController.login(
        usernameController.text,
        passwordController.text,
      );

      if (mounted) {
        print('Login successful, triggering success animation');
        // Only animate if controller is initialized
        if (stateMachineController != null) {
          // Reset all other animations before showing success
          isChecking?.value = false;
          isHandsUp?.value = false;
          trigFail?.value = false;
          trigSuccess?.value = true;

          // Wait for success animation to complete (2 seconds)
          await Future.delayed(const Duration(seconds: 2));
        }
        if (mounted) {
          Get.offAllNamed('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        print('Login failed, triggering fail animation');
        // Handle specific error messages
        if (e.toString().contains('401')) {
          usernameError.value = 'نام کاربری یا رمز عبور اشتباه است';
        } else if (e.toString().contains('404')) {
          usernameError.value = 'کاربر یافت نشد';
        }

        // Only animate if controller is initialized
        if (stateMachineController != null) {
          // Reset all other animations before showing fail
          isChecking?.value = false;
          isHandsUp?.value = false;
          trigSuccess?.value = false;
          trigFail?.value = true;

          // Wait for fail animation to complete (2 seconds)
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            trigFail?.value = false;
          }
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    usernameFocus.dispose();
    passwordFocus.dispose();
    usernameController.removeListener(_onUsernameChanged);
    passwordController.removeListener(_onPasswordChanged);
    usernameController.dispose();
    passwordController.dispose();
    stateMachineController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        height: MediaQuery.of(context).size.height * 0.41,
        width: double.infinity,
        child: rive.RiveAnimation.asset(
          animationLink,
          fit: BoxFit.contain,
          onInit: _onRiveInit,
        ),
      ),
      bottomSheet: // Bottom part with login form
          Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ورود به حساب کاربری',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: usernameController,
                  focusNode: usernameFocus,
                  decoration: InputDecoration(
                    labelText: 'نام کاربری (انگلیسی)',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    errorText:
                        usernameError.value.isNotEmpty
                            ? usernameError.value
                            : null,
                    errorStyle: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                  onChanged: (_) => _clearErrors(),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => passwordFocus.requestFocus(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفا نام کاربری را وارد کنید';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                      return 'نام کاربری باید فقط شامل حروف انگلیسی، اعداد و خط زیر باشد';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  focusNode: passwordFocus,
                  decoration: const InputDecoration(
                    labelText: 'رمز عبور',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _login(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفا رمز عبور را وارد کنید';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        isLoading
                            ? const CircularProgressIndicator()
                            : const Text('ورود'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Get.closeCurrentSnackbar();
                    Get.toNamed('/register');
                  },
                  child: const Text('حساب کاربری ندارید؟ ثبت نام کنید'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
