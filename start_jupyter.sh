#!/bin/bash -l

#PBS -P v14
#PBS -q normal
#PBS -l walltime=00:30:00
#PBS -l mem=4gb
#PBS -l ncpus=1
#PBS -l wd
#PBS -l storage=gdata/v14+scratch/v14
#PBS -j oe
#PBS -o ~/
#PBS -N jupyter

if [ ! $# -eq 0 ]; then
    NOTEBOOK_DIR=$1
fi

# TO BE EDITED BY THE USER (MAYBE) 
# ================================
conda activate pangeo

LOG_DIR=/g/data/v14/${USER}/tmp/logs
# ================================

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
  ssh -N -L $PORT:${HOST}:$PORT ${USER}@gadi.nci.org.au
Then open a browser and go to:
  http://localhost:$PORT
The Jupyter web interface will ask you for your password.

To get the dashboard working, use the dask labextension and navigate to
  http://localhost:$PORT/proxy/<dashboard-port>

Use Control-C to shut down this job...
"
echo "$INSTRUCTIONS" >> $INSTRUCTIONSFILE

# Wait for user kill command -----
sleep inf

