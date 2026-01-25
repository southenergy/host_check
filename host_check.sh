#!/bin/bash

listFile="host_list.csv"
ts=$(TZ=Europe/Rome date "+%F_%T" | sed 's|[:]|-|g')
#logFile="$0_$ts.txt"

#echo ${0/\.sh/}
scriptName=$(basename ${0/\.sh/})
scriptFolder=${0%\/$scriptName*}
echo $scriptName
echo $scriptFolder
logFolder="${scriptFolder}/Scriptlogs"
logFile="${logFolder}/${scriptName}_$ts.log"
echo $logFile

#start="2025-12-01"
#end="2026-01-01"

function getStartEnd(){

    local curY=$(date +%Y)
    local curM=$(date +%m)
    local curD=$(date +%d)

    local Y=$curY
    local M=$(echo $curM | sed 's|^[0]*||')
    local D=$(echo $curD | sed 's|^[0]*||')

    if [[ $D -eq 1 ]]
    then
        if [[ $M -eq 1 ]]
        then
            local start="$((Y-1))-12-01"
        else
            local prevM=$(printf "%02d" $((M-1)))
            local start="${curY}-${prevM}-01"
        fi
    else
        local start="${curY}-${curM}-01"
    fi

    echo "$start ${curY}-${curM}-${curD}"
}

start=$1
end=$2

if (echo $start | grep -E "^[0-9]+-[0-9]+-[0-9]+$") && (echo $end | grep -E "^[0-9]+-[0-9]+-[0-9]+$")
then
    echo "Period from input"
