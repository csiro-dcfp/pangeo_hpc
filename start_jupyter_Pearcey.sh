#!/bin/bash -l

#SBATCH --time=02:00:00
#SBATCH --mem-per-cpu=16gb
#SBATCH --cpus-per-task=4
#SBATCH --output=/dev/null 

if [ ! $# -eq 0 ]; then
    NOTEBOOK_DIR=$1
    RUN_SCRIPT_DIR=$2
fi
LOG_DIR=/scratch1/${USER}/tmp/logs
HPC_ADDRESS=pearcey.hpc.csiro.au

conda activate pangeo

${RUN_SCRIPT_DIR}/start_jupyter.sh ${NOTEBOOK_DIR} ${LOG_DIR} ${HPC_ADDRESS}
