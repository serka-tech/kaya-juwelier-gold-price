using System.Text.Json.Serialization;

namespace KayaJuwelier.GoldPrice.Api.Models;

public class FinnhubTradeMessage
{
    [JsonPropertyName("type")]
    public string Type { get; set; } = string.Empty;

    [JsonPropertyName("data")]
    public List<FinnhubTrade>? Data { get; set; }
}

public class FinnhubTrade
{
    [JsonPropertyName("s")]
    public string Symbol { get; set; } = string.Empty;

    [JsonPropertyName("p")]
    public decimal Price { get; set; }

    [JsonPropertyName("t")]
    public long Timestamp { get; set; }

    [JsonPropertyName("v")]
    public decimal Volume { get; set; }
}
