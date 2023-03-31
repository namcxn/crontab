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

PRICE_STATE=".state/$GITHUB_JOB-last-price"

if [ -f $PRICE_STATE ]
then
    last_price=$(cat $PRICE_STATE)
else
    last_price="0.0"
fi

echo "Last price: $last_price"

if python3 - <<EOF

diff = abs(($last_price/$current_price - 1.0) * 100)

if diff > $NOTIFY_PERCENT:
    print(f"price change {diff}% compare to $NOTIFY_PERCENT% difference, fire notify")
    exit(0)
else:
    print(f"price change {diff}%")
    exit(1)
EOF
then
curl -X POST \
     -H 'Content-Type: application/json' \
     https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage \
    -d  @- << EOF 
{
    "chat_id": "$TELEGRAM_CHAT_ID", 
    "text": "Ronin - \$RON price change > $NOTIFY_PERCENT% since last notify\nPrice [USD]: $current_price\nH: $h24h | L: $l24h\n1h changed: $price_1h_percent%\n24h changed: $price_24h_percent%\n7d changed: $price_7d_percent%\n\nCronjob at: https://github.com/duythinht/crontab/",
    "disable_notification": true
}
EOF

echo "$current_price" > $PRICE_STATE

else
    echo 'Wont notify!'
fi