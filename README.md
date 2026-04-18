# Kaya Juwelier – Gold Price Tracker

Real-time gold price tracking system displaying live EUR prices for 18K, 21K, 22K, and 24K gold — built for Kaya Juwelier.

## Features

- Live gold prices in EUR per gram (18K / 21K / 22K / 24K)
- Troy ounce price display
- Price flash animation on change (green = up, red = down)
- Auto-refresh every 60 seconds
- Demo mode (no API key required to run)

## Setup

```bash
npm install
cp .env.example .env
# Add your GOLD_API_KEY from https://www.goldapi.io
npm start
```

Open [http://localhost:3000](http://localhost:3000).

## API

| Endpoint | Description |
|---|---|
| `GET /api/gold-price` | Returns current gold prices in EUR |

## Tech Stack

- **Backend:** Node.js, Express
- **Frontend:** Vanilla HTML/CSS/JS
- **Data:** [goldapi.io](https://www.goldapi.io)
