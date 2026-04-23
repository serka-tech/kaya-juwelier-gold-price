using Microsoft.EntityFrameworkCore;
using KayaJuwelier.GoldPrice.Api.Models;

namespace KayaJuwelier.GoldPrice.Api.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<GoldPriceSnapshot> GoldPriceSnapshots => Set<GoldPriceSnapshot>();

    protected override void OnModelCreating(ModelBuilder b)
    {
        b.Entity<GoldPriceSnapshot>(e =>
        {
            e.ToTable("gold_price_snapshots");
            e.HasKey(x => x.Id);
            e.Property(x => x.PriceGram24K).HasPrecision(10, 4);
            e.Property(x => x.PriceGram22K).HasPrecision(10, 4);
            e.Property(x => x.PriceGram21K).HasPrecision(10, 4);
            e.Property(x => x.PriceGram18K).HasPrecision(10, 4);
            e.Property(x => x.PriceTroyOz ).HasPrecision(12, 4);
            e.Property(x => x.PriceUsdOz  ).HasPrecision(12, 4);
            e.Property(x => x.EurUsdRate  ).HasPrecision(10, 6);
            e.Property(x => x.Currency    ).HasMaxLength(3);
            e.Property(x => x.Source      ).HasMaxLength(10);
            e.HasIndex(x => x.RecordedAt);
        });
    }
}
