using KayaJuwelier.GoldPrice.Api.DTOs;
using GoldPriceModel = KayaJuwelier.GoldPrice.Api.Models.GoldPrice;

namespace KayaJuwelier.GoldPrice.Api.Services;

/// <summary>Thread-safe in-memory store for the latest gold price.</summary>
public class GoldPriceCache
{
    private GoldPriceModel? _latest;
    private readonly object _lock = new();

    public void Set(GoldPriceModel price) { lock (_lock) { _latest = price; } }

    public GoldPriceModel? Get() { lock (_lock) { return _latest; } }

    public GoldPriceDto? GetDto() => Get()?.ToDto();
}

public static class GoldPriceExtensions
{
    public static GoldPriceDto ToDto(this GoldPriceModel p) => new(
        PriceGram24K: p.PriceGram24K,
        PriceGram22K: p.PriceGram22K,
        PriceGram21K: p.PriceGram21K,
        PriceGram18K: p.PriceGram18K,
        PriceTroyOz:  p.PriceTroyOz,
        PriceUsdOz:   p.PriceUsdOz,
        EurUsdRate:   p.EurUsdRate,
        Currency:     p.Currency,
        IsDemo:       p.IsDemo,
        UpdatedAt:    p.RecordedAt.ToString("O")
    );
}
