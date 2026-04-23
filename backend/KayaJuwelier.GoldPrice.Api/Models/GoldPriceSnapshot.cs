using System.ComponentModel.DataAnnotations.Schema;

namespace KayaJuwelier.GoldPrice.Api.Models;

[Table("gold_price_snapshots")]
public class GoldPriceSnapshot
{
    public long     Id           { get; set; }
    public decimal  PriceGram24K { get; set; }
    public decimal  PriceGram22K { get; set; }
    public decimal  PriceGram21K { get; set; }
    public decimal  PriceGram18K { get; set; }
    public decimal  PriceTroyOz  { get; set; }
    public decimal  PriceUsdOz   { get; set; }
    public decimal  EurUsdRate   { get; set; }
    public string   Currency     { get; set; } = "EUR";
    public string   Source       { get; set; } = "live";
    public DateTime RecordedAt   { get; set; }
}
