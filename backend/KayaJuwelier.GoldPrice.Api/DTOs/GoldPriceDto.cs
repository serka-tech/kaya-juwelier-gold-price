namespace KayaJuwelier.GoldPrice.Api.DTOs;

public record GoldPriceDto(
    decimal PriceGram24K,
    decimal PriceGram22K,
    decimal PriceGram21K,
    decimal PriceGram18K,
    decimal PriceGram14K,
    decimal PriceTroyOz,
    decimal PriceUsdOz,
    decimal EurUsdRate,
    string  Currency,
    bool    IsDemo,
    string  UpdatedAt
);
