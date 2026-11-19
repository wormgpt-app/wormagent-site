# Wormagent

وكيل برمجة يعمل في الطرفية — Linux x86_64.

## التثبيت

```bash
curl -fsSL https://wormagent.net/install | bash
```

أو يدوياً من الحزمة:

```bash
unzip Wormagent-full-linux-x64.zip
cd Wormagent-full-linux-x64
./install-portable.sh
```

## التحميل

- الحزمة الكاملة (V1 + V2 + سكربتات): صفحة [Releases](../../releases/latest)
- الملف التنفيذي المفرد: `Wormagent-linux-x64`

## التحقق من السلامة

```bash
sha256sum Wormagent-full-linux-x64.zip
# a61417ac201469926e8195cc64fe7731fc79a12d08c6bbf3715fd2495283e477
```

## الاستخدام

```bash
export PATH="$HOME/.Wormagent/bin:$PATH"
cd my-project
Wormagent
```

## الموقع

هذا المستودع يستضيف صفحة التحميل على GitHub Pages والملف التنفيذي كأصول إصدارات (Release assets).

- `index.html` — صفحة الموقع
- `install` / `install.sh` — سكربت التثبيت
- `CNAME` — ربط النطاق `wormagent.net`
