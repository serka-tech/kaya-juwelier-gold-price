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
    private readonly GoldPriceCache _goldCache;
    private readonly MarketCache    _marketCache;
    private readonly ILogger<FinnhubWebSocketService> _logger;

    // Latest prices from Finnhub
    private decimal _latestXauUsd  = 0m;
    private decimal _latestEurUsd  = 1.10m;
    private decimal _latestXagUsd  = 0m;
    private decimal _latestXptUsd  = 0m;
    private decimal _latestXpdUsd  = 0m;
    private decimal _latestUsdTry  = 0m;
    private decimal _latestEurTry  = 0m;

    // Open prices (set on first tick — used for change%)
    private decimal _openXauUsd  = 0m;
    private decimal _openXagUsd  = 0m;
    private decimal _openXptUsd  = 0m;
    private decimal _openXpdUsd  = 0m;
    private decimal _openUsdTry  = 0m;
    private decimal _openEurTry  = 0m;

    private const decimal TroyOz = 31.1035m;

    public FinnhubWebSocketService(
        IConfiguration config,
        IServiceScopeFactory scopeFactory,
        IHubContext<GoldPriceHub> hub,
        GoldPriceCache goldCache,
        MarketCache marketCache,
        ILogger<FinnhubWebSocketService> logger)
    {
        _config      = config;
        _scopeFactory = scopeFactory;
        _hub         = hub;
        _goldCache   = goldCache;
        _marketCache = marketCache;
        _logger      = logger;
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
            try   { await ConnectAndListenAsync(token, ct); }
            catch (Exception ex) when (!ct.IsCancellationRequested)
            {
                _logger.LogError(ex, "Finnhub WebSocket disconnected. Reconnecting in 5s...");
                await Task.Delay(5000, ct);
            }
        }
    }

    private async Task ConnectAndListenAsync(string token, CancellationToken ct)
    {
        using var ws  = new ClientWebSocket();
        var uri       = new Uri($"wss://ws.finnhub.io?token={token}");

        _logger.LogInformation("Connecting to Finnhub WebSocket...");
        await ws.ConnectAsync(uri, ct);
        _logger.LogInformation("Connected to Finnhub.");

        // Subscribe to all symbols
        var symbols = new[]
        {
            _config["Finnhub:GoldSymbol"]      ?? "OANDA:XAU_USD",
            _config["Finnhub:EurUsdSymbol"]    ?? "OANDA:EUR_USD",
            _config["Finnhub:SilverSymbol"]    ?? "OANDA:XAG_USD",
            _config["Finnhub:PlatinumSymbol"]  ?? "OANDA:XPT_USD",
            _config["Finnhub:PalladiumSymbol"] ?? "OANDA:XPD_USD",
            _config["Finnhub:UsdTrySymbol"]    ?? "OANDA:USD_TRY",
            _config["Finnhub:EurTrySymbol"]    ?? "OANDA:EUR_TRY",
        };

        foreach (var sym in symbols)
            await SendSubscribeAsync(ws, sym, ct);

        var buffer        = new byte[8192];
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

            if (result.MessageType == WebSocketMessageType.Close) break;

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

            var goldSym  = _config["Finnhub:GoldSymbol"]      ?? "OANDA:XAU_USD";
            var eurSym   = _config["Finnhub:EurUsdSymbol"]    ?? "OANDA:EUR_USD";
            var agSym    = _config["Finnhub:SilverSymbol"]    ?? "OANDA:XAG_USD";
            var ptSym    = _config["Finnhub:PlatinumSymbol"]  ?? "OANDA:XPT_USD";
            var pdSym    = _config["Finnhub:PalladiumSymbol"] ?? "OANDA:XPD_USD";
            var usdTrySym= _config["Finnhub:UsdTrySymbol"]    ?? "OANDA:USD_TRY";
            var eurTrySym= _config["Finnhub:EurTrySymbol"]    ?? "OANDA:EUR_TRY";

            bool goldUpdated = false;
            bool marketUpdated = false;

            foreach (var trade in msg.Data)
            {
                if (trade.Price <= 0) continue;
                if (trade.Symbol == goldSym)   { _latestXauUsd = trade.Price; SetOpen(ref _openXauUsd, trade.Price); goldUpdated = true; }
                if (trade.Symbol == eurSym)    { _latestEurUsd = trade.Price; }
                if (trade.Symbol == agSym)     { _latestXagUsd = trade.Price; SetOpen(ref _openXagUsd, trade.Price); marketUpdated = true; }
                if (trade.Symbol == ptSym)     { _latestXptUsd = trade.Price; SetOpen(ref _openXptUsd, trade.Price); marketUpdated = true; }
                if (trade.Symbol == pdSym)     { _latestXpdUsd = trade.Price; SetOpen(ref _openXpdUsd, trade.Price); marketUpdated = true; }
                if (trade.Symbol == usdTrySym) { _latestUsdTry = trade.Price; SetOpen(ref _openUsdTry, trade.Price); marketUpdated = true; }
                if (trade.Symbol == eurTrySym) { _latestEurTry = trade.Price; SetOpen(ref _openEurTry, trade.Price); marketUpdated = true; }
            }

            // Broadcast gold price on gold tick
            if (goldUpdated && _latestXauUsd > 0)
            {
                var price = GoldPriceCalculator.Build(_latestXauUsd, _latestEurUsd);
                _goldCache.Set(price);
                await _hub.Clients.All.SendAsync("ReceiveGoldPrice", price.ToDto(), ct);
                await PersistAsync(price, ct);
                marketUpdated = true; // gold change affects EUR/gram values
            }

            // Broadcast market data on any update
            if (marketUpdated && _latestXauUsd > 0)
            {
                var market = BuildMarketData(false);
                _marketCache.Set(market);
                await _hub.Clients.All.SendAsync("ReceiveMarketPrices", market, ct);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error processing Finnhub message.");
        }
    }

    // ── Market data builder ───────────────────────────────────────────────────
    private MarketData BuildMarketData(bool isDemo)
    {
        var eur = _latestEurUsd > 0 ? _latestEurUsd : 1.10m;

        // Convert USD/oz → EUR/gram
        decimal ToEurGram(decimal usdOz) =>
            usdOz > 0 ? Math.Round(usdOz / TroyOz / eur, 4) : 0m;

        decimal Bid(decimal price, decimal spread = 0.0005m) =>
            price > 0 ? Math.Round(price * (1m - spread), 4) : 0m;
        decimal Ask(decimal price, decimal spread = 0.0005m) =>
            price > 0 ? Math.Round(price * (1m + spread), 4) : 0m;

        decimal Change(decimal current, decimal open) =>
            open > 0 && current > 0
                ? Math.Round((current - open) / open * 100m, 3)
                : 0m;

        var goldEur    = ToEurGram(_latestXauUsd);
        var silverEur  = ToEurGram(_latestXagUsd);
        var platinEur  = ToEurGram(_latestXptUsd);
        var palladEur  = ToEurGram(_latestXpdUsd);

        var goldEurOpen   = ToEurGram(_openXauUsd);
        var silverEurOpen = ToEurGram(_openXagUsd);
        var platinEurOpen = ToEurGram(_openXptUsd);
        var palladEurOpen = ToEurGram(_openXpdUsd);

        return new MarketData(
            GoldEurGram:          goldEur,
            GoldBid:              Bid(goldEur),
            GoldAsk:              Ask(goldEur),
            GoldChangePercent:    Change(goldEur, goldEurOpen),

            SilverEurGram:        silverEur,
            SilverBid:            Bid(silverEur),
            SilverAsk:            Ask(silverEur),
            SilverChangePercent:  Change(silverEur, silverEurOpen),

            PlatinumEurGram:      platinEur,
            PlatinumBid:          Bid(platinEur),
            PlatinumAsk:          Ask(platinEur),
            PlatinumChangePercent: Change(platinEur, platinEurOpen),

            PalladiumEurGram:     palladEur,
            PalladiumBid:         Bid(palladEur),
            PalladiumAsk:         Ask(palladEur),
            PalladiumChangePercent: Change(palladEur, palladEurOpen),

            UsdTry:               _latestUsdTry,
            UsdTryBid:            Bid(_latestUsdTry, 0.0002m),
            UsdTryAsk:            Ask(_latestUsdTry, 0.0002m),
            UsdTryChangePercent:  Change(_latestUsdTry, _openUsdTry),

            EurTry:               _latestEurTry,
            EurTryBid:            Bid(_latestEurTry, 0.0002m),
            EurTryAsk:            Ask(_latestEurTry, 0.0002m),
            EurTryChangePercent:  Change(_latestEurTry, _openEurTry),

            EurUsd:               eur,
            IsDemo:               isDemo,
            UpdatedAt:            DateTime.UtcNow.ToString("O")
        );
    }

    private static void SetOpen(ref decimal open, decimal price)
    {
        if (open == 0m) open = price;
    }

    // ── Persist gold snapshot ─────────────────────────────────────────────────
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

    // ── Demo mode ─────────────────────────────────────────────────────────────
    private async Task RunDemoModeAsync(CancellationToken ct)
    {
        // Seed open prices for demo
        _openXauUsd = 3200m; _openXagUsd = 32m; _openXptUsd = 1000m;
        _openXpdUsd = 1100m; _openUsdTry = 38m; _openEurTry = 42m;
        _latestEurUsd = 1.10m;

        using var timer = new PeriodicTimer(TimeSpan.FromSeconds(1));
        while (await timer.WaitForNextTickAsync(ct))
        {
            var rng = Random.Shared;
            _latestXauUsd  = _openXauUsd  + (decimal)(rng.NextDouble() * 20 - 10);
            _latestXagUsd  = _openXagUsd  + (decimal)(rng.NextDouble() * 0.4 - 0.2);
            _latestXptUsd  = _openXptUsd  + (decimal)(rng.NextDouble() * 10 - 5);
            _latestXpdUsd  = _openXpdUsd  + (decimal)(rng.NextDouble() * 15 - 7.5);
            _latestUsdTry  = _openUsdTry  + (decimal)(rng.NextDouble() * 0.2 - 0.1);
            _latestEurTry  = _openEurTry  + (decimal)(rng.NextDouble() * 0.3 - 0.15);
            _latestEurUsd  = 1.08m        + (decimal)(rng.NextDouble() * 0.04);

            var price = GoldPriceCalculator.Build(_latestXauUsd, _latestEurUsd, isDemo: true);
            _goldCache.Set(price);
            await _hub.Clients.All.SendAsync("ReceiveGoldPrice", price.ToDto(), ct);

            var market = BuildMarketData(isDemo: true);
            _marketCache.Set(market);
            await _hub.Clients.All.SendAsync("ReceiveMarketPrices", market, ct);
        }
    }

    private static async Task SendSubscribeAsync(ClientWebSocket ws, string symbol, CancellationToken ct)
    {
        var msg = JsonSerializer.Serialize(new { type = "subscribe", symbol });
        await ws.SendAsync(Encoding.UTF8.GetBytes(msg), WebSocketMessageType.Text, true, ct);
    }
}
