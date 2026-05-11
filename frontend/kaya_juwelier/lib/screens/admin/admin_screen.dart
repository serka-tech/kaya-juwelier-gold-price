import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kaya_juwelier/core/theme/app_theme.dart';
import 'package:kaya_juwelier/models/commission_model.dart';
import 'package:kaya_juwelier/providers/commission_provider.dart';
import 'package:kaya_juwelier/providers/upload_provider.dart';
import 'package:kaya_juwelier/utils/image_picker_helper.dart';
import 'package:kaya_juwelier/utils/web_file_input_button.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  final Map<String, double> _edits = {};
  bool _saving = false;
  String? _message;
  bool _messageIsError = false;

  @override
  Widget build(BuildContext context) {
    final token     = ref.watch(authProvider).asData?.value;
    final commAsync = ref.watch(commissionProvider);
    final manifest  = ref.watch(uploadManifestProvider).asData?.value;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: SvgPicture.asset('assets/juvkaya-yataylogo.svg', height: 26),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: () async {
              final nav = Navigator.of(context);
              await ref.read(authProvider.notifier).logout();
              if (mounted) nav.pop();
            },
            icon: const Icon(Icons.logout_rounded,
                color: AppTheme.textSecondary, size: 18),
            label: const Text('Çıkış',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: commAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.gold)),
        error: (e, _) => Center(
            child: Text('Hata: $e',
                style: const TextStyle(color: AppTheme.priceDown))),
        data: (commMap) => _buildBody(token, commMap, manifest),
      ),
    );
  }

  Widget _buildBody(
      String? token, CommissionMap commMap, UploadManifest? manifest) {
    if (commMap.isEmpty) {
      return const Center(
        child: Text('Komisyon verisi bulunamadı.',
            style: TextStyle(color: AppTheme.textSecondary)),
      );
    }

    for (final entry in commMap.entries) {
      _edits.putIfAbsent(entry.key, () => entry.value.commissionPercent);
    }

    final gramKeys  = ['24K', '22K', '21K', '18K', 'troy'];
    final altinKeys = ['ceyrek_altin','yarim_altin','tam_altin','gremse_altin','besli_altin'];
    final resatKeys = ['ceyrek_resat','yarim_resat','tam_resat','iki5_resat','besli_resat'];
    final jewlKeys  = ['burma','ajda'];

    return Column(
      children: [
        // ── Message banner ──────────────────────────────────────────────────
        if (_message != null)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            color: _messageIsError ? AppTheme.priceDownBg : AppTheme.priceUpBg,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(
                  _messageIsError
                      ? Icons.error_outline
                      : Icons.check_circle_outline,
                  color: _messageIsError ? AppTheme.priceDown : AppTheme.priceUp,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(_message!,
                    style: TextStyle(
                      color: _messageIsError
                          ? AppTheme.priceDown
                          : AppTheme.priceUp,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Logo upload ───────────────────────────────────────────────
              _sectionHeader('LOGO', Icons.image_outlined),
              _LogoUploadTile(token: token, manifest: manifest),
              const SizedBox(height: 20),

              // ── Gram gold ────────────────────────────────────────────────
              _sectionHeader('GRAM ALTIN', Icons.straighten_rounded),
              ..._buildRows(commMap, gramKeys, token, manifest),
              const SizedBox(height: 20),

              _sectionHeader('ALTIN PARALAR', Icons.monetization_on_outlined),
              ..._buildRows(commMap, altinKeys, token, manifest),
              const SizedBox(height: 20),

              _sectionHeader('REŞAT PARALAR', Icons.workspace_premium_outlined),
              ..._buildRows(commMap, resatKeys, token, manifest),
              const SizedBox(height: 20),

              _sectionHeader('TAKILAR', Icons.diamond_outlined),
              ..._buildRows(commMap, jewlKeys, token, manifest),
              const SizedBox(height: 24),
            ],
          ),
        ),

        // ── Save commissions button ─────────────────────────────────────────
        Container(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            border: Border(top: BorderSide(color: AppTheme.divider)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : () => _saveAll(token),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.gold,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save_rounded, size: 20),
              label: Text(_saving ? 'Kaydediliyor...' : 'Tümünü Kaydet',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRows(CommissionMap commMap, List<String> keys,
      String? token, UploadManifest? manifest) {
    return keys
        .where((k) => commMap.containsKey(k))
        .map((k) => _CommissionRow(
              commission: commMap[k]!,
              value: _edits[k] ?? 0,
              onChanged: (v) => setState(() => _edits[k] = v),
              token: token,
              imageUrl: manifest?.fullAssetUrl(k),
            ))
        .toList();
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 4, height: 16,
            decoration: BoxDecoration(
              color: AppTheme.gold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, size: 15, color: AppTheme.textSecondary),
          const SizedBox(width: 6),
          Text(title,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              )),
        ],
      ),
    );
  }

  Future<void> _saveAll(String? token) async {
    if (token == null) {
      setState(() {
        _message = 'Oturum süresi dolmuş. Lütfen tekrar giriş yapın.';
        _messageIsError = true;
      });
      return;
    }
    setState(() {
      _saving = true;
      _message = null;
    });

    final err = await ref
        .read(commissionProvider.notifier)
        .bulkUpdate(token, Map.from(_edits));

    if (!mounted) return;
    setState(() {
      _saving = false;
      _messageIsError = err != null;
      _message = err ?? 'Komisyonlar başarıyla kaydedildi.';
    });

    if (err == null) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _message = null);
      });
    }
  }
}

