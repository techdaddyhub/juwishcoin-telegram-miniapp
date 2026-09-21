#!/usr/bin/env python3
"""
JuwishCoin ($JWC) Official Ecosystem & User Guide Generator
Generates a professional, publication-grade PDF manual for Telegram channels, groups, and investors.
"""

import os
import subprocess
from odf.opendocument import OpenDocumentText
from odf.text import P, H, Span
from odf.table import Table, TableColumn, TableRow, TableCell
from odf.draw import Frame, Image
from odf.style import (
    Style, TextProperties, ParagraphProperties, TableProperties,
    TableColumnProperties, TableCellProperties, PageLayout, PageLayoutProperties,
    HeaderFooterProperties, MasterPage
)

def create_guide():
    doc = OpenDocumentText()
    
    # -------------------------------------------------------------
    # 1. Page Layout (A4, 1.8cm margins)
    # -------------------------------------------------------------
    pl = PageLayout(name="A4Layout")
    pl.addElement(PageLayoutProperties(
        pagewidth="21.0cm",
        pageheight="29.7cm",
        margintop="1.8cm",
        marginbottom="1.8cm",
        marginleft="1.8cm",
        marginright="1.8cm"
    ))
    doc.automaticstyles.addElement(pl)
    
    mp = MasterPage(name="Standard", pagelayoutname="A4Layout")
    doc.masterstyles.addElement(mp)
    
    # -------------------------------------------------------------
    # 2. Typography & Paragraph Styles
    # -------------------------------------------------------------
    # Cover Styles
    s_cover_title = Style(name="CoverTitle", family="paragraph")
    s_cover_title.addElement(ParagraphProperties(textalign="center", marginbottom="0.3cm"))
    s_cover_title.addElement(TextProperties(fontsize="26pt", fontweight="bold", color="#B8860B", fontfamily="DejaVu Sans"))
    doc.automaticstyles.addElement(s_cover_title)

    s_cover_sub = Style(name="CoverSub", family="paragraph")
    s_cover_sub.addElement(ParagraphProperties(textalign="center", marginbottom="0.8cm"))
    s_cover_sub.addElement(TextProperties(fontsize="12pt", fontstyle="italic", color="#4A4A4A", fontfamily="DejaVu Sans"))
    doc.automaticstyles.addElement(s_cover_sub)

    s_cover_meta = Style(name="CoverMeta", family="paragraph")
    s_cover_meta.addElement(ParagraphProperties(textalign="center", marginbottom="0.2cm"))
    s_cover_meta.addElement(TextProperties(fontsize="10pt", color="#555555", fontfamily="DejaVu Sans"))
    doc.automaticstyles.addElement(s_cover_meta)

    # Chapter Headings (Starts on New Page)
    s_h1 = Style(name="ChapterHeading", family="paragraph")
    s_h1.addElement(ParagraphProperties(breakbefore="page", margintop="0.4cm", marginbottom="0.4cm"))
    s_h1.addElement(TextProperties(fontsize="18pt", fontweight="bold", color="#B8860B", fontfamily="DejaVu Sans"))
    doc.automaticstyles.addElement(s_h1)

    # Section Headings
    s_h2 = Style(name="SectionHeading", family="paragraph")
    s_h2.addElement(ParagraphProperties(margintop="0.5cm", marginbottom="0.2cm"))
    s_h2.addElement(TextProperties(fontsize="13pt", fontweight="bold", color="#121214", fontfamily="DejaVu Sans"))
    doc.automaticstyles.addElement(s_h2)

    # Subheadings
    s_h3 = Style(name="SubHeading", family="paragraph")
    s_h3.addElement(ParagraphProperties(margintop="0.3cm", marginbottom="0.15cm"))
    s_h3.addElement(TextProperties(fontsize="10.5pt", fontweight="bold", color="#333333", fontfamily="DejaVu Sans"))
    doc.automaticstyles.addElement(s_h3)

    # Body Paragraph
    s_body = Style(name="BodyText", family="paragraph")
    s_body.addElement(ParagraphProperties(marginbottom="0.25cm", lineheight="130%"))
    s_body.addElement(TextProperties(fontsize="9.5pt", color="#222222", fontfamily="DejaVu Sans"))
    doc.automaticstyles.addElement(s_body)

    # Bullet / List Paragraph
    s_bullet = Style(name="BulletText", family="paragraph")
    s_bullet.addElement(ParagraphProperties(marginleft="0.6cm", marginbottom="0.15cm", lineheight="125%"))
    s_bullet.addElement(TextProperties(fontsize="9.5pt", color="#222222", fontfamily="DejaVu Sans"))
    doc.automaticstyles.addElement(s_bullet)

    # Center Image Paragraph
    s_img_center = Style(name="ImageCenter", family="paragraph")
    s_img_center.addElement(ParagraphProperties(textalign="center", margintop="0.4cm", marginbottom="0.4cm"))
    doc.automaticstyles.addElement(s_img_center)

    # Callout Box Paragraph
    s_callout = Style(name="CalloutBox", family="paragraph")
    s_callout.addElement(ParagraphProperties(
        backgroundcolor="#F4F5F7",
        borderleft="3.5pt solid #D4AF37",
        bordertop="0.5pt solid #E2E4E8",
        borderright="0.5pt solid #E2E4E8",
        borderbottom="0.5pt solid #E2E4E8",
        padding="0.3cm",
        margintop="0.3cm",
        marginbottom="0.35cm"
    ))
    s_callout.addElement(TextProperties(fontsize="9.5pt", color="#1A1A1A", fontfamily="DejaVu Sans"))
    doc.automaticstyles.addElement(s_callout)

    # Code / Contract Box Paragraph
    s_codebox = Style(name="CodeBox", family="paragraph")
    s_codebox.addElement(ParagraphProperties(
        backgroundcolor="#121214",
        border="1pt solid #D4AF37",
        padding="0.25cm",
        margintop="0.2cm",
        marginbottom="0.3cm",
        textalign="center"
    ))
    s_codebox.addElement(TextProperties(fontsize="9.5pt", fontweight="bold", color="#FFD700", fontfamily="Courier New, monospace"))
    doc.automaticstyles.addElement(s_codebox)

    # Text Spans (Inline formatting)
    sp_bold = Style(name="SpanBold", family="text")
    sp_bold.addElement(TextProperties(fontweight="bold"))
    doc.automaticstyles.addElement(sp_bold)

    sp_gold = Style(name="SpanGold", family="text")
    sp_gold.addElement(TextProperties(fontweight="bold", color="#B8860B"))
    doc.automaticstyles.addElement(sp_gold)

    sp_code = Style(name="SpanCode", family="text")
    sp_code.addElement(TextProperties(fontfamily="Courier New, monospace", color="#000000", backgroundcolor="#EEEEEE"))
    doc.automaticstyles.addElement(sp_code)

    # -------------------------------------------------------------
    # 3. Table Styles
    # -------------------------------------------------------------
    s_table = Style(name="CustomTable", family="table")
    s_table.addElement(TableProperties(width="17.4cm", align="center", marginbottom="0.4cm"))
    doc.automaticstyles.addElement(s_table)

    s_col_narrow = Style(name="ColNarrow", family="table-column")
    s_col_narrow.addElement(TableColumnProperties(columnwidth="4.8cm"))
    doc.automaticstyles.addElement(s_col_narrow)

    s_col_wide = Style(name="ColWide", family="table-column")
    s_col_wide.addElement(TableColumnProperties(columnwidth="12.6cm"))
    doc.automaticstyles.addElement(s_col_wide)

    s_col_tri_1 = Style(name="ColTri1", family="table-column")
    s_col_tri_1.addElement(TableColumnProperties(columnwidth="4.5cm"))
    doc.automaticstyles.addElement(s_col_tri_1)

    s_col_tri_2 = Style(name="ColTri2", family="table-column")
    s_col_tri_2.addElement(TableColumnProperties(columnwidth="4.5cm"))
    doc.automaticstyles.addElement(s_col_tri_2)

    s_col_tri_3 = Style(name="ColTri3", family="table-column")
    s_col_tri_3.addElement(TableColumnProperties(columnwidth="8.4cm"))
    doc.automaticstyles.addElement(s_col_tri_3)

    # Table Cells
    s_th_cell = Style(name="ThCell", family="table-cell")
    s_th_cell.addElement(TableCellProperties(
        backgroundcolor="#121214",
        paddingtop="0.2cm", paddingbottom="0.2cm", paddingleft="0.25cm", paddingright="0.25cm",
        border="0.5pt solid #333333"
    ))
    doc.automaticstyles.addElement(s_th_cell)

    s_td_cell = Style(name="TdCell", family="table-cell")
    s_td_cell.addElement(TableCellProperties(
        backgroundcolor="#FFFFFF",
        paddingtop="0.18cm", paddingbottom="0.18cm", paddingleft="0.25cm", paddingright="0.25cm",
        border="0.5pt solid #E0E0E0"
    ))
    doc.automaticstyles.addElement(s_td_cell)

    s_td_cell_alt = Style(name="TdCellAlt", family="table-cell")
    s_td_cell_alt.addElement(TableCellProperties(
        backgroundcolor="#F8F9FA",
        paddingtop="0.18cm", paddingbottom="0.18cm", paddingleft="0.25cm", paddingright="0.25cm",
        border="0.5pt solid #E0E0E0"
    ))
    doc.automaticstyles.addElement(s_td_cell_alt)

    # Paragraph inside table cells
    s_p_th = Style(name="ParagraphTH", family="paragraph")
    s_p_th.addElement(TextProperties(fontsize="9pt", fontweight="bold", color="#FFD700", fontfamily="DejaVu Sans"))
    doc.automaticstyles.addElement(s_p_th)

    s_p_td = Style(name="ParagraphTD", family="paragraph")
    s_p_td.addElement(TextProperties(fontsize="9pt", color="#222222", fontfamily="DejaVu Sans"))
    doc.automaticstyles.addElement(s_p_td)

    s_p_td_bold = Style(name="ParagraphTDBold", family="paragraph")
    s_p_td_bold.addElement(TextProperties(fontsize="9pt", fontweight="bold", color="#121214", fontfamily="DejaVu Sans"))
    doc.automaticstyles.addElement(s_p_td_bold)

    # -------------------------------------------------------------
    # Helper Functions
    # -------------------------------------------------------------
    def add_p(text, bold_prefix="", stylename="BodyText"):
        p = P(stylename=stylename)
        if bold_prefix:
            p.addElement(Span(stylename="SpanBold", text=bold_prefix))
        p.addElement(Span(text=text))
        doc.text.addElement(p)

    def add_bullet(text, bold_title=""):
        p = P(stylename="BulletText")
        p.addElement(Span(stylename="SpanGold", text="• "))
        if bold_title:
            p.addElement(Span(stylename="SpanBold", text=bold_title + " "))
        p.addElement(Span(text=text))
        doc.text.addElement(p)

    def add_callout(text, title=""):
        p = P(stylename="CalloutBox")
        if title:
            p.addElement(Span(stylename="SpanBold", text=title + "\n"))
        p.addElement(Span(text=text))
        doc.text.addElement(p)

    def add_code_box(text):
        p = P(stylename="CodeBox", text=text)
        doc.text.addElement(p)

    def add_image(rel_path, width="12.0cm", height="6.75cm"):
        if os.path.exists(rel_path):
            href = doc.addPicture(rel_path)
            p = P(stylename="ImageCenter")
            f = Frame(width=width, height=height, anchortype="as-char")
            f.addElement(Image(href=href))
            p.addElement(f)
            doc.text.addElement(p)

    def add_table_2col(rows, headers=("Parameter", "Specification")):
        t = Table(stylename="CustomTable")
        t.addElement(TableColumn(stylename="ColNarrow"))
        t.addElement(TableColumn(stylename="ColWide"))

        hr = TableRow()
        for h in headers:
            c = TableCell(stylename="ThCell")
            c.addElement(P(stylename="ParagraphTH", text=h))
            hr.addElement(c)
        t.addElement(hr)

        for i, (col1, col2) in enumerate(rows):
            r = TableRow()
            c1_style = "TdCellAlt" if i % 2 == 1 else "TdCell"
            c2_style = "TdCellAlt" if i % 2 == 1 else "TdCell"
            
            c1 = TableCell(stylename=c1_style)
            c1.addElement(P(stylename="ParagraphTDBold", text=col1))
            r.addElement(c1)

            c2 = TableCell(stylename=c2_style)
            c2.addElement(P(stylename="ParagraphTD", text=col2))
            r.addElement(c2)

            t.addElement(r)
        doc.text.addElement(t)

    def add_table_3col(rows, headers=("Category", "Details", "Ecosystem Impact")):
        t = Table(stylename="CustomTable")
        t.addElement(TableColumn(stylename="ColTri1"))
        t.addElement(TableColumn(stylename="ColTri2"))
        t.addElement(TableColumn(stylename="ColTri3"))

        hr = TableRow()
        for h in headers:
            c = TableCell(stylename="ThCell")
            c.addElement(P(stylename="ParagraphTH", text=h))
            hr.addElement(c)
        t.addElement(hr)

        for i, (col1, col2, col3) in enumerate(rows):
            c_style = "TdCellAlt" if i % 2 == 1 else "TdCell"
            r = TableRow()
            
            c1 = TableCell(stylename=c_style)
            c1.addElement(P(stylename="ParagraphTDBold", text=col1))
            r.addElement(c1)

            c2 = TableCell(stylename=c_style)
            c2.addElement(P(stylename="ParagraphTD", text=col2))
            r.addElement(c2)

            c3 = TableCell(stylename=c_style)
            c3.addElement(P(stylename="ParagraphTD", text=col3))
            r.addElement(c3)

            t.addElement(r)
        doc.text.addElement(t)

    # =============================================================
    # COVER PAGE
    # =============================================================
    doc.text.addElement(P(stylename="CoverTitle", text="JuwishCoin ($JWC)"))
    doc.text.addElement(P(stylename="CoverSub", text="Official Ecosystem & User Guide\nHow to Mine, Stake, Trade & Build VIP Wealth on Telegram"))
    
    add_image("telegram_assets/bot_avatar_512x512.png", width="4.5cm", height="4.5cm")

    add_code_box("OFFICIAL BEP-20 CONTRACT (BNB SMART CHAIN):\n0xfEEEF79d2A97d9e1f9bcB8eBA8FD9587079C9e99")

    add_p("Default Trading / Selling Target: $3.0000 USDT | Primary DEX: PancakeSwap V3", stylename="CoverMeta")
    add_p("BscScan Explorer: https://bscscan.com/token/0xfEEEF79d2A97d9e1f9bcB8eBA8FD9587079C9e99", stylename="CoverMeta")
    add_p("Document Version: 2.4 (Official Community & Investor Release) • Powered by Telegram WebApp", stylename="CoverMeta")
    add_p("Authorized for distribution across Telegram channels, chat groups, and crypto communities.", stylename="CoverMeta")

    # =============================================================
    # TABLE OF CONTENTS
    # =============================================================
    doc.text.addElement(H(outlinelevel=1, stylename="ChapterHeading", text="Table of Contents"))
    add_bullet("What is JuwishCoin ($JWC), BNB Smart Chain BEP-20 architecture, and token specifications.", "1. Executive Summary & Token Architecture:")
    add_bullet("How beginners can launch the app, start mining, and earn tokens in under 60 seconds.", "2. Quick-Start Guide for Beginners:")
    add_bullet("Active Tap-to-Mine, 1,000 Energy bar, 142.8 GH/s Cloud Hashrate, and 34.5 JWC/hr passive yield.", "3. Mining Mechanics (Tap & Cloud Rigs):")
    add_bullet("Compounding passive wealth, multi-token deposits, 0% vault fee, and +32.5% APY rewards.", "4. VIP Staking Vault (+32.5% APY):")
    add_bullet("Order book, live Candlestick charts, buying JWC, and selling JWC at $3.00 on PancakeSwap V3.", "5. DEX Trading Terminal & $3.00 Cash-Out:")
    add_bullet("Multi-asset balances and instant zero-fee transfers via Telegram @username or BSC address.", "6. Assets Portfolio & P2P Escrow Transfers:")
    add_bullet("7-day login streak calendar, social bounty tasks, and 10% lifetime VIP referral commissions.", "7. Earn Hub, Daily Streaks & Referrals:")
    add_bullet("Step-by-step instructions to import 0xfEEE...9e99 into MetaMask, Trust Wallet, and SafePal.", "8. Web3 Wallet Setup (MetaMask & Trust Wallet):")
    add_bullet("On-chain auditability, anti-bot rate-limiting safeguards, and community safety guidelines.", "9. Security, Anti-Cheat & Fair Play:")
    add_bullet("Common beginner questions answered and official community resource directory.", "10. Frequently Asked Questions (FAQ) & Directory:")

    # =============================================================
    # CHAPTER 1: EXECUTIVE SUMMARY & TOKEN ARCHITECTURE
    # =============================================================
    doc.text.addElement(H(outlinelevel=1, stylename="ChapterHeading", text="1. Executive Summary & Token Architecture"))

    add_p(
        "JuwishCoin ($JWC) is a next-generation decentralized financial ecosystem deployed on the BNB Smart Chain (BSC). "
        "Engineered natively as a high-performance Telegram Mini App, JuwishCoin seamlessly bridges decentralized finance (DeFi) "
        "and Telegram's 900+ million global active users without requiring complicated browser setups, manual RPC configurations, "
        "or external bridge protocols."
    )
    
    add_p(
        "The application integrates an interactive Tap-to-Mine game, an automated 24/7 Virtual Cloud Mining rig, a high-yield VIP Staking Vault (+32.5% APY), "
        "an institutional-grade DEX Trading Terminal with real-time candlestick charts, instant zero-fee Peer-to-Peer (P2P) transfers, and a multi-tier VIP referral program."
    )

    doc.text.addElement(H(outlinelevel=2, stylename="SectionHeading", text="Official Token Specifications"))
    add_table_2col([
        ("Token Name", "JuwishCoin"),
        ("Token Symbol / Ticker", "$JWC"),
        ("Underlying Blockchain", "BNB Smart Chain (BSC - BEP-20)"),
        ("Smart Contract Address", "0xfEEEF79d2A97d9e1f9bcB8eBA8FD9587079C9e99"),
        ("Token Decimals", "18 Decimals"),
        ("Default Trade / Sell Price", "$3.0000 USDT per JWC"),
        ("Primary DEX Router", "PancakeSwap V3 (0.05% Liquidity Pool)"),
        ("Blockchain Explorer", "BscScan (Official Contract Tracker & Verified Code)"),
        ("Platform Compatibility", "Telegram WebApp (iOS, Android, Desktop & Web Browser)"),
    ], headers=("Specification", "Network Details"))

    add_callout(
        "Always verify that you are interacting with the genuine JuwishCoin smart contract (0xfEEE...9e99). "
        "JuwishCoin will never ask for your private key, seed phrase, or send unofficial contract addresses in direct messages.",
        title="IMPORTANT SECURITY NOTICE:"
    )

    # =============================================================
    # CHAPTER 2: QUICK-START GUIDE FOR BEGINNERS
    # =============================================================
    doc.text.addElement(H(outlinelevel=1, stylename="ChapterHeading", text="2. Quick-Start Guide (Get Started in 60 Seconds)"))

    add_p("Getting started with JuwishCoin requires zero initial deposit and takes less than a minute. Follow these 5 essential steps:")

    add_bullet("Launch the JuwishCoin Mini App inside Telegram via the official bot link (@juwishcoin_bot).", "Step 1: Open the Mini App.")
    add_bullet("Head to the Mine tab. Activate your cloud rig and tap nodes by depositing or buying at least 5 JWC ($15.00 USDT). Once unlocked, tap to mine (+10 JWC) and earn 24/7 passive cloud rewards.", "Step 2: Activate Node & Start Mining.")
    add_bullet("Navigate to the Earn tab to claim your Day 1 streak bonus (+50 JWC) and complete quick social bounties for extra tokens.", "Step 3: Collect Daily Streak & Bounties.")
    add_bullet("Move your mined tokens into the VIP Vault to start compounding interest at +32.5% APY with zero deposit fees.", "Step 4: Stake in the VIP Vault.")
    add_bullet("Open the Trade terminal to swap your mined JWC directly for USDT at the $3.00 rate or execute on PancakeSwap V3.", "Step 5: Trade or Cash Out at $3.00.")

    add_image("telegram_assets/botfather_app_photo_640x360.png", width="12cm", height="6.75cm")

    # =============================================================
    # CHAPTER 3: MINING MECHANICS (TAP & CLOUD RIGS)
    # =============================================================
    doc.text.addElement(H(outlinelevel=1, stylename="ChapterHeading", text="3. Mining Mechanics: Tap-to-Mine & Cloud Rigs"))

    add_p(
        "JuwishCoin employs a hybrid dual-mining engine designed to reward both active participants and passive holders. "
        "Users can extract tokens actively through high-frequency tapping or passively through virtual cloud ASIC rigs."
    )

    doc.text.addElement(H(outlinelevel=2, stylename="SectionHeading", text="Mining Activation Gate (Anti-Sybil & Bot Protection)"))
    add_p(
        "To protect genuine community members and eliminate malicious multi-account botfarms, JuwishCoin enforces an anti-sybil "
        "activation requirement before mining begins: users must buy or deposit at least 5 JWC (approx. $15.00 USDT at the $3.00 price)."
    )
    add_bullet("Shields community tokenomics from automated scripts draining pool rewards.", "Anti-Bot Defense:")
    add_bullet("Once 5 JWC is deposited or purchased, your 142.8 GH/s cloud rig and tap nodes are unlocked for life.", "Permanent Node Activation:")
    add_bullet("(1) Instant In-App Activate, (2) Trade Terminal swap, (3) Direct BEP-20 deposit, or (4) PancakeSwap V3 purchase.", "Four Flexible Channels:")

    doc.text.addElement(H(outlinelevel=2, stylename="SectionHeading", text="Pillar A: Active Tap-to-Mine System"))
    add_bullet("Tap Yield: Every single tap on the digital gold medallion extracts exactly 10.0 JWC tokens.", "Base Extraction Rate:")
    add_bullet("Energy Capacity: Each miner has a maximum energy reserve of 1,000 Energy.", "Energy Reserve:")
    add_bullet("Auto-Regeneration: Energy refills continuously in real-time every second. Once replenished, miners can tap again.", "Regeneration Engine:")
    add_bullet("Haptic Feedback: Real-time kinetic and haptic pulses accompany every tap, confirming valid on-chain mining pulses.", "Interactive UI:")

    doc.text.addElement(H(outlinelevel=2, stylename="SectionHeading", text="Pillar B: 24/7 Virtual Cloud Mining Rigs (Offline Yield)"))
    add_p(
        "Even when your smartphone is turned off or Telegram is closed, your JuwishCoin cloud mining rig continues operating around the clock. "
        "This ensures that players in all timezones earn continuous rewards."
    )
    add_bullet("Base Cloud Hashrate: Every user starts with an active computing power of 142.8 GH/s.", "Cloud Hashrate:")
    add_bullet("Passive Yield Rate: Generates 34.5 JWC per hour (828 JWC every 24-hour cycle) without requiring any screen interaction.", "Passive Hourly Yield:")
    add_bullet("1-Tap Claim: Accumulated offline mining rewards can be harvested directly into your main wallet with a single button tap.", "Harvest Mechanism:")

    add_table_2col([
        ("Mining Activation Gate", "5.0 JWC Deposit or Purchase (One-time unlock)"),
        ("Max Active Energy", "1,000 Points"),
        ("Active Tap Reward", "+10.0 JWC / Tap"),
        ("Full Energy Tap Yield", "1,000 JWC per full energy cycle"),
        ("Cloud ASIC Hashrate", "142.8 GH/s"),
        ("Passive Cloud Output", "34.5 JWC / Hour (828 JWC / Day)"),
        ("Total Estimated Daily Yield", "1,828+ JWC / Day for active miners"),
    ], headers=("Mining Metric", "Operational Value"))

    add_image("telegram_assets/screenshot_2_mining.png", width="12.0cm", height="6.75cm")

    # =============================================================
    # CHAPTER 4: STAKING MECHANICS (VIP VAULT +32.5% APY)
    # =============================================================
    doc.text.addElement(H(outlinelevel=1, stylename="ChapterHeading", text="4. VIP Staking Vault: High-Yield Compounding (+32.5% APY)"))

    add_p(
        "The VIP Staking Vault is the wealth preservation engine of the JuwishCoin ecosystem. "
        "By staking your mined or purchased JWC tokens into the vault, you contribute to ecosystem liquidity stability and earn "
        "an industry-leading +32.5% Annual Percentage Yield (APY)."
    )

    doc.text.addElement(H(outlinelevel=2, stylename="SectionHeading", text="Key Staking Vault Highlights"))
    add_bullet("+32.5% Annual Percentage Yield calculated on daily compounding cycles.", "Dynamic High Yield:")
    add_bullet("Stake directly from your mined balance or deposit external BNB, USDT, BUSD, or WBNB.", "Multi-Token Auto-Deposit:")
    add_bullet("Deposits made via BNB or USDT are automatically converted to JWC via PancakeSwap V3 and staked instantly.", "Atomic Liquidity Gateway:")
    add_bullet("JuwishCoin charges zero deposit tax or vault management fees for stakers.", "0% Vault Fee:")
    add_bullet("Harvest your earned staking rewards anytime directly back to your liquid portfolio.", "Flexible Harvesting:")

    add_table_3col([
        ("Staking 1,000 JWC", "+325.0 JWC / Year", "$975.00 USDT Annual Yield (@ $3.00)"),
        ("Staking 5,000 JWC", "+1,625.0 JWC / Year", "$4,875.00 USDT Annual Yield (@ $3.00)"),
        ("Staking 20,000 JWC", "+6,500.0 JWC / Year", "$19,500.00 USDT Annual Yield (@ $3.00)"),
        ("Staking 100,000 JWC", "+32,500.0 JWC / Year", "$97,500.00 USDT Annual Yield (@ $3.00)"),
    ], headers=("Staked Principal", "Estimated Annual Reward (+32.5% APY)", "Valuation at $3.00 Target"))

    add_callout(
        "Staking rewards are paid out in native JWC tokens. When combined with the $3.00 trading target, stakers benefit "
        "both from token quantity growth and token valuation appreciation.",
        title="STAKER ADVANTAGE:"
    )

    # =============================================================
    # CHAPTER 5: TRADING TERMINAL & $3.00 CASH-OUT
    # =============================================================
    doc.text.addElement(H(outlinelevel=1, stylename="ChapterHeading", text="5. DEX Trading Terminal: Buying, Selling & $3.00 Cash-Out"))

    add_p(
        "The JuwishCoin Trade Terminal provides an institutional-grade crypto trading interface modeled after professional exchange terminals. "
        "Traders can view live Candlestick charts across 1H, 1D, 1W, and 1M intervals, analyze real-time order books, inspect market depth, "
        "and execute atomic swaps."
    )

    doc.text.addElement(H(outlinelevel=2, stylename="SectionHeading", text="Available Trading Pairs"))
    add_bullet("JWC / USDT: The primary stablecoin trading pair pegged at the $3.0000 benchmark.", "1. Primary Dollar Pair:")
    add_bullet("JWC / BNB: Direct decentralized trading pair against native Binance Coin.", "2. Blockchain Native Pair:")
    add_bullet("JWC / BTC: Macro pair for high-net-worth portfolio diversification.", "3. High-Net-Worth Macro Pair:")

    doc.text.addElement(H(outlinelevel=2, stylename="SectionHeading", text="How to Sell JuwishCoin ($JWC -> $USDT) at $3.00"))
    add_p("Cashing out your tokens is straightforward and fully transparent:")
    add_bullet("Click on the Trade tab on the bottom navigation bar and select the 'SELL' mode.", "1. Select Sell Tab:")
    add_bullet("Enter the amount of JWC you wish to sell (or use the 25%, 50%, 75%, or MAX quick selectors).", "2. Specify Quantity:")
    add_bullet("The terminal automatically calculates your exact USDT return at $3.00 per token (e.g. 1,000 JWC = 3,000 USDT).", "3. Review Rate:")
    add_bullet("Tap 'EXECUTE SELL ORDER'. The order is processed via the PancakeSwap V3 router with 0.05% liquidity fee.", "4. Instant Swap:")
    add_bullet("You can also tap the 'PANCAKESWAP' button to execute directly in PancakeSwap's Web3 interface or verify on BscScan.", "5. External Web3 Router:")

    add_image("telegram_assets/screenshot_1_trading.png", width="12.0cm", height="6.75cm")

    add_callout(
        "Direct PancakeSwap Sell Route:\n"
        "https://pancakeswap.finance/swap\n"
        "?inputCurrency=0xfEEEF79d2A97d9e1f9bcB8eBA8FD9587079C9e99\n"
        "&outputCurrency=0x55d398326f99059fF775485246999027B3197955\n\n"
        "Tokens Pre-filled: JWC (0xfEEE...9e99) -> BSC-USDT (0x55d3...7955)",
        title="OFFICIAL PANCAKESWAP DIRECT TRADE ROUTE:"
    )

    # =============================================================
    # CHAPTER 6: ASSETS PORTFOLIO & P2P ESCROW TRANSFERS
    # =============================================================
    doc.text.addElement(H(outlinelevel=1, stylename="ChapterHeading", text="6. Assets Portfolio & Zero-Fee P2P Instant Transfers"))

    add_p(
        "The Assets dashboard offers a comprehensive overview of your wealth across multiple tokens (JWC, BNB, USDT, BTC) "
        "with real-time net-worth valuation in USD, 24-hour profit/loss analytics, and balance privacy toggles."
    )

    doc.text.addElement(H(outlinelevel=2, stylename="SectionHeading", text="VIP Peer-to-Peer (P2P) Escrow Protocol"))
    add_p(
        "One of the standout features of JuwishCoin is its internal Off-Chain Settlement Protocol, enabling users to transfer "
        "JWC instantly to friends, buyers, or OTC trading partners with ZERO gas fees."
    )
    add_bullet("Send to any user simply by typing their Telegram username (e.g. @alex_whale) or pasting their BSC 0x address.", "Telegram Synced:")
    add_bullet("Transfers settle in under 0.5 seconds on the internal multi-sig ledger.", "Sub-Second Settlement:")
    add_bullet("VIP P2P transfers incur 0.00 fee — completely free of blockchain gas costs.", "100% Zero-Fee:")
    add_bullet("Attach an encrypted transfer memo (e.g., 'Payment for OTC deal #42').", "Custom Transaction Memos:")
    add_bullet("Quick-select recent contacts for frictionless 1-tap transfers.", "Whale Contact Book:")

    add_table_2col([
        ("Transfer Mechanism", "VIP Peer-to-Peer Internal Escrow"),
        ("Supported Identifiers", "Telegram @handle, VIP Member ID, or BSC 0x... Address"),
        ("Transaction Fee", "0.00 (100% Free for VIP Members)"),
        ("Execution Speed", "Sub-Second (<0.5 seconds)"),
        ("Security Standard", "Multi-Sig Audited Internal Ledger"),
    ], headers=("Protocol Feature", "Standard"))

    # =============================================================
    # CHAPTER 7: EARN HUB, STREAKS & VIP REFERRAL PROGRAM
    # =============================================================
    doc.text.addElement(H(outlinelevel=1, stylename="ChapterHeading", text="7. Earn Hub: Daily Streaks, Bounties & VIP Referral Program"))

    add_p(
        "The Earn Hub is designed to accelerate community viral growth and reward loyalty through three core mechanisms: "
        "the 7-Day Login Streak, Social Bounty Tasks, and the VIP Whale Referral Program."
    )

    doc.text.addElement(H(outlinelevel=2, stylename="SectionHeading", text="7-Day Progressive Streak Rewards"))
    add_table_3col([
        ("Day 1 Streak", "+50 JWC Bonus", "Initial login reward"),
        ("Day 2 Streak", "+100 JWC Bonus", "Consecutive day multiplier"),
        ("Day 3 Streak", "+200 JWC Bonus", "Active miner streak boost"),
        ("Day 4 Streak", "+400 JWC Bonus", "Mid-week loyalty drop"),
        ("Day 5 Streak", "+800 JWC Bonus", "Prestige status activation"),
        ("Day 6 Streak", "+1,500 JWC Bonus", "High-tier multiplier drop"),
        ("Day 7 Streak", "+3,000 JWC + Mystery Gold Box", "Weekly jackpot & streak cycle reset"),
    ], headers=("Streak Day", "JWC Token Drop", "Multiplier & Bonus Status"))

    doc.text.addElement(H(outlinelevel=2, stylename="SectionHeading", text="VIP Whale Referral Program (10% Lifetime Commission)"))
    add_p(
        "Users can generate passive income by building their personal miner guild. "
        "Share your unique referral link to earn a continuous 10% commission on all tokens mined and earned by your invitees."
    )
    add_bullet("Earn a flat 10% lifetime commission on every single JWC token extracted or earned by your friends.", "Direct 10% Commission:")
    add_bullet("Unlock VIP Tier status as your invite count grows (Bronze Whale, Silver Whale, Gold Whale, Platinum Whale, Diamond Whale).", "Tier Progression:")
    add_bullet("Receive direct JWC milestone drops of up to +50,000 JWC as your team expands.", "Milestone Bonuses:")
    add_bullet("1-Tap Telegram sharing pre-fills an engaging invite message with your personalized deep link.", "Viral Sharing:")

    add_image("telegram_assets/screenshot_3_earn_streak.png", width="12.0cm", height="6.75cm")

    # =============================================================
    # CHAPTER 8: WEB3 WALLET SETUP (METAMASK & TRUST WALLET)
    # =============================================================
    doc.text.addElement(H(outlinelevel=1, stylename="ChapterHeading", text="8. Web3 Wallet Setup: MetaMask & Trust Wallet Guide"))

    add_p(
        "To view and manage your JuwishCoin ($JWC) tokens outside of Telegram or trade on external decentralized exchanges, "
        "you can import the token into any standard Web3 wallet such as MetaMask, Trust Wallet, Bitget Wallet, or SafePal."
    )

    doc.text.addElement(H(outlinelevel=2, stylename="SectionHeading", text="Step-by-Step Wallet Configuration"))
    add_bullet("Open your Web3 wallet and ensure the network is set to BNB Smart Chain (BSC / BNB Mainnet - Chain ID: 56).", "Step 1: Network Selection:")
    add_bullet("Scroll to the bottom of your token list and tap 'Import Tokens' or 'Add Custom Token'.", "Step 2: Add Custom Token:")
    add_bullet("Paste the official JuwishCoin contract address: 0xfEEEF79d2A97d9e1f9bcB8eBA8FD9587079C9e99", "Step 3: Paste Contract Address:")
    add_bullet("The token symbol (JWC) and decimals of precision (18) will automatically populate. If not, enter 'JWC' and '18'.", "Step 4: Verify Parameters:")
    add_bullet("Tap 'Import' or 'Save'. JuwishCoin will now appear in your wallet balance.", "Step 5: Confirm Import:")

    add_table_2col([
        ("Network Name", "BNB Smart Chain (BSC)"),
        ("RPC URL", "https://bsc-dataseed.binance.org/"),
        ("Chain ID", "56"),
        ("Currency Symbol", "BNB"),
        ("Contract Address", "0xfEEEF79d2A97d9e1f9bcB8eBA8FD9587079C9e99"),
        ("Token Symbol", "JWC"),
        ("Decimals", "18"),
        ("Block Explorer URL", "https://bscscan.com"),
    ], headers=("Network Parameter", "Configuration Value"))

    # =============================================================
    # CHAPTER 9: SECURITY, FAIR PLAY & SMART CONTRACT VERIFICATION
    # =============================================================
    doc.text.addElement(H(outlinelevel=1, stylename="ChapterHeading", text="9. Security, Anti-Cheat & Contract Verification"))

    add_p(
        "Security, decentralization, and fair distribution are the cornerstones of the JuwishCoin project. "
        "The development team has implemented stringent safeguards to protect community participants."
    )

    doc.text.addElement(H(outlinelevel=2, stylename="SectionHeading", text="Core Security Standards"))
    add_bullet("The BEP-20 token contract is deployed on the public BNB Smart Chain, enabling any participant to inspect code and balances on BscScan.", "Public Blockchain Auditability:")
    add_bullet("Anti-scripting and rate-limiting modules prevent automated macro clickers from abusing the mining faucet, protecting token valuation.", "Anti-Bot Rate Limiting:")
    add_bullet("Liquidity is locked in the PancakeSwap V3 protocol, ensuring uninterrupted swap liquidity for buyers and sellers.", "Decentralized Liquidity:")
    add_bullet("The global admin parameters (energy, rates, broadcasts) are protected by a secure master PIN (7777).", "VIP Admin Architecture:")

    add_callout(
        "• NEVER share your 12 or 24-word recovery seed phrase with anyone.\n"
        "• JuwishCoin team members and community moderators will NEVER send you a DM asking for cryptocurrency or passwords.\n"
        "• Always bookmark and use the official contract address: 0xfEEEF79d2A97d9e1f9bcB8eBA8FD9587079C9e99",
        title="OFFICIAL SAFETY RULES FOR TELEGRAM MEMBERS:"
    )

    # =============================================================
    # CHAPTER 10: FAQ & OFFICIAL DIRECTORY
    # =============================================================
    doc.text.addElement(H(outlinelevel=1, stylename="ChapterHeading", text="10. Frequently Asked Questions (FAQ) & Official Directory"))

    doc.text.addElement(H(outlinelevel=2, stylename="SectionHeading", text="Frequently Asked Questions"))

    add_bullet("To safeguard genuine miners and prevent bot farms, users deposit or buy at least 5 JWC ($15.00 USDT) once. This permanently unlocks tap mining (+10 JWC/tap) and 24/7 cloud rigs (34.5 JWC/hr).", "Q1: How do I start mining JuwishCoin?")
    add_bullet("0xfEEEF79d2A97d9e1f9bcB8eBA8FD9587079C9e99 on BNB Smart Chain.", "Q2: What is the official contract address?")
    add_bullet("The default baseline trading rate is initialized at $3.0000 USDT per JWC, available on the internal Trade terminal and PancakeSwap V3.", "Q3: At what price can I trade or sell JWC?")
    add_bullet("Staked tokens earn an annual return of +32.5%, compounded daily and harvestable whenever you choose.", "Q4: How does the +32.5% APY Staking Vault work?")
    add_bullet("Yes. Using the P2P transfer protocol on the Assets screen, you can send tokens instantly to any Telegram @username or BSC wallet address with zero fees.", "Q5: Can I transfer JWC to friends?")
    add_bullet("You earn a 10% lifetime commission on every token your referred friends mine or earn in the app.", "Q6: How does the referral program reward me?")

    doc.text.addElement(H(outlinelevel=2, stylename="SectionHeading", text="Official Links & Resource Directory"))
    add_table_2col([
        ("Telegram Bot", "https://t.me/juwishcoin_bot"),
        ("Live WebApp Portal", "https://techdaddyhub.github.io/juwishcoin-telegram-miniapp/"),
        ("BscScan Explorer", "https://bscscan.com/token/0xfEEEF79d2A97d9e1f9bcB8eBA8FD9587079C9e99"),
        ("PancakeSwap Buy Route", "https://pancakeswap.finance/swap\n?outputCurrency=0xfEEEF79d2A97d9e1f9bcB8eBA8FD9587079C9e99"),
        ("PancakeSwap Sell Route", "https://pancakeswap.finance/swap\n?inputCurrency=0xfEEEF79d2A97d9e1f9bcB8eBA8FD9587079C9e99"),
        ("DexScreener Tracker", "https://dexscreener.com/bsc/0xfEEEF79d2A97d9e1f9bcB8eBA8FD9587079C9e99"),
    ], headers=("Resource", "Official URL / Deep Link"))

    add_p(
        "© 2026 JuwishCoin ($JWC) Global Community Foundation. All rights reserved. "
        "This document is authorized for free distribution across official Telegram channels, groups, forums, and partner communities.",
        stylename="CoverMeta"
    )

    # -------------------------------------------------------------
    # 4. Save ODT and Convert to PDF
    # -------------------------------------------------------------
    odt_path = "JuwishCoin_Official_User_Guide.odt"
    pdf_path = "JuwishCoin_Official_User_Guide.pdf"
    
    doc.save(odt_path)
    print(f"Saved ODT to {odt_path}")

    # Convert using LibreOffice
    profile_dir = "/tmp/lo_profile_jwc"
    os.makedirs(profile_dir, exist_ok=True)
    cmd = [
        "soffice",
        f"-env:UserInstallation=file://{profile_dir}",
        "--headless",
        "--convert-to", "pdf",
        odt_path,
        "--outdir", "."
    ]
    res = subprocess.run(cmd, capture_output=True, text=True)
    print("LibreOffice STDOUT:", res.stdout)
    print("LibreOffice STDERR:", res.stderr)
    print("LibreOffice Return Code:", res.returncode)

    if os.path.exists(pdf_path):
        size = os.path.getsize(pdf_path)
        print(f"SUCCESS: Generated {pdf_path} ({size} bytes)")
    else:
        print(f"ERROR: {pdf_path} was not created!")

if __name__ == "__main__":
    create_guide()
