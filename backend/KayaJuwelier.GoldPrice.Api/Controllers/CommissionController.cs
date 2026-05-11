using KayaJuwelier.GoldPrice.Api.Data;
using KayaJuwelier.GoldPrice.Api.DTOs;
using KayaJuwelier.GoldPrice.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace KayaJuwelier.GoldPrice.Api.Controllers;

[ApiController]
[Route("api/commissions")]
public class CommissionController : ControllerBase
{
    private readonly AppDbContext _db;

    public CommissionController(AppDbContext db) => _db = db;

    // GET /api/commissions  — public (Flutter reads this)
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var list = await _db.AssetCommissions
            .OrderBy(x => x.Id)
            .Select(x => new CommissionDto(x.AssetKey, x.AssetLabel, x.CommissionPercent))
            .ToListAsync();
        return Ok(list);
    }

    // PUT /api/commissions  — admin only
    [HttpPut]
    [Authorize]
    public async Task<IActionResult> Update([FromBody] UpdateCommissionRequest req)
    {
        if (req.CommissionPercent < 0 || req.CommissionPercent > 100)
            return BadRequest(new { message = "Komisyon 0-100 arasında olmalıdır." });

        var item = await _db.AssetCommissions
            .FirstOrDefaultAsync(x => x.AssetKey == req.AssetKey);

        if (item == null) return NotFound(new { message = "Asset bulunamadı." });

        item.CommissionPercent = req.CommissionPercent;
        item.UpdatedAt         = DateTime.UtcNow;
        await _db.SaveChangesAsync();
        return Ok(new CommissionDto(item.AssetKey, item.AssetLabel, item.CommissionPercent));
    }

    // PUT /api/commissions/bulk  — update all at once
    [HttpPut("bulk")]
    [Authorize]
    public async Task<IActionResult> BulkUpdate([FromBody] List<UpdateCommissionRequest> requests)
    {
        foreach (var req in requests)
        {
            if (req.CommissionPercent < 0 || req.CommissionPercent > 100) continue;
            var item = await _db.AssetCommissions
                .FirstOrDefaultAsync(x => x.AssetKey == req.AssetKey);
            if (item == null) continue;
            item.CommissionPercent = req.CommissionPercent;
            item.UpdatedAt         = DateTime.UtcNow;
        }
        await _db.SaveChangesAsync();
        return Ok(new { message = "Komisyonlar güncellendi." });
    }
}
