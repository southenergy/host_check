#!/bin/bash
ip=$1
hostName=$2
#ip=192.168.30.50
script=checkDataAndMove.sh
serviceIdentity=/home/kitano/rclone/rclone-service-identity-1ac8f925e71f.json

declare -A drives
while read line
do
    arr=($(echo $line))
    host=${arr[0]}
    folder=${arr[1]}
    id=${arr[2]}
    drives[$host]="$folder $id"

done <<"drives"
SN2	edge_SN2	0AEFBzkXMJgBBUk9PVA
PTRC	edge_PTRC	0ACDwtX90MRGfUk9PVA
STRN	edge_STRN	0ALzObHSpy06PUk9PVA
SN3	edge_SN3	0AM99M0Fq-9aKUk9PVA
SN4	edge_SN4	0AKgPe82GEi2GUk9PVA
ZINGAD	edge_ZINGAD	0AFh05qCQEcodUk9PVA
BOVINO	edge_BOVINO	0ABN_ssiC6UzTUk9PVA
MINICHILLO	edge_MINICHILLO	0AEuO-9Hz92G0Uk9PVA
ZINGAG	edge_ZINGAG	0ADPjyIg5cVVKUk9PVA
ALDO2	edge_ALDO2	0ADcHd_bs_yeaUk9PVA
RITOLI	edge_RITOLI	0AK4tpbo_2hfWUk9PVA
ALDO3	edge_ALDO3	0APIwrE6CbsW9Uk9PVA
BICCARI	edge_BICCARI	0AH3CokSWYANlUk9PVA
FALCONE	edge_FALCONE	0AAZiFjZNtqewUk9PVA
ETAPOWER	edge_ETAPOWER	0AJ29uWJNkzvQUk9PVA
VALENTE	edge_VALENTE	0APCRdZV0X_PtUk9PVA
FARES1	edge_FARES1	0AGINGmjnMMQlUk9PVA
IAPOZZUTO	edge_IAPOZZUTO	0AIh-7x8yZa3sUk9PVA
FALCONE2	edge_FALCONE2	0AHMgG3ks6Qp5Uk9PVA
SERRATRAVERSA	edge_SERRATRAVERSA	0AG8V1Wmgu6xUUk9PVA
FANELLI	edge_FANELLI	0AOpGRm1PFmo1Uk9PVA
CANDELA	edge_CANDELA	0AIfcRy1yi877Uk9PVA
LAURIOLA	edge_LAURIOLA	0AFpeMuX2FMWvUk9PVA
TREQUERCE	edge_TREQUERCE	0AF5yMkpxFoAtUk9PVA
ASCOLI	edge_ASCOLI	0ALM6U2KFrNysUk9PVA
MONTARATRO	edge_MONTARATRO	0ACT2SachR4NJUk9PVA
BICCARI2	edge_BICCARI2	0ANk3DmraHCoBUk9PVA
SCRIMA	edge_SCRIMA	0AE6EtnOiZH67Uk9PVA
LOBUONO	edge_LOBUONO	0AIZcB0hhoJ1ZUk9PVA
FANELLI2	edge_FANELLI2	0AN_IPfD5-u43Uk9PVA
CASTELLUCCIO2	edge_CASTELLUCCIO2	0ALynQfQDfMvEUk9PVA
BOVINO2	edge_BOVINO2	0AB2S6c3Sj_e2Uk9PVA
SAURI	edge_SAURI	0AIcezvJs9VM6Uk9PVA
CELOZZI2	edge_CELOZZI2	0AGue-wDqVwfVUk9PVA
DADDARIO1	edge_DADDARIO1	0AMkUw5g2DPy-Uk9PVA
DADDARIO2	edge_DADDARIO2	0AMy8AkDdFDYjUk9PVA
MONTARATRO2	edge_MONTARATRO2	0ADX9TCDSZESgUk9PVA
CANDELA2	edge_CANDELA2	0ANK_4clr-sfHUk9PVA
MONTARATRO4	edge_MONTARATRO4	0APulQJRuiK-oUk9PVA
CRETA	edge_CRETA	0ACX6jVhZZcehUk9PVA
SCROCCO	edge_SCROCCO	0AAbuL688f4BtUk9PVA
TERRANOVA	edge_TERRANOVA	0AG0SBQnUF1KxUk9PVA
JONICA	edge_JONICA	0AAXh0kV3EJrFUk9PVA
MEDI1	edge_MEDI1	0AABr-jYz9vVjUk9PVA
LACEDONIA	edge_LACEDONIA	0AE90V11e6FY8Uk9PVA
GARWIND	edge_GARWIND	0AMDdBUYAmreQUk9PVA
DELICETO	edge_DELICETO	0AI-ZIGVbP9ErUk9PVA
BICCARI3	edge_BICCARI3	0AL9wqgfrs7FOUk9PVA
RUOCCOTROIA	edge_RUOCCOTROIA	0AM58uqtDwjPnUk9PVA
RUOCCOLUCERA	edge_RUOCCOLUCERA	0ANTTXjptwds7Uk9PVA
SOLOUNO	edge_SOLOUNO	0ANBxjDhgFakCUk9PVA
ORSARA	edge_ORSARA	0AOcs5BofYJcYUk9PVA
PIA	edge_PIA	0ACNSt0hlRGhVUk9PVA
ARCOSTUDIO	edge_ARCOSTUDIO	0AKKpqsHpIobpUk9PVA
MATERA1	edge_MATERA1	0ABZVnfhGt0UlUk9PVA
MATERA2	edge_MATERA2	0APFhd4kHA92HUk9PVA
POMARICO	edge_POMARICO	0ALoRmKQ9WGf6Uk9PVA
FERRANDINA1	edge_FERRANDINA1	0AGwGsXWHuRSuUk9PVA
FERRANDINA2	edge_FERRANDINA2	0AOqWqDBpk2egUk9PVA
drives


