#!/bin/bash

function state.get { # key
    redis-cli -u $REDIS_ADDR get $1
}

function state.set { # key, value
    redis-cli -u $REDIS_ADDR set $1 $2
}