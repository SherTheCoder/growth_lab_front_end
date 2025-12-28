import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growth_lab/shared/presentation/widgets/app_text_field.dart';
import 'package:growth_lab/shared/utils/ui_utils.dart';
import '../providers/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final PageController _pageController = PageController();

  // Step 1 Fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  // Step 2 Fields
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // Keys
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();

  void _nextStep() {
    if (_step1Key.currentState!.validate()) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut
      );
      FocusScope.of(context).unfocus();
    }
  }

  void _submitSignUp() async {
    if (_step2Key.currentState!.validate()) {
      try {
        await ref.read(authProvider.notifier).signUp(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
        );

        if (mounted) {
          // FIX: Pass 'context' directly (positional argument), not as a named parameter
          showResultDialog(
              context,
              title: "Account Created",
              message: "Please check your email to verify your account before logging in.",
              isError: false,
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.popUntil(context, (route) => route.isFirst); // Go to Login
              }
          );
        }
      } catch (e) {
        if (mounted) {
          final friendlyMessage = getUserFriendlyErrorMessage(e);

          // FIX: Pass 'context' directly here too
          showResultDialog(
            context,
            title: "Sign Up Failed",
            message: friendlyMessage,
            isError: true,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.iconTheme.color),
      ),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildStep1(theme),
            _buildStep2(theme),
          ],
        ),
      ),
    );
  }

  // --- STEP 1 ---
  Widget _buildStep1(ThemeData theme) {
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _step1Key,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "What's your full name?",
                      style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color
                      )
                  ),
                  const SizedBox(height: 10),
                  Text(
                      "Please enter the full name you use in your daily life.",
                      style: TextStyle(color: theme.hintColor)
                  ),
                  const SizedBox(height: 40),

                  Row(
                    children: [
                      Expanded(
                          child: _buildTextField("First Name", _firstNameController, isRequired: true)
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildTextField("Last Name", _lastNameController, isRequired: true)
                      ),
                    ],
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Continue", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- STEP 2 ---
  Widget _buildStep2(ThemeData theme) {
    final isLoading = ref.watch(authProvider).isLoading;

    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _step2Key,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "Set Up Your Login Details",
                      style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color
                      )
                  ),
                  const SizedBox(height: 10),
                  Text(
                      "We'll send a verification link to your email.",
                      style: TextStyle(color: theme.hintColor)
                  ),
                  const SizedBox(height: 40),

                  _buildTextField("Email", _emailController, isRequired: true),
                  const SizedBox(height: 20),
                  _buildTextField("Phone Number", _phoneController, isRequired: false),
                  const SizedBox(height: 20),
                  _buildTextField("Password", _passwordController, isPassword: true, isRequired: true),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submitSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("Create Account", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isPassword = false, bool isRequired = false}) {
    return AppTextField(
      controller: controller,
      label: label,
      isPassword: isPassword,
    );
  }
}