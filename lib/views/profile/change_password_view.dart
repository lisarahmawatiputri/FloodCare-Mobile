import 'package:flutter/material.dart';
import 'package:floodcare_mobile/utils/colors.dart';
import 'package:floodcare_mobile/viewmodels/auth_viewmodel.dart';

class ChangePasswordView extends StatefulWidget {
  final String currentPassword;

  const ChangePasswordView({
    super.key,
    required this.currentPassword,
  });

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final AuthViewModel authViewModel = AuthViewModel();

  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    authViewModel.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> handleUpdatePassword() async {
    final success = await authViewModel.changePassword(
      currentPassword: widget.currentPassword,
      newPassword: newPasswordController.text,
      confirmPassword: confirmPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      showMessage('Password berhasil diperbarui');
      Navigator.pop(context);
    } else {
      showMessage(authViewModel.errorMessage ?? 'Gagal memperbarui password');
    }
  }

  Widget passwordInput({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'interbold',
            fontSize: 13,
            letterSpacing: 0.7,
            color: Color(0xFF7477B8),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          textInputAction: textInputAction,
          onFieldSubmitted: (_) {
            if (textInputAction == TextInputAction.done) {
              handleUpdatePassword();
            }
          },
          style: const TextStyle(
            fontFamily: 'intersemibold',
            fontSize: 14,
            color: Color(0xFF4B5563),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'intermedium',
              fontSize: 13,
              color: Color(0xFFB8B8B8),
            ),
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: Color(0xFFB8B8B8),
              size: 21,
            ),
            suffixIcon: GestureDetector(
              onTap: onToggle,
              child: Icon(
                obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFFB8B8B8),
                size: 21,
              ),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: const BorderSide(
                color: Color(0xFF8F969C),
                width: 1.3,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: const BorderSide(
                color: Color(0xFFFF6A00),
                width: 1.6,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget updateButton() {
    return AnimatedBuilder(
      animation: authViewModel,
      builder: (context, _) {
        return GestureDetector(
          onTap: authViewModel.isLoading ? null : handleUpdatePassword,
          child: Container(
            height: 58,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: orangeGradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6A00).withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: authViewModel.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.4,
                      ),
                    )
                  : const Text(
                      'Perbarui Password',
                      style: TextStyle(
                        fontFamily: 'interbold',
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(28, 18, 28, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(100),
                onTap: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.arrow_back,
                    size: 25,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              const SizedBox(height: 52),
              const Center(
                child: Text(
                  'Ganti Password',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'jakartabold',
                    fontSize: 28,
                    color: Color(0xFF1F2933),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Password minimal 8 karakter dengan huruf besar,\nhuruf kecil, dan simbol untuk keamanan lebih baik.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'intermedium',
                    fontSize: 14,
                    height: 1.45,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              passwordInput(
                label: 'Password Baru',
                hint: 'Masukkan password baru',
                controller: newPasswordController,
                obscureText: obscureNewPassword,
                onToggle: () {
                  setState(() {
                    obscureNewPassword = !obscureNewPassword;
                  });
                },
              ),
              const SizedBox(height: 18),
              passwordInput(
                label: 'Konfirmasi Password',
                hint: 'Masukkan ulang password',
                controller: confirmPasswordController,
                obscureText: obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                onToggle: () {
                  setState(() {
                    obscureConfirmPassword = !obscureConfirmPassword;
                  });
                },
              ),
              const SizedBox(height: 28),
              updateButton(),
            ],
          ),
        ),
      ),
    );
  }
}