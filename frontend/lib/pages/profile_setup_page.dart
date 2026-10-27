import 'package:flutter/material.dart';

import '../auth.dart';
import 'package:study_shared/theme.dart';
import 'login_page.dart';

String formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

/// Shown after creating an account: asks for a name and date of birth.
class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({
    super.key,
    required this.auth,
    required this.user,
    required this.password,
  });

  final Auth auth;
  final String user;
  final String password;

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _name = TextEditingController();
  DateTime? _birthday;
  String? _error;
  bool _busy = false;

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(now.year - 20, 1, 1),
      firstDate: DateTime(1950),
      lastDate: now,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Ngày tháng năm sinh',
    );
    if (picked != null) setState(() => _birthday = picked);
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Cho mình biết tên bạn nhé');
      return;
    }
    if (_birthday == null) {
      setState(() => _error = 'Chọn ngày tháng năm sinh nhé');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.auth.saveProfile(name: name, birthday: _birthday!);
    } catch (_) {
      setState(() {
        _busy = false;
        _error = 'Không lưu được, kiểm tra mạng rồi thử lại nhé';
      });
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) =>
          LoginPage(auth: widget.auth, user: widget.user, password: widget.password),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HeartBackdrop(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Column(
                  children: [
                    const Mascot(size: 130),
                    const SizedBox(height: 12),
                    const Text('Bạn tên là gì?',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    const Text('Cho mình làm quen chút nhé! 💕',
                        style: TextStyle(color: AppColors.muted)),
                    const SizedBox(height: 28),
                    TextField(
                      controller: _name,
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _birthday == null ? _pickBirthday() : _save(),
                      decoration: const InputDecoration(
                        hintText: 'Tên của bạn',
                        prefixIcon: Icon(Icons.face_retouching_natural, color: AppColors.muted),
                      ),
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _pickBirthday,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.cake_outlined, color: AppColors.muted),
                          suffixIcon: Icon(Icons.calendar_month, color: AppColors.pink),
                        ),
                        child: Text(
                          _birthday == null ? 'Ngày tháng năm sinh' : formatDate(_birthday!),
                          style: TextStyle(
                            fontSize: 16,
                            color: _birthday == null ? AppColors.muted : AppColors.text,
                          ),
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: AppColors.red)),
                    ],
                    const SizedBox(height: 24),
                    GradientButton(
                      label: 'Tiếp tục',
                      trailingIcon: Icons.arrow_forward,
                      onPressed: _busy ? null : _save,
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
}
