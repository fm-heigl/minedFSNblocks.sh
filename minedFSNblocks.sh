#!/bin/bash


NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
GRAY='\033[1;30m'


echo -e "\n\n-------------------------------------------------------------------------------"
echo -e "> > > > > > > > > > > > > > >    ${GREEN}W E L C O M E !${NC}    < < < < < < < < < < < < < <"
echo -e "> ${GRAY}this script allows you to export stats about mined FSN blocks to a CSV file${NC} <"
echo -e "-------------------------------------------------------------------------------"
read -p "please enter your staking address (0x...): " address
echo -e "-------------------------------------------------------------------------------"
echo -e "\ngetting total number of mined blocks from api.fsnscan.com..."

totalBlocksMined=$(curl -s 'https://api.fsnscan.com/blocks?m='$address'&ps=1' | jq -r '.total')

echo -e "\nTotal number of blocks mined by $address: $totalBlocksMined"

pages=0
i=$totalBlocksMined
while [[ $i > 100 ]] ; do
    (( i -= 100 ))
    (( pages += 1 ))
done

echo -e "data from api.fsnscan.com contains $pages pages (1 page = 100 transactions)"

echo -e "-------------------------------------------------------------------------------"
echo -e "\n> > >  please bear in mind that exporting many pages may take some time!  < < <"
echo -e "if you are mining a block while this process is running, output might not be correct!\n"
read -p "enter the anount of pages you want to export: (1-$pages) " pagesAmount

echo -e "starting...\n"

csv="block_height,block_time_utc,tx_count,block_gas_used,block_gas_limit,reward\n"

for (( n=1; n<=$pagesAmount; n++ ))
do
    echo -e "-------------------------------------------------------------------------------"
    echo -ne "processing page $n of $pagesAmount... getting data from api.fsnscan.com...\n"
    JSON=$(curl -s 'https://api.fsnscan.com/blocks?m='$address'&ps=100&p='$n)
    for (( row=0; row<=99; row++ ))
    do
        if [[ "$(echo $JSON | jq -r '.list['$row'].block_height')" == "null" ]]
        then
            echo -ne ""
        else
            csv+=$(echo $JSON | jq -r '.list['$row'].block_height')','
            csv+=$(echo $JSON | jq -r '.list['$row'].block_time_utc')','
            csv+=$(echo $JSON | jq -r '.list['$row'].tx_count')','
            csv+=$(echo $JSON | jq -r '.list['$row'].block_gas_used')','
            csv+=$(echo $JSON | jq -r '.list['$row'].block_gas_limit')','
            csv+=$(echo $JSON | jq -r '.list['$row'].reward')'\n'
        fi
        echo -ne "$row%\r"
    done
    echo -ne "page $n of $pagesAmount done!\n"
done
echo -e "-------------------------------------------------------------------------------"

filename=$address'_'$(date +"%Y%m%d%H%M")'.csv'

echo -e $csv > $filename
echo -e "> > >  file output: ${BLUE}$filename${NC}"
echo -e "> > > > > > > > > > > >   ${GREEN}all done - have a nice day!${NC}   < < < < < < < < < < < <"
echo -e "-------------------------------------------------------------------------------\n\n"
