import 'package:flutter/material.dart';

import '../pwa.dart';
import 'package:study_shared/theme.dart';

/// Cài app vào điện thoại — add the web app to the home screen.
class InstallPage extends StatefulWidget {
  const InstallPage({super.key});

  @override
  State<InstallPage> createState() => _InstallPageState();
}

class _InstallPageState extends State<InstallPage> {
  late bool _ios = Pwa.platform == 'ios';
  String? _status;

  Future<void> _install() async {
    final outcome = await Pwa.prompt();
    if (!mounted) return;
    setState(() => _status = switch (outcome) {
          'accepted' => 'Đã cài xong! Mở app từ màn hình chính nhé 💕',
          'dismissed' => 'Bạn đã bấm hủy — bấm lại nút bên trên khi muốn cài nhé.',
          _ => 'Trình duyệt chưa cho cài tự động, làm theo các bước bên dưới nhé.',
        });
  }

  @override
  Widget build(BuildContext context) {
    final installed = Pwa.isStandalone;
    return Scaffold(
      appBar: AppBar(title: const Text('Cài app vào điện thoại')),
      body: PageBody(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const Center(child: Mascot(size: 130)),
            const SizedBox(height: 8),
            Text('Study For You',
                textAlign: TextAlign.center, style: brandTitle(30)),
            const SizedBox(height: 4),
            const Text('Cài app để mở nhanh từ màn hình chính,\nhọc toàn màn hình như app thật!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, height: 1.4)),
            const SizedBox(height: 20),
            if (installed)
              const SoftCard(
                child: Row(children: [
                  Icon(Icons.check_circle, color: AppColors.green),
                  SizedBox(width: 10),
                  Expanded(child: Text('Bạn đang dùng app đã cài rồi 🎉',
                      style: TextStyle(fontWeight: FontWeight.w800))),
                ]),
              )
            else ...[
              if (Pwa.canPrompt) ...[
                GradientButton(
                  label: 'Cài đặt ngay',
                  icon: Icons.download_rounded,
                  onPressed: _install,
                ),
                const SizedBox(height: 8),
              ],
              if (_status != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(_status!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.pink, fontWeight: FontWeight.w700)),
                ),
              const SizedBox(height: 8),
              _platformSwitch(),
              const SizedBox(height: 14),
              ...(_ios ? _iosSteps : _androidSteps)
                  .indexed
                  .map((e) => _Step(index: e.$1 + 1, icon: e.$2.$1, text: e.$2.$2)),
            ],
            const SizedBox(height: 20),
            const Row(
              children: [
                Expanded(child: _Perk(icon: Icons.touch_app_rounded, text: 'Mở bằng 1 chạm')),
                SizedBox(width: 10),
                Expanded(child: _Perk(icon: Icons.fullscreen_rounded, text: 'Toàn màn hình')),
                SizedBox(width: 10),
                Expanded(child: _Perk(icon: Icons.favorite_rounded, text: 'Lưu tiến độ')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _platformSwitch() {
    Widget option(String label, IconData icon, bool ios) {
      final selected = _ios == ios;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _ios = ios),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.blush : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: selected ? AppColors.pink : AppColors.muted),
                const SizedBox(width: 6),
                Text(label,
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: selected ? AppColors.pink : AppColors.muted)),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        option('iPhone', Icons.phone_iphone, true),
        option('Android', Icons.android, false),
      ]),
    );
  }
}

const _iosSteps = [
  (Icons.public, 'Mở trang web bằng Safari (không dùng được trong Messenger/Zalo — bấm "Mở bằng Safari").'),
  (Icons.ios_share, 'Bấm nút Chia sẻ (ô vuông có mũi tên lên) ở thanh dưới cùng.'),
  (Icons.add_box_outlined, 'Kéo xuống, chọn "Thêm vào MH chính".'),
  (Icons.check_circle_outline, 'Bấm "Thêm" — icon trái tim Study For You sẽ hiện trên màn hình chính.'),
];

const _androidSteps = [
  (Icons.public, 'Mở trang web bằng Chrome (nếu đang trong Messenger/Zalo thì bấm "Mở bằng trình duyệt").'),
  (Icons.more_vert, 'Bấm nút ⋮ ở góc trên bên phải.'),
  (Icons.install_mobile, 'Chọn "Cài đặt ứng dụng" hoặc "Thêm vào màn hình chính".'),
  (Icons.check_circle_outline, 'Bấm "Cài đặt" — mở app từ icon trái tim trên màn hình chính.'),
];

class _Step extends StatelessWidget {
  const _Step({required this.index, required this.icon, required this.text});

  final int index;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SoftCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  gradient: AppColors.gradient, shape: BoxShape.circle),
              child: Text('$index',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: const TextStyle(height: 1.4))),
            const SizedBox(width: 8),
            Icon(icon, color: AppColors.pink),
          ],
        ),
      ),
    );
  }
}

class _Perk extends StatelessWidget {
  const _Perk({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(color: AppColors.blush, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.pink),
          ),
          const SizedBox(height: 6),
          Text(text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w700)),
        ],
      );
}
