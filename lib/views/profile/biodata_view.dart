import 'dart:io';
import 'package:floodcare_mobile/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:floodcare_mobile/utils/colors.dart';

class BiodataView extends StatefulWidget {
  final Map<String, dynamic> initialUser;

  const BiodataView({
    super.key,
    required this.initialUser,
  });

  @override
  State<BiodataView> createState() => _BiodataViewState();
}

class _BiodataViewState extends State<BiodataView> {
  final AuthService authService = AuthService();
  final ImagePicker imagePicker = ImagePicker();

  File? selectedPhoto;
  String? updatedPhotoUrl;

  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController addressController;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: _readString(
        widget.initialUser,
        ['name', 'nama_lengkap', 'display_name'],
      ),
    );

    emailController = TextEditingController(
      text: _readString(
        widget.initialUser,
        ['email'],
      ),
    );

    phoneController = TextEditingController(
      text: _readString(
        widget.initialUser,
        ['no_telepon', 'phone', 'phone_number', 'telepon'],
      ),
    );

    addressController = TextEditingController(
      text: _readString(
        widget.initialUser,
        ['alamat', 'address'],
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  String _readString(
    Map<String, dynamic> data,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = data[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return fallback;
  }
  String? get photoUrl {
    if (updatedPhotoUrl != null && updatedPhotoUrl!.isNotEmpty) {
      return updatedPhotoUrl;
    }

    final photo = widget.initialUser['foto_profil_url'] ??
        widget.initialUser['foto_profil'] ??
        widget.initialUser['photo'] ??
        widget.initialUser['avatar'] ??
        widget.initialUser['picture'] ??
        widget.initialUser['profile_photo_url'];

    if (photo == null || photo.toString().trim().isEmpty) {
      return null;
    }

    return photo.toString();
  }

  Future<void> handleChangePhoto() async {
  if (isSaving) return;

  final pickedFile = await imagePicker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 80,
  );

  if (pickedFile == null) {
    return;
  }

  final file = File(pickedFile.path);

  setState(() {
    selectedPhoto = file;
    isSaving = true;
  });

  try {
    final response = await authService.updateProfilePhoto(
      photo: file,
    );

    final user = response['user'];

    if (!mounted) return;

    setState(() {
      isSaving = false;
      updatedPhotoUrl = user is Map<String, dynamic>
          ? (user['foto_profil_url'] ?? user['foto_profil'])?.toString()
          : null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Foto profil berhasil diperbarui'),
      ),
    );
  } catch (e) {
    if (!mounted) return;

    setState(() {
      isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      ),
    );
  }
}

  Future<void> handleSave() async {
    if (isSaving) return;

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final address = addressController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama lengkap tidak boleh kosong'),
        ),
      );
      return;
    }

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email tidak boleh kosong'),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await authService.updateProfile(
    namaLengkap: name,
    noTelepon: phone.isEmpty ? null : phone,
    alamat: address.isEmpty ? null : address,
  );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Biodata berhasil disimpan')),
  );

  Navigator.pop(context);
} catch (e) {
  if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
  );
  } finally {
  if (mounted) setState(() => isSaving = false);
  }
}

  Widget profilePhoto() {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;

    return Column(
      children: [
        Container(
          width: 104,
          height: 104,
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
          child: selectedPhoto != null
              ? Image.file(
                  selectedPhoto!,
                  fit: BoxFit.cover,
                )
              : hasPhoto
                  ? Image.network(
                      photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const _OrangeAvatar();
                      },
                    )
                  : const _OrangeAvatar(),
        ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: handleChangePhoto,
          child: const Text(
            'Ubah Foto',
            style: TextStyle(
              fontFamily: 'interbold',
              fontSize: 14,
              color: Color(0xFFD95A00),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget inputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'interbold',
            fontSize: 13,
            letterSpacing: 0.5,
            color: Color(0xFF7477B8),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(
            fontFamily: 'intersemibold',
            fontSize: 14,
            color: Color(0xFF4B5563),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'intermedium',
              fontSize: 14,
              color: Color(0xFFB8B8B8),
            ),
            prefixIcon: Icon(
              icon,
              color: const Color(0xFFB8B8B8),
              size: 22,
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
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1.3,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget saveButton() {
    return GestureDetector(
      onTap: isSaving ? null : handleSave,
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
          child: isSaving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.4,
                  ),
                )
              : const Text(
                  'Simpan Perubahan',
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
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

              const SizedBox(height: 32),

              Center(
                child: profilePhoto(),
              ),

              const SizedBox(height: 28),

              inputField(
                label: 'Nama Lengkap',
                controller: nameController,
                icon: Icons.person_outline,
                hint: 'Masukkan nama lengkap',
              ),

              const SizedBox(height: 18),

              inputField(
                label: 'Email',
                controller: emailController,
                icon: Icons.mail_outline,
                hint: 'Masukkan email',
                keyboardType: TextInputType.emailAddress,
                readOnly: true,
              ),

              const SizedBox(height: 18),

              inputField(
                label: 'No. Telepon',
                controller: phoneController,
                icon: Icons.phone_outlined,
                hint: 'Masukkan nomor telepon',
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 18),

              inputField(
                label: 'Alamat',
                controller: addressController,
                icon: Icons.location_on_outlined,
                hint: 'Masukkan alamat',
              ),

              const SizedBox(height: 32),

              saveButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrangeAvatar extends StatelessWidget {
  const _OrangeAvatar();

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
        size: 54,
        color: Colors.white,
      ),
    );
  }
}