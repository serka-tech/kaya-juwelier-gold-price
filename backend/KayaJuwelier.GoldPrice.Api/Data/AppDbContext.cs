using Microsoft.EntityFrameworkCore;
using KayaJuwelier.GoldPrice.Api.Models;

namespace KayaJuwelier.GoldPrice.Api.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<GoldPriceSnapshot> GoldPriceSnapshots => Set<GoldPriceSnapshot>();
    public DbSet<AdminUser>         AdminUsers          => Set<AdminUser>();
    public DbSet<AssetCommission>   AssetCommissions    => Set<AssetCommission>();
    public DbSet<AppImage>          AppImages           => Set<AppImage>();

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

        b.Entity<AdminUser>(e =>
        {
            e.ToTable("admin_users");
            e.HasKey(x => x.Id);
            e.Property(x => x.Username).HasMaxLength(50).IsRequired();
            e.HasIndex(x => x.Username).IsUnique();
            e.Property(x => x.PasswordHash).HasMaxLength(100).IsRequired();
        });

        b.Entity<AssetCommission>(e =>
        {
            e.ToTable("asset_commissions");
            e.HasKey(x => x.Id);
            e.Property(x => x.AssetKey).HasMaxLength(30).IsRequired();
            e.HasIndex(x => x.AssetKey).IsUnique();
            e.Property(x => x.AssetLabel).HasMaxLength(60).IsRequired();
            e.Property(x => x.CommissionPercent).HasPrecision(5, 2);
        });

        b.Entity<AppImage>(e =>
        {
            e.ToTable("app_images");
            e.HasKey(x => x.ImageKey);
            e.Property(x => x.ImageKey).HasMaxLength(50).IsRequired();
            e.Property(x => x.ContentType).HasMaxLength(50);
            e.Property(x => x.ImageData).HasColumnType("LONGBLOB");
        });
    }
}
