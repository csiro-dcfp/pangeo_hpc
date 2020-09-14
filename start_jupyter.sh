#!/bin/bash -l

# Adapted from code written by Paul Branson

NOTEBOOK_DIR=$1
LOG_DIR=$2
HPC_ADDRESS=$3
PANGEO_ENVIRONMENT=$4

conda deactivate
conda activate ${PANGEO_ENVIRONMENT}

HOST=$(hostname)
mkdir -p $LOG_DIR
LOGFILE=$LOG_DIR/pangeo_jupyter_log.$(date +%Y%m%dT%H%M%S)
INSTRUCTIONSFILE=./jupyter_instructions.txt
rm -f $INSTRUCTIONSFILE

# Start the notebook -----
echo -e "Starting jupyter notebook..." \
> $INSTRUCTIONSFILE
JPORT=$(shuf -n 1 -i 8301-8400) # As in NCI pangeo module
jupyter lab --no-browser --ip=$HOST --port=${JPORT} --notebook-dir=$NOTEBOOK_DIR \
>& $LOGFILE &

# Wait for notebook to start -----
ELAPSED=0
ADDRESS=
while [[ $ADDRESS != *"${HOST}"* ]]; do
    sleep 1
    ELAPSED=$(($ELAPSED+1))
    ADDRESS=$(grep -e '^\[.*\]\s*http://.*:.*/.*' $LOGFILE | head -n 1 | awk -F'//' '{print $NF}')
    if [[ $ELAPSED -gt 360 ]]; then
        echo -e "Something went wrong:\n-----"
        cat $LOGFILE
        echo "-----"
        kill_server
    fi
done

# Print jupyter port forwarding info -----
PORT=$(echo $ADDRESS | awk -F':' ' { print $2 } ' | awk -F'/' ' { print $1 } ')
TOKEN=$(echo $ADDRESS | awk -F'=' ' { print $NF } ')
INSTRUCTIONS="
Run the following command on your local computer:
  ssh -N -L $PORT:${HOST}:$PORT ${USER}@${HPC_ADDRESS}
Then open a browser and go to:
  http://localhost:$PORT
The Jupyter web interface will ask you for your password.

To view the dask dashboard, enter the following into the dask labextension / new browser:
  http://localhost:$PORT/proxy/<dashboard-port>/status
where <dashboard-port> is the port serving your dashboard (8787 by default)

Use Control-C to shut down this job...
"
echo "$INSTRUCTIONS" >> $INSTRUCTIONSFILE

# Wait for user kill command -----
sleep inf

