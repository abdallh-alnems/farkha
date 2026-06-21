#!/usr/bin/env python3
"""
يولّد الرسم المميز (Feature Graphic 1024×500) لمتجر Google Play — تطبيق فرخة.
المخرجات:
  feature_graphic/ar/feature_graphic_1024x500.png
  feature_graphic/feature_graphic_1024x500.png   (نسخة افتراضية = عربية)

المتطلبات: pip3 install pillow arabic-reshaper python-bidi
"""
import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import arabic_reshaper
from bidi.algorithm import get_display

HERE  = os.path.dirname(os.path.abspath(__file__))
# IBM Plex Sans Arabic (في store_assets/fonts) — يحوي Presentation Forms اللازمة
# لـ arabic_reshaper مع Pillow. خط Cairo لا يُشكَّل صحيحاً في Pillow بدون libraqm.
FONTS = os.path.join(HERE, "..", "fonts")
FB = os.path.join(FONTS, "IBMPlexSansArabic-Bold.ttf")
FS = os.path.join(FONTS, "IBMPlexSansArabic-SemiBold.ttf")
FM = os.path.join(FONTS, "IBMPlexSansArabic-Medium.ttf")
ICON = os.path.join(HERE, "icon", "app_icon_512.png")

W, H = 1024, 500
C1, C2 = (107, 156, 90), (58, 92, 46)   # أخضر فرخة: primaryLight -> primaryDark
GOLD = (223, 192, 106)

def ar(t): return get_display(arabic_reshaper.reshape(t))

def gradient():
    img = Image.new("RGB", (W, H)); px = img.load(); m = W + H
    for y in range(H):
        for x in range(W):
            t = (x + y) / m
            px[x, y] = tuple(int(C1[i] + (C2[i] - C1[i]) * t) for i in range(3))
    img = img.convert("RGBA")
    d = ImageDraw.Draw(img, "RGBA")
    for r in (150, 250, 360, 480):
        d.ellipse([W - 120 - r, -80 - r, W - 120 + r, -80 + r], outline=(255, 255, 255, 20), width=3)
    return img

def rounded_icon(size, radius):
    ic = Image.open(ICON).convert("RGBA").resize((size, size), Image.LANCZOS)
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, size, size], radius=radius, fill=255)
    out = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    out.paste(ic, (0, 0), mask)
    return out

def build(out_path, lang):
    bg = gradient(); d = ImageDraw.Draw(bg, "RGBA")

    # --- الأيقونة على اليسار مع ظل ناعم ---
    isz = 300; ix = 78; iy = (H - isz) // 2
    icon = rounded_icon(isz, 70)
    sh = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(sh).rounded_rectangle([ix + 10, iy + 18, ix + isz + 10, iy + isz + 18], radius=70, fill=(0, 0, 0, 120))
    sh = sh.filter(ImageFilter.GaussianBlur(26))
    bg = Image.alpha_composite(bg, sh); bg.alpha_composite(icon, (ix, iy))
    d = ImageDraw.Draw(bg, "RGBA")

    # --- النصوص ---
    if lang == "ar":
        brand = ar("فرخة"); sub = ar("إدارة مزارع الدواجن")
        tag   = ar("دورات · أسعار · تحصينات · أدوات حسابية")
        bf = ImageFont.truetype(FB, 96); sf = ImageFont.truetype(FS, 40); tf = ImageFont.truetype(FM, 27)
        anchor_right = W - 70                # محاذاة لليمين
    else:
        brand = "Farkha"; sub = "Poultry Farm Manager"
        tag   = "Cycles · Prices · Vaccines · Calculators"
        bf = ImageFont.truetype(FB, 92); sf = ImageFont.truetype(FS, 38); tf = ImageFont.truetype(FM, 25)
        anchor_left = ix + isz + 56          # محاذاة لليسار بعد الأيقونة

    def measure(txt, font):
        b = d.textbbox((0, 0), txt, font=font); return b[2] - b[0], b[3] - b[1], b[1]

    bw, bh, boff = measure(brand, bf)
    sw, shh, soff = measure(sub, sf)
    tw, thh, toff = measure(tag, tf)

    gap1, gap2, gap3 = 26, 30, 26
    underline_h = 11
    block_h = bh + gap1 + underline_h + gap2 + shh + gap3 + thh
    top = (H - block_h) // 2

    def x_of(width):
        return (anchor_right - width) if lang == "ar" else anchor_left

    # العلامة
    by = top
    d.text((x_of(bw), by - boff), brand, font=bf, fill=(255, 255, 255, 255))
    # الخط الذهبي تحت العلامة
    uy = by + bh + gap1
    ux = x_of(bw)
    d.rounded_rectangle([ux, uy, ux + bw, uy + underline_h], radius=underline_h // 2, fill=GOLD + (255,))
    # العنوان الفرعي
    sy = uy + underline_h + gap2
    d.text((x_of(sw), sy - soff), sub, font=sf, fill=(232, 244, 236, 255))
    # الوسم
    ty = sy + shh + gap3
    d.text((x_of(tw), ty - toff), tag, font=tf, fill=(206, 226, 210, 255))

    bg.convert("RGB").save(out_path, "PNG")
    print("✓", os.path.relpath(out_path, HERE))

if __name__ == "__main__":
    # التطبيق عربي فقط — نولّد ملفاً واحداً مباشرةً في مجلد feature_graphic
    outdir = os.path.join(HERE, "feature_graphic"); os.makedirs(outdir, exist_ok=True)
    build(os.path.join(outdir, "feature_graphic_1024x500.png"), "ar")
