#!/usr/bin/env python3
"""
يحوّل لقطات iPhone الخام (1320×2868) إلى لقطات App Store مصمّمة لتطبيق فرخة.
ضع اللقطات في:
  screenshots/raw/ar/   (الواجهة العربية)  -> screenshots/iphone_6_9/ar/
ثم: python3 make_screenshots.py
أسماء الملفات يجب أن تحوي أحد المفاتيح:
  cycles / record / prices / tools / vaccination / diseases / articles / notes

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
FM = os.path.join(FONTS, "IBMPlexSansArabic-Medium.ttf")

# مقاسات App Store المطلوبة لـ iPhone (المجلد, العرض, الارتفاع)
# 6.9" و 6.5" يغطيان متطلبات Apple الحالية لأجهزة iPhone.
DEVICES = [
    ("iphone_6_9", 1320, 2868),
    ("iphone_6_5", 1284, 2778),
]
# مقاس التصميم المرجعي (تُحسب باقي القياسات نسبةً إليه)
BASE_W, BASE_H = 1320, 2868

C1, C2 = (107, 156, 90), (58, 92, 46)   # أخضر فرخة
GOLD = (223, 192, 106)

# key -> (output name, العنوان, العنوان الفرعي)  — عربي فقط (التطبيق عربي)
SLIDES = [
    ("home",        "01_home",        "كل مزرعتك في يدك",     "أسعار ودورات وأدوات في مكان واحد"),
    ("prices",      "02_prices",      "أسعار السوق اليومية",  "تابع أسعار الفراخ والأعلاف"),
    ("tools",       "03_tools",       "أدوات حسابية للدواجن", "أكثر من 20 أداة في متناول يدك"),
    ("weight",      "04_weight",      "الوزن حسب العمر",      "اعرف الوزن المتوقع لكل يوم"),
    ("vaccination", "05_vaccination", "جدول التحصينات",       "مواعيد التحصين حسب العمر"),
    ("diseases",    "06_diseases",    "تشخيص الأمراض",        "تعرّف على المرض من الأعراض"),
    ("articles",    "07_articles",    "مقالات ونصائح",        "دليلك في تربية الدواجن"),
    ("notes",       "08_notes",       "نوتة الملاحظات",       "دوّن ملاحظاتك بسرعة"),
]

def ar(t): return get_display(arabic_reshaper.reshape(t))

def gradient(W, H):
    img = Image.new("RGB", (W, H)); px = img.load(); m = W + H
    for y in range(H):
        for x in range(W):
            t = (x + y) / m
            px[x, y] = tuple(int(C1[i] + (C2[i] - C1[i]) * t) for i in range(3))
    return img.convert("RGBA")

def frame(shot, fw, fh, radius, border):
    iw, ih = fw - 2 * border, fh - 2 * border
    shot = shot.convert("RGB")
    target = iw / ih; sw, sh = shot.size
    if sw / sh > target:
        nw = int(sh * target); shot = shot.crop(((sw - nw) // 2, 0, (sw - nw) // 2 + nw, sh))
    else:
        nh = int(sw / target); shot = shot.crop((0, 0, sw, nh))
    shot = shot.resize((iw, ih), Image.LANCZOS).convert("RGBA")
    smask = Image.new("L", (iw, ih), 0)
    ImageDraw.Draw(smask).rounded_rectangle([0, 0, iw, ih], radius=radius - border, fill=255)
    phone = Image.new("RGBA", (fw, fh), (0, 0, 0, 0))
    fmask = Image.new("L", (fw, fh), 0)
    ImageDraw.Draw(fmask).rounded_rectangle([0, 0, fw, fh], radius=radius, fill=255)
    black = Image.new("RGBA", (fw, fh), (12, 14, 18, 255))
    phone.paste(black, (0, 0), fmask)
    phone.paste(shot, (border, border), smask)
    return phone, fw, fh

def build(out_path, title, sub, raw_path, W, H):
    sx = W / BASE_W; sy = H / BASE_H   # عوامل القياس النسبية لكل مقاس جهاز
    bg = gradient(W, H); d = ImageDraw.Draw(bg, "RGBA")
    for r in (int(420 * sy), int(640 * sy), int(900 * sy)):
        d.ellipse([W - int(200 * sx) - r, -int(300 * sy) - r,
                   W - int(200 * sx) + r, -int(300 * sy) + r],
                  outline=(255, 255, 255, 18), width=5)
    tt = ar(title); st = ar(sub)
    tf = ImageFont.truetype(FB, int(104 * sy)); sf = ImageFont.truetype(FM, int(56 * sy))
    top = int(170 * sy)
    tb = d.textbbox((0, 0), tt, font=tf); tw = tb[2] - tb[0]
    d.text(((W - tw) // 2, top), tt, font=tf, fill=(255, 255, 255, 255))
    uy = top + (tb[3] - tb[1]) + int(44 * sy)
    d.rounded_rectangle([(W - tw) // 2, uy, (W - tw) // 2 + tw, uy + int(14 * sy)],
                        radius=int(7 * sy), fill=GOLD + (255,))
    sb = d.textbbox((0, 0), st, font=sf); sw = sb[2] - sb[0]
    d.text(((W - sw) // 2, uy + int(40 * sy)), st, font=sf, fill=(225, 240, 230, 255))
    fw, fh = int(940 * sx), int(2040 * sy)
    radius, border = int(120 * sy), int(16 * sy)
    phone, fw, fh = frame(Image.open(raw_path), fw, fh, radius, border)
    px = (W - fw) // 2; py = int(520 * sy)
    sh = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(sh).rounded_rectangle(
        [px + int(14 * sx), py + int(28 * sy), px + fw + int(14 * sx), py + fh + int(28 * sy)],
        radius=radius, fill=(0, 0, 0, 110))
    sh = sh.filter(ImageFilter.GaussianBlur(int(34 * sy)))
    bg = Image.alpha_composite(bg, sh); bg.alpha_composite(phone, (px, py))
    bg.convert("RGB").save(out_path, "PNG")

def run():
    raw = os.path.join(HERE, "screenshots", "raw")
    if not os.path.isdir(raw):
        print("no raw dir"); return
    raws = [r for r in sorted(os.listdir(raw)) if r.lower().endswith((".png", ".jpg", ".jpeg"))]
    if not raws:
        print("no raw screenshots"); return
    for folder, W, H in DEVICES:
        out = os.path.join(HERE, "screenshots", folder); os.makedirs(out, exist_ok=True)
        print(f"== {folder}  {W}x{H} ==")
        for key, name, title, sub in SLIDES:
            m = [r for r in raws if key in r.lower()]
            if not m:
                print(f"· skip {key}"); continue
            build(os.path.join(out, name + ".png"), title, sub, os.path.join(raw, m[0]), W, H)
            print(f"✓ {name}.png")

if __name__ == "__main__":
    run()   # التطبيق عربي فقط
