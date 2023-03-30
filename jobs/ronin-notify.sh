#!/bin/bash

set -e

DATA=$(curl -XGET 'https://api.coingecko.com/api/v3/coins/ronin?tickers=false&market_data=1&community_data=false&developer_data=false&sparkline=false&localization=false' -H 'accept: application/json')

price_1h_percent=$(echo $DATA | jq .market_data.price_change_percentage_1h_in_currency.usd)
current_price=$(echo $DATA | jq .market_data.current_price.usd)

echo Current price is $current_price

curl -X POST \
     -H 'Content-Type: application/json' \
     https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage \
    -d  @- << EOF 
{
    "chat_id": "$TELEGRAM_CHAT_ID", 
    "text": "Ronin - \$RON\nPrice [USD]: $current_price\n1h changed: $price_1h_percent%\nCronjob at: https://github.com/duythinht/crontab/",
    "disable_notification": true
}
EOF