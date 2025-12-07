import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';
import '../widgets/kintana_widgets.dart';
import '../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Stepper State
  int _currentStep = 0; // 0: Email, 1: Password, 2: Success

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Logic State
  String? errorMessage;
  bool isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String? _resetToken;

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Step 1: Request Token
  Future<void> _handleEmailStep() async {
    if (_emailController.text.isEmpty) {
      setState(() => errorMessage = 'Veuillez entrer votre email');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await ApiService.requestPasswordReset(
        _emailController.text.trim(),
      );

      if (result['success']) {
        // In real app, we wouldn't get the token here, but user asked for simple flow
        if (result['token'] != null) {
          setState(() {
            _resetToken = result['token'];
            _currentStep = 1;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage =
                'Erreur: Impossible de récupérer le token (Mode démo)';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = result['message'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur technique: $e';
        isLoading = false;
      });
    }
  }

  // Step 2: Reset Password
  Future<void> _handlePasswordStep() async {
    if (_newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      setState(() => errorMessage = 'Tous les champs sont requis');
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() => errorMessage = 'Les mots de passe ne correspondent pas');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await ApiService.resetPassword(
        _resetToken!,
        _newPasswordController.text,
      );

      if (result['success']) {
        setState(() {
          _currentStep = 2; // Move to Success Step
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              result['message']; // Will show "Saisie un nouveau mot de passe" if applicable
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur technique: $e';
        isLoading = false;
      });
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

                    // Header
                    if (_currentStep < 2) ...[
                      const Text('KINTANA', style: KintanaTextStyles.title),
                      const SizedBox(height: KintanaDimensions.spacingXSmall),
                      Text(
                        _currentStep == 0
                            ? 'Récupération de compte'
                            : 'Nouveau mot de passe',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: KintanaColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: KintanaDimensions.spacingLarge),

                      // Progress Bar
                      LinearProgressIndicator(
                        value: _currentStep == 0 ? 0.33 : 0.66,
                        backgroundColor: KintanaColors.lightGray,
                        color: KintanaColors.secondary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: KintanaDimensions.spacingLarge),
                    ],

                    // STEP 0: EMAIL
                    if (_currentStep == 0) ...[
                      const Text(
                        'Entrez votre email pour commencer.',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: KintanaDimensions.spacingMedium),
                      KintanaTextField(
                        controller: _emailController,
                        hintText: 'exemple@gmail.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        backgroundColor: KintanaColors.inputEmailBackground,
                        borderColor: KintanaColors.inputEmailBackground,
                      ),
                    ],

                    // STEP 1: PASSWORD
                    if (_currentStep == 1) ...[
                      const Text(
                        'Créez un mot de passe fort et sécurisé.',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: KintanaDimensions.spacingMedium),
                      KintanaTextField(
                        controller: _newPasswordController,
                        hintText: 'Nouveau mot de passe',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscureNewPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNewPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.black,
                          ),
                          onPressed: () => setState(
                            () => _obscureNewPassword = !_obscureNewPassword,
                          ),
                        ),
                      ),
                      const SizedBox(height: KintanaDimensions.spacingSmall),
                      KintanaTextField(
                        controller: _confirmPasswordController,
                        hintText: 'Confirmer nouveau mot de passe',
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

                    // STEP 2: SUCCESS
                    if (_currentStep == 2) ...[
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 60,
                      ),
                      const SizedBox(height: KintanaDimensions.spacingMedium),
                      const Text(
                        'Succès !',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: KintanaColors.primary,
                        ),
                      ),
                      const SizedBox(height: KintanaDimensions.spacingSmall),
                      const Text(
                        'Votre mot de passe a été mis à jour avec succès.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: KintanaDimensions.spacingLarge),
                    ],

                    const SizedBox(height: KintanaDimensions.spacingMedium),

                    // Error Message
                    if (errorMessage != null && _currentStep < 2) ...[
                      KintanaErrorMessage(message: errorMessage!),
                      const SizedBox(height: KintanaDimensions.spacingMedium),
                    ],

                    // Buttons
                    if (isLoading)
                      const CircularProgressIndicator(
                        color: KintanaColors.secondary,
                      )
                    else if (_currentStep < 2) ...[
                      KintanaButton(
                        text: _currentStep == 0 ? 'Continuer' : 'Valider',
                        onPressed: _currentStep == 0
                            ? _handleEmailStep
                            : _handlePasswordStep,
                      ),
                      const SizedBox(height: KintanaDimensions.spacingMedium),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Annuler',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ] else ...[
                      KintanaButton(
                        text: 'Retour à la connexion',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
