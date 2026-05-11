using KayaJuwelier.GoldPrice.Api.Services;
using Microsoft.AspNetCore.SignalR;

namespace KayaJuwelier.GoldPrice.Api.Hubs;

public class GoldPriceHub : Hub
{
    private readonly GoldPriceCache _goldCache;
    private readonly MarketCache    _marketCache;

    public GoldPriceHub(GoldPriceCache goldCache, MarketCache marketCache)
    {
        _goldCache   = goldCache;
        _marketCache = marketCache;
    }

    /// <summary>Sends the latest cached gold price to the connecting client.</summary>
    public async Task GetCurrentPrice()
    {
        var dto = _goldCache.GetDto();
        if (dto is not null)
            await Clients.Caller.SendAsync("ReceiveGoldPrice", dto);
    }

    /// <summary>Sends the latest cached market prices to the connecting client.</summary>
    public async Task GetCurrentMarket()
    {
        var data = _marketCache.Get();
        if (data is not null)
            await Clients.Caller.SendAsync("ReceiveMarketPrices", data);
    }
}
