using KayaJuwelier.GoldPrice.Api.Data;
using KayaJuwelier.GoldPrice.Api.Hubs;
using KayaJuwelier.GoldPrice.Api.Services;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// --- Database (MySQL via Pomelo EF Core) ---
var connStr = builder.Configuration.GetConnectionString("Default")!;
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseMySql(connStr, ServerVersion.AutoDetect(connStr)));

// --- SignalR ---
builder.Services.AddSignalR();

// --- Controllers + Swagger ---
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// --- App Services ---
builder.Services.AddSingleton<GoldPriceCache>();
builder.Services.AddHostedService<FinnhubWebSocketService>();
builder.Services.AddHostedService<DataPruningService>();

// Prevent app from stopping when BackgroundService is cancelled on shutdown
builder.Services.Configure<HostOptions>(options =>
    options.BackgroundServiceExceptionBehavior = BackgroundServiceExceptionBehavior.Ignore);

// --- CORS: Flutter web + Android emulator + physical devices on local network ---
builder.Services.AddCors(options =>
    options.AddPolicy("AllowFlutter", policy =>
        policy
            .SetIsOriginAllowed(origin =>
            {
                if (string.IsNullOrEmpty(origin)) return false;
                var host = new Uri(origin).Host;
                // Allow localhost, Android emulator (10.0.2.2), and any 192.168.x.x LAN address
                return host == "localhost"
                    || host == "127.0.0.1"
                    || host == "10.0.2.2"
                    || host.StartsWith("192.168.")
                    || host.StartsWith("10.");
            })
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials()));

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("AllowFlutter");
app.MapControllers();
app.MapHub<GoldPriceHub>("/hubs/goldprice");

app.Run();
