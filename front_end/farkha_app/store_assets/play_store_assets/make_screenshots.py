#!/usr/bin/env python3
"""
يحوّل لقطات Android الخام (1080×1920) إلى لقطات Google Play مصمّمة لتطبيق فرخة.
ضع اللقطات في:
  screenshots/raw/ar/   (الواجهة العربية)  -> screenshots/phone/ar/
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
# نستخدم IBM Plex Sans Arabic (المرفق في store_assets/fonts) لنصوص اللافتة لأنه
# يحتوي على Arabic Presentation Forms التي يحتاجها arabic_reshaper مع Pillow.
# خط التطبيق Cairo لا يحوي هذه الأشكال ولا يُشكَّل بشكل صحيح في Pillow بدون libraqm،
# فتظهر الحروف منفصلة. (لقطات الواجهة نفسها تبقى بخط Cairo داخل التطبيق.)
FONTS = os.path.join(HERE, "..", "fonts")
FB = os.path.join(FONTS, "IBMPlexSansArabic-Bold.ttf")      # عناوين
FS = os.path.join(FONTS, "IBMPlexSansArabic-SemiBold.ttf")
FM = os.path.join(FONTS, "IBMPlexSansArabic-Medium.ttf")    # نص فرعي

W, H = 1080, 1920
# ألوان علامة فرخة (أخضر) من lib/core/constant/theme/colors.dart
C1, C2 = (107, 156, 90), (58, 92, 46)   # primaryLight -> primaryDark
GOLD = (223, 192, 106)                  # secondaryLight

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

_BG = None
def base_bg():
    """تدرّج الخلفية مع الدوائر — يُحسب مرة واحدة ويُعاد استخدامه."""
    global _BG
    if _BG is not None:
        return _BG.copy()
    img = Image.new("RGB", (W, H)); px = img.load(); m = W + H
    for y in range(H):
        for x in range(W):
            t = (x + y) / m
            px[x, y] = tuple(int(C1[i] + (C2[i] - C1[i]) * t) for i in range(3))
    img = img.convert("RGBA")
    d = ImageDraw.Draw(img, "RGBA")
    for r in (320, 500, 720):
        d.ellipse([W - 160 - r, -240 - r, W - 160 + r, -240 + r], outline=(255, 255, 255, 18), width=4)
    _BG = img
    return _BG.copy()

def frame(shot):
    fh = 1360; radius = 90; border = 14
    ih = fh - 2 * border
    iw = int(ih * (W / H))          # 9:16 — نفس نسبة اللقطة فلا يحدث أي قص
    fw = iw + 2 * border
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

def build(out_path, title, sub, raw_path, lang):
    bg = base_bg(); d = ImageDraw.Draw(bg, "RGBA")
    tt = ar(title) if lang == "ar" else title
    st = ar(sub) if lang == "ar" else sub
    tf = ImageFont.truetype(FB, 72); sf = ImageFont.truetype(FM, 40)
    tb = d.textbbox((0, 0), tt, font=tf); tw = tb[2] - tb[0]
    d.text(((W - tw) // 2, 100), tt, font=tf, fill=(255, 255, 255, 255))
    uy = 100 + (tb[3] - tb[1]) + 30
    d.rounded_rectangle([(W - tw) // 2, uy, (W - tw) // 2 + tw, uy + 10], radius=5, fill=GOLD + (255,))
    sb = d.textbbox((0, 0), st, font=sf); sw = sb[2] - sb[0]
    d.text(((W - sw) // 2, uy + 28), st, font=sf, fill=(225, 240, 230, 255))
    phone, fw, fh = frame(Image.open(raw_path))
    px = (W - fw) // 2; py = 346
    sh = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(sh).rounded_rectangle([px + 12, py + 24, px + fw + 12, py + fh + 24], radius=90, fill=(0, 0, 0, 110))
    sh = sh.filter(ImageFilter.GaussianBlur(28))
    bg = Image.alpha_composite(bg, sh); bg.alpha_composite(phone, (px, py))
    bg.convert("RGB").save(out_path, "PNG")

def run():
    raw = os.path.join(HERE, "screenshots", "raw")
    out = os.path.join(HERE, "screenshots", "phone"); os.makedirs(out, exist_ok=True)
    if not os.path.isdir(raw):
        print("no raw dir"); return
    raws = [r for r in sorted(os.listdir(raw)) if r.lower().endswith((".png", ".jpg", ".jpeg"))]
    if not raws:
        print("no raw screenshots"); return
    for key, name, title, sub in SLIDES:
        m = [r for r in raws if key in r.lower()]
        if not m:
            print(f"· skip {key}"); continue
        build(os.path.join(out, name + ".png"), title, sub, os.path.join(raw, m[0]), "ar")
        print(f"✓ {name}.png")

if __name__ == "__main__":
    run()   # التطبيق عربي فقط
