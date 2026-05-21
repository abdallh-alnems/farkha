# DNS Backup — nims-farkha.com

**تاريخ الحفظ:** 2026-05-16 (قبل نقل سيرفر Hostinger من فرنسا لألمانيا)

---

## ⚠️ القيم اللي **مش لازم** تتغير بعد النقل:

### `@ A` → **76.76.21.21** (Vercel — للموقع الرئيسي)
**حرجة جداً** — لو اتغيّرت، الموقع كله يقع.

### `www CNAME` → **nims-farkha.com.**

### `@ MX` → mx1.hostinger.com (priority 5), mx2.hostinger.com (priority 10)

### `@ TXT`:
- `google-site-verification=0fuP-eoRWJCfloMF53_i2tWhBPxtSda-0zZKIp3GI-w`
- `v=spf1 include:_spf.mail.hostinger.com ~all`

### `_dmarc TXT` → `v=DMARC1; p=none`

### CNAME records للـ mail (hostingermail-a/b/c._domainkey, autodiscover, autoconfig)

---

## ⚠️ القيم اللي **هتتغير** بعد النقل (الـ IP الجديد لسيرفر ألمانيا):

| Name | Type | القيمة الحالية | الحالة بعد النقل |
|------|------|----------------|------------------|
| `api` | A | `92.113.28.77` | يتحدّث بـ IP ألمانيا |
| `api` | AAAA | `2a02:4780:27:1749:0:33d4:2d31:2` | يتحدّث بـ IPv6 الجديد |
| `ftp` | A | `92.113.28.77` | يتحدّث بـ IP ألمانيا |
| `backend` | A | `147.93.88.36` | (سيرفر VPS مختلف، غالباً مش هيتأثر) |

---

## 📋 الـ DNS Records الكاملة (JSON):

```json
[
  {"name":"@","type":"A","ttl":300,"content":"76.76.21.21"},
  {"name":"@","type":"MX","ttl":14400,"content":["5 mx1.hostinger.com.","10 mx2.hostinger.com."]},
  {"name":"@","type":"TXT","ttl":3600,"content":[
    "google-site-verification=0fuP-eoRWJCfloMF53_i2tWhBPxtSda-0zZKIp3GI-w",
    "v=spf1 include:_spf.mail.hostinger.com ~all"
  ]},
  {"name":"www","type":"CNAME","ttl":300,"content":"nims-farkha.com."},
  {"name":"api","type":"A","ttl":1800,"content":"92.113.28.77"},
  {"name":"api","type":"AAAA","ttl":1800,"content":"2a02:4780:27:1749:0:33d4:2d31:2"},
  {"name":"ftp","type":"A","ttl":1800,"content":"92.113.28.77"},
  {"name":"backend","type":"A","ttl":1800,"content":"147.93.88.36"},
  {"name":"_dmarc","type":"TXT","ttl":3600,"content":"v=DMARC1; p=none"},
  {"name":"autoconfig","type":"CNAME","ttl":300,"content":"autoconfig.mail.hostinger.com."},
  {"name":"autodiscover","type":"CNAME","ttl":300,"content":"autodiscover.mail.hostinger.com."},
  {"name":"hostingermail-a._domainkey","type":"CNAME","ttl":300,"content":"hostingermail-a.dkim.mail.hostinger.com."},
  {"name":"hostingermail-b._domainkey","type":"CNAME","ttl":300,"content":"hostingermail-b.dkim.mail.hostinger.com."},
  {"name":"hostingermail-c._domainkey","type":"CNAME","ttl":300,"content":"hostingermail-c.dkim.mail.hostinger.com."}
]
```

---

## 🔧 إجراءات بعد النقل:

### 1. اشيك على `@ A`
```bash
dig +short nims-farkha.com A
```
**المتوقع:** `76.76.21.21` — لو اتغيّرت، رجّعها فوراً.

### 2. حدّث `api A` و `api AAAA` بـ IP السيرفر الألماني الجديد:
- Hostinger هيقولك الـ IP الجديد بعد ما النقل يخلص
- لو ما حدثوش تلقائياً، حدّثهم يدوياً

### 3. تأكد إن `api.nims-farkha.com` بيرد:
```bash
curl -I https://api.nims-farkha.com/backend_farkha/
```

### 4. اشيك من الموقع:
- ادخل `https://nims-farkha.com`
- شوف لو الأسعار بتظهر → الـ API شغال

---

## 📞 IP السيرفر الفرنسي القديم (للرجوع):
`92.113.28.77` (IPv4)
`2a02:4780:27:1749:0:33d4:2d31:2` (IPv6)

---

## 🌐 IPs مهمة:
- **Vercel:** `76.76.21.21` (الموقع الرئيسي)
- **Hostinger France:** `92.113.28.77` (هينتقل لألمانيا)
- **VPS (backend.nims-farkha.com):** `147.93.88.36`
