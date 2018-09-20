#!/bin/bash
HA_PATH=/tmp/ha-vm
HA_LOG=/var/log/ha-vm
PROCESS=/tmp/ha-vm/running.process
HA_SSH_SHUTDOWN=/etc/ha-vm/zone/available

red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

exec > >(tee ${HA_LOG}/trace.log) 2>&1
exec 2> >(tee ${HA_LOG}/error.log)

mkdir -p $HA_LOG
mkdir -p $HA_PATH

HA_LOG_script()
{
    echo "[${USER}][`date`] - ${*}" >> ${HA_LOG}/scripts.log
}

if [ -f ${PROCESS} ]; then
    message="Prerious process ha is still running, skip this process!"
    echo $message
    HA_LOG_script $message
    exit 1
fi
touch ${PROCESS}

# List compute down
LIST_COM_DOWN=`openstack compute service list --service nova-compute | awk '{print $6,$12}' | grep down | awk '{ print $1 }' `

if [ -z "$LIST_COM_DOWN" ]
then
    # If no service compute down, skip evacuate
    echo "[${green} Notification ${reset}] State computes OK!"
    message="State computes OK!"
    echo $message
    HA_LOG_script $message
    rm -rf ${PROCESS}
    exit 0
else
    # If yes, check evacuate
    message="[${red} Notification ${reset}] Something wrong, evacuate Compute node"
    echo $message
    HA_LOG_script $message
fi

message="[${red} Notification ${reset}] Process compute down $LIST_COM_DOWN"
echo $message
HA_LOG_script $message

# Check evacuate Compute
for com in $LIST_COM_DOWN
do   
    LIST_VM=`openstack server list --host $com | awk '{print $6,$12}' | sed '/^\s*$/d' | wc -l`

    if [ $LIST_VM -eq 0 ]
    then
        # If compute has no VM, skip evacuate
        message="$com has no VM to evacuate."
        echo $message
        HA_LOG_script $message
    else
        message="Evacuate $com"
        echo $message
        HA_LOG_script $message
        
        # check node script and run               
        if [ -f ${HA_SSH_SHUTDOWN}/${com} ] 
        then            
            message="$com is availble zone."
            echo $message
            HA_LOG_script $message            

            message="RUN: SSH Shutdown Compute node $com."
            echo $message
            HA_LOG_script $message
                        
            bash ${HA_SSH_SHUTDOWN}/${com}
            # mv zone/available/${com} zone/failure/
        fi
                    
        message="RUN: nova host-evacuate  $com."
        echo $message
        HA_LOG_script $message

        nova host-evacuate $com
        sleep 30s
    fi
done

rm -rf ${PROCESS}

