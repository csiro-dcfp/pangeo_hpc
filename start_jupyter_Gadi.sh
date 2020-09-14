#!/bin/bash -l

#PBS -P v14
#PBS -l storage=gdata/v14+scratch/v14

#PBS -q normal
#PBS -l walltime=02:00:00
#PBS -l mem=16gb
#PBS -l ncpus=4
#PBS -l jobfs=100GB
#PBS -l wd
#PBS -j oe
#PBS -o /dev/null

if [ ! $# -eq 0 ]; then
    NOTEBOOK_DIR=$1
    RUN_SCRIPT_DIR=$2
fi

# USER TO EDIT (if appropriate)
# ----------------------------
PANGEO_ENVIRONMENT=pangeo
LOG_DIR=/g/data/${PROJECT}/${USER}/tmp/logs
HPC_ADDRESS=gadi.nci.org.au
# ----------------------------

${RUN_SCRIPT_DIR}/start_jupyter.sh ${NOTEBOOK_DIR} ${LOG_DIR} ${HPC_ADDRESS} ${PANGEO_ENVIRONMENT}
