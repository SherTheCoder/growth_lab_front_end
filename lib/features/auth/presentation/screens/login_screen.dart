import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growth_lab/shared/presentation/widgets/app_text_field.dart';
import 'package:growth_lab/shared/utils/ui_utils.dart'; // Import the shared utils
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
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // 1. Ensure the scaffold resizes when keyboard opens
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        // 2. Use CustomScrollView to handle flexible scrolling
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              // 3. hasScrollBody: false tells Flutter this isn't a long list,
              // but a single layout that should fill the screen.
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
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
                              ? null
                              : () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                // Attempt Login
                                await ref.read(authProvider.notifier).login(
                                    _emailController.text.trim(),
                                    _passwordController.text
                                );
                                // If successful, AuthProvider state change will trigger
                                // the MainWrapper to switch to HomeScreen.
                              } catch (e) {
                                if (!mounted) return;

                                // FIX: Use shared utility for readable errors
                                final friendlyMessage = getUserFriendlyErrorMessage(e);

                                showResultDialog(
                                  context,
                                  title: "Login Failed",
                                  message: friendlyMessage,
                                  isError: true,
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
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

                      // 4. Spacer fills remaining space when keyboard is closed
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
          ],
        ),
      ),
    );
  }
}