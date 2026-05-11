namespace KayaJuwelier.GoldPrice.Api.Models;

public class AssetCommission
{
    public int     Id                { get; set; }
    public string  AssetKey          { get; set; } = string.Empty; // e.g. "24K"
    public string  AssetLabel        { get; set; } = string.Empty; // e.g. "24 Ayar"
    public decimal CommissionPercent { get; set; } = 0m;
    public DateTime UpdatedAt        { get; set; } = DateTime.UtcNow;
}
