import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaya_juwelier/core/theme/app_theme.dart';
import 'package:kaya_juwelier/models/commission_model.dart';
import 'package:kaya_juwelier/models/turkish_gold_model.dart';

// GitHub raw base URL for coin images
const _ghBase =
    'https://raw.githubusercontent.com/serka-tech/kaya-juwelier-gold-price/main/assets/';

String _img(String key) => '$_ghBase$key.png';

class TurkishGoldSection extends StatelessWidget {
  final TurkishGoldPrices prices;
  final String currencySymbol;
  final CommissionMap commMap;

  const TurkishGoldSection({
    super.key,
    required this.prices,
    this.currencySymbol = '€',
    this.commMap = const {},
  });

  @override
  Widget build(BuildContext context) {
    final fmtDec = NumberFormat('#,##0.00', 'de_DE');

    // Helper: apply commission if exists
    double c(double p, String key) => commMap[key]?.apply(p) ?? p;

    final pairs = [
      _CoinPair(
        leftName: 'Çeyrek Altın', leftEmoji: '🪙',
        leftImageUrl: _img('ceyrek_altin'),
        leftPrice: fmtDec.format(c(prices.ceyrekAltin, 'ceyrek_altin')),
        leftSub: '1.804g · 22K',
        rightName: 'Çeyrek Reşat', rightEmoji: '🏅',
        rightImageUrl: _img('ceyrek_resat'),
        rightPrice: fmtDec.format(c(prices.ceyrekResat, 'ceyrek_resat')),
        rightSub: '1.804g · 22K',
      ),
      _CoinPair(
        leftName: 'Yarım Altın', leftEmoji: '🪙',
        leftImageUrl: _img('yarim_altin'),
        leftPrice: fmtDec.format(c(prices.yarimAltin, 'yarim_altin')),
        leftSub: '3.608g · 22K',
        rightName: 'Yarım Reşat', rightEmoji: '🏅',
        rightImageUrl: _img('yarim_resat'),
        rightPrice: fmtDec.format(c(prices.yarimResat, 'yarim_resat')),
        rightSub: '3.608g · 22K',
      ),
      _CoinPair(
        leftName: 'Tam Altın', leftEmoji: '🪙',
        leftImageUrl: _img('tam_altin'),
        leftPrice: fmtDec.format(c(prices.tamAltin, 'tam_altin')),
        leftSub: '7.216g · 22K',
        rightName: 'Tam Reşat', rightEmoji: '🏅',
        rightImageUrl: _img('tam_resat'),
        rightPrice: fmtDec.format(c(prices.tamResat, 'tam_resat')),
        rightSub: '7.216g · 22K',
      ),
      _CoinPair(
        leftName: 'Gremse Altın', leftEmoji: '🪙',
        leftImageUrl: _img('gremse_altin'),
        leftPrice: fmtDec.format(c(prices.gremseAltin, 'gremse_altin')),
        leftSub: '18.04g · 22K',
        rightName: '2.5 Reşat', rightEmoji: '🏅',
        rightImageUrl: _img('iki5_resat'),
        rightPrice: fmtDec.format(c(prices.ikiNokta5, 'iki5_resat')),
        rightSub: '18.04g · 22K',
      ),
      _CoinPair(
        leftName: 'Beşli Altın', leftEmoji: '🪙',
        leftImageUrl: _img('besli_altin'),
        leftPrice: fmtDec.format(c(prices.besliAltin, 'besli_altin')),
        leftSub: '36.08g · 22K',
        rightName: 'Beşli Reşat', rightEmoji: '🏅',
        rightImageUrl: _img('besli_resat'),
        rightPrice: fmtDec.format(c(prices.besliResat, 'besli_resat')),
        rightSub: '36.08g · 22K',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Column headers ─────────────────────────────────────────────
        Container(
          color: AppTheme.background,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'ALTIN',
                  style: TextStyle(
                    color: AppTheme.textHint,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Container(width: 1, height: 12, color: AppTheme.divider),
              Expanded(
                child: Text(
                  'REŞAT',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: AppTheme.textHint,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppTheme.divider),

        // ── Coin pair rows ─────────────────────────────────────────────
        for (int i = 0; i < pairs.length; i++) ...[
          _CoinPairRow(
            pair: pairs[i],
            currencySymbol: currencySymbol,
          ),
          if (i < pairs.length - 1)
            const Divider(height: 1, color: AppTheme.divider),
        ],

        // ── Burma / Ajda (per gram) ────────────────────────────────────
        const Divider(height: 1, color: AppTheme.divider),
        _PerGramRow(
          leftName: 'Burma Bilezik',
          leftSub: '22K · gram başına',
          leftPrice: '${fmtDec.format(c(prices.burmaPerGram, 'burma'))} $currencySymbol/g',
          leftEmoji: '💍',
          leftImageUrl: _img('burma'),
          rightName: 'Ajda / Kibrit',
          rightSub: '22K · gram başına',
          rightPrice: '${fmtDec.format(c(prices.ajdaPerGram, 'ajda'))} $currencySymbol/g',
          rightEmoji: '📿',
          rightImageUrl: _img('ajda'),
        ),
        const Divider(height: 1, color: AppTheme.divider),

        // ── Disclaimer ─────────────────────────────────────────────────
        Container(
          color: AppTheme.background,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 12, color: AppTheme.textHint),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Altın para fiyatları piyasa primli hesaplanmıştır. '
                  'Güncel alım/satım fiyatları için mağazamızı arayınız.',
                  style: TextStyle(
                    color: AppTheme.textHint, fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Coin pair data ────────────────────────────────────────────────────────────
class _CoinPair {
  final String leftName, leftEmoji, leftImageUrl, leftPrice, leftSub;
  final String rightName, rightEmoji, rightImageUrl, rightPrice, rightSub;

  const _CoinPair({
    required this.leftName,
    required this.leftEmoji,
    required this.leftImageUrl,
    required this.leftPrice,
    required this.leftSub,
    required this.rightName,
    required this.rightEmoji,
    required this.rightImageUrl,
    required this.rightPrice,
    required this.rightSub,
  });
}

class _CoinPairRow extends StatelessWidget {
  final _CoinPair pair;
  final String currencySymbol;

  const _CoinPairRow({required this.pair, required this.currencySymbol});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          // ── Left: Altın ──────────────────────────────────────────────
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  _CoinIcon(
                    imageUrl: pair.leftImageUrl,
                    emoji: pair.leftEmoji,
                    bgColor: AppTheme.goldGlow,
                    borderColor: AppTheme.gold.withAlpha(60),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(pair.leftName,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            )),
                        const SizedBox(height: 2),
                        Text(pair.leftSub,
                            style: const TextStyle(
                                color: AppTheme.textHint, fontSize: 10)),
                        const SizedBox(height: 4),
                        Text('$currencySymbol ${pair.leftPrice}',
                            style: const TextStyle(
                              color: AppTheme.gold,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Divider ──────────────────────────────────────────────────
          const VerticalDivider(width: 1, color: AppTheme.divider),

          // ── Right: Reşat ─────────────────────────────────────────────
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  _CoinIcon(
                    imageUrl: pair.rightImageUrl,
                    emoji: pair.rightEmoji,
                    bgColor: const Color(0xFFF5F0FF),
                    borderColor: const Color(0xFF8B6914).withAlpha(60),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(pair.rightName,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            )),
                        const SizedBox(height: 2),
                        Text(pair.rightSub,
                            style: const TextStyle(
                                color: AppTheme.textHint, fontSize: 10)),
                        const SizedBox(height: 4),
                        Text('$currencySymbol ${pair.rightPrice}',
                            style: const TextStyle(
                              color: Color(0xFF8B6914),
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Per-gram row (Burma / Ajda) ───────────────────────────────────────────────
class _PerGramRow extends StatelessWidget {
  final String leftName, leftSub, leftPrice, leftEmoji, leftImageUrl;
  final String rightName, rightSub, rightPrice, rightEmoji, rightImageUrl;

  const _PerGramRow({
    required this.leftName,
    required this.leftSub,
    required this.leftPrice,
    required this.leftEmoji,
    required this.leftImageUrl,
    required this.rightName,
    required this.rightSub,
    required this.rightPrice,
    required this.rightEmoji,
    required this.rightImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(child: _GramCell(
              name: leftName, sub: leftSub, price: leftPrice,
              emoji: leftEmoji, imageUrl: leftImageUrl)),
          const VerticalDivider(width: 1, color: AppTheme.divider),
          Expanded(child: _GramCell(
              name: rightName, sub: rightSub, price: rightPrice,
              emoji: rightEmoji, imageUrl: rightImageUrl)),
        ],
      ),
    );
  }
}

class _GramCell extends StatelessWidget {
  final String name, sub, price, emoji, imageUrl;

  const _GramCell({
    required this.name,
    required this.sub,
    required this.price,
    required this.emoji,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _CoinIcon(
            imageUrl: imageUrl,
            emoji: emoji,
            bgColor: AppTheme.surfaceElevated,
            borderColor: AppTheme.cardBorder,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 2),
                Text(sub,
                    style: const TextStyle(
                        color: AppTheme.textHint, fontSize: 10)),
                const SizedBox(height: 4),
                Text(price,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Coin icon: loads from GitHub, falls back to emoji on error ────────────────
class _CoinIcon extends StatelessWidget {
  final String imageUrl;
  final String emoji;
  final Color bgColor;
  final Color borderColor;

  const _CoinIcon({
    required this.imageUrl,
    required this.emoji,
    required this.bgColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Image.network(
          imageUrl,
          width: 38, height: 38,
          fit: BoxFit.cover,
          // Show emoji while loading or on error
          loadingBuilder: (context, child, progress) =>
              progress == null ? child
              : Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
          errorBuilder: (context, error, stackTrace) =>
              Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
        ),
      ),
    );
  }
}
