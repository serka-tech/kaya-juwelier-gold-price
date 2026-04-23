namespace KayaJuwelier.GoldPrice.Api.Models;

public record GoldPrice(
    decimal PriceGram24K,
    decimal PriceGram22K,
    decimal PriceGram21K,
    decimal PriceGram18K,
    decimal PriceTroyOz,
    decimal PriceUsdOz,
    decimal EurUsdRate,
    string  Currency,
    bool    IsDemo,
    DateTime RecordedAt
);
