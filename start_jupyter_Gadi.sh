#!/bin/bash -l

#PBS -P xv83
#PBS -l storage=gdata/xv83+gdata/v14+gdata/v19+scratch/v14+scratch/ux06+gdata/oi10

#PBS -q normal
#PBS -l walltime=02:00:00
#PBS -l mem=16gb
#PBS -l ncpus=4
#PBS -l jobfs=100GB
#PBS -l wd
#PBS -j oe
##PBS -o /dev/null

# ====================================
# Submit a job running Jupyter on Gadi
#
#    USAGE: qsub -v NOTEBOOK_DIR=<directory to start notebook in> \
#                -v RUN_SCRIPT_DIR=<location of start_jupyter.sh> \
#                -v PANGEO_ENV_NAME=<name of pangeo environment> \
#		 start_jupyter_Gadi.sh
#
#    Dougie Squire
#    19/08/2020
# ====================================

# export MALLOC_TRIM_THRESHOLD_="0"

if [ ! $# -eq 0 ]; then
    NOTEBOOK_DIR=$1
    RUN_SCRIPT_DIR=$2
    PANGEO_ENV_NAME=$3
fi

# USER TO EDIT (optional)
# ----------------------------
LOG_DIR=/scratch/${PROJECT}/${USER}/tmp/logs
# ----------------------------

HPC_ADDRESS=gadi.nci.org.au

${RUN_SCRIPT_DIR}/start_jupyter.sh ${NOTEBOOK_DIR} ${LOG_DIR} ${HPC_ADDRESS} ${PANGEO_ENV_NAME}
