#!/bin/bash

startArray=()
if (($#))
then
        for start in $@
        do
                startArray[${#startArray[@]}]=$start
        done
else
        startArray=("2026-01-01")
fi
#start="2025-01-01"
#end="2025-02-01"
#end=$(echo $start | awk 'BEGIN{FS="-"}{ if($2==12) {y=$1+1;m="01";d=$3}  else  {y=$1;m=sprintf("%02d",$2+1);d=$3} ; print y"-"m"-"d }')

for start in ${startArray[@]}
do
        end=$(echo $start | awk 'BEGIN{FS="-"}{ if($2==12) {y=$1+1;m="01";d=$3}  else  {y=$1;m=sprintf("%02d",$2+1);d=$3} ; print y"-"m"-"d }')

        echo "from $start  to $end"

        ip="localhost"
        #ip=192.168.30.50

        dbsRes=$(curl -Gs 'http://'$ip':8086/query?' --data-urlencode 'q=SHOW DATABASES')
        dbs=($(echo $dbsRes | jq -r '.results[] | .series[]? | .values[] | .[]' ))
        echo "db: ${dbs[@]}"
        for db in ${dbs[@]}
        do
                echo "$db retention policies:"
                rpsRes=$(curl -Gs 'http://'$ip':8086/query?db='$db --data-urlencode 'q=SHOW RETENTION POLICIES')
                rps=($(echo $rpsRes | jq -rc '.results[] | .series[]? | .values[] '))
                printf "%s\n" "${rps[@]}"
        done

        echo "DB plc_datalog"
        rpsRes=$(curl -Gs 'http://'$ip':8086/query?db=plc_datalog' --data-urlencode 'q=SHOW RETENTION POLICIES')
        rps=($(echo $rpsRes | jq '.results[] | .series[]? | .values[] | .[0]'))
        echo "retention policies: ${rps[@]}"
        #printf "%s\n" $(echo $rpsRes | jq -rc '.results[] | .series[]? | .values[]')


        measurementsRes=$(curl -Gs 'http://'$ip':8086/query?db=plc_datalog' --data-urlencode 'q=SHOW MEASUREMENTS')
        measurements=($( echo $measurementsRes | jq '.results[] | .series[]? | .values[]'))
        echo "measurements: ${measurements[@]}"

        plcDataMeas=($(echo ${measurements[@]} | jq '.[] | select(contains("plcData"))'))


        for measurement in ${plcDataMeas[@]};
        do
                for rp in ${rps[@]};
                do
                        rpMeas=""${rp}.${measurement}"";
                        echo $rpMeas;
                        #queryRes=$(curl -s -G ""http://$ip:8086/query?db=plc_datalog"" --data-urlencode ""q=SELECT \""Energy\"" FROM ${rpMeas} WHERE time >= '""${start}""' AND time < '""${end}""' ORDER BY time ASC LIMIT 1"");
                        queryData="q=SELECT \"Energy\" FROM ${rpMeas} WHERE time >= '"${start}"' AND time < '"${end}"' ORDER BY time ASC LIMIT 1"
                        echo $queryData
                        queryRes=$(curl -s -G ""http://$ip:8086/query?db=plc_datalog"" --data-urlencode "$queryData")
                        echo $queryRes
                        echo "$start $end OLDEST"
                        res=($(echo $queryRes  | jq -rc '.results[] | .series[]? | .values[]'));
                        echo ${res[@]}
                        echo ${res[@]} | jq 
                        echo $?
                        ((${#res})) && echo "${res[@]}" | jq -rc || echo "NO DATA"

                        #queryRes=$(curl -s -G ""http://$ip:8086/query?db=plc_datalog"" --data-urlencode ""q=SELECT \""Energy\"" FROM ${rpMeas} WHERE time >= '""${start}""' AND time < '""${end}""' ORDER BY time DESC LIMIT 1"");
                        queryData="q=SELECT \"Energy\" FROM ${rpMeas} WHERE time >= '"${start}"' AND time < '"${end}"' ORDER BY time DESC LIMIT 1"
                        queryRes=$(curl -s -G ""http://$ip:8086/query?db=plc_datalog"" --data-urlencode "$queryData")
                        echo "$start $end NEWEST"
                        res=($(echo $queryRes  | jq '.results[] | .series[]? | .values[]'));
                        ((${#res})) && echo ${res[@]} | jq -rc || echo "NO DATA"


                        queryData="q=SELECT first(\"Energy\") FROM ${rpMeas}"
                        queryRes=$(curl -s -G ""http://$ip:8086/query?db=plc_datalog"" --data-urlencode "$queryData")
                        echo "FIRST"
                        res=($(echo $queryRes  | jq '.results[] | .series[]? | .values[]'));
                        ((${#res})) && echo ${res[@]} | jq -rc || echo "NO DATA"


                        queryData="q=SELECT last(\"Energy\") FROM ${rpMeas}"
                        queryRes=$(curl -s -G ""http://$ip:8086/query?db=plc_datalog"" --data-urlencode "$queryData")
                        echo "LAST"
                        res=($(echo $queryRes  | jq '.results[] | .series[]? | .values[]'));
                        ((${#res})) && echo ${res[@]} | jq -rc || echo "NO DATA"


                        queryData="q=SELECT count(\"Energy\") FROM ${rpMeas} group by time(1w)"
                        queryRes=$(curl -s -G ""http://$ip:8086/query?db=plc_datalog"" --data-urlencode "$queryData")
                        echo "COUNT"
                        res=($(echo $queryRes  | jq -rc '.results[] | .series[]? | .values[]'));
                        ((${#res})) && echo ${res[@]} | jq -rc || echo "NO DATA"


                done;
        done
done
