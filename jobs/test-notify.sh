#!/bin/bash

set -e

source 'lib/coin.sh'
source 'lib/telegram.sh'
source 'lib/math.sh'
source 'lib/state.sh'

data=$(coin.get "ronin")

current_price=$(coin.data.current_price "$data")

last_price=$(state.get $LAST_PRICE_KEY)

if [ -z "$last_price" ]
then
    last_price="0.0"
fi

last_price_change_percent=$(math.percent $last_price $current_price)

if [[ -z $(math.gt $last_price_change_percent $NOTIFY_PERCENT) ]]
then
    message=$(coin.fmt.notify_price "$data")
    telegram.send_message $TELEGRAM_CHAT_ID "$message"
    state.set $LAST_PRICE_KEY $current_price
else
    echo 'wont nofify'
fi