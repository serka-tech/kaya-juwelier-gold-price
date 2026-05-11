using KayaJuwelier.GoldPrice.Api.Models;

namespace KayaJuwelier.GoldPrice.Api.Services;

public static class GoldPriceCalculator
{
    private const decimal TroyOzToGrams = 31.1035m;

    public static decimal Calc14K(decimal p24) => Round(p24 * 14m / 24m);
    public static decimal Calc18K(decimal p24) => Round(p24 * 18m / 24m);
    public static decimal Calc21K(decimal p24) => Round(p24 * 21m / 24m);
    public static decimal Calc22K(decimal p24) => Round(p24 * 22m / 24m);
    public static decimal GramToOz(decimal p24) => Round(p24 * TroyOzToGrams);

    /// <summary>Converts USD/troy oz to EUR/gram (24K)</summary>
    public static decimal UsdOzToEurGram24K(decimal usdOz, decimal eurUsd)
        => Round(usdOz / TroyOzToGrams / eurUsd);

    public static Models.GoldPrice Build(decimal usdOz, decimal eurUsd, bool isDemo = false)
    {
        var gram24k = UsdOzToEurGram24K(usdOz, eurUsd);
        return new Models.GoldPrice(
            PriceGram24K: gram24k,
            PriceGram22K: Calc22K(gram24k),
            PriceGram21K: Calc21K(gram24k),
            PriceGram18K: Calc18K(gram24k),
            PriceGram14K: Calc14K(gram24k),
            PriceTroyOz:  GramToOz(gram24k),
            PriceUsdOz:   Round(usdOz),
            EurUsdRate:   Round(eurUsd),
            Currency:     "EUR",
            IsDemo:       isDemo,
            RecordedAt:   DateTime.UtcNow
        );
    }

    public static Models.GoldPrice GenerateDemo()
    {
        var usdOz  = 3200m + (decimal)(Random.Shared.NextDouble() * 100.0);
        var eurUsd = 1.08m + (decimal)(Random.Shared.NextDouble() * 0.04);
        return Build(usdOz, eurUsd, isDemo: true);
    }

    private static decimal Round(decimal v) =>
        Math.Round(v, 4, MidpointRounding.AwayFromZero);
}