drive=(${drives[$hostName]})
driveName=${drive[0]}
driveId=${drive[1]}
echo "###${hostName} GET DRIVE Info : "
echo "###${hostName}: ${driveName} ; ${driveId}"

if ((${#drive}))
then
    echo "###${hostName} UPDATE Drive ID : ${driveId}"
    echo "docker run --rm --entrypoint rclone --name rclone -v rclone-config:/config/rclone kitanonet/tcpdatalog:rclone config update gdrive team_drive=${driveId}" \
    | ssh -o ConnectTimeout=10 -qT root@$ip
    updateRC=$?
    echo "###${hostName} UPDATE Drive ID rc: $updateRC"

    # echo "MOVE compressed csv"
    # folder=/home/TCPdatalog/AppData/DataLog/ ; 

    # cmd='docker run --rm --entrypoint rclone --name rclone \
    # -v '$folder':'$folder' -v /root/rclone/rclone-service-identity-1ac8f925e71f.json:/root/.rclone/rclone-service-identity-1ac8f925e71f.json:ro kitanonet/tcpdatalog:rclone \
    # -v --progress move $folder gdrive:/'$HOSTNAME$folder' --include "*.gz"'

    # testcmd='docker run --rm \
    # -v '$folder':'$folder' -v /root/rclone/rclone-service-identity-1ac8f925e71f.json:/root/.rclone/rclone-service-identity-1ac8f925e71f.json:ro alpine \
    # echo '$HOSTNAME$folder

    # ssh root@192.168.30.50 screen -ls
    # rc=$?
    # ((rc)) && echo "creating screen session" && ssh root@192.168.30.50 screen -dmS test
    # ssh root@192.168.30.50 screen -dr test -X exec "$testcmd"

    # ssh root@192.168.30.50 screen -dr test -X exec "$testcmd"

    # declare -a sessions

    # fifo=/tmp/fifo
    # [[ -p $fifo ]] || mkfifo $fifo 

    # ssh -o ConnectTimeout=10 -qT  root@$ip  screen -ls $session | grep tached > $fifo &

    # while read line 
    # do
    #         echo $line
    #         sessions[${#sessions[@]}]="$line"

    # done < $fifo 

    # echo ${sessions[@]}

    # if [[ ${#sessions[@]} -eq 0 ]]
    # then
    #     ssh -o ConnectTimeout=10 -qT  root@$ip  screen -dmS test
    #     ssh -o ConnectTimeout=10 -qT  root@$ip  screen -ls $session | grep tached
    # else
    #     echo "SESSION EXISTS"
    # fi

    echo "###${hostName} UPLOAD ${script}"
    scp -o ConnectTimeout=10 -qT  ./${script} root@$ip:/root
    rc1=$?
    echo "###${hostName} UPLOAD rclone service identity"
    echo '[[ -d /root/rclone  ]] && echo "dir exists" || mkdir /root/rclone' | ssh -o ConnectTimeout=10 -qT root@$ip
    scp -o ConnectTimeout=10 -qT  $serviceIdentity root@$ip:/root/rclone/
    rc2=$?

    if [[ $rc1 -eq 0 ]] && [[ $rc2 -eq 0 ]] 
    then
        echo "###${hostName} LAUNCHING REMOTE SCREEN SESSION DAEMON"
        #ssh -o ConnectTimeout=10 -qT  root@$ip screen "-dr test -X exec bash /root/${script}"

        ###ssh -n closes stdin otherwise ssh reads parent while loop stdin and while loop exits
        ssh -o ConnectTimeout=10 -n -qT  root@$ip screen -L -dmS 'script.$HOSTNAME' 'bash /root/checkDataAndMove.sh'

        echo 'while true ; do  screen -ls ; rc=$? ; \
        printf "%s script " $HOSTNAME; if (($rc)) ; \
        then printf " TERMINATED " ; df -h ; break ; \
        else  printf " RUNNING " ; date "+%F %T" ; sleep 60 ; fi ; done' | ssh -o ConnectTimeout=10 -qT  root@$ip bash

        echo "###${hostName} COMPLETED checkDataAndMove "
    else
        echo "###${hostName} ERROR UPLOADING FILES"
    fi
else
    echo "ERROR: hostName ${hostName} NOT FOUND IN DRIVE LIST"
fi