// ── Logo upload tile ──────────────────────────────────────────────────────────
class _LogoUploadTile extends ConsumerStatefulWidget {
  final String? token;
  final UploadManifest? manifest;

  const _LogoUploadTile({this.token, this.manifest});

  @override
  ConsumerState<_LogoUploadTile> createState() => _LogoUploadTileState();
}

class _LogoUploadTileState extends ConsumerState<_LogoUploadTile> {
  bool _uploading = false;

  Future<void> _upload(PickedFile file) async {
    if (widget.token == null || !mounted) return;
    setState(() => _uploading = true);
    final err = await ref
        .read(uploadManifestProvider.notifier)
        .uploadLogo(widget.token!, file);
    if (!mounted) return;
    setState(() => _uploading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(err ?? 'Logo güncellendi ✓'),
      backgroundColor: err == null ? AppTheme.priceUp : AppTheme.priceDown,
    ));
  }

  // Mobile fallback
  Future<void> _pickMobile() async {
    if (widget.token == null) return;
    final file = await pickImageFile();
    if (file == null) return;
    await _upload(file);
  }

  @override
  Widget build(BuildContext context) {
    final logoUrl = widget.manifest?.fullLogoUrl();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Logo preview
          Container(
            width: 72, height: 48,
            decoration: BoxDecoration(
              color: AppTheme.goldGlow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: logoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      logoUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.image_not_supported_outlined,
                          color: AppTheme.textHint),
                    ),
                  )
                : const Center(
                    child: Icon(Icons.image_outlined,
                        color: AppTheme.textHint, size: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Uygulama Logosu',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  logoUrl != null ? 'Özel logo kullanılıyor' : 'Varsayılan SVG kullanılıyor',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          // Upload button
          _uploading
              ? const SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(
                      color: AppTheme.gold, strokeWidth: 2))
              : WebFileInputButton(
                  onFilePicked: _upload,
                  child: TextButton.icon(
                    onPressed: _pickMobile, // no-op on web (overlay handles it)
                    icon: const Icon(Icons.upload_rounded,
                        size: 16, color: AppTheme.gold),
                    label: const Text('Değiştir',
                        style: TextStyle(
                            color: AppTheme.gold, fontWeight: FontWeight.w700)),
                  ),
                ),
        ],
      ),
    );
  }
}

