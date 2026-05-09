import 'package:flutter/material.dart';
import 'package:floodcare_mobile/services/auth_service.dart';
import 'package:floodcare_mobile/views/auth/login_view.dart';

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

  Future<void> handleLogout() async {
    await authService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginView(),
      ),
      (route) => false,
    );
  }

  String getUserName(Map<String, dynamic>? user) {
    if (user == null) return 'User';

    return user['name'] ??
        user['nama_lengkap'] ??
        user['display_name'] ??
        'User';
  }

  String? getUserPhoto(Map<String, dynamic>? user) {
    if (user == null) return null;

    final photo = user['photo'] ??
        user['avatar'] ??
        user['picture'] ??
        user['profile_photo_url'];

    if (photo == null || photo.toString().isEmpty) {
      return null;
    }

    return photo.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: userFuture,
          builder: (context, snapshot) {
            final user = snapshot.data;
            final name = getUserName(user);
            final photoUrl = getUserPhoto(user);

            return SingleChildScrollView(
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
                    onTap: () {},
                  ),

                  const SizedBox(height: 12),

                  _ProfileMenuItem(
                    icon: Icons.lock_outline,
                    iconColor: const Color(0xFF5364C8),
                    iconBackground: const Color(0xFFEFF1FF),
                    title: 'Ganti Password',
                    subtitle: 'Perbarui keamanan akun Anda',
                    onTap: () {},
                  ),

                  const SizedBox(height: 12),

                  _ProfileMenuItem(
                    icon: Icons.logout_rounded,
                    iconColor: const Color(0xFFFF4B4B),
                    iconBackground: const Color(0xFFFFEEEE),
                    title: 'Keluar',
                    subtitle: 'Logout dari akun Anda',
                    onTap: handleLogout,
                  ),
                ],
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
            color: Colors.black.withOpacity(0.08),
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
                errorBuilder: (_, __, ___) {
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
                color: Colors.black.withOpacity(0.035),
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