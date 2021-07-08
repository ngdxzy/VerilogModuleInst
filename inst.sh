#!/bin/bash

MODULE_NAME=$(cat $1 | grep module | sed -n '1p' | sed 's/module//' | tr -cd '0-9a-zA-Z_')
PARAMETERS=(`cat $1 | grep parameter | sed -e 's/parameter//' -e 's/=.*$//'`)
PORTS=(`cat $1 | grep -E 'input|output' | sed -e 's/^[ ]*$//g' -e 's/input//g' -e 's/output.*reg//g' -e 's/output//g' -e 's/\[.*\]//g' | tr ',' ' '`)

cat $1 | grep parameter | sed -e 's/,//' -e 's/;//' | sed 's/^.*$/&;/'
cat $1 | grep input | sed 's/input/wire/g' | sed 's/,//g' | sed 's/^.*$/&;/g'
cat $1 | grep output | sed 's/output.*reg/wire/g' | sed 's/output/wire/g' | sed 's/,//g' | sed 's/^.*$/&;/g'


M=${#PARAMETERS[*]}
if [ M == 0 ]
then
    echo "    ${MODULE_NAME} ${MODULE_NAME}_inst("
else
    echo "    ${MODULE_NAME} #("
    echo "        .${PARAMETERS[0]}(${PARAMETERS[0]})"
    i=1
    while(( $i < $M ))
    do
        echo "        ,.${PARAMETERS[$i]}(${PARAMETERS[$i]})"
        let "i++"
    done
    echo "    )${MODULE_NAME}_inst("
fi

N=${#PORTS[*]}
i=1
echo "        .${PORTS[0]}(${PORTS[0]})"
while(( $i < $N ))
do
    echo "        ,.${PORTS[$i]}(${PORTS[$i]})"
    let "i++"
done
echo "    );"