// ── Commission row with image upload ─────────────────────────────────────────
class _CommissionRow extends ConsumerStatefulWidget {
  final CommissionModel commission;
  final double value;
  final ValueChanged<double> onChanged;
  final String? token;
  final String? imageUrl;

  const _CommissionRow({
    required this.commission,
    required this.value,
    required this.onChanged,
    this.token,
    this.imageUrl,
  });

  @override
  ConsumerState<_CommissionRow> createState() => _CommissionRowState();
}

class _CommissionRowState extends ConsumerState<_CommissionRow> {
  late TextEditingController _ctrl;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value.toStringAsFixed(2));
  }

  @override
  void didUpdateWidget(_CommissionRow old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      final formatted = widget.value.toStringAsFixed(2);
      if (_ctrl.text != formatted) _ctrl.text = formatted;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _uploadImage(PickedFile file) async {
    if (widget.token == null || !mounted) return;
    setState(() => _uploading = true);
    final err = await ref
        .read(uploadManifestProvider.notifier)
        .uploadAsset(widget.token!, widget.commission.assetKey, file);
    if (!mounted) return;
    setState(() => _uploading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(err ?? '${widget.commission.assetLabel} görseli güncellendi ✓'),
      backgroundColor: err == null ? AppTheme.priceUp : AppTheme.priceDown,
    ));
  }

  // Mobile fallback
  Future<void> _pickMobile() async {
    if (widget.token == null) return;
    final file = await pickImageFile();
    if (file == null) return;
    await _uploadImage(file);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: image + label + upload button ──────────────────────
          Row(
            children: [
              // Asset image thumbnail (clickable on mobile)
              WebFileInputButton(
                onFilePicked: _uploadImage,
                child: GestureDetector(
                  onTap: _pickMobile,
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.goldGlow,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: _uploading
                        ? const Center(
                            child: SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  color: AppTheme.gold, strokeWidth: 2),
                            ))
                        : widget.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  widget.imageUrl!,
                                  fit: BoxFit.cover,
                                  width: 44, height: 44,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.add_photo_alternate_outlined,
                                          color: AppTheme.textHint, size: 20),
                                ),
                              )
                            : const Icon(Icons.add_photo_alternate_outlined,
                                color: AppTheme.textHint, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Label
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.commission.assetLabel,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        )),
                    Text(widget.commission.assetKey,
                        style: const TextStyle(
                            color: AppTheme.textHint, fontSize: 11)),
                  ],
                ),
              ),

              // Upload button
              WebFileInputButton(
                onFilePicked: _uploadImage,
                child: TextButton(
                  onPressed: _uploading ? null : _pickMobile,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Görsel',
                      style: TextStyle(color: AppTheme.gold, fontSize: 12)),
                ),
              ),

              // Percent input
              SizedBox(
                width: 70,
                child: TextField(
                  controller: _ctrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppTheme.gold,
                      fontWeight: FontWeight.w800,
                      fontSize: 14),
                  decoration: InputDecoration(
                    suffixText: '%',
                    suffixStyle:
                        const TextStyle(color: AppTheme.textHint, fontSize: 12),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: AppTheme.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: AppTheme.gold, width: 1.5),
                    ),
                  ),
                  onChanged: (v) {
                    final parsed = double.tryParse(v);
                    if (parsed != null && parsed >= 0 && parsed <= 100) {
                      widget.onChanged(parsed);
                    }
                  },
                ),
              ),
            ],
          ),

          // ── Slider ─────────────────────────────────────────────────────────
          Slider(
            value: widget.value.clamp(0, 20),
            min: 0, max: 20, divisions: 200,
            activeColor: AppTheme.gold,
            inactiveColor: AppTheme.divider,
            onChanged: (v) {
              widget.onChanged(double.parse(v.toStringAsFixed(2)));
              _ctrl.text = v.toStringAsFixed(2);
            },
          ),
        ],
      ),
    );
  }
}
