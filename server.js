require('dotenv').config();
const express = require('express');
const axios = require('axios');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.static('public'));

// Cache to avoid hitting rate limits
let priceCache = null;
let cacheTimestamp = 0;
const CACHE_TTL_MS = 60 * 1000; // 1 minute

app.get('/api/gold-price', async (req, res) => {
  try {
    const now = Date.now();

    if (priceCache && (now - cacheTimestamp) < CACHE_TTL_MS) {
      return res.json({ ...priceCache, cached: true });
    }

    const apiKey = process.env.GOLD_API_KEY;

    if (!apiKey) {
      // Return mock data when no API key is configured
      const mockData = getMockPrices();
      priceCache = mockData;
      cacheTimestamp = now;
      return res.json({ ...mockData, mock: true });
    }

    const response = await axios.get('https://www.goldapi.io/api/XAU/EUR', {
      headers: {
        'x-access-token': apiKey,
        'Content-Type': 'application/json'
      }
    });

    const data = response.data;
    const result = {
      price_gram_18k: +(data.price_gram_18k).toFixed(2),
      price_gram_21k: +(data.price_gram_21k).toFixed(2),
      price_gram_22k: +(data.price_gram_22k).toFixed(2),
      price_gram_24k: +(data.price_gram_24k).toFixed(2),
      price_oz:       +(data.price).toFixed(2),
      currency:       data.currency,
      timestamp:      data.timestamp,
      updatedAt:      new Date().toISOString()
    };

    priceCache = result;
    cacheTimestamp = now;
    res.json(result);

  } catch (err) {
    console.error('Gold API error:', err.message);
    res.status(500).json({ error: 'Failed to fetch gold prices', details: err.message });
  }
});

function getMockPrices() {
  const base24k = 55 + Math.random() * 5; // ~55–60 EUR/g
  return {
    price_gram_24k: +base24k.toFixed(2),
    price_gram_22k: +(base24k * (22 / 24)).toFixed(2),
    price_gram_21k: +(base24k * (21 / 24)).toFixed(2),
    price_gram_18k: +(base24k * (18 / 24)).toFixed(2),
    price_oz:       +(base24k * 31.1035).toFixed(2),
    currency:       'EUR',
    timestamp:      Math.floor(Date.now() / 1000),
    updatedAt:      new Date().toISOString()
  };
}

app.listen(PORT, () => {
  console.log(`Kaya Juwelier Gold Price server running on http://localhost:${PORT}`);
});