else
    echo "Period calculated"
    startend=$(getStartEnd)
    start=${startend// */}
    end=${startend//* /}
fi

startEpoch=$(date -d $start +%s)
endEpoch=$(date -d $end +%s)

periodOK=0
if [[ $endEpoch -gt $startEpoch ]]
then
    echo "Period OK"
    periodOK=1
else
    echo "Period NOT OK"
fi

energyFolder="${scriptFolder}/Energy_csv"
energyFile="${energyFolder}/Energy_${start}_${end}_${ts}.csv"
echo $energyFile
exit
#echo "NAME,measurement,TIMESTAMP,start,end,TOTAL" > $energyFile
echo "NAME,Time First,First Counter,Time Last,Last Counter,Timestamp,Energy" > $energyFile

function systemCheck(){
    local ip=$1
    #ssh root@$ip "lsb_release -a" ## THE SCRIPT ENDS AFTER SSH
    #echo "lsb_release -a && df -h 1>&2" | ssh -qT  root@$ip bash 1>/dev/null
    echo "lsb_release -a && df -h" | ssh  -o ConnectTimeout=10 -qT  root@$ip bash
    rc=$?
    echo "rc:$rc"
}

function dockerCheck(){
    local ip=$1
    #ssh root@$ip "lsb_release -a" ## THE SCRIPT ENDS AFTER SSH
    #echo "docker ps 1>&2" | ssh -qT  root@$ip bash 1>/dev/null
    echo "docker ps" | ssh  -o ConnectTimeout=10 -qT  root@$ip bash
    rc=$?
    echo "rc:$rc"
}

function getEnergy(){
    local ip=$1
    local measurement="plcData"

    #q="select first(\"Energy\") , last(\"Energy\") , last(\"Energy\")-first(\"Energy\") as Total from plcData where time > '${start}' and time < '${end}' tz('Europe/Rome')"
    #command="docker exec plc-datalog-influxDB-1 influx -precision rfc3339 -database 'plc_datalog' -format csv -execute \"$q\" 1>&2"

    q1="select first(\"Energy\") from ${measurement} where time > '${start}' and time < '${end}' tz('Europe/Rome')"
    q2="select last(\"Energy\") from ${measurement} where time > '${start}' and time < '${end}' tz('Europe/Rome')"
    q3="select last(\"Energy\")-first(\"Energy\") as Total from ${measurement} where time > '${start}' and time < '${end}' tz('Europe/Rome')"
    #command="docker exec plc-datalog-influxDB-1 influx -precision rfc3339 -database 'plc_datalog' -format csv -execute \"$q1;$q2;$q3\" 1>&2"
    command="docker exec plc-datalog-influxDB-1 influx -precision rfc3339 -database 'plc_datalog' -format csv -execute \"$q1;$q2;$q3\""

    printf "%s" $hostName | tee -a $energyFile
    #echo "$command 1>&2" | ssh -qT  root@$ip  bash 2>/dev/null 3>&2 2>&1 1>&3 3>&- | while read line
    echo "$command" | ssh  -o ConnectTimeout=10 -qT  root@$ip  bash | while read line
    do
        #echo $line
        if [[ $line =~ ^"${measurement}" ]]
        then
            #echo "match "$line
            data="${line#$measurement,}"
            #echo $data
            #energy+=$data
            printf "%s" "${data}" 
        elif [[ $line =~ ^"name" ]]
        then
            printf "%s" ","
        else
            printf "%s" ",ERROR?,$line"
        fi | tee -a $energyFile

    done
    printf "\n" | tee -a  $energyFile

    echo "${PIPESTATUS[@]}"
}



function getEnergyJson(){
    local ip=$1
    local measurement="plcData"

    #q="select first(\"Energy\") , last(\"Energy\") , last(\"Energy\")-first(\"Energy\") as Total from plcData where time > '${start}' and time < '${end}' tz('Europe/Rome')"
    #command="docker exec plc-datalog-influxDB-1 influx -precision rfc3339 -database 'plc_datalog' -format csv -execute \"$q\" 1>&2"

    q1="select first(\"Energy\") from ${measurement} where time > '${start}' and time < '${end}' tz('Europe/Rome')"
    q2="select last(\"Energy\") from ${measurement} where time > '${start}' and time < '${end}' tz('Europe/Rome')"
    q3="select last(\"Energy\")-first(\"Energy\") as Total from ${measurement} where time > '${start}' and time < '${end}' tz('Europe/Rome')"
    #command="docker exec plc-datalog-influxDB-1 influx -precision rfc3339 -database 'plc_datalog' -format csv -execute \"$q1;$q2;$q3\" 1>&2"
    command="docker exec plc-datalog-influxDB-1 influx -precision rfc3339 -database 'plc_datalog' -format json -execute \"$q1;$q2;$q3\""

    printf "%s" $hostName | tee -a $energyFile
    #echo "$command" | ssh -qT  root@$ip  bash | tee -a  $energyFile
    res=$(echo "$command" | ssh  -o ConnectTimeout=10 -qT  root@$ip  bash 2>&1)
    rc=$?
    #echo $rc
    #sheetData=""
    if (($rc))
    then
        error=$(echo $res | tr -d '\n') 
        printf ",$ip,ERROR,%s" "$error" | tee -a $energyFile
        #sheetData='[["'$hostName'","ERROR","'$res'"]]'
        #echo $sheetData
        errorDataArray[${#errorDataArray[@]}]='["'$hostName'","'$ip'","ERROR","'$(printf "%s" "$error")'"]'
    else
        echo $res
        resLengths=($(echo $res | jq '.results[] | length'))
        dataCheck=0
        for r in ${resLengths[@]}
        do
            (($r)) && ((dataCheck+=$r))
        done

        if ((dataCheck))
        then
            jsonDataHeaders=$(echo $res | jq -c '["SITE",.results[]?.series[]?.columns[]?]')
            jsonDataValues=$(echo $res | jq -c '["'$hostName'",.results[]?.series[]?.values[][]?]')
            echo $jsonDataHeaders
            echo $jsonDataValues
            #sheetData=$(echo $res | jq -c '[["'$hostName'",.results[].series[].columns[]],["'$hostName'",.results[].series[].values[][]]]')
            #echo $sheetData

            if [[  "$jsonDataHeaders" == "$rowHeader" ]] 
            then
                echo "SAME Header"
                #sheetData=$jsonDataValues
                
            else
                echo "new Header \"$jsonDataHeaders\" \"$rowHeader\""
                #sheetData=$jsonDataHeaders" "$jsonDataValues 
                [[ $(echo $jsonDataHeaders | jq '. | length ') -gt 1 ]] && sheetDataArray[${#sheetDataArray[@]}]=$jsonDataHeaders
                rowHeader=$jsonDataHeaders
            fi
            sheetDataArray[${#sheetDataArray[@]}]=$jsonDataValues

            series=($(echo $res | jq -rc '.results[].series'))
            for i in ${!series[@]}
            do
                #echo $i
                data=${series[$i]}
                headers=($(echo $data | jq -r '.[].columns[]'))
                values=($(echo $data | jq -r '.[].values[] | .[]'))
                #echo ${values[@]}
                printf ",%s,%s" ${values[@]} | tee -a $energyFile

            done
        else
            echo "NO DATA IN DB FOR SELECTED TIME RANGE"

            q1="select last(\"Energy\") from ${measurement} where time < '${start}' tz('Europe/Rome')"
            q2="select first(\"Energy\") from ${measurement} where time > '${end}' tz('Europe/Rome')"
            
            command="docker exec plc-datalog-influxDB-1 influx -precision rfc3339 -database 'plc_datalog' -format json -execute \"$q1;$q2\""
            res=$(echo "$command" | ssh  -o ConnectTimeout=10 -qT  root@$ip  bash 2>&1)
            echo $res
            nearestData=$(echo $res | jq -c '.results?[].series' | tr -d '"')

            sheetDataArray[${#sheetDataArray[@]}]='["'$hostName'","'$ip'","NO DATA IN RANGE","'$nearestData'"]'

            printf ",$ip,NO DATA" | tee -a $energyFile

        fi

    fi
    #docker exec node-dev node googleapi/index.js "$sheetData"
    
    echo "ERRORS:${#errorDataArray[@]}"
    echo "DATA:${#sheetDataArray[@]}"
    printf "\n" | tee -a $energyFile

}

(

errorDataArray=()
sheetDataArray=()
rowHeader=""

while read line
do
    echo "########################################"
    echo $i $line

    fields=(${line//,/ })
    #echo ${fields[@]}

    fields=$line
    f=1
    while [[ $fields ]] #&& [[ $f -le 6 ]]
    do
        field=${fields%%,*}
        #echo $f $field
        #if [[ $i -eq 1 ]]
        if !((i))
        then
            headers[$f]=$field
            #echo "Header $f : ${headers[$f]}"
        else
            #echo "Field $f ${headers[$f]} : $field"
            host[$f]=$field
        fi

        [[ $fields == $field ]] && break
        fields=${fields#*,}
        ##echo $f $fields
        ((f++))
    done

    ((i++))
    siteName=${host[1]}
    hostName=${host[2]}
    plcIp=ip=${host[4]}
    ip=${host[5]}
    routerIp=${host[6]}

    if [[ "$siteName" != "#" ]]
    then
        echo $ip | grep -q -E "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$"
        rc=$?
        if [[ $rc -eq 0 ]]
        then
            echo "host: $hostName ; IP: $ip"
            ping -c 1 $ip
            if (($?))
            then
                echo "PING FAILED ... CHECKING ROUTER $routerIp" 
                ping -c 1 $routerIp
                if (($?))
                then
                    pingRouter='FAILED'
                else
                    pingRouter='OK'
                fi
                echo "$hostName,$ip,PING EMBEDDED FAILED,$routerIp,PING ROUTER $pingRouter" >> $energyFile
                errorDataArray[${#errorDataArray[@]}]='["'$hostName'","'$ip'","PING EMBEDDED FAILED","'$routerIp'","PING ROUTER '$pingRouter'"]'
                continue
            fi

            #osCheck $ip
            #dockerCheck $ip
            #echo $?
            #printf "$hostName,%s\n" $(getEnergy $ip) | tee -a $energyFile && echo "DONE"   

            echo "#####${HOST} OS CHECK"
            systemCheck $ip 2>&1 | while read line ; do ((s++)) ; echo $line ; done

            echo "#####${HOST} DOCKER CHECK"
            dockerCheck $ip 2>&1 | while read line ; do ((d++)) ; echo $line ; done 

            echo "#####${HOST} ENERGY CHECK"
            #getEnergy $ip 2>&1 | while read line
            #do ((e++))
            #    #echo $host","$line
            #    echo $line
            #done | tee -a $energyFile && echo "#####DONE" 
            (($periodOK)) && getEnergyJson $ip
            echo "#####DONE"
        fi
    else
        echo "$hostName REMOVED"
    fi

done < $listFile #| tee -a $logFile #### WITH PIPE sheetDataArray NOT VISIBLE OUTSIDE

#echo "[${sheetDataArray[@]}]" | sed 's|\] \[|\],\[|g'  | tr -d '\n'
jsonData=$(echo "[${sheetDataArray[@]} [\"\"] [\"ERRORS:\"] ${errorDataArray[@]}]" | sed 's|\] \[|\],\[|g' | tr -d '\n' | jq -c)

docker exec node-dev node googleapi/sheet.js "Energy_${start}_${end}_${ts}" "$jsonData"

for i in ${!sheetDataArray[@]}
do
    #printf "%s\t" $i
    echo ${sheetDataArray[$i]}
done
echo -e "\nERRORS:"
for i in ${!errorDataArray[@]}
do
    #printf "%s\t" $i
    echo ${errorDataArray[$i]}
done

)| tee -a $logFile
