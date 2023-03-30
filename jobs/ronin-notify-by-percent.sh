#!/bin/bash

set -e

DATA=$(curl -XGET 'https://api.coingecko.com/api/v3/coins/ronin?tickers=false&market_data=1&community_data=false&developer_data=false&sparkline=false&localization=false' -H 'accept: application/json')

price_1h_percent=$(echo $DATA | jq .market_data.price_change_percentage_1h_in_currency.usd)
price_24h_percent=$(echo $DATA | jq .market_data.price_change_percentage_24h_in_currency.usd)
price_7d_percent=$(echo $DATA | jq .market_data.price_change_percentage_7d_in_currency.usd)
current_price=$(echo $DATA | jq .market_data.current_price.usd)
h24h=$(echo $DATA | jq .market_data.high_24h.usd)
l24h=$(echo $DATA | jq .market_data.low_24h.usd)

echo Current price is $current_price

which python

python - <<EOF

if abs($price_1h_percent) > $NOTIFY_PERCENT:
    print("price change $price_1h_percent% compare to $NOTIFY_PERCENT% difference, fire notify")
    exit(0)
else:
    print("price changed 1h: $price_1h_percent")
    exit(1)
EOF

curl -X POST \
     -H 'Content-Type: application/json' \
     https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage \
    -d  @- << EOF 
{
    "chat_id": "$TELEGRAM_CHAT_ID", 
    "text": "Ronin - \$RON\nPrice [USD]: $current_price\nH: $h24h | L: $l24h\n1h changed: $price_1h_percent%\n24h changed: $price_24h_percent%\n7d changed: $price_7d_percent%\n\nCronjob at: https://github.com/duythinht/crontab/",
    "disable_notification": true
}
EOF