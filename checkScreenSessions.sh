#!/bin/bash


declare -A drives
while read line
do
    arr=($(echo $line))
    hostName=${arr[0]}
    folder=${arr[1]}
    id=${arr[2]}
    drives[$hostName]="$folder $id"

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

# for hostDrive in ${!drives[@]}
# do
#     echo $hostDrive
# done


declare -A hosts
while read line
do
    declare -a host
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

        [[ $fields == $field ]] && echo ${host[@]} && break
        fields=${fields#*,}
        #echo $f $fields
        ((f++))
    done
    ((i++))
    siteName=${host[1]}
    hostName=${host[2]}
    plcIp=ip=${host[4]}
    ip=${host[5]}
    routerIp=${host[6]}

    echo "${hostName} ${ip}"

    (echo 'while screen -ls ; do rc=$? ;  \
    echo $rc ; echo "script '${hostName}' RUNNING" ; sleep 10 ;\
    done ; echo "script '${hostName}' TERMINATED"' | ssh -o ConnectTimeout=10 -qT  root@$ip bash)&

done <host_list.csv


