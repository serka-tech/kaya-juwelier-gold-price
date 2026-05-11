using System.Text;
using KayaJuwelier.GoldPrice.Api.Data;
using KayaJuwelier.GoldPrice.Api.Hubs;
using KayaJuwelier.GoldPrice.Api.Models;
using KayaJuwelier.GoldPrice.Api.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

var builder = WebApplication.CreateBuilder(args);

// --- Database ---
var connStr = builder.Configuration.GetConnectionString("Default")!;
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseMySql(connStr, ServerVersion.AutoDetect(connStr)));

// --- JWT Authentication ---
var jwtKey = builder.Configuration["Jwt:Key"]!;
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer           = true,
            ValidateAudience         = true,
            ValidateLifetime         = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer              = builder.Configuration["Jwt:Issuer"],
            ValidAudience            = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey         = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(jwtKey))
        };
    });
builder.Services.AddAuthorization();

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

builder.Services.Configure<HostOptions>(options =>
    options.BackgroundServiceExceptionBehavior = BackgroundServiceExceptionBehavior.Ignore);

// --- CORS ---
builder.Services.AddCors(options =>
    options.AddPolicy("AllowFlutter", policy =>
        policy
            .SetIsOriginAllowed(origin =>
            {
                if (string.IsNullOrEmpty(origin)) return false;
                var host = new Uri(origin).Host;
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

// --- Auto-migrate & seed ---
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    db.Database.Migrate();
    await SeedAsync(db, builder.Configuration);
}

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("AllowFlutter");
app.UseDefaultFiles();
app.UseStaticFiles();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.MapHub<GoldPriceHub>("/hubs/goldprice");
// Fallback: serve Flutter web app for any non-API route
app.MapFallbackToFile("index.html");

app.Run();

// ── Seed admin user + default commissions ─────────────────────────────────────
static async Task SeedAsync(AppDbContext db, IConfiguration config)
{
    // Admin user
    var adminUser = config["AdminSeed:Username"] ?? "admin";
    var adminPass = config["AdminSeed:Password"] ?? "admin123";

    if (!db.AdminUsers.Any(u => u.Username == adminUser))
    {
        db.AdminUsers.Add(new AdminUser
        {
            Username     = adminUser,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(adminPass),
            CreatedAt    = DateTime.UtcNow
        });
        await db.SaveChangesAsync();
    }

    // Default commissions (0% for all assets)
    var defaults = new[]
    {
        ("24K",           "24 Ayar"),
        ("22K",           "22 Ayar"),
        ("21K",           "21 Ayar"),
        ("18K",           "18 Ayar"),
        ("troy",          "Troy Ons"),
        ("ceyrek_altin",  "Çeyrek Altın"),
        ("yarim_altin",   "Yarım Altın"),
        ("tam_altin",     "Tam Altın"),
        ("gremse_altin",  "Gremse Altın"),
        ("besli_altin",   "Beşli Altın"),
        ("ceyrek_resat",  "Çeyrek Reşat"),
        ("yarim_resat",   "Yarım Reşat"),
        ("tam_resat",     "Tam Reşat"),
        ("iki5_resat",    "2.5 Reşat"),
        ("besli_resat",   "Beşli Reşat"),
        ("burma",         "Burma Bilezik"),
        ("ajda",          "Ajda / Kibrit"),
    };

    foreach (var (key, label) in defaults)
    {
        if (!db.AssetCommissions.Any(c => c.AssetKey == key))
        {
            db.AssetCommissions.Add(new AssetCommission
            {
                AssetKey          = key,
                AssetLabel        = label,
                CommissionPercent = 0m,
                UpdatedAt         = DateTime.UtcNow
            });
        }
    }
    await db.SaveChangesAsync();
}
