سلام — من چند فایل کمکی برای ساخت، تبدیل آدرس و استقرار قرارداد FunC telegram_username_sale.fc اضافه کردم. مراحل خلاصه و دستورها در این فایل آمده است.

محتویات و هدف فایل‌ها:
- README.md: راهنمای گام‌به‌گام برای build و deploy با toncli و FunC و نکات مهم.
- deploy.sh: اسکریپت شل ساده برای build و deploy با toncli (نیاز به toncli نصب‌شده و کیف پول محلی دارد).
- convert_address.py: اسکریپتی برای تبدیل آدرس عمومی TON (فرمت Base64/URL-safe مثل UQA...) به hex/32-byte که باید در متغیر seller_addr قرارداد قرار گیرد.

مهم: من تراکنش‌های شبکه یا کلیدها را ندارم و نمی‌توانم از طرف شما استقرار انجام دهم. شما باید بر روی ماشین خودتان فایل‌ها را اجرا و تراکنش را امضا کنید.

دستورالعمل‌های سریع:

1) نصب وابستگی‌ها و ابزارها
- Python3 و pip
- نصب toncli: pip install toncli
- اگر از FunC مستقیم استفاده می‌کنید: نصب func و fift از مخازن رسمی TON

2) تبدیل آدرس به hex
- مثال:
  python3 convert_address.py "UQAthIWpZO1dDaIjRflCr-Yy529rkmkIERdiNonFKdXEnJ5M"
- خروجی شامل hex کامل و 32-byte آخر است (برای seller_addr استفاده شود). اگر تبدیل دقیق لازم دارید، حتماً خروجی را بررسی کنید.

3) آماده‌سازی قرارداد
- باز کن telegram_username_sale.fc و مقدار seller_addr را با hex 32-byte تولیدشده جایگزین کن.

4) Build
- toncli build
  یا با func/fift:
  func -o telegram_username_sale.fif -SPA telegram_username_sale.fc
  fift -s telegram_username_sale.fif

5) Deploy (testnet پیشنهاد می‌شود)
- ساخت یا بازیابی ولت در toncli:
  toncli wallet
- شارژ ولت در testnet از faucet مربوطه
- سپس اجرایی کردن اسکریپت deploy:
  bash deploy.sh

6) بررسی و تایید
- آدرس قرارداد را در testnet.tonviewer.com یا tonscan بررسی کن.

نکات امنیتی و توصیه‌ها:
- همیشه ابتدا در testnet تست کن.
- قبل از deploy مقدار seller_addr را حتماً کنترل کن.
- من فقط فایل‌ها را اضافه کردم؛ تراکنش‌ها را خودت امضا کن.
