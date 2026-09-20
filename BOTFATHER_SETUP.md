# JuwishCoin (JWC) Telegram Mini App - @BotFather Setup & Production Deployment Guide

This guide provides the complete setup automation and deployment workflow to launch the **JuwishCoin (JWC) Crypto Trading & Gold Mining Telegram Mini App (TMA)** on Telegram.

---

## 1. Production Build & Optimization

To balance low-latency initial load times on mobile 3G/4G connections with smooth 60fps GPU rendering for the interactive 3D Gold Medallion and live charting, compile the production release using Flutter's web compiler with optimized renderer flags.

### 1.1 Recommended Release Build Command

```bash
flutter build web --release \
  --web-renderer auto \
  -O4 \
  --no-source-maps \
  --base-href "/"
```

### 1.2 Renderer Flags Analysis for Telegram Mini Apps

| Mode | Initial Payload | First Contentful Paint (FCP) | 60 FPS Animation & Canvas | Recommendation |
| :--- | :--- | :--- | :--- | :--- |
| **`--web-renderer auto`** *(Recommended)* | ~1.8 MB on Mobile / ~3.5 MB Desktop | **Fast (< 1.2s)** | High Fidelity (CanvasKit on Desktop, HTML/Canvas fallback on Mobile) | **Ideal for Telegram Mini Apps** across low-end Androids and high-end iPhones. |
| **`--web-renderer canvaskit`** | ~4.2 MB (CanvasKit WASM bundle) | ~2.5s on 4G | Ultra-smooth pixel-perfect 60 FPS Skia shaders | Best if targeting primarily desktop or WiFi users. |
| **`--wasm`** *(Experimental in Flutter 3.22+)* | Smaller binary with GC support | Extremely fast execution | Requires Cross-Origin-Embedder-Policy (COEP) & COOP headers | Optional future upgrade for browsers supporting WasmGC. |

---

## 2. Step-by-Step Telegram @BotFather Configuration

