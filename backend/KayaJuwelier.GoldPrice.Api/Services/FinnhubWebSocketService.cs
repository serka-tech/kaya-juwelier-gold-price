using System.Net.WebSockets;
using System.Text;
using System.Text.Json;
using KayaJuwelier.GoldPrice.Api.Data;
using KayaJuwelier.GoldPrice.Api.Hubs;
using KayaJuwelier.GoldPrice.Api.Models;
using Microsoft.AspNetCore.SignalR;

namespace KayaJuwelier.GoldPrice.Api.Services;

public class FinnhubWebSocketService : BackgroundService
{
    private readonly IConfiguration _config;
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly IHubContext<GoldPriceHub> _hub;
    private readonly GoldPriceCache _cache;
    private readonly ILogger<FinnhubWebSocketService> _logger;

    private decimal _latestXauUsd = 0m;
    private decimal _latestEurUsd = 1.10m; // safe default

    public FinnhubWebSocketService(
        IConfiguration config,
        IServiceScopeFactory scopeFactory,
        IHubContext<GoldPriceHub> hub,
        GoldPriceCache cache,
        ILogger<FinnhubWebSocketService> logger)
    {
        _config = config;
        _scopeFactory = scopeFactory;
        _hub = hub;
        _cache = cache;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken ct)
    {
        var token = _config["Finnhub:Token"];

        if (string.IsNullOrWhiteSpace(token))
        {
            _logger.LogWarning("Finnhub token not configured — running in demo mode.");
            await RunDemoModeAsync(ct);
            return;
        }

        while (!ct.IsCancellationRequested)
        {
            try
            {
                await ConnectAndListenAsync(token, ct);
            }
            catch (Exception ex) when (!ct.IsCancellationRequested)
            {
                _logger.LogError(ex, "Finnhub WebSocket disconnected. Reconnecting in 5s...");
                await Task.Delay(5000, ct);
            }
        }
    }

    private async Task ConnectAndListenAsync(string token, CancellationToken ct)
    {
        using var ws = new ClientWebSocket();
        var uri = new Uri($"wss://ws.finnhub.io?token={token}");

        _logger.LogInformation("Connecting to Finnhub WebSocket...");
        await ws.ConnectAsync(uri, ct);
        _logger.LogInformation("Connected to Finnhub.");

        var goldSymbol  = _config["Finnhub:GoldSymbol"]  ?? "OANDA:XAU_USD";
        var eurUsdSymbol = _config["Finnhub:EurUsdSymbol"] ?? "OANDA:EUR_USD";

        await SendSubscribeAsync(ws, goldSymbol,  ct);
        await SendSubscribeAsync(ws, eurUsdSymbol, ct);

        var buffer = new byte[8192];
        var messageBuffer = new System.IO.MemoryStream();

        while (ws.State == WebSocketState.Open && !ct.IsCancellationRequested)
        {
            WebSocketReceiveResult result;
            messageBuffer.SetLength(0);

            do
            {
                result = await ws.ReceiveAsync(buffer, ct);
                if (result.MessageType == WebSocketMessageType.Close) break;
                messageBuffer.Write(buffer, 0, result.Count);
            }
            while (!result.EndOfMessage);

            if (result.MessageType == WebSocketMessageType.Close)
                break;

            var json = Encoding.UTF8.GetString(messageBuffer.ToArray());
            await ProcessMessageAsync(json, ct);
        }
    }

    private async Task ProcessMessageAsync(string json, CancellationToken ct)
    {
        try
        {
            var msg = JsonSerializer.Deserialize<FinnhubTradeMessage>(json);
            if (msg?.Type != "trade" || msg.Data == null) return;

            var goldSymbol   = _config["Finnhub:GoldSymbol"]   ?? "OANDA:XAU_USD";
            var eurUsdSymbol = _config["Finnhub:EurUsdSymbol"]  ?? "OANDA:EUR_USD";

            bool updated = false;
            foreach (var trade in msg.Data)
            {
                if (trade.Symbol == goldSymbol  && trade.Price > 0) { _latestXauUsd = trade.Price; updated = true; }
                if (trade.Symbol == eurUsdSymbol && trade.Price > 0) { _latestEurUsd = trade.Price; }
            }

            if (!updated || _latestXauUsd <= 0) return;

            var price = GoldPriceCalculator.Build(_latestXauUsd, _latestEurUsd);
            _cache.Set(price);

            await _hub.Clients.All.SendAsync("ReceiveGoldPrice", price.ToDto(), ct);
            await PersistAsync(price, ct);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error processing Finnhub message.");
        }
    }

    private async Task PersistAsync(Models.GoldPrice price, CancellationToken ct)
    {
        try
        {
            using var scope = _scopeFactory.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
            db.GoldPriceSnapshots.Add(new GoldPriceSnapshot
            {
                PriceGram24K = price.PriceGram24K,
                PriceGram22K = price.PriceGram22K,
                PriceGram21K = price.PriceGram21K,
                PriceGram18K = price.PriceGram18K,
                PriceGram14K = price.PriceGram14K,
                PriceTroyOz  = price.PriceTroyOz,
                PriceUsdOz   = price.PriceUsdOz,
                EurUsdRate   = price.EurUsdRate,
                Currency     = price.Currency,
                Source       = "live",
                RecordedAt   = price.RecordedAt
            });
            await db.SaveChangesAsync(ct);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Failed to persist price snapshot.");
        }
    }

    private async Task RunDemoModeAsync(CancellationToken ct)
    {
        // Simulate second-by-second price updates in demo mode
        using var timer = new PeriodicTimer(TimeSpan.FromSeconds(1));
        while (await timer.WaitForNextTickAsync(ct))
        {
            var price = GoldPriceCalculator.GenerateDemo();
            _cache.Set(price);
            await _hub.Clients.All.SendAsync("ReceiveGoldPrice", price.ToDto(), ct);
        }
    }

    private static async Task SendSubscribeAsync(ClientWebSocket ws, string symbol, CancellationToken ct)
    {
        var msg = JsonSerializer.Serialize(new { type = "subscribe", symbol });
        await ws.SendAsync(Encoding.UTF8.GetBytes(msg), WebSocketMessageType.Text, true, ct);
    }
}
