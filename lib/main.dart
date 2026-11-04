import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'src/app.dart';
import 'src/data/image_store.dart';
import 'src/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Chỉ màn hình dọc (SPEC mục 5); Android còn khóa trong manifest.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final docs = await getApplicationDocumentsDirectory();
  final images = ImageStore(Directory(p.join(docs.path, 'photos')));
  final temp = await getTemporaryDirectory();
  final info = await PackageInfo.fromPlatform();
  runApp(
    ProviderScope(
      overrides: [
        imageStoreProvider.overrideWithValue(images),
        appDirsProvider.overrideWithValue(
          AppDirs(
            temp: Directory(p.join(temp.path, 'backup')),
            safety: Directory(p.join(docs.path, 'safety')),
          ),
        ),
        appVersionProvider.overrideWithValue(
          '${info.version}+${info.buildNumber}',
        ),
      ],
      child: const CookNoteApp(),
    ),
  );
}
