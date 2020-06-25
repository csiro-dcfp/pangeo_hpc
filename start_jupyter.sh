#!/bin/bash -l

#PBS -P v14
#PBS -q normal
#PBS -l walltime=03:00:00
#PBS -l mem=4gb
#PBS -l ncpus=1
#PBS -l wd
#PBS -l storage=gdata/v14+scratch/v14
#PBS -j oe
#PBS -N jupyter

JOBID=$PBS_JOBID

conda activate pangeo
export PYTHONPATH="${PYTHONPATH}:/g/data/v14/ds0092/software/zarrtools"

HOST=$(hostname)
NOTEBOOK_DIR=/g/data/v14/ds0092
logDirectory=/g/data/v14/ds0092/tmp/logs
mkdir -p $logDirectory
LOGFILE=$logDirectory/pangeo_jupyter_log.$(date +%Y%m%dT%H%M%S)
INSTRUCTIONSFILE=~/jupyter_instructions.txt
rm -f $INSTRUCTIONSFILE

# Start the notebook -----
echo -e "Starting jupyter notebook (logging jupyter notebook session on ${HOST} to ${LOGFILE})...\n" \
> $INSTRUCTIONSFILE
jupyter lab --no-browser --ip=$HOST --notebook-dir=$NOTEBOOK_DIR \
>& $LOGFILE &

# Wait for notebook to start -----
ELAPSED=0
ADDRESS=
while [[ $ADDRESS != *"${HOST}"* ]]; do
    sleep 1
    ELAPSED=$(($ELAPSED+1))
    ADDRESS=$(grep -e '^\[.*\]\s*http://.*:.*/\?token=.*' $LOGFILE | head -n 1 | awk -F'//' '{print $NF}')
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

  The Jupyter web interface will ask you for a token. Use the following:

	$TOKEN

  Note that anyone to whom you give the token can access (and modify/delete)
  files in your PAWSEY spaces, regardless of the file permissions you
  have set. SHARE TOKENS RARELY AND WISELY!

  To get the dashboard working, use the dask labextension and navigate to

  	http://localhost:$PORT/proxy/<dashboard-port>
"
echo "$INSTRUCTIONS" >> $INSTRUCTIONSFILE

# Wait for user kill command -----
sleep inf

