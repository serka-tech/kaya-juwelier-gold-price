import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:image_picker/image_picker.dart';

class PickedFile {
  final Uint8List bytes;
  final String name;
  const PickedFile({required this.bytes, required this.name});
}

/// Opens a native file picker and returns the selected image.
/// Uses dart:html on web, image_picker on mobile.
Future<PickedFile?> pickImageFile() async {
  if (kIsWeb) {
    return _pickWeb();
  } else {
    return _pickMobile();
  }
}

// ── Web implementation using dart:html ────────────────────────────────────────
Future<PickedFile?> _pickWeb() {
  final completer = Completer<PickedFile?>();

  final input = html.FileUploadInputElement()
    ..accept = 'image/*'
    ..style.display = 'none';

  html.document.body!.append(input);

  input.onChange.listen((event) {
    final files = input.files;
    if (files == null || files.isEmpty) {
      input.remove();
      if (!completer.isCompleted) completer.complete(null);
      return;
    }
    final file = files[0];
    final reader = html.FileReader();
    // Use readAsDataURL — result is a plain Dart String, no JS interop issues
    reader.readAsDataUrl(file);
    reader.onLoadEnd.first.then((_) {
      input.remove();
      if (completer.isCompleted) return;
      try {
        final dataUrl = reader.result as String;
        // Format: "data:image/jpeg;base64,/9j/..."
        final base64Str = dataUrl.split(',').last;
        final bytes = base64Decode(base64Str);
        completer.complete(PickedFile(bytes: bytes, name: file.name));
      } catch (_) {
        completer.complete(null);
      }
    });
  });

  input.click();
  return completer.future;
}

// ── Mobile implementation using image_picker ──────────────────────────────────
Future<PickedFile?> _pickMobile() async {
  try {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(source: ImageSource.gallery);
    if (xfile == null) return null;
    final bytes = await xfile.readAsBytes();
    return PickedFile(bytes: bytes, name: xfile.name);
  } catch (_) {
    return null;
  }
}
