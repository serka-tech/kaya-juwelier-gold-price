const REFRESH_MS = 60_000;

const els = {
  price24k:    document.getElementById('price-24k'),
  price22k:    document.getElementById('price-22k'),
  price21k:    document.getElementById('price-21k'),
  price18k:    document.getElementById('price-18k'),
  priceOz:     document.getElementById('price-oz'),
  statusDot:   document.getElementById('status-dot'),
  statusText:  document.getElementById('status-text'),
  lastUpdated: document.getElementById('last-updated'),
};

let prevPrices = {};

function fmt(value) {
  return new Intl.NumberFormat('de-DE', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  }).format(value);
}

function flash(el, key, newVal) {
  if (prevPrices[key] === undefined) return;
  const cls = newVal > prevPrices[key] ? 'flash-up' : newVal < prevPrices[key] ? 'flash-down' : null;
  if (!cls) return;
  el.classList.add(cls);
  setTimeout(() => el.classList.remove(cls), 1200);
}

async function fetchPrices() {
  try {
    const res = await fetch('/api/gold-price');
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const data = await res.json();

    flash(els.price24k, '24k', data.price_gram_24k);
    flash(els.price22k, '22k', data.price_gram_22k);
    flash(els.price21k, '21k', data.price_gram_21k);
    flash(els.price18k, '18k', data.price_gram_18k);

    els.price24k.textContent = fmt(data.price_gram_24k);
    els.price22k.textContent = fmt(data.price_gram_22k);
    els.price21k.textContent = fmt(data.price_gram_21k);
    els.price18k.textContent = fmt(data.price_gram_18k);
    els.priceOz.textContent  = fmt(data.price_oz);

    prevPrices = {
      '24k': data.price_gram_24k,
      '22k': data.price_gram_22k,
      '21k': data.price_gram_21k,
      '18k': data.price_gram_18k,
    };

    const ts = new Date(data.updatedAt);
    els.lastUpdated.textContent = ts.toLocaleTimeString('tr-TR');

    els.statusDot.className  = 'dot live';
    els.statusText.textContent = data.mock ? 'Demo modu' : 'Canlı veri';

  } catch (err) {
    els.statusDot.className  = 'dot error';
    els.statusText.textContent = 'Bağlantı hatası';
    console.error(err);
  }
}

fetchPrices();
setInterval(fetchPrices, REFRESH_MS);
