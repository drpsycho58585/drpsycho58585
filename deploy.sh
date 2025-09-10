#!/usr/bin/env bash
set -e

# اسکریپت ساده برای build و deploy قرارداد telegram_username_sale
# نیاز: toncli نصب‌شده، کیف پول آماده و funded (testnet)

CONTRACT_FC="telegram_username_sale.fc"
BUILD_DIR="build"

if ! command -v toncli &> /dev/null; then
  echo "toncli not found. لطفا آن را نصب کنید: pip install toncli" >&2
  exit 1
fi

echo "Building contract with toncli..."
toncli build

TVC_PATH="$BUILD_DIR/telegram_username_sale.tvc"
if [ ! -f "$TVC_PATH" ]; then
  echo "فایل TVC ساخته نشده: $TVC_PATH" >&2
  exit 1
fi

echo "شروع فرآیند deploy..."

# دستور deploy تعاملی است و از شما seed/Wallet را می‌پرسد تا تراکنش امضا شود.
toncli deploy --path "$TVC_PATH"

echo "Deploy command finished. لطفا خروجی را بررسی کنید و آدرس قرارداد را در اکسپلورر تست‌نت تایید کن."