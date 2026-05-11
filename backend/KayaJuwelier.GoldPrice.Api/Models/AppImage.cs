namespace KayaJuwelier.GoldPrice.Api.Models;

public class AppImage
{
    public string ImageKey   { get; set; } = string.Empty; // "logo", "ceyrek_altin", etc.
    public byte[] ImageData  { get; set; } = [];
    public string ContentType{ get; set; } = "image/png";
    public DateTime UpdatedAt{ get; set; } = DateTime.UtcNow;
}
