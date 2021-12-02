#!/bin/bash -l

#SBATCH --time=02:00:00
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=64G
#SBATCH --cpus-per-task=8
#SBATCH --output=/dev/null 

# ====================================
# Submit a job running Jupyter on Petrichor
#
#    USAGE: qsub --export NOTEBOOK_DIR=<directory to start notebook in> \
#                --export RUN_SCRIPT_DIR=<location of start_jupyter.sh> \
#                --export PANGEO_ENV_NAME=<name of pangeo environment> \
#                start_jupyter_Petrichor.sh
#
#    Dougie Squire
#    19/08/2020
# ====================================

if [ ! $# -eq 0 ]; then
    NOTEBOOK_DIR=$1
    RUN_SCRIPT_DIR=$2
    PANGEO_ENV_NAME=$3
fi

# USER TO EDIT (optional)
# ----------------------------
LOG_DIR=/scratch1/${USER}/tmp/logs
# ----------------------------

HPC_ADDRESS=petrichor.hpc.csiro.au

${RUN_SCRIPT_DIR}/start_jupyter.sh ${NOTEBOOK_DIR} ${LOG_DIR} ${HPC_ADDRESS} ${PANGEO_ENV_NAME}
