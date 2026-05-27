#/bin/bash

###Scan Folders

echo "###Scan Folders"
l=0;
level=3;
f(){  
    for elem in $@;  
    do   
        if [[ -d $elem ]] ;    
        then      
            du -sh $elem ;      
            local subfolders=() ;      
            nodeList=($(ls $elem)) ;      
            declare -A files ;      
            for node in ${nodeList[@]} ;      
            do        
                path=$elem"/"$node ;        
                if [[ -d $path ]] ;        
                then           
                    subfolders=(${subfolders[@]} $path)  ;        
                else          
                    type=${node//*.} ;          
                    ((files[$type]++)) ;       
                fi;      
            done;      
            if ((${#files[@]}));     
            then       
                printf "%s\t" "FILES:" ;        
                for t in ${!files[@]} ;        
                do          
                    printf "%s\t" "."$t" "${files[$t]} ;        
                done;       
                printf "\n";     
            else       
                printf "%s\n" "NO FILES";     
            fi;     
            files=() ;       
            ((l++));     
            [[ $l -le $level ]] && ((${#subfolders})) && echo "SUBFOLDERS $l: "${subfolders[@]} && f ${subfolders[@]};      
            ((l--));   
        else     
            printf "%s\t" "FILE" ;      
            du -sh $elem ;   
        fi ;  
    done;  
}

cd /root ; f /home /root /mnt | tee $HOSTNAME"_folders_scan_"$(date +%F_%T)".txt"

###Check Space
# pcent=$(df -h --output=pcent /home/)
# echo "/home usage:$pcent"
# usage=echo ${pcent[1]/\%/}
# echo "/home usage:$pcent"

###BACKUP dir in root

# if [[ -d /root/BACKUP ]]
# mkdir -p /root/BACKUP

###Compress csv in Datalog folder


function compressFiles(){
    local folder=$1
    local extension=${2-.csv}

    echo serchinng $extension files
    du -sh $folder ; 
    local files=($(ls $folder | grep -v ".gz" | grep -v $(date +%y-%m-%d) | grep $extension$ )) ; 
    for file in ${files[@]} ; 
    do 
        echo $file ; 
        gzip -f $folder"/"$file ; 
    done ; 
    du -sh $folder
}

echo "Compress DataLog csv"
datalogFolder=""

if [[ -d /home/TCPdatalog/AppData/DataLog ]]
then
    datalogFolder="/home/TCPdatalog/AppData/DataLog" ;

elif [[ -d /home/plc ]]
then
    datalogFolder="/home/plc" ;
fi

[[ -d $datalogFolder ]] && compressFiles $datalogFolder ".csv" || echo "datalogFolder NOT A DIRECTORY : $datalogFolder"


echo "Compress ERRORS"
errorsFolder=/home/TCPdatalog/AppData/ERRORS
[[ -d $errorsFolder ]] && compressFiles $errorsFolder ".log" && compressFiles $errorsFolder ".mailFile" || echo "errorsFolder NOT A DIRECTORY : $errorsFolder"

echo "Compress IMPORT"
importFolder=/home/TCPdatalog/AppData/Import
[[ -d $importFolder ]] && compressFiles $importFolder ".import" || echo "importFolder NOT A DIRECTORY : $importFolder"


echo "###Drive Upload"
serviceIdentity="rclone-service-identity-1ac8f925e71f.json"

echo "Uploading datalogFolder gz files to Drive"
folder=$datalogFolder
# docker run --rm --entrypoint rclone --name rclone -v $folder:/mnt$folder \
# -v /root/rclone/${serviceId}:/root/.rclone/${serviceId}:ro kitanonet/tcpdatalog:rclone \
# -v --progress move /mnt$folder gdrive:/$HOSTNAME$folder --include "*.gz"

docker run --rm --entrypoint rclone --name rclone \
-v $folder:/mnt$folder \
-v /root/rclone/${serviceIdentity}:/root/.rclone/${serviceIdentity}:ro \
-v rclone-config:/config/rclone \
kitanonet/tcpdatalog:rclone -v --progress \
move /mnt$folder gdrive:/$HOSTNAME$folder --include "*.gz"

echo "Uploading ERRORS files to Drive"
folder=$errorsFolder
docker run --rm --entrypoint rclone --name rclone \
-v $folder:/mnt$folder \
-v /root/rclone/${serviceIdentity}:/root/.rclone/${serviceIdentity}:ro \
-v rclone-config:/config/rclone \
kitanonet/tcpdatalog:rclone -v --progress \
move /mnt$folder gdrive:/$HOSTNAME$folder --include  "*.gz"

echo "Uploading IMPORT files to Drive"
folder=$importFolder
docker run --rm --entrypoint rclone --name rclone \
-v $folder:/mnt$folder \
-v /root/rclone/${serviceIdentity}:/root/.rclone/${serviceIdentity}:ro \
-v rclone-config:/config/rclone \
kitanonet/tcpdatalog:rclone -v --progress \
move /mnt$folder gdrive:/$HOSTNAME$folder --include "*.gz"

echo "Uploading root log and txt files to Drive"
folder=/root
docker run --rm --entrypoint rclone --name rclone \
-v $folder:/mnt$folder \
-v /root/rclone/${serviceIdentity}:/root/.rclone/${serviceIdentity}:ro \
-v rclone-config:/config/rclone \
kitanonet/tcpdatalog:rclone -v --progress \
move /mnt$folder gdrive:/$HOSTNAME$folder --include "*.txt" --include "*.log"

echo "Uploading root backup folder to Drive"
folder=""
if [[ -d  /root/backup ]]
then
    folder=/root/backup
elif [[ -d  /root/BACKUP ]]
then
    folder=/root/BACKUP
fi
[[ -d $folder ]] && docker run --rm --entrypoint rclone --name rclone \
-v $folder:/mnt$folder \
-v /root/rclone/${serviceIdentity}:/root/.rclone/${serviceIdentity}:ro \
-v rclone-config:/config/rclone \
kitanonet/tcpdatalog:rclone -v --progress \
move /mnt$folder gdrive:/$HOSTNAME$folder