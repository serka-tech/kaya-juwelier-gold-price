using KayaJuwelier.GoldPrice.Api.Services;
using Microsoft.AspNetCore.SignalR;

namespace KayaJuwelier.GoldPrice.Api.Hubs;

public class GoldPriceHub : Hub
{
    private readonly GoldPriceCache _cache;

    public GoldPriceHub(GoldPriceCache cache) => _cache = cache;

    /// <summary>
    /// Called by Flutter client immediately after connecting to receive
    /// the latest cached price without waiting for the next Finnhub tick.
    /// </summary>
    public async Task GetCurrentPrice()
    {
        var dto = _cache.GetDto();
        if (dto is not null)
            await Clients.Caller.SendAsync("ReceiveGoldPrice", dto);
    }
}
