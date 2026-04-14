import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 800) {
            return const DesktopLoginLayout();
          } else {
            return const MobileLoginLayout();
          }
        },
      ),
    );
  }
}

class DesktopLoginLayout extends StatelessWidget {
  const DesktopLoginLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left side image coverage
        Expanded(
          flex: 5,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/space_bg.png',
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 40,
                left: 40,
                child: const AppLogo(),
              ),
              Positioned(
                bottom: 40,
                left: 40,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'SIGN IN TO YOUR',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      'ADVENTURE!',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF7A36D4), // Purple tint
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Right side login form
        Expanded(
          flex: 4,
          child: Container(
            color: const Color(0xFF0C071C), // Deep dark purple background
            child: Stack(
              children: [
                Positioned(
                  top: 40,
                  right: 40,
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                      children: [
                        TextSpan(text: 'DON\'T HAVE AN ACCOUNT? '),
                        TextSpan(
                          text: 'SIGN UP',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 40),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: const LoginForm(isDesktop: true),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MobileLoginLayout extends StatelessWidget {
  const MobileLoginLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/space_bg.png',
          fit: BoxFit.cover,
          alignment: Alignment.topLeft,
        ),
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AppLogo(),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                        children: [
                          TextSpan(text: 'DON\'T HAVE AN ACCOUNT? '),
                          TextSpan(
                            text: 'SIGN UP',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: const LoginForm(isDesktop: false),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Text(
                  'COPYRIGHT BY IBRAHIM MEMON',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Simulating the logo icon
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Center(
            child: Icon(
              Icons.bolt, // Placeholder for the actual custom geometric logo
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'Ibrahim',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.0,
              ),
            ),
            Text(
              'MEMON',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
                letterSpacing: 2.0,
                height: 1.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class LoginForm extends StatefulWidget {
  final bool isDesktop;

  const LoginForm({super.key, required this.isDesktop});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.isDesktop) const SizedBox(height: 80),
          Text(
            'SIGN IN',
            style: TextStyle(
              fontSize: widget.isDesktop ? 64 : 56,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: widget.isDesktop ? 24 : 16),
          const Text(
            'Sign in with your email and password',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          // Email Input Field
          TextFormField(
            controller: _emailController,
            style: const TextStyle(color: Colors.white),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
              if (!emailRegex.hasMatch(value)) {
                return 'Enter a valid email address';
              }
              return null;
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF1D123A),
              hintText: 'Yourname@gmail.com',
              hintStyle: const TextStyle(color: Colors.white54, fontSize: 15),
              prefixIcon: const Icon(Icons.mail_outline, color: Colors.white54),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            ),
          ),
          const SizedBox(height: 16),
          // Password Input Field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(color: Colors.white),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              return null;
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF1D123A),
              hintText: 'Password',
              hintStyle: const TextStyle(color: Colors.white54, fontSize: 15),
              prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.white54,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            ),
          ),
          const SizedBox(height: 24),
          // Sign in Button
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: _isLoading
                  ? null
                  : const LinearGradient(
                      colors: [Color(0xFF5D24AA), Color(0xFF3860A3)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
              color: _isLoading ? Colors.grey.shade800 : null,
            ),
            child: MaterialButton(
              onPressed: _isLoading ? null : _submitForm,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 32),
          // Divider
          Row(
            children: const [
              Expanded(child: Divider(color: Colors.white24, thickness: 1)),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Or continue with',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          // Social Buttons
          Row(
            children: [
              Expanded(
                child: SocialButton(
                  icon: const FaIcon(FontAwesomeIcons.google, color: Colors.greenAccent, size: 20),
                  label: 'Google',
                  color: const Color(0xFF281E4B),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SocialButton(
                  icon: const FaIcon(FontAwesomeIcons.facebook, color: Colors.blueAccent, size: 20),
                  label: 'Facebook',
                  color: const Color(0xFF281E4B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 12, color: Colors.white54),
              children: [
                TextSpan(text: 'By registering you agree to our '),
                TextSpan(
                  text: 'Terms and Conditions',
                  style: TextStyle(color: Color(0xFF8B4EF5)), // Lighter purple link
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SocialButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final Color color;

  const SocialButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onPressed: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