Follow this exact dialogue walkthrough in Telegram with [@BotFather](https://t.me/BotFather).

### Step 2.1: Create the Telegram Bot (`/newbot`)

1. Open Telegram and start a chat with [@BotFather](https://t.me/BotFather).
2. Send:
   ```text
   /newbot
   ```
3. Enter the public display name of your bot:
   ```text
   JuwishCoin Trading & Mining
   ```
4. Enter the bot username (must end in `bot`):
   ```text
   JuwishCoinBot
   ```
   *(Or an available unique handle like `JuwishCoinTradingBot`)*
5. **Save the HTTP API Bot Token** provided by @BotFather (e.g. `7123456789:AAFlkd9...`). Keep this private.

---

### Step 2.2: Configure the Persistent Chat Menu Button (`/setmenubutton`)

The Menu Button allows users to launch your Mini App directly from the bottom-left of the Telegram chat interface without typing any commands.

1. Send to @BotFather:
   ```text
   /setmenubutton
   ```
2. Select your newly created bot: `@JuwishCoinBot`.
3. Enter the button text:
   ```text
   ⚡ Launch Terminal & Mine
   ```
4. Enter your production HTTPS web URL (Telegram Mini Apps require valid SSL/TLS):
   ```text
   https://app.juwishcoin.io/
   ```

---

### Step 2.3: Create Direct Short Link Mini App (`/newapp`)

A Telegram Mini App short link (e.g., `t.me/JuwishCoinBot/app`) lets you share viral referral links and direct launch buttons in channels, chats, and social media.

1. Send to @BotFather:
   ```text
   /newapp
   ```
2. Select your bot: `@JuwishCoinBot`.
3. Provide the App Title:
   ```text
   JuwishCoin VIP Terminal
   ```
4. Enter a short description (up to 128 characters):
   ```text
   Institutional crypto trading, BNB Smart Chain cloud mining, and VIP gold dividends.
   ```
5. Upload the **App Photo / Icon**:
   - **Resolution:** Exactly **640 x 360 px** (JPG/PNG).
   - *Design suggestion:* Deep obsidian background (`#080808`) with a high-specular 3D Gold JuwishCoin Medallion (`#FFD700`).
6. Upload the optional **App GIF / Video Demo** (640x360, up to 30 seconds).
7. Enter your Web App HTTPS URL:
   ```text
   https://app.juwishcoin.io/
   ```
8. Choose a short name for the URL slug:
   ```text
   app
   ```
   Your permanent direct launch link is now:
   ```text
   https://t.me/JuwishCoinBot/app
   ```

---

### Step 2.4: Bot Profile, Bio, and Description Customization

Configure the aesthetic presentation of the bot:

1. **Set Bot Description** (shown before a user presses "Start"):
   ```text
   /setdescription
   ```
   ```text
   Welcome to the JuwishCoin (JWC) VIP Trading & Mining Terminal on BNB Smart Chain.

   Features:
   • Live JWC/USDT Trading & AI Technical Breakout Signals
   • 1-Click PancakeSwap V3 Atomic Auto-Buy & Staking
   • 24/7 Cloud Mining Core & Daily Gold Streak Rewards
   • VIP Peer-to-Peer Off-Chain Transfers with Zero Fees
   ```

2. **Set About Text** (shown in the bot profile info):
   ```text
   /setabouttext
   ```
   ```text
   Official JuwishCoin (JWC) Web3 Telegram Mini App on BNB Smart Chain.
   ```

3. **Set Bot Avatar Profile Photo**:
   ```text
   /setuserpic
   ```
   Upload the square avatar (512x512 px) located at `vip_crypto_trader_avatar_portrait_.../screen.png` or `juwishcoin_jwc_3d_gold_medallion/screen.png`.

---

## 3. Production Hosting & Reverse Proxy Deployment

Telegram Mini Apps enforce strict HTTPS with valid TLS/SSL certificates and security headers. Below are two verified deployment methods:

### Option A: High-Performance Production Nginx Setup

Place the compiled `build/web` files on your Linux server (e.g., `/var/www/juwishcoin/build/web`).

Create `/etc/nginx/sites-available/juwishcoin`:

```nginx
server {
    listen 80;
    server_name app.juwishcoin.io;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name app.juwishcoin.io;

    # SSL Certificates (Let's Encrypt / Certbot)
    ssl_certificate /etc/letsencrypt/live/app.juwishcoin.io/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/app.juwishcoin.io/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    root /var/www/juwishcoin/build/web;
    index index.html;

    # Enable Gzip & Brotli compression for rapid 3G/4G asset delivery
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript application/wasm;
    gzip_min_length 256;

    # Mandatory Telegram WebApp Headers
    # Allows iframe embedding from Telegram clients
    add_header X-Frame-Options "ALLOW-FROM https://web.telegram.org/" always;
    add_header Content-Security-Policy "frame-ancestors 'self' https://web.telegram.org https://*.telegram.org;" always;
    add_header Access-Control-Allow-Origin "*" always;

    # CanvasKit WASM caching headers
    location ~* \.(wasm)$ {
        types { application/wasm wasm; }
        expires 1y;
        add_header Cache-Control "public, max-age=31536000, immutable";
    }

    # Static assets long-term caching
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|woff|woff2)$ {
        expires 30d;
        add_header Cache-Control "public, max-age=2592000";
    }

    # Single Page App routing fallback to index.html
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

Enable the configuration and reload Nginx:
```bash
sudo ln -s /etc/nginx/sites-available/juwishcoin /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

### Option B: Automatic HTTPS with Caddy

If using Caddy, simply add this block to your `/etc/caddy/Caddyfile`:

```caddy
app.juwishcoin.io {
    root * /var/www/juwishcoin/build/web
    file_server
    try_files {path} /index.html

    encode gzip zstd

    header {
        Content-Security-Policy "frame-ancestors 'self' https://web.telegram.org https://*.telegram.org;"
        X-Frame-Options "ALLOW-FROM https://web.telegram.org/"
        Access-Control-Allow-Origin "*"
    }

    @wasm path *.wasm
    header @wasm {
        Content-Type application/wasm
        Cache-Control "public, max-age=31536000, immutable"
    }
}
```

Reload Caddy:
```bash
sudo caddy reload
```

---

### Option C: GitHub Pages Fast Deployment

You can host the Mini App directly on GitHub Pages:

```bash
# 1. Compile web release
flutter build web --release --base-href "/stitch_juwishcoin_telegram_trading_mining_miniapp/"

# 2. Deploy to gh-pages branch
cd build/web
git init
git checkout -b gh-pages
git add .
git commit -m "Deploy JuwishCoin TMA release build"
git remote add origin https://github.com/your-org/juwishcoin-tma.git
git push -u origin gh-pages --force
```

Then configure the URL in @BotFather:
`https://your-org.github.io/stitch_juwishcoin_telegram_trading_mining_miniapp/`

---

## 4. Local Testing & Live Simulation in Telegram

1. Run the local Flutter development server:
   ```bash
   flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0
   ```
2. Tunnel your local port with Cloudflare Tunnels or ngrok:
   ```bash
   ngrok http 8080
   ```
3. Set the ngrok URL (e.g., `https://abc1234.ngrok-free.app`) in @BotFather via `/setmenubutton`.
4. Open your bot in Telegram on iOS, Android, or Telegram Desktop and tap **⚡ Launch Terminal & Mine**.

---

## 5. Summary of Built-in Telegram UX Features

- **Closing Confirmation:** `Telegram.WebApp.enableClosingConfirmation()` is invoked on launch to eliminate accidental dismissal during gold mining tap streaks.
- **Full Viewport Expansion:** `Telegram.WebApp.expand()` maximizes the screen real estate.
- **Overscroll & Zoom Prevention:** Complete CSS freeze of body rubber-banding ensures native touch ergonomics.
- **Instant Gold Forge Splash:** Instant visual feedback for low-bandwidth mobile networks while Flutter loads.
- **Cross-Platform Resilient:** Scaffolds are wrapped in a 480px constrained layout with `resizeToAvoidBottomInset: true` to prevent keyboard overflow issues.

