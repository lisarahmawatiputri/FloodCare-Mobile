import 'package:flutter/material.dart';
import 'package:floodcare_mobile/config/api_config.dart';
import 'package:floodcare_mobile/services/auth_service.dart';
import 'package:floodcare_mobile/views/profile/biodata_view.dart';
import 'package:floodcare_mobile/views/profile/logout_confirm_view.dart';
import 'package:floodcare_mobile/views/profile/verify_password_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final AuthService authService = AuthService();

  late Future<Map<String, dynamic>> userFuture;

  @override
  void initState() {
    super.initState();
    userFuture = authService.getCurrentUser();
  }

  String getUserName(Map<String, dynamic>? user) {
    if (user == null) return 'User';

    return user['name'] ??
        user['nama_lengkap'] ??
        user['display_name'] ??
        'User';
  }

  String getUserEmail(Map<String, dynamic>? user) {
    if (user == null) return '';

    return user['email']?.toString() ?? '';
  }

  String? getUserPhoto(Map<String, dynamic>? user) {
    if (user == null) return null;

    final photo = user['foto_profil'] ??
        user['photo'] ??
        user['avatar'] ??
        user['picture'] ??
        user['profile_photo_url'];

    if (photo == null || photo.toString().trim().isEmpty) {
      return null;
    }

    final photoString = photo.toString();

    if (photoString.startsWith('http://') ||
        photoString.startsWith('https://')) {
      return photoString;
    }

    return ApiConfig.getImageUrl(photoString);
  }

  bool isGoogleUser(Map<String, dynamic>? user) {
    if (user == null) return false;

    final provider = user['provider']?.toString().toLowerCase();
    final loginProvider = user['login_provider']?.toString().toLowerCase();
    final googleId = user['google_id'];

    return provider == 'google' ||
        provider == 'gmail' ||
        provider == 'google.com' ||
        loginProvider == 'google' ||
        loginProvider == 'gmail' ||
        googleId != null;
  }

  void openBiodata(Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BiodataView(
          initialUser: user,
        ),
      ),
    );
  }

  void openChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const VerifyPasswordView(),
      ),
    );
  }

  void openLogoutConfirmation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LogoutConfirmView(),
      ),
    );
  }

  Future<void> refreshUser() async {
    setState(() {
      userFuture = authService.getCurrentUser();
    });

    await userFuture;
  }

  Widget errorState(String message) {
    return RefreshIndicator(
      onRefresh: refreshUser,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 42,
                  color: Color(0xFFFF4B4B),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Gagal memuat profil',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2933),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: refreshUser,
                  child: const Text(
                    'Coba Lagi',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFF6B2C),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: userFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError && snapshot.data == null) {
              return errorState(
                snapshot.error.toString().replaceFirst('Exception: ', ''),
              );
            }

            final user = snapshot.data;
            final name = getUserName(user);
            final email = getUserEmail(user);
            final photoUrl = getUserPhoto(user);
            final googleUser = isGoogleUser(user);

            return RefreshIndicator(
              onRefresh: refreshUser,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 28),
                    Center(
                      child: Column(
                        children: [
                          _ProfileAvatar(photoUrl: photoUrl),
                          const SizedBox(height: 14),
                          Text(
                            snapshot.connectionState == ConnectionState.waiting
                                ? 'Loading...'
                                : name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1F2933),
                            ),
                          ),
                          if (email.isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Text(
                              email,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                          if (googleUser) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified_user_outlined,
                                    size: 15,
                                    color: Color(0xFF2563EB),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Login dengan Google',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                    _ProfileMenuItem(
                      icon: Icons.person_outline,
                      iconColor: const Color(0xFFFF6B2C),
                      iconBackground: const Color(0xFFFFF0E8),
                      title: 'Biodata Diri',
                      subtitle: 'Lihat informasi profil Anda',
                      onTap: () => openBiodata(user ?? {}),
                    ),
                    const SizedBox(height: 12),
                    if (!googleUser) ...[
                      _ProfileMenuItem(
                        icon: Icons.lock_outline,
                        iconColor: const Color(0xFF5364C8),
                        iconBackground: const Color(0xFFEFF1FF),
                        title: 'Ganti Password',
                        subtitle: 'Perbarui keamanan akun Anda',
                        onTap: openChangePassword,
                      ),
                      const SizedBox(height: 12),
                    ],
                    _ProfileMenuItem(
                      icon: Icons.logout_rounded,
                      iconColor: const Color(0xFFFF4B4B),
                      iconBackground: const Color(0xFFFFEEEE),
                      title: 'Keluar',
                      subtitle: 'Logout dari akun Anda',
                      onTap: openLogoutConfirmation,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? photoUrl;

  const _ProfileAvatar({
    required this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;

    return Container(
      width: 92,
      height: 92,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(
        child: hasPhoto
            ? Image.network(
                photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const _DefaultAvatar();
                },
              )
            : const _DefaultAvatar(),
      ),
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  const _DefaultAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color(0xFFC94A00),
            Color(0xFFFF6A00),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(
        Icons.person_outline,
        size: 46,
        color: Colors.white,
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: onTap,
        child: Container(
          height: 74,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 21,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2933),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 24,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}