using KayaJuwelier.GoldPrice.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace KayaJuwelier.GoldPrice.Api.Controllers;

[ApiController]
[Route("api/market")]
public class MarketController : ControllerBase
{
    private readonly MarketCache _cache;
    public MarketController(MarketCache cache) => _cache = cache;

    // GET /api/market/current
    [HttpGet("current")]
    public IActionResult GetCurrent()
    {
        var data = _cache.Get();
        return data is null
            ? StatusCode(503, new { error = "Piyasa verisi henüz yüklenmedi." })
            : Ok(data);
    }
}
