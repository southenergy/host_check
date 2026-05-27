#!/bin/bash

datalogFolder="/home/TCPdatalog/AppData/DataLog/"
plcFolder="/home/plc"

folder=""
if [[ -d $datalogFolder ]]
then
    folder=$datalogFolder
    timeField="PlcDateTime"
    energyField="Energy"
elif [[ -d $plcFolder ]]
then
    folder=$plcFolder
    timeField="Time"
    energyField="EnergyTot"
fi
echo "folder $folder"
cd $folder


#ls $datalogFolder
folderName=$(basename ${folder})
parent=${folder/${folderName}*}
countersFile="${parent}counters.csv"

date 

function getEnergy(){
    local file=$1
    filename=${file/.csv*}
    [[ -f $countersFile ]] || touch $countersFile
    grep -E "^${filename}" $countersFile
    if (($?))
    then       
        if echo $file | grep -E "\.gz$"
        then
            echo "file is gz"
            gunzip $file
            rc=$?
            echo "rc:"$rc
            if [[ $rc -eq 0 ]]
            then
                echo "file unzipped"
                csvFile=${file/.gz/}
                if echo $csvFile | grep -E "\.csv$" && [[ -f $csvFile ]]
                then
                    echo "csv file found: $csvFile"
                    idx=$(cat $csvFile | head -n 1 | awk 'BEGIN{FS=";"}{split($0,headers,";") ; for (h in headers)  {if(headers[h] == "'$timeField'") t=h ; else if (headers[h] == "'$energyField'") e=h} ; print t","e}')
                    counter=$(cat $csvFile | head -n 2 | cut -d ";" -f $idx) 
                    fileStat=$(stat -c "%n %s" $csvFile)
                    echo $fileStat";"$counter | tr ',' '.' | tr ' ' ';' | tee -a $countersFile
                    gzip $csvFile
                fi
            else
                echo "error unzipping file"
            fi
        elif echo $file | grep -E "\.csv$"
        then
            echo "file is csv"
            idx=$(cat $file | head -n 1 | awk 'BEGIN{FS=";"}{split($0,headers,";") ; for (h in headers)  {if(headers[h] == "'$timeField'") t=h ; else if (headers[h] == "'$energyField'") e=h} ; print t","e}')
            if echo $idx | grep -qE '^[0-9]+,[0-9]+$'
            then
                counter=$(cat $file | head -n 2 | cut -d ";" -f $idx)
                fileStat=$(stat -c "%n %s" $file)
                echo $fileStat";"$counter | tr ',' '.' | tr ' ' ';' | tee -a $countersFile
                gzip $file
            else
                echo "WRONG idx:$idx"
            fi
        else
            echo "OTHER FILE: $file"
            #COMPRESS IT???
        fi
    else
        echo "$file ALREADY PROCESSED"
    fi

}

#day="2026-01-01"
if [[ $1 ]]
then
    echo "date from input: $1"
    day=$1
    files=($(ls -t $folder | grep $day))
else
    echo "scanning files"
    files=($(ls -t $folder | grep ".csv"))
fi

filesCount=${#files[@]}

if (($filesCount))
then
    #echo ${files[@]}
    echo "found ${filesCount} files"
    gzfiles=($(echo ${files[@]} | grep -E '.gz$'))
    echo "found ${#gzfiles[@]} gz files"
    csvfiles=($(echo ${files[@]} | grep -E '.csv$'))
    echo "found ${#csvfiles[@]} csv files"

    lastFile=${files[0]}
    firstFile=${files[$((filesCount-1))]}
    echo "firstFile: ${firstFile}"
    echo "lastFile: ${lastFile}"
    firstDate=$(echo $firstFile | sed "s|.*_\([0-9-]*\)_.*|\1|g")
    lastDate=$(echo $lastDate | sed "s|.*_\([0-9-]*\)_.*|\1|g")
    echo "first date: $firstDate"
    echo "last date: $lastDate"

    echo $firstDate | grep -E "[0-9]+-[0-9]+-[0-9]+"
    if (($?))
    then
        echo "date NOT VALID: '${firstDate}'"
    else
        d=$firstDate
        # for i in {1..10}
        # do
        #     echo $d
        #     sleep 1
        #     d=$(date -d "$d next day" +%Y-%m-%d)
        # done
        
        today=$(date  +%Y-%m-%d)
        while [[ ! $d == $today ]] ; 
        do 
            echo $d ; 
            f=($(printf "%s\n" ${files[@]} | grep -E "$d"))
            n=${#f[@]}
            
            if [[ $n -eq 0 ]]
            then
                echo "NO FILES FOUND"
            else
                echo "$n files"
                file=${f[$((n-1))]}
                echo "PROCESSING $file"
                getEnergy $file
            fi
            #sleep 1 ; 
            d=$(date -d "$d next day" +%Y-%m-%d) ; 
        done
        echo "DONE" 
    fi
else
    echo "ERROR: NO FILES"
fi








# file1=${files1[$((${#files1[@]}-1))]}
# echo $file1
# echo $file1 | grep -E "\.gz$"
# echo $?
# csv1=$(gunzip $file1)
# echo $csv1

# files1=($(ls -t | grep 2026-01-01))
# echo ${files1[$((${#files1[@]}-1))]}
# csv1=${files1[$((${#files1[@]}-1))]}
# idx=$(cat $csv1 | head -n 1 | awk 'BEGIN{FS=";"}{split($0,headers,";") ; for (h in headers)  {if(headers[h] == "PlcDateTime") t=h ; else if (headers[h] == "Energy") e=h} ; print t","e}')
# cat $csv1 | head -n 2 | cut -d ";" -f $idx