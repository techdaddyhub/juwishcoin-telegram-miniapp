---
name: VIP Prestige Wealth
colors:
  surface: '#131313'
  surface-dim: '#131313'
  surface-bright: '#3a3939'
  surface-container-lowest: '#0e0e0e'
  surface-container-low: '#1c1b1b'
  surface-container: '#201f1f'
  surface-container-high: '#2a2a2a'
  surface-container-highest: '#353534'
  on-surface: '#e5e2e1'
  on-surface-variant: '#d0c6ab'
  inverse-surface: '#e5e2e1'
  inverse-on-surface: '#313030'
  outline: '#999077'
  outline-variant: '#4d4732'
  surface-tint: '#e9c400'
  primary: '#fff6df'
  on-primary: '#3a3000'
  primary-container: '#ffd700'
  on-primary-container: '#705e00'
  inverse-primary: '#705d00'
  secondary: '#ffcf90'
  on-secondary: '#452b00'
  secondary-container: '#ffaa00'
  on-secondary-container: '#694300'
  tertiary: '#fff5e4'
  on-tertiary: '#38301b'
  tertiary-container: '#e7d8bb'
  on-tertiary-container: '#685e46'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffe16d'
  primary-fixed-dim: '#e9c400'
  on-primary-fixed: '#221b00'
  on-primary-fixed-variant: '#544600'
  secondary-fixed: '#ffddb4'
  secondary-fixed-dim: '#ffb952'
  on-secondary-fixed: '#291800'
  on-secondary-fixed-variant: '#633f00'
  tertiary-fixed: '#f0e1c3'
  tertiary-fixed-dim: '#d3c5a8'
  on-tertiary-fixed: '#221b08'
  on-tertiary-fixed-variant: '#4f4630'
  background: '#131313'
  on-background: '#e5e2e1'
  surface-variant: '#353534'
typography:
  headline-xl:
    fontFamily: Inter
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
  headline-xl-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
  headline-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 30px
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 26px
  headline-sm:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 22px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-numeric:
    fontFamily: JetBrains Mono
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 18px
  label-caps:
    fontFamily: Inter
    fontSize: 10px
    fontWeight: '700'
    lineHeight: 12px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 0.75rem
  gutter-mobile: 0.5rem
  margin: 1rem
  margin-mobile: 0.75rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-lg: 1rem
  space-xl: 1.5rem
---

## Brand & Style
The design system delivers an elite, bespoke Telegram Mini App (TMA) experience targeted at high-net-worth crypto traders, yield farmers, and gold-tier cloud mining operatives on the BNB Smart Chain. It projects absolute liquidity, architectural precision, discretion, and wealth. 

The aesthetic is a hybrid of **Precision VIP Dark Fintech** and **Tactile Glassmorphism**:
- **Atmosphere:** Deep obsidian spatial depths, low-emission surfaces, and high-frequency metallic luster.
- **Visual Tension:** Pitch-black structural panels offset by razor-sharp 1px gold gradient borders and targeted micro-specular highlights.
- **Sensory Tone:** Heavy, institutional, responsive, and exclusive. Interactions should feel weighted and deliberate, akin to a mechanical luxury timepiece paired with the low-latency execution of a tier-1 exchange terminal.

## Colors
The palette evokes an elite private vault illuminated by amber telemetry and gold bullion reflection.

### Palette Architecture
- **Primary (`#FFD700` - Radiant Metallic Gold):** High-priority calls to action, active mining hash-rate readouts, VIP tiers, and prime metrics.
- **Secondary (`#FFAA00` - Warm Amber):** Staking states, warning thresholds, transitional yields, and sub-actions.
- **Tertiary (`#F5E6C8` - Champagne Highs):** Micro-reflections, label highlights, crisp metric caps, and active gradient stops.
- **Neutral Canvas (`#080808` - Obsidian Base):** Total dark-room canvas engineered for OLED efficiency in Telegram Mini App viewports.
- **Surface Elevation 1 (`#121214` - Dark Charcoal Glass):** Base card fill paired with an internal luminance of `rgba(255, 215, 0, 0.035)`.
- **Surface Elevation 2 (`#1E1E24` - Deep Slate Glass):** Interactive surfaces, pill-tabs, inputs, and bottom drawer menus.
- **Functional Alpha - Emerald (`#00E676`):** Positive PnL, hash verification, buy executions, and network confirmations.
- **Functional Omega - Crimson (`#FF4D4D`):** Sell orders, liquidations, error states, and unbonding alerts.

### Color Rules
- Never use flat primary gold fills on expansive structural backdrops. Gold is reserved for actionable triggers, micro-accents, dynamic telemetry, and border illumination.
- Inactive text and subtle metadata must utilize muted zinc tones (`#8E8E93` and `#52525B`) to keep visual hierarchy locked onto gold balance counters and emerald yields.

## Typography
Typography reflects the high-density informational demands of institutional derivatives and mining telemetry.

- **Primary Typeface (`Inter`):** Selected for high legibility at micro-scales inside Telegram viewports, optical balance, and geometric weight distribution.
- **Monospaced Numerical Layer (`JetBrains Mono`):** Applied strictly to order book depths, real-time hash-rates (TH/s, GH/s), BNB contract addresses, transaction hashes, and live currency tickers. This eliminates layout jitter during rapid data streaming.
- **Uppercase Kerning:** All micro-labels (`label-caps`) must feature an explicit `0.08em` letter spacing with uppercase transformation to maintain legibility on dark glass surfaces.

