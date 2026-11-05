import 'dart:io';

import 'package:cooknote/src/scan/ocr_accuracy.dart';
import 'package:flutter_test/flutter_test.dart';

// Bộ mẫu AC-25: test/scan/ocr_samples/ (cách làm: README.md trong thư mục đó).
const _samplesDir = 'test/scan/ocr_samples';
const _minPagesPerLanguage = 5;
const _meanThreshold = 0.90; // AC-25, đề xuất trong khảo sát mục 5
const _pageThreshold = 0.80;

class _Sample {
  _Sample(this.id, this.reference, this.recognized);

  final String id;
  final String reference;
  final String recognized;

  String get language => id.split('-').first;
  double get accuracy => characterAccuracy(recognized, reference);
  double get folded =>
      characterAccuracy(recognized, reference, ignoreDiacritics: true);
}

List<_Sample> _loadSamples() {
  final dir = Directory(_samplesDir);
  if (!dir.existsSync()) return const [];
  final out = <_Sample>[];
  for (final ref in dir.listSync().whereType<File>()) {
    final name = ref.uri.pathSegments.last;
    if (!name.endsWith('.ref.txt')) continue;
    final id = name.substring(0, name.length - '.ref.txt'.length);
    final ocr = File('$_samplesDir/$id.ocr.txt');
    if (!ocr.existsSync()) continue;
    out.add(_Sample(id, ref.readAsStringSync(), ocr.readAsStringSync()));
  }
  out.sort((a, b) => a.id.compareTo(b.id));
  return out;
}

void main() {
  group('normalizeForAccuracy', () {
    test('dấu tách (NFD, mọi thứ tự) thành dấu dựng sẵn', () {
      // "Phở bò" gõ kiểu tổ hợp: o + móc + hỏi.
      expect(normalizeForAccuracy('Pho\u031B\u0309 bo\u0300'), 'Phở bò');
      // "ệ": dấu nặng trước hay sau dấu mũ đều thành một ký tự.
      expect(normalizeForAccuracy('e\u0323\u0302'), 'ệ');
      expect(normalizeForAccuracy('e\u0302\u0323'), 'ệ');
      // Chữ dựng sẵn một nửa + dấu thanh tách.
      expect(normalizeForAccuracy('ê\u0323'), 'ệ');
      expect(normalizeForAccuracy('A\u0306\u0301'), 'Ắ');
    });

    test('gộp khoảng trắng và xuống dòng', () {
      expect(
        normalizeForAccuracy('  Nguyên  liệu:\n\n500 g\tthịt bò \n'),
        'Nguyên liệu: 500 g thịt bò',
      );
    });

    test('bỏ dấu giữ hoa thường, đ thành d', () {
      expect(
        normalizeForAccuracy(
          'Đường phèn, ỚT, nước mắm',
          ignoreDiacritics: true,
        ),
        'Duong phen, OT, nuoc mam',
      );
      expect(
        normalizeForAccuracy('Phe\u0302\u0301', ignoreDiacritics: true),
        'Phe',
      );
      expect(
        normalizeForAccuracy('crème brûlée', ignoreDiacritics: true),
        'creme brulee',
      );
    });

    test(
      'đủ 132 nguyên âm có dấu tiếng Việt (66 thường + 66 hoa) giữ nguyên',
      () {
        const all =
            'àáảãạăằắẳẵặâầấẩẫậèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợ'
            'ùúủũụưừứửữựỳýỷỹỵ';
        expect(all.runes.length, 66);
        expect(normalizeForAccuracy(all), all);
        final upper = all.toUpperCase();
        expect(upper.runes.length, 66);
        expect(normalizeForAccuracy(upper), upper);
        expect(
          normalizeForAccuracy(all, ignoreDiacritics: true),
          'a' * 17 + 'e' * 11 + 'i' * 5 + 'o' * 17 + 'u' * 11 + 'y' * 5,
        );
      },
    );
  });

  group('levenshtein', () {
    test('các trường hợp cơ bản', () {
      expect(levenshtein('', ''), 0);
      expect(levenshtein('abc', ''), 3);
      expect(levenshtein('', 'abc'), 3);
      expect(levenshtein('kitten', 'sitting'), 3);
      expect(levenshtein('bò', 'bo'), 1); // một ký tự, không phải hai byte
    });
  });

  group('characterAccuracy', () {
    test('trùng khớp = 1, kể cả khác dạng Unicode và khoảng trắng', () {
      expect(characterAccuracy('Phở  bò\n', 'Pho\u031B\u0309 bo\u0300'), 1);
    });

    test('lỗi dấu chỉ bị trừ ở bản có dấu', () {
      const ref = 'Nước mắm'; // 8 ký tự
      const got = 'Nuoc mam'; // sai 3 ký tự (ư, ớ, ắ)
      expect(characterAccuracy(got, ref), closeTo(1 - 3 / 8, 1e-9));
      expect(characterAccuracy(got, ref, ignoreDiacritics: true), 1);
    });

    test('nhận ra nhiều rác hơn chữ chuẩn thì chặn về 0', () {
      expect(characterAccuracy('xxxxxxxxxxxx', 'ab'), 0);
    });

    test('chuẩn rỗng', () {
      expect(characterAccuracy('', ''), 1);
      expect(characterAccuracy('a', ' '), 0);
    });

    test('ví dụ có số: 1 lỗi trên 20 ký tự = 95%', () {
      const ref = '2 thìa nước mắm ngon'; // 20 ký tự
      expect(ref.runes.length, 20);
      expect(
        characterAccuracy('2 thìa nưóc mắm ngon', ref),
        closeTo(0.95, 1e-9),
      );
    });
  });

  group('bộ mẫu AC-25 (test/scan/ocr_samples)', () {
    final samples = _loadSamples();
    final vi = samples.where((s) => s.language == 'vi').toList();
    final en = samples.where((s) => s.language == 'en').toList();

    test('định dạng mẫu và in bảng kết quả', () {
      for (final s in samples) {
        // ignore: avoid_print
        print(
          '${s.id.padRight(12)} '
          'đúng ${(s.accuracy * 100).toStringAsFixed(1)}% · '
          'bỏ dấu ${(s.folded * 100).toStringAsFixed(1)}%',
        );
        expect(s.reference.trim(), isNotEmpty, reason: '${s.id}.ref.txt rỗng');
      }
    });

    final complete =
        vi.length >= _minPagesPerLanguage && en.length >= _minPagesPerLanguage;
    for (final (lang, set) in [('vi', vi), ('en', en)]) {
      test(
        'AC-25 $lang: trung bình ≥ ${(_meanThreshold * 100).round()}%, '
        'không trang nào < ${(_pageThreshold * 100).round()}%',
        () {
          final mean =
              set.map((s) => s.accuracy).reduce((a, b) => a + b) / set.length;
          for (final s in set) {
            expect(
              s.accuracy,
              greaterThanOrEqualTo(_pageThreshold),
              reason: s.id,
            );
          }
          expect(mean, greaterThanOrEqualTo(_meanThreshold));
        },
        skip: complete
            ? false
            : 'Chưa đủ mẫu: cần ≥ $_minPagesPerLanguage trang vi-* và en-* '
                  '(có ${vi.length} vi, ${en.length} en). CHƯA kiểm chứng AC-25.',
      );
    }
  });
}
