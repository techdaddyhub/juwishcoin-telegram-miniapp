import os
import subprocess
from PIL import Image, ImageDraw, ImageFont, ImageFilter

BANNER_PATH = "/home/thbinnovation/.gemini/antigravity/brain/fd676ef6-126b-4d71-bdc6-36986407a5dd/telegram_app_banner_1789917869152.jpg"
COIN_PATH = "juwishcoin_jwc_3d_gold_medallion/screen.png"
AVATAR_PATH = "vip_crypto_trader_avatar_portrait_handsome_stylish_young_man_wearing_sleek/screen.png"
TRADE_PATH = "juwish_trading_terminal/screen.png"
MINE_PATH = "jwc_gold_mining_core/screen.png"
EARN_PATH = "vip_earn_gold_streak/screen.png"

OUTPUT_DIR = "telegram_assets"
os.makedirs(OUTPUT_DIR, exist_ok=True)

print("1. Creating 640x360 @BotFather App Photo...")
if os.path.exists(BANNER_PATH):
    img = Image.open(BANNER_PATH)
    # Resize and crop to exact 640x360
    img_640 = img.resize((640, 360), Image.Resampling.LANCZOS)
    img_640.save(os.path.join(OUTPUT_DIR, "botfather_app_photo_640x360.png"), format="PNG", optimize=True)
    img_640.save(os.path.join(OUTPUT_DIR, "botfather_app_photo_640x360.jpg"), format="JPEG", quality=95)
    print("   ✓ Saved botfather_app_photo_640x360.png and .jpg")

print("2. Creating 512x512 Bot Avatar Photo...")
if os.path.exists(AVATAR_PATH):
    av = Image.open(AVATAR_PATH)
    av_512 = av.resize((512, 512), Image.Resampling.LANCZOS)
    av_512.save(os.path.join(OUTPUT_DIR, "bot_avatar_512x512.png"), format="PNG", optimize=True)
    print("   ✓ Saved bot_avatar_512x512.png")

print("3. Creating Luxury Showcase Gallery Screenshots...")
screens = [
    ("Trade Terminal", "Institutional JWC/USDT Trading & AI Signals", TRADE_PATH, "screenshot_1_trading.png"),
    ("Cloud Mining Core", "Interactive 3D Gold Medallion & Daily Yield", MINE_PATH, "screenshot_2_mining.png"),
    ("VIP Earn & Streak", "7-Day Gold Streak & Ecosystem Quests", EARN_PATH, "screenshot_3_earn_streak.png"),
]

for title, subtitle, path, filename in screens:
    if os.path.exists(path):
        # Create luxury 1280x720 16:9 presentation slide
        slide = Image.new("RGB", (1280, 720), color="#080808")
        draw = ImageDraw.Draw(slide)
        
        # Load screenshot
        screen_img = Image.open(path)
        # Crop top 700px of screen to capture main features
        screen_crop = screen_img.crop((0, 0, screen_img.width, min(screen_img.height, 950)))
        # Resize to fit height ~620
        ratio = 620 / screen_crop.height
        screen_resized = screen_crop.resize((int(screen_crop.width * ratio), 620), Image.Resampling.LANCZOS)
        
        # Draw background radial golden aura
        for r in range(300, 50, -20):
            alpha = int(12 * (1 - r / 300))
            draw.ellipse((640 - r, 360 - r, 640 + r, 360 + r), fill=(255, 215, 0, alpha))
            
        # Draw Left Typography Column
        draw.text((70, 180), "JUWISHCOIN (JWC)", fill="#FFAA00")
        draw.text((70, 220), title, fill="#FFF6DF")
        draw.text((70, 280), subtitle, fill="#E5E2E1")
        draw.text((70, 340), "• BNB Smart Chain VIP Node\n• 3.0s Finality Settlement\n• Telegram Mini App Web3 UX", fill="#8E8E93")
        
        # Draw VIP Badge pill
        draw.rounded_rectangle((70, 480, 260, 525), radius=12, fill="#1E1E24", outline="#FFD700", width=1)
        draw.text((95, 495), "⭐ VIP TIER 3 EXCLUSIVE", fill="#FFD700")

        # Paste Screenshot on Right with shadow / border
        pos_x = 1280 - screen_resized.width - 90
        pos_y = 50
        # Card outline
        draw.rounded_rectangle((pos_x - 6, pos_y - 6, pos_x + screen_resized.width + 6, pos_y + screen_resized.height + 6), radius=18, outline="#FFD700", width=2)
        slide.paste(screen_resized, (pos_x, pos_y))
        
        slide.save(os.path.join(OUTPUT_DIR, filename), format="PNG", optimize=True)
        print(f"   ✓ Generated {filename}")

print("4. Creating BotFather 640x360 Demo Video & Animated GIF...")
# Use ffmpeg to create a 6-second dynamic 640x360 video with gold zoom, panning, and particle fade
mp4_output = os.path.join(OUTPUT_DIR, "botfather_demo_preview.mp4")
gif_output = os.path.join(OUTPUT_DIR, "botfather_demo_preview.gif")

banner_input = BANNER_PATH
if os.path.exists(banner_input):
    # Zoompan 6 seconds from 1.0 to 1.15 centered on medallion, 30 fps
    cmd_mp4 = [
        "ffmpeg", "-y", "-loop", "1", "-i", banner_input,
        "-vf", "zoompan=z='min(zoom+0.0015,1.2)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=180:s=640x360:fps=30,format=yuv420p",
        "-t", "6",
        "-c:v", "libx264", "-pix_fmt", "yuv420p",
        "-movflags", "+faststart",
        mp4_output
    ]
    subprocess.run(cmd_mp4, check=True)
    print("   ✓ Generated botfather_demo_preview.mp4 (H.264, 640x360)")

    # Convert to lightweight GIF for Telegram preview
    cmd_gif = [
        "ffmpeg", "-y", "-i", mp4_output,
        "-vf", "fps=15,scale=640:360:flags=lanczos,split[s0][s1];[s0]palettegen=max_colors=128[p];[s1][p]paletteuse=dither=bayer",
        gif_output
    ]
    subprocess.run(cmd_gif, check=True)
    print("   ✓ Generated botfather_demo_preview.gif (640x360)")

print("\nAll Telegram preview assets successfully generated in:", OUTPUT_DIR)
