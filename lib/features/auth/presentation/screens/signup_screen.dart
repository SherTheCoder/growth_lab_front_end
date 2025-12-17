import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growth_lab/shared/presentation/widgets/app_text_field.dart';
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

  // Form Keys for validation (Optional but good practice)
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();

  void _nextStep() {
    if (_firstNameController.text.isNotEmpty && _lastNameController.text.isNotEmpty) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut
      );
      FocusScope.of(context).unfocus(); // Close keyboard on transition
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
    }
  }

  void _submitSignUp() async {
    // Basic validation
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in email and password")),
      );
      return;
    }

    // 1. Trigger the signup
    await ref.read(authProvider.notifier).signUp(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );

    // 2. Check the result
    if (!mounted) return;
    final authState = ref.read(authProvider);

    if (authState.hasError) {
      final errorMsg = authState.error.toString().replaceAll("Exception: ", "");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // 3. Success: Show confirmation dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text("Account Created", style: Theme.of(context).textTheme.titleLarge),
          content: Text(
            "Please check your email to verify your account before logging in.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // Close Dialog
                Navigator.popUntil(context, (route) => route.isFirst); // Go to Login
              },
              child: Text("OK", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        // Use theme icon color (Auto black/white based on mode)
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

  Widget _buildStep1(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              "What's your full name?",
              style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color // Dynamic Text Color
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
              Expanded(child: _buildTextField("First Name", _firstNameController)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField("Last Name", _lastNameController)),
            ],
          ),
          const Spacer(), // Pushes button to bottom area

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary, // Theme Primary Color
                foregroundColor: theme.colorScheme.onPrimary, // Text on Primary
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Matches Login
              ),
              child: const Text("Continue", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStep2(ThemeData theme) {
    // Watch loading state to show spinner
    final isLoading = ref.watch(authProvider).isLoading;

    return Padding(
      padding: const EdgeInsets.all(24.0),
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

          _buildTextField("Email", _emailController),
          const SizedBox(height: 20),
          _buildTextField("Phone Number", _phoneController),
          const SizedBox(height: 20),
          _buildTextField("Password", _passwordController, isPassword: true),

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
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isPassword = false}) {
    return AppTextField(controller: controller, label: label, isPassword: isPassword);
  }
}