## Layout & Spacing
Designed explicitly for the Telegram WebApp viewport constraints (both standard and fullscreen expansions on iOS/Android).

### Layout System
- **Grid Structure:** Fluid 4-column layout for portrait mobile screens, transforming into an 8-column layout when opened on Telegram Desktop or iPad clients.
- **Vertical Spacing:** Compact vertical rhythm utilizing an 8-point base grid to fit charts, order inputs, and active rig metrics above the fold without requiring aggressive scrolling.
- **Safe Area Insets:** Strict enforcement of dynamic top/bottom padding to account for Telegram header bars and device-native home indicators (`env(safe-area-inset-bottom)`).

## Elevation & Depth
Depth is produced using dark atmospheric tiers, layered glass, and precise directional edge lighting rather than standard diffuse drop-shadows.

### Structural Layers
- **Tier 0 (Canvas Base):** Pure `#080808` void.
- **Tier 1 (Surface Glass):** Fill `#121214` rendered at 85% opacity with an intense backdrop blur (`backdrop-filter: blur(16px)`). Surface features an internal hairline sheen: `inset 0 1px 0 0 rgba(245, 230, 200, 0.08)`.
- **Tier 2 (Floating Action Modules & Modals):** Fill `#1E1E24` rendered at 92% opacity with `backdrop-filter: blur(24px)`. Outer boundary uses a 1px directional linear-gradient border: `linear-gradient(135deg, rgba(255, 215, 0, 0.35) 0%, rgba(255, 170, 0, 0.1) 40%, rgba(255, 255, 255, 0.02) 100%)`.

### Micro-Reflections & Glow
- VIP cards and prime CTA states leverage an ambient outer aura: `box-shadow: 0 8px 32px -4px rgba(255, 215, 0, 0.12), 0 2px 8px -2px rgba(255, 170, 0, 0.18)`.
- Data charts and active mining rigs utilize an emerald/gold cathode glow: `drop-shadow(0 0 6px rgba(0, 230, 116, 0.4))`.

## Shapes
Geometry is structured, refined, and confident. Border radiuses prioritize clean ergonomics for thumb-driven mobile touchpoints without sacrificing structural rigidity.

- **Standard Containers & Cards:** `0.5rem` (8px) for inner transaction rows; `1rem` (16px) for major glass cards and interactive terminal panels.
- **Action Triggers & Modals:** `1.5rem` (24px) top-rounded bottom drawers; `0.75rem` (12px) for buttons and segmented leverage selectors.
- **Badges & Micro Chips:** Fully rounded pills (`9999px`) to separate metadata status indicators from structural rectangular panels.

## Components

### 1. Primary Action Buttons (VIP Transact & Mine)
- **Base Style:** Metallic gradient fill (`linear-gradient(135deg, #FFD700 0%, #FFAA00 100%)`) with dark charcoal text (`#080808`) rendered in bold typography.
- **Hairline Accent:** 1px inner border (`inset 0 1px 0 rgba(245, 230, 200, 0.8)`).
- **Haptic Press State:** Scaled down to `0.98` with an intense ambient gold edge spread.

### 2. Secondary Trade Triggers (Buy Long / Sell Short)
- **Buy / Long:** Solid emerald surface (`#00E676`) or transparent glass with 1px border (`#00E676`) and emerald text.
- **Sell / Short:** Deep charcoal background with crisp crimson outline (`#FF4D4D`) and soft crimson typography.

### 3. Glass Cards & Mining Rig Tiles
- **Surface Fill:** `#121214` combined with `backdrop-filter: blur(14px)`.
- **Perimeter Border:** 1px gold gradient border transitioning from `#FFD700` at top-left to `rgba(255, 215, 0, 0.05)` at bottom-right.
- **Interior Micro-Reflection:** Radial gold beam pseudo-element placed in the upper-right corner at 4% opacity to simulate overhead showroom lighting.

### 4. Chips, Tickers, and VIP Badges
- **VIP Level Badge:** Obsidian background, border in `1px solid #FFD700`, text in champagne gold (`#F5E6C8`), accompanied by a solid metallic gold micro-crown/diamond icon.
- **Yield / PnL Pills:** Pill-shaped capsules with subtle tint fills (`rgba(0, 230, 116, 0.12)`) and monospace green metrics (`#00E676`).

### 5. Input Fields & Order Sliders
- **Field Surfaces:** Inset styling with background `#0C0C0E` and border `1px solid #1E1E24`.
- **Focus State:** Border shifts dynamically to `#FFD700` with an outer micro-glow (`box-shadow: 0 0 12px rgba(255, 215, 0, 0.2)`).
- **Asset Tickers:** Fixed-width trailing chips pinned inside the right boundary of the field.

### 6. Cloud Mining Hashrate Gauges
- **Progress Arc / Track:** Track background in `#1E1E24` with active gradient progress stroke (`#FFAA00` to `#FFD700`).
- **Telemetry Display:** Dynamic numerical values rendered in `JetBrains Mono` with subtle pulsing neon status dot (emerald for active hashing, amber for maintenance).