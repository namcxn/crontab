#!/bin/bash

set -e

source 'lib/coin.sh'
source 'lib/telegram.sh'
source 'lib/math.sh'
source 'lib/state.sh'

data=$(coin.get "ronin")

current_price=$(coin.data.current_price "$data")

message=$(coin.fmt.notify_price "$data")

telegram.send_message $TELEGRAM_CHAT_ID "$message"

state.set $LAST_PRICE_KEY $current_price