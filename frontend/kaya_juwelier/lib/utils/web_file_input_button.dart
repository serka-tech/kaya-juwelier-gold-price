import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
import 'package:kaya_juwelier/utils/image_picker_helper.dart';

typedef OnFilePicked = void Function(PickedFile file);

int _viewCounter = 0;

/// On web: stacks a transparent <input type="file"> over [child] via
/// HtmlElementView so the browser receives a real user-gesture click.
/// On mobile: renders [child] unchanged (caller uses pickImageFile()).
class WebFileInputButton extends StatefulWidget {
  final Widget child;
  final OnFilePicked onFilePicked;

  const WebFileInputButton({
    super.key,
    required this.child,
    required this.onFilePicked,
  });

  @override
  State<WebFileInputButton> createState() => _WebFileInputButtonState();
}

class _WebFileInputButtonState extends State<WebFileInputButton> {
  late final String _viewId;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) return;

    _viewId = 'file-input-${_viewCounter++}';

    final input = html.FileUploadInputElement()
      ..accept = 'image/*'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.opacity = '0.01' // nearly invisible but still receives clicks
      ..style.cursor = 'pointer'
      ..style.display = 'block'
      ..style.margin = '0'
      ..style.padding = '0';

    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) return;
      final file = files[0];
      final reader = html.FileReader();
      reader.readAsDataUrl(file);
      reader.onLoadEnd.first.then((_) {
        try {
          final dataUrl = reader.result.toString();
          if (!dataUrl.contains(',')) return;
          final bytes = base64Decode(dataUrl.split(',').last);
          if (mounted) {
            widget.onFilePicked(PickedFile(bytes: bytes, name: file.name));
          }
        } catch (_) {}
        input.value = ''; // reset so same file can be re-selected
      });
    });

    ui_web.platformViewRegistry.registerViewFactory(_viewId, (_) => input);
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return widget.child;

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: HtmlElementView(viewType: _viewId),
        ),
      ],
    );
  }
}
