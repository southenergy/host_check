#!/bin/bash

curY=$1
curM=$2
curD=$3

Y=$(echo $curY | sed 's|^[0]*||')
M=$(echo $curM | sed 's|^[0]*||')
D=$(echo $curD | sed 's|^[0]*||')

#echo $curY $curM $curD


# case $curM in
#     "01")
#         start="$((curY-1))-12-01"
#     ;;
#     *)
#         start="$curY-$((curM-1))-01"
#     ;;
# esac


if [[ $D -eq 1 ]]
then
    if [[ $M -eq 1 ]]
    then
        start="$((Y-1))-12-01"
    else
        prevM=$(printf "%02d" $((M-1)))
        start="${curY}-${prevM}-01"
    fi
else
    start="${curY}-${curM}-01"
fi

echo -e "$start ${1}-${2}-${3}\n"