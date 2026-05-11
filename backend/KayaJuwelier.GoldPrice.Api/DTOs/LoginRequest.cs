namespace KayaJuwelier.GoldPrice.Api.DTOs;

public record LoginRequest(string Username, string Password);
public record LoginResponse(string Token, string Username);
public record CommissionDto(string AssetKey, string AssetLabel, decimal CommissionPercent);
public record UpdateCommissionRequest(string AssetKey, decimal CommissionPercent);
