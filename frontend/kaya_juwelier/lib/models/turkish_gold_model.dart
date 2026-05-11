// Turkish gold coin & jewelry price calculator.
// All prices derived from the live 22K EUR/gram price.
// Weights: Çeyrek=1.804g, Yarım=3.608g, Tam=7.216g, Gremse=18.04g, Beşli=36.08g
// Premiums: Altın ~2.8%, Reşat ~5.7%, Burma/Ajda ~5-7%

class TurkishGoldCalculator {
  // ── Coin weights (grams) ────────────────────────────────────────────────────
  static const double wCeyrek  = 1.804;
  static const double wYarim   = 3.608;
  static const double wTam     = 7.216;
  static const double wGremse  = 18.04;
  static const double wBesli   = 36.08;

  // ── Premiums ────────────────────────────────────────────────────────────────
  static const double premiumAltin = 1.028;
  static const double premiumResat = 1.057;
  static const double premiumBurma = 1.059;
  static const double premiumAjda  = 1.075;

  static TurkishGoldPrices calculate(double priceGram22K) {
    double coin(double weight, double premium) =>
        weight * priceGram22K * premium;

    return TurkishGoldPrices(
      // Altın
      ceyrekAltin : coin(wCeyrek, premiumAltin),
      yarimAltin  : coin(wYarim,  premiumAltin),
      tamAltin    : coin(wTam,    premiumAltin),
      gremseAltin : coin(wGremse, premiumAltin),
      besliAltin  : coin(wBesli,  premiumAltin),
      // Reşat
      ceyrekResat : coin(wCeyrek, premiumResat),
      yarimResat  : coin(wYarim,  premiumResat),
      tamResat    : coin(wTam,    premiumResat),
      ikiNokta5   : coin(wGremse, premiumResat),
      besliResat  : coin(wBesli,  premiumResat),
      // Per-gram jewelry
      burmaPerGram: priceGram22K * premiumBurma,
      ajdaPerGram : priceGram22K * premiumAjda,
    );
  }
}

class TurkishGoldPrices {
  final double ceyrekAltin;
  final double yarimAltin;
  final double tamAltin;
  final double gremseAltin;
  final double besliAltin;

  final double ceyrekResat;
  final double yarimResat;
  final double tamResat;
  final double ikiNokta5;
  final double besliResat;

  final double burmaPerGram;
  final double ajdaPerGram;

  const TurkishGoldPrices({
    required this.ceyrekAltin,
    required this.yarimAltin,
    required this.tamAltin,
    required this.gremseAltin,
    required this.besliAltin,
    required this.ceyrekResat,
    required this.yarimResat,
    required this.tamResat,
    required this.ikiNokta5,
    required this.besliResat,
    required this.burmaPerGram,
    required this.ajdaPerGram,
  });
}
