#!/bin/bash -l

if [[ "$HOSTNAME" == *"gadi"* ]]; then
    SYSTEM=gadi
elif [[ "$HOSTNAME" == *"pearcey"* ]]; then
    SYSTEM=pearcey
else 
    echo "Cannot determine system" 1>&2
fi

if [[ "$SYSTEM" == "gadi" ]]; then
    PANGEO_FUNCTION='function pangeo {
    WALLTIME=${1:-"02:00:00"}
    NCPUS=${2:-"4"}
    MEM=${3:-"16GB"}
    PROJECT=${4:-"'$PROJECT'"}
    NOTEBOOK_DIR=${5:-"~"}
    PANGEO_RUN_SCRIPT_DIR="'$(pwd)'"

    rm -f jupyter_instructions.txt

    jobid=$(qsub -l walltime=${WALLTIME} -l mem=${MEM} -l ncpus=${NCPUS} -P ${PROJECT} -v "NOTEBOOK_DIR=${NOTEBOOK_DIR},RUN_SCRIPT_DIR=${PANGEO_RUN_SCRIPT_DIR}" ${PANGEO_RUN_SCRIPT_DIR}/start_jupyter_Gadi.sh)
    while [ ! -f jupyter_instructions.txt ]; do
        sleep 1
    done
    tail -f -n 50 jupyter_instructions.txt

    echo "Closing ${jobid}"
    qdel ${jobid}
}'
elif [[ "$SYSTEM" == "pearcey" ]]; then
    PANGEO_FUNCTION='function pangeo {
    WALLTIME=${1:-"02:00:00"}
    NCPUS=${2:-"4"}
    MEM=${3:-"16GB"}
    NOTEBOOK_DIR=${5:-"~"}
    PANGEO_RUN_SCRIPT_DIR="'$(pwd)'"

    rm -f jupyter_instructions.txt

    jobid=$(sbatch --time=${WALLTIME} --mem-per-cpu=${MEM} --cpus-per-task=${NCPUS} --export "NOTEBOOK_DIR=${NOTEBOOK_DIR},RUN_SCRIPT_DIR=${PANGEO_RUN_SCRIPT_DIR}" ${PANGEO_RUN_SCRIPT_DIR}/start_jupyter_Pearcey.sh)
    while [ ! -f jupyter_instructions.txt ]; do
        sleep 1
    done
    tail -f -n 50 jupyter_instructions.txt

    echo "Closing ${jobid}"
    qdel ${jobid}
}'
fi

echo "$PANGEO_FUNCTION" >> ~/.bashrc 
