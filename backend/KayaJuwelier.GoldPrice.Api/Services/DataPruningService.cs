using KayaJuwelier.GoldPrice.Api.Data;
using Microsoft.EntityFrameworkCore;

namespace KayaJuwelier.GoldPrice.Api.Services;

/// <summary>
/// Runs every 6 hours and deletes price snapshots older than 1 year.
/// Keeps the database lean without manual maintenance.
/// </summary>
public class DataPruningService : BackgroundService
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<DataPruningService> _logger;

    public DataPruningService(IServiceScopeFactory scopeFactory, ILogger<DataPruningService> logger)
    {
        _scopeFactory = scopeFactory;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken ct)
    {
        // Wait 2 minutes after startup before first prune
        await Task.Delay(TimeSpan.FromMinutes(2), ct);

        using var timer = new PeriodicTimer(TimeSpan.FromHours(6));
        do
        {
            await PruneAsync(ct);
        }
        while (await timer.WaitForNextTickAsync(ct));
    }

    private async Task PruneAsync(CancellationToken ct)
    {
        try
        {
            using var scope = _scopeFactory.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();

            var cutoff = DateTime.UtcNow.AddYears(-1);

            // Use bulk delete for efficiency
            var deleted = await db.GoldPriceSnapshots
                .Where(s => s.RecordedAt < cutoff)
                .ExecuteDeleteAsync(ct);

            if (deleted > 0)
                _logger.LogInformation("DataPruning: deleted {Count} snapshots older than 1 year.", deleted);

            // Also thin out data older than 30 days: keep only 1 row per hour
            // (avoid DB growing too large from second-by-second ticks over months)
            await ThinOldDataAsync(db, ct);
        }
        catch (Exception ex) when (!ct.IsCancellationRequested)
        {
            _logger.LogWarning(ex, "DataPruning failed.");
        }
    }

    /// <summary>
    /// For data 30-365 days old: keep only the first row per hour bucket.
    /// This reduces ~3600 rows/hour down to 1 row/hour for old data.
    /// </summary>
    private static async Task ThinOldDataAsync(AppDbContext db, CancellationToken ct)
    {
        var thirtyDaysAgo = DateTime.UtcNow.AddDays(-30);
        var oneYearAgo    = DateTime.UtcNow.AddYears(-1);

        // Load candidate rows (old data) — group by hour, keep lowest Id per group
        var toKeep = await db.GoldPriceSnapshots
            .Where(s => s.RecordedAt >= oneYearAgo && s.RecordedAt < thirtyDaysAgo)
            .GroupBy(s => new
            {
                s.RecordedAt.Year,
                s.RecordedAt.Month,
                s.RecordedAt.Day,
                s.RecordedAt.Hour,
            })
            .Select(g => g.Min(x => x.Id))
            .ToListAsync(ct);

        if (toKeep.Count == 0) return;

        var deleted = await db.GoldPriceSnapshots
            .Where(s => s.RecordedAt >= oneYearAgo
                     && s.RecordedAt < thirtyDaysAgo
                     && !toKeep.Contains(s.Id))
            .ExecuteDeleteAsync(ct);

        if (deleted > 0)
            Console.WriteLine($"[DataPruning] Thinned {deleted} old rows (kept 1/hour for 30d-1y range).");
    }
}
