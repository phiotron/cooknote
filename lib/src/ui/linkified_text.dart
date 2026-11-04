import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import 'messenger.dart';

final _url = RegExp(r'https?://[^\s<>"]+', caseSensitive: false);

/// Cắt dấu câu thường dính cuối URL khi viết trong câu.
String trimUrl(String url) => url.replaceFirst(RegExp(r'[.,;:!?)\]]+$'), '');

/// Tách [text] thành các đoạn; đoạn nào là URL thì `isLink` đúng (AC-09).
List<({String text, bool isLink})> splitLinks(String text) {
  final parts = <({String text, bool isLink})>[];
  var last = 0;
  for (final m in _url.allMatches(text)) {
    final url = trimUrl(m.group(0)!);
    if (m.start > last) {
      parts.add((text: text.substring(last, m.start), isLink: false));
    }
    parts.add((text: url, isLink: true));
    last = m.start + url.length;
  }
  if (last < text.length) {
    parts.add((text: text.substring(last), isLink: false));
  }
  return parts;
}

Future<void> openLink(BuildContext context, String url) async {
  final message = AppLocalizations.of(context).openLinkError;
  final ok = await launchUrl(
    Uri.parse(url),
    mode: LaunchMode.externalApplication,
  ).catchError((_) => false);
  if (!ok) showMessage(message);
}

/// Chữ có URL chạm được để mở trình duyệt (AC-09).
class LinkifiedText extends StatefulWidget {
  const LinkifiedText(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  State<LinkifiedText> createState() => _LinkifiedTextState();
}

class _LinkifiedTextState extends State<LinkifiedText> {
  final _recognizers = <TapGestureRecognizer>[];

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  TapGestureRecognizer _recognizer(VoidCallback onTap) {
    final r = TapGestureRecognizer()..onTap = onTap;
    _recognizers.add(r);
    return r;
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();
    final linkStyle = TextStyle(
      color: Theme.of(context).colorScheme.primary,
      decoration: TextDecoration.underline,
    );
    return Text.rich(
      TextSpan(
        style: widget.style,
        children: [
          for (final part in splitLinks(widget.text))
            if (part.isLink)
              TextSpan(
                text: part.text,
                style: linkStyle,
                recognizer: _recognizer(() => openLink(context, part.text)),
              )
            else
              TextSpan(text: part.text),
        ],
      ),
    );
  }
}
