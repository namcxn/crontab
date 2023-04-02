#!/bin/bash

function math.gt { # f1, f2
    python3 - <<EOF
if $1 < $2:
    print("no")
EOF
}

function math.percent { # f1, f2
   python3 - <<EOF
per = abs(($1/$2 - 1.0) * 100)
f = '{:.2f}'.format(per)
print(f)
EOF
}