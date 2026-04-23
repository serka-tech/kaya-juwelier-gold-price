using KayaJuwelier.GoldPrice.Api.Data;
using KayaJuwelier.GoldPrice.Api.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace KayaJuwelier.GoldPrice.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class GoldPriceController : ControllerBase
{
    private readonly GoldPriceCache _cache;

    public GoldPriceController(GoldPriceCache cache) => _cache = cache;

    // ─────────────────────────────────────────────────────────────────
    // GET /api/goldprice/current
    // ─────────────────────────────────────────────────────────────────
    /// <summary>Returns the latest cached gold price (REST fallback).</summary>
    [HttpGet("current")]
    public IActionResult GetCurrent()
    {
        var dto = _cache.GetDto();
        return dto is null
            ? StatusCode(503, new { error = "Fiyat henüz yüklenmedi, lütfen bekleyin." })
            : Ok(dto);
    }

    // ─────────────────────────────────────────────────────────────────
    // GET /api/goldprice/stats?range=1h|1d|5d|1m|3m|1y
    // Returns open/high/low/close/change% for the selected range
    // ─────────────────────────────────────────────────────────────────
    [HttpGet("stats")]
    public async Task<IActionResult> GetStats(
        [FromQuery] string range,
        [FromServices] AppDbContext db,
        CancellationToken ct)
    {
        var since = RangeSince(range);

        var rows = await db.GoldPriceSnapshots
            .Where(s => s.RecordedAt >= since)
            .OrderBy(s => s.RecordedAt)
            .Select(s => new { s.PriceGram24K, s.PriceTroyOz, s.PriceUsdOz })
            .ToListAsync(ct);

        if (rows.Count == 0)
            return Ok(new { open = 0, high = 0, low = 0, close = 0, changePercent = 0 });

        var open  = (double)rows.First().PriceGram24K;
        var close = (double)rows.Last().PriceGram24K;
        var high  = rows.Max(r => (double)r.PriceGram24K);
        var low   = rows.Min(r => (double)r.PriceGram24K);
        var chg   = open > 0 ? Math.Round((close - open) / open * 100.0, 3) : 0;

        return Ok(new { open, high, low, close, changePercent = chg });
    }

    // ─────────────────────────────────────────────────────────────────
    // GET /api/goldprice/chart?range=1h|1d|5d|1m|3m|1y
    // Returns aggregated chart points
    // ─────────────────────────────────────────────────────────────────
    [HttpGet("chart")]
    public async Task<IActionResult> GetChart(
        [FromQuery] string range,
        [FromServices] AppDbContext db,
        CancellationToken ct)
    {
        var (since, bucketMinutes) = RangeSinceAndBucket(range);

        var rows = await db.GoldPriceSnapshots
            .Where(s => s.RecordedAt >= since)
            .OrderBy(s => s.RecordedAt)
            .ToListAsync(ct);

        var points = rows
            .GroupBy(s => new DateTime(
                s.RecordedAt.Year, s.RecordedAt.Month, s.RecordedAt.Day,
                s.RecordedAt.Hour,
                (s.RecordedAt.Minute / bucketMinutes) * bucketMinutes,
                0))
            .Select(g => new
            {
                t           = g.Key,
                price24K    = Math.Round(g.Average(x => (double)x.PriceGram24K), 4),
                price22K    = Math.Round(g.Average(x => (double)x.PriceGram22K), 4),
                price18K    = Math.Round(g.Average(x => (double)x.PriceGram18K), 4),
                priceTroyOz = Math.Round(g.Average(x => (double)x.PriceTroyOz),  4),
                priceUsdOz  = Math.Round(g.Average(x => (double)x.PriceUsdOz),   2),
            })
            .OrderBy(p => p.t)
            .ToList();

        return Ok(points);
    }

    // ─────────────────────────────────────────────────────────────────
    // GET /api/goldprice/history?limit=100
    // ─────────────────────────────────────────────────────────────────
    [HttpGet("history")]
    public async Task<IActionResult> GetHistory(
        [FromQuery] int limit,
        [FromServices] AppDbContext db,
        CancellationToken ct)
    {
        limit = Math.Clamp(limit == 0 ? 100 : limit, 1, 500);
        var rows = await db.GoldPriceSnapshots
            .OrderByDescending(s => s.RecordedAt)
            .Take(limit)
            .ToListAsync(ct);
        return Ok(rows);
    }

    // ─────────────────────────────────────────────────────────────────
    // Helpers
    // ─────────────────────────────────────────────────────────────────
    private static DateTime RangeSince(string range) => range switch
    {
        "1h" => DateTime.UtcNow.AddHours(-1),
        "1d" => DateTime.UtcNow.AddDays(-1),
        "5d" => DateTime.UtcNow.AddDays(-5),
        "1m" => DateTime.UtcNow.AddMonths(-1),
        "3m" => DateTime.UtcNow.AddMonths(-3),
        "1y" => DateTime.UtcNow.AddYears(-1),
        _    => DateTime.UtcNow.AddHours(-1),
    };

    private static (DateTime since, int bucketMinutes) RangeSinceAndBucket(string range) => range switch
    {
        "1h" => (DateTime.UtcNow.AddHours(-1),   1),
        "1d" => (DateTime.UtcNow.AddDays(-1),    5),
        "5d" => (DateTime.UtcNow.AddDays(-5),    30),
        "1m" => (DateTime.UtcNow.AddMonths(-1),  120),
        "3m" => (DateTime.UtcNow.AddMonths(-3),  360),
        "1y" => (DateTime.UtcNow.AddYears(-1),   1440),
        _    => (DateTime.UtcNow.AddHours(-1),   1),
    };
}
