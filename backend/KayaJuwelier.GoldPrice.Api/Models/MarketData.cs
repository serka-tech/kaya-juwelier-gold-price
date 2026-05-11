namespace KayaJuwelier.GoldPrice.Api.Models;

/// <summary>Snapshot of all tracked market prices for the Piyasalar screen.</summary>
public record MarketData(
    // Gold (EUR/gram 24K)
    decimal GoldEurGram,
    decimal GoldBid,
    decimal GoldAsk,
    decimal GoldChangePercent,

    // Silver (EUR/gram)
    decimal SilverEurGram,
    decimal SilverBid,
    decimal SilverAsk,
    decimal SilverChangePercent,

    // Platinum (EUR/gram)
    decimal PlatinumEurGram,
    decimal PlatinumBid,
    decimal PlatinumAsk,
    decimal PlatinumChangePercent,

    // Palladium (EUR/gram)
    decimal PalladiumEurGram,
    decimal PalladiumBid,
    decimal PalladiumAsk,
    decimal PalladiumChangePercent,

    // USD/TRY
    decimal UsdTry,
    decimal UsdTryBid,
    decimal UsdTryAsk,
    decimal UsdTryChangePercent,

    // EUR/TRY
    decimal EurTry,
    decimal EurTryBid,
    decimal EurTryAsk,
    decimal EurTryChangePercent,

    // Meta
    decimal EurUsd,
    bool    IsDemo,
    string  UpdatedAt
);
