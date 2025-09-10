#!/usr/bin/env python3
# تبدیل ساده آدرس کاربری TON (Base64/URL-safe) به hex

import base64
import sys

if len(sys.argv) != 2:
    print("Usage: convert_address.py <TON_address>")
    sys.exit(1)

addr = sys.argv[1]
# تبدیل URL-safe به استاندارد base64
b64 = addr.replace('-', '+').replace('_', '/')
# padding
b64 += '=' * ((4 - len(b64) % 4) % 4)
try:
    raw = base64.b64decode(b64)
except Exception as e:
    print("خطا در دیکد base64:", e)
    sys.exit(2)

print("raw (hex):", raw.hex())
if len(raw) >= 32:
    print("last 32 bytes (account id):", raw[-32:].hex())
else:
    print("تعداد بایت‌ها کمتر از 32 است؛ ممکن است آدرس غیرمعمول باشد.")

print("\nتوجه: این اسکریپت یک تبدیل کلی انجام می‌دهد. برای مطمئن شدن از 32-byte account id، خروجی را بررسی کنید و اگر نیاز به تبدیل دقیق‌تر یا استفاده از کتابخانه‌های TON داشتید، اطلاع دهید.")