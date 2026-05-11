using KayaJuwelier.GoldPrice.Api.Models;

namespace KayaJuwelier.GoldPrice.Api.Services;

/// <summary>Thread-safe in-memory store for the latest market prices.</summary>
public class MarketCache
{
    private MarketData? _latest;
    private readonly object _lock = new();

    public void Set(MarketData data) { lock (_lock) { _latest = data; } }
    public MarketData? Get()         { lock (_lock) { return _latest;  } }
}
