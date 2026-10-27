import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isar_plus/isar_plus.dart';
import 'package:study_shared/api.dart';

import 'auth.dart';
import 'db.dart';
import 'package:study_shared/theme.dart';

String _bytesKey(String username) => 'avatar_bytes:${username.trim().toLowerCase()}';
String _pathKey(String username) => 'avatar_path:${username.trim().toLowerCase()}';

/// The avatar saved on this device for [username], if any (works offline).
ImageProvider? cachedAvatar(Isar db, String username) {
  final b64 = db.setting(_bytesKey(username));
  return b64 == null ? null : MemoryImage(base64Decode(b64));
}

/// Downloads the profile's avatar if it changed, caches it, and returns it.
Future<ImageProvider?> loadAvatar(Isar db, ApiClient api, Profile profile) async {
  final path = profile.avatarPath;
  if (path == null) {
    db.setSetting(_bytesKey(profile.username), null);
    db.setSetting(_pathKey(profile.username), null);
    return null;
  }
  if (db.setting(_pathKey(profile.username)) == path) {
    return cachedAvatar(db, profile.username);
  }
  try {
    final bytes = await api.getBytes('/users/${profile.id}/avatar');
    _cache(db, profile.username, path, bytes);
    return MemoryImage(bytes);
  } catch (_) {
    return cachedAvatar(db, profile.username);
  }
}

/// Uploads a new avatar for the signed-in user.
Future<void> uploadAvatar(Isar db, ApiClient api, Profile profile, Uint8List png) async {
  final res = await api.putBytes('/me/avatar', png, 'image/png') as Map<String, dynamic>;
  _cache(db, profile.username, res['avatar_path'] as String, png);
}

/// Removes the avatar so the mascot is shown again.
Future<void> removeAvatar(Isar db, ApiClient api, Profile profile) async {
  await api.delete('/me/avatar');
  db.setSetting(_bytesKey(profile.username), null);
  db.setSetting(_pathKey(profile.username), null);
}

void _cache(Isar db, String username, String path, Uint8List bytes) {
  db.setSetting(_bytesKey(username), base64Encode(bytes));
  db.setSetting(_pathKey(username), path);
}

/// Lets the user pick a photo and returns it as a square PNG thumbnail.
Future<Uint8List?> pickAvatarPhoto() async {
  final files = await FilePicker.pickFiles(type: FileType.image);
  if (files.isEmpty) return null;
  final bytes = await files.first.xFile.readAsBytes();
  final codec = await ui.instantiateImageCodec(bytes);
  final image = (await codec.getNextFrame()).image;

  const size = 360;
  final side = min(image.width, image.height).toDouble();
  final src = Rect.fromLTWH(
      (image.width - side) / 2, (image.height - side) / 2, side, side);
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawImageRect(
    image,
    src,
    const Rect.fromLTWH(0, 0, size + 0.0, size + 0.0),
    Paint()..filterQuality = FilterQuality.high,
  );
  final thumb = await recorder.endRecording().toImage(size, size);
  final data = await thumb.toByteData(format: ui.ImageByteFormat.png);
  return data?.buffer.asUint8List();
}

/// Round profile picture, falling back to the mascot.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.image, this.size = 44});

  final ImageProvider? image;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (image == null) return MascotAvatar(size: size);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: size > 60 ? 3 : 2),
        boxShadow: [BoxShadow(color: AppColors.pink.withValues(alpha: 0.25), blurRadius: 10)],
        image: DecorationImage(
            image: image!, fit: BoxFit.cover, filterQuality: FilterQuality.medium),
      ),
    );
  }
}
