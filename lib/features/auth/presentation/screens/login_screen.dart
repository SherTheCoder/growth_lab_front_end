import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growth_lab/shared/presentation/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';
import 'signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // 1. The key requires a Form widget to work
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          // 2. Wrap your inputs in a FORM widget using the key
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Icon(Icons.hub, size: 60, color: theme.iconTheme.color),
                ),
                const SizedBox(height: 60),

                // Email
                AppTextField(
                  controller: _emailController,
                  label: "email or handle",
                  isPassword: false,
                  // Ensure your AppTextField supports validators, or add logic here
                ),

                const SizedBox(height: 20),

                // Password
                AppTextField(
                    controller: _passwordController,
                    label: "password",
                    isPassword: true
                ),

                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                      onPressed: () {},
                      child: Text("Forgot Password", style: TextStyle(color: theme.hintColor))
                  ),
                ),
                const SizedBox(height: 30),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: authState.isLoading
                        ? null // Disable button while loading
                        : () async {
                      // 3. Validate Form
                      if (_formKey.currentState!.validate()) {
                        try {
                          // 4. Call Login (Await it!)
                          await ref.read(authProvider.notifier).login(
                              _emailController.text.trim(), // Trim whitespace
                              _passwordController.text
                          );

                          // Navigation is usually handled by listening to authState changes
                          // or typically: Navigator.pushReplacementNamed(context, '/feed');

                        } catch (e) {
                          // 5. Catch Error & Show SnackBar
                          if (!mounted) return;

                          final errorMessage = e.toString().replaceAll("Exception: ", "");

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage, style: const TextStyle(color: Colors.white)),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary, // Teal
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: authState.isLoading
                        ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                        : const Text("Log in", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),

                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ", style: TextStyle(color: theme.hintColor)),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
                      child: Text(
                          "Sign up",
                          style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold
                          )
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}