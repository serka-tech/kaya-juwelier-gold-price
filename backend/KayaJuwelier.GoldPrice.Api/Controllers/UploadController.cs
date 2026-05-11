using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using KayaJuwelier.GoldPrice.Api.Data;
using KayaJuwelier.GoldPrice.Api.Models;

namespace KayaJuwelier.GoldPrice.Api.Controllers;

[ApiController]
[Route("api/upload")]
public class UploadController : ControllerBase
{
    private readonly AppDbContext _db;
    private static readonly string[] AllowedImageTypes =
        ["image/jpeg", "image/png", "image/gif", "image/webp", "image/svg+xml"];

    public UploadController(AppDbContext db) => _db = db;

    // ── Upload admin page (plain HTML, no Flutter) ────────────────────────────
    [AllowAnonymous]
    [HttpGet("/upload-panel")]
    public IActionResult UploadPanel()
    {
        return Content(UploadPageHtml, "text/html; charset=utf-8");
    }

    // ── Serve image from DB ───────────────────────────────────────────────────
    [AllowAnonymous]
    [HttpGet("image/{key}")]
    public async Task<IActionResult> GetImage(string key)
    {
        var img = await _db.AppImages.FindAsync(key);
        if (img == null) return NotFound();
        return File(img.ImageData, img.ContentType);
    }

    // ── Upload logo ───────────────────────────────────────────────────────────
    [Authorize]
    [HttpPost("logo")]
    public async Task<IActionResult> UploadLogo(IFormFile file)
        => await SaveImage(file, "logo");

    // ── Upload asset image ────────────────────────────────────────────────────
    [Authorize]
    [HttpPost("asset/{assetKey}")]
    public async Task<IActionResult> UploadAsset(string assetKey, IFormFile file)
    {
        assetKey = assetKey.Replace("..", "").Replace("/", "").Replace("\\", "");
        return await SaveImage(file, assetKey);
    }

    // ── Manifest: which image keys exist + their timestamps ──────────────────
    [AllowAnonymous]
    [HttpGet("manifest")]
    public async Task<IActionResult> GetManifest()
    {
        var images = await _db.AppImages
            .Select(x => new { x.ImageKey, x.UpdatedAt })
            .ToListAsync();

        var result = images.ToDictionary(
            x => x.ImageKey,
            x => x.UpdatedAt.ToString("o") // ISO timestamp for cache busting
        );

        return Ok(result);
    }

    // ── Helper ────────────────────────────────────────────────────────────────
    private async Task<IActionResult> SaveImage(IFormFile? file, string key)
    {
        if (file == null || file.Length == 0)
            return BadRequest(new { message = "Dosya boş." });

        // Determine content type — Flutter web may send application/octet-stream
        var contentType = file.ContentType?.ToLower() ?? "application/octet-stream";
        if (contentType == "application/octet-stream" || contentType == "binary/octet-stream")
        {
            var ext = Path.GetExtension(file.FileName).ToLowerInvariant();
            contentType = ext switch
            {
                ".jpg" or ".jpeg" => "image/jpeg",
                ".png"            => "image/png",
                ".gif"            => "image/gif",
                ".webp"           => "image/webp",
                ".svg"            => "image/svg+xml",
                _                 => contentType
            };
        }

        if (!AllowedImageTypes.Any(t => contentType.Contains(t.Split('/')[1])))
            return BadRequest(new { message = "Geçersiz dosya türü. JPG, PNG, GIF, WEBP veya SVG yükleyin." });

        using var ms = new MemoryStream();
        await file.CopyToAsync(ms);
        var data = ms.ToArray();

        var existing = await _db.AppImages.FindAsync(key);
        if (existing != null)
        {
            existing.ImageData   = data;
            existing.ContentType = contentType;
            existing.UpdatedAt   = DateTime.UtcNow;
        }
        else
        {
            _db.AppImages.Add(new AppImage
            {
                ImageKey    = key,
                ImageData   = data,
                ContentType = contentType,
                UpdatedAt   = DateTime.UtcNow,
            });
        }

        await _db.SaveChangesAsync();
        return Ok(new { url = $"/api/upload/image/{key}" });
    }

    // ── Embedded upload panel HTML ────────────────────────────────────────────
    private const string UploadPageHtml = """
<!DOCTYPE html>
<html lang="tr">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Kaya Juwelier – Görsel Yönetimi</title>
<style>
*{box-sizing:border-box;margin:0;padding:0}
body{background:#1a1a2e;color:#e0e0e0;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;min-height:100vh;padding:24px 16px}
h1{color:#d4af37;font-size:22px;margin-bottom:4px}
.sub{color:#888;font-size:13px;margin-bottom:24px}
.card{background:#252540;border:1px solid #333360;border-radius:12px;padding:20px;margin-bottom:16px}
.card h2{font-size:12px;color:#d4af37;margin-bottom:14px;text-transform:uppercase;letter-spacing:1px}
label.lbl{display:block;font-size:13px;color:#aaa;margin-bottom:6px}
input[type=text],input[type=password]{width:100%;padding:10px 12px;background:#1a1a2e;border:1px solid #444;border-radius:8px;color:#fff;font-size:14px;outline:none}
input[type=text]:focus,input[type=password]:focus{border-color:#d4af37}
.row{display:flex;align-items:center;gap:10px;margin-bottom:10px;flex-wrap:wrap}
.albl{flex:1;min-width:120px;font-size:13px;color:#ccc}
img.prev{width:48px;height:48px;border-radius:8px;object-fit:cover;border:1px solid #444;flex-shrink:0}
.ph{width:48px;height:48px;border-radius:8px;background:#1a1a2e;border:1px dashed #555;display:flex;align-items:center;justify-content:center;color:#555;font-size:18px;flex-shrink:0}
input[type=file]{display:none}
.btn{padding:8px 14px;background:transparent;border:1px solid #d4af37;border-radius:8px;color:#d4af37;font-size:13px;cursor:pointer;white-space:nowrap;flex-shrink:0}
.btn:hover{background:rgba(212,175,55,.1)}
.st{font-size:12px;min-width:80px}
.st.ok{color:#4caf50}.st.err{color:#e53935}.st.busy{color:#d4af37}
</style>
</head>
<body>
<h1>JUWELIER KAYA</h1>
<p class="sub">Görsel Yönetim Paneli</p>

<div class="card">
  <h2>Giriş</h2>
  <label class="lbl">Admin Token (Uygulamadan kopyalayın)</label>
  <input type="password" id="tok" placeholder="eyJhbGci...">
</div>

<div class="card">
  <h2>Logo</h2>
  <div class="row">
    <div class="ph" id="prev_logo">🖼</div>
    <span class="albl">Uygulama Logosu</span>
    <label class="btn" for="f_logo">Dosya Seç</label>
    <input type="file" id="f_logo" accept="image/*">
    <span class="st" id="st_logo"></span>
  </div>
</div>

<div class="card">
  <h2>Altın Görselleri</h2>
  <div id="assets"></div>
</div>

<script>
const API='';
const ASSETS=[
  {key:'24K',label:'24 Ayar Altın'},{key:'22K',label:'22 Ayar Altın'},
  {key:'21K',label:'21 Ayar Altın'},{key:'18K',label:'18 Ayar Altın'},
  {key:'troy',label:'Troy Ons'},
  {key:'ceyrek_altin',label:'Çeyrek Altın'},{key:'yarim_altin',label:'Yarım Altın'},
  {key:'tam_altin',label:'Tam Altın'},{key:'gremse_altin',label:'Gremse Altın'},
  {key:'besli_altin',label:'Beşli Altın'},
  {key:'ceyrek_resat',label:'Çeyrek Reşat'},{key:'yarim_resat',label:'Yarım Reşat'},
  {key:'tam_resat',label:'Tam Reşat'},{key:'iki5_resat',label:'2.5 Reşat'},
  {key:'besli_resat',label:'Beşli Reşat'},
  {key:'burma',label:'Burma Bilezik'},{key:'ajda',label:'Ajda Bilezik'}
];

const container=document.getElementById('assets');
ASSETS.forEach(a=>{
  container.insertAdjacentHTML('beforeend',`
    <div class="row">
      <div class="ph" id="prev_${a.key}">🥇</div>
      <span class="albl">${a.label}</span>
      <label class="btn" for="f_${a.key}">Dosya Seç</label>
      <input type="file" id="f_${a.key}" accept="image/*">
      <span class="st" id="st_${a.key}"></span>
    </div>`);
  document.getElementById('f_'+a.key).onchange=()=>upload('/api/upload/asset/'+a.key,a.key);
});

document.getElementById('f_logo').onchange=()=>upload('/api/upload/logo','logo');

const HDR={'ngrok-skip-browser-warning':'true'};

async function upload(path,key){
  const tok=document.getElementById('tok').value.trim();
  const file=document.getElementById('f_'+key).files[0];
  const st=document.getElementById('st_'+key);
  if(!tok){st.textContent='Token girin!';st.className='st err';return;}
  if(!file)return;
  st.textContent='Yükleniyor...';st.className='st busy';
  const fd=new FormData();fd.append('file',file);
  try{
    const r=await fetch(API+path,{method:'POST',headers:{...HDR,'Authorization':'Bearer '+tok},body:fd});
    if(r.ok){
      st.textContent='✓ Güncellendi';st.className='st ok';
      const ts=encodeURIComponent(new Date().toISOString());
      const el=document.getElementById('prev_'+key);
      const img=document.createElement('img');
      img.className='prev';img.id='prev_'+key;
      img.src=API+'/api/upload/image/'+key+'?v='+ts;
      el.replaceWith(img);
    }else{st.textContent='Hata '+r.status;st.className='st err';}
  }catch(e){st.textContent='Bağlantı hatası';st.className='st err';}
}

// Load existing images
(async()=>{
  try{
    const r=await fetch(API+'/api/upload/manifest',{headers:HDR});
    if(!r.ok)return;
    const data=await r.json();
    Object.entries(data).forEach(([k,ts])=>{
      const el=document.getElementById('prev_'+k);
      if(!el)return;
      const img=document.createElement('img');
      img.className='prev';img.id='prev_'+k;
      img.src=API+'/api/upload/image/'+k+'?v='+encodeURIComponent(ts);
      el.replaceWith(img);
    });
  }catch(_){}
})();
</script>
</body>
</html>
""";
}
