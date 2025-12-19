import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/theme_constants.dart';
import '../widgets/kintana_widgets.dart';
import '../widgets/custom_snackbar.dart';
import '../services/api_service.dart';
import 'forgot_password_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Toggle State: true = Login, false = Register
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  // Registration specific
  String _selectedRole = 'etudiant';
  final List<DropdownMenuItem<String>> _roleItems = const [
    DropdownMenuItem(value: 'etudiant', child: Text('Étudiant')),
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // API Call handlers
  Future<void> _handleAuth() async {
    if (!_isLogin) {
      if (_passwordController.text != _confirmPasswordController.text) {
        CustomSnackbar.error(
          context,
          'Les mots de passe ne correspondent pas.',
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    Map<String, dynamic> result;

    if (_isLogin) {
      result = await ApiService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } else {
      result = await ApiService.register(
        nom: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
      );
    }

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      CustomSnackbar.success(context, result['message']);
      if (!_isLogin) {
        // After register, clear fields and switch to login tab
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        setState(() => _isLogin = true);
      } else {
        // ✨ NOUVELLE PARTIE : Navigation vers le chatbot après connexion réussie
        final prefs = await SharedPreferences.getInstance();
        
        // Sauvegarder le token et les infos utilisateur
        if (result['data'] != null && result['data']['token'] != null) {
          await prefs.setString('auth_token', result['data']['token']);
        } else {
          // Si pas de token dans la réponse, on en crée un temporaire
          await prefs.setString('auth_token', 'logged_in');
        }
        
        // Sauvegarder l'email ou le nom de l'utilisateur
        await prefs.setString('username', _emailController.text.split('@')[0]);
        
        if (!mounted) return;
        
        // Navigation vers le chatbot
        Navigator.pushReplacementNamed(context, '/chat');
      }
    } else {
      CustomSnackbar.error(context, result['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KintanaColors.background,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: KintanaDimensions.maxContainerWidth,
              ),
              decoration: BoxDecoration(
                color: KintanaColors.white,
                borderRadius: BorderRadius.circular(
                  KintanaDimensions.borderRadiusXLarge,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(KintanaDimensions.spacingXLarge),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    const KintanaLogo(),
                    const SizedBox(height: KintanaDimensions.spacingMedium),

                    // Title
                    const Text('KINTANA', style: KintanaTextStyles.title),
                    const SizedBox(height: KintanaDimensions.spacingXSmall),
                    const Text(
                      'Car nous sommes tous enfants des étoiles',
                      style: KintanaTextStyles.subtitle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: KintanaDimensions.spacingLarge),

                    // Toggle Buttons
                    Container(
                      decoration: BoxDecoration(
                        color: KintanaColors.lightGray,
                        borderRadius: BorderRadius.circular(
                          KintanaDimensions.borderRadiusMedium,
                        ),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildToggleButton('Connexion', true),
                          ),
                          Expanded(
                            child: _buildToggleButton('Inscription', false),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: KintanaDimensions.spacingLarge),

                    // Form Fields
                    if (!_isLogin) ...[
                      KintanaTextField(
                        controller: _nameController,
                        hintText: 'Nom complet',
                        prefixIcon: Icons.person_outline,
                      ),
                      const SizedBox(height: KintanaDimensions.spacingSmall),
                    ],

                    KintanaTextField(
                      controller: _emailController,
                      hintText: 'exemple@gmail.com',
                      prefixIcon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: KintanaDimensions.spacingSmall),

                    if (!_isLogin) ...[
                      // Role Dropdown styling to match KintanaTextField
                      Container(
                        decoration: BoxDecoration(
                          color: KintanaColors.inputEmailBackground,
                          borderRadius: BorderRadius.circular(
                            KintanaDimensions.borderRadiusMedium,
                          ),
                          border: Border.all(color: KintanaColors.inputBorder),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: KintanaDimensions.inputPadding,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedRole,
                            isExpanded: true,
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: KintanaColors.inputText,
                            ),
                            dropdownColor: KintanaColors.white,
                            style: const TextStyle(
                              color: KintanaColors.inputText,
                              fontSize: 16,
                            ),
                            items: _roleItems,
                            onChanged: (v) =>
                                setState(() => _selectedRole = v!),
                          ),
                        ),
                      ),
                      const SizedBox(height: KintanaDimensions.spacingSmall),
                    ],
                    KintanaTextField(
                      controller: _passwordController,
                      hintText: '........',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.black,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),

                    if (!_isLogin) ...[
                      const SizedBox(height: KintanaDimensions.spacingSmall),
                      KintanaTextField(
                        controller: _confirmPasswordController,
                        hintText: 'Confirmer mot de passe',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscureConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.black,
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: KintanaDimensions.spacingLarge),

                    // Action Button
                    if (_isLoading)
                      const CircularProgressIndicator(
                        color: KintanaColors.primary,
                      )
                    else
                      KintanaButton(
                        text: _isLogin ? 'Se connecter' : 'S\'inscrire',
                        onPressed: _handleAuth,
                        backgroundColor: KintanaColors.secondary,
                      ),

                    const SizedBox(height: KintanaDimensions.spacingMedium),

                    // Forgot Password
                    if (_isLogin)
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Mot de passe oublié ?',
                          style: KintanaTextStyles.link,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isLoginButton) {
    final bool isActive = _isLogin == isLoginButton;
    return GestureDetector(
      onTap: () {
        if (_isLogin != isLoginButton) {
          setState(() {
            _isLogin = isLoginButton;
            _nameController.clear();
            _emailController.clear();
            _passwordController.clear();
            _confirmPasswordController.clear();
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? KintanaColors.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(
            KintanaDimensions.borderRadiusMedium,
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? Colors.white : KintanaColors.secondary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}