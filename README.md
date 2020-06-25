# Scripts and advice for running Pangeo with `dask-jobqueue` on NCI Gadi
Users will need to be able to log in to Gadi and request resources under a project. New users can sign up here https://my.nci.org.au/mancini/signup/0, but they will need to either join an existing project or propose a new project to be able to access NCI resources.
Users will also need to have a github account.

## Getting set up:
1. Log in to Gadi: `ssh -Y <username>@gadi.nci.org.au`.
2. If you don't have conda installed or access to conda (`which conda`), please install it:  
	```
	wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
	chmod +x Miniconda3-latest-Linux-x86_64.sh
	./Miniconda3-latest-Linux-x86_64.sh
	```  
	You'll get prompted for where to install conda. The default is home, which is quite limited for space. I recommend using a persistent location, e.g. `/g/data/v14/<username>/apps/` (you'll have to create the `apps` directory first).
3. Clone this repo to a location of your choice: go to the desired location (e.g. `/g/data/v14/<username>`) and enter `git clone git@github.com:csiro-dcfp/pangeo_Gadi.git`.
4. If you don't already have a pangeo conda environment, create one: `conda env create -f pangeo.yml`. This will create a new conda environment called `pangeo`. If you wish to use a different name: `conda env create --name pangeo_new -f pangeo.yml`.
5. Activate your new `pangeo` environment and install/enable the following Jupyter labextensions (you'll only need to do this once):
	```
	conda activate pangeo
	
	conda install -c conda-forge dask-labextension
	jupyter labextension install dask-labextension
	jupyter serverextension enable dask_labextension

	jupyter labextension install @jupyter-widgets/jupyterlab-manager
	jupyter serverextension enable --py nbserverproxy
	jupyter nbextension enable --py widgetsnbextension --sys-prefix
	```
6. Configure your Jupyter password: 
	```
	jupyter notebook --generate-config
	jupyter notebook password
	```
	and follow the prompts.
7. At this point, you're ready to submit a job to run your JupyterLab and python instances. Once this job is running and you've accessed JupyterLab via your web browser (see below) you'll be able to request additional resources as a dask cluster (using `dask-jobqueue`). We can submit a job to run our JupyterLab instance using `start_jupyter.sh` but it will require a little editing first.
	1. Edit the PBS header information (the `#PBS` lines) to reflect your project, required resources, etc. Remember these are just the resources needed for Python and JupyterLab. For interactive science work, I usually request few resources for a long time, and then do any heavy compute task(s) on dask clusters that are spun up from within JupyterLab specifically for the task(s).
	2. If you called you conda environment anything other than "pangeo", you'll need to edit the `conda activate pangeo` line accordingly at the beginning of the script.
	3. Change the `LOG_DIR` path where log files are output to.
	4. You may wish to edit some environment variables, e.g. add a directory to your `PYTHONPATH`.
	
	For convenience, I've written a little function for handling the submission of `start_jupyter.sh` and parsing instructions from the output file. You can put this in your `.bashrc` or `.bash_profile`:
	```
	function pangeo {
		WALLTIME=${1:-"02:00:00"}
        	MEM=${2:-"16GB"}
        	NCPUS=${3:-"4"}
		NOTEBOOK_DIR=${4:-`pwd`}
		PANGEO_RUN_SCRIPT_DIR="/location/of/clone/of/pangeo_Gadi"

		rm -f jupyter_instructions.txt

		jobid=`qsub -l walltime=${WALLTIME} -l mem=${MEM} -l ncpus=${NCPUS} -v "NOTEBOOK_DIR=${NOTEBOOK_DIR}" ${PANGEO_RUN_SCRIPT_DIR}/start_jupyter.sh`

		while [ ! -f jupyter_instructions.txt ]; do
			sleep 5
		done
		tail -f jupyter_instructions.txt

		echo "Closing ${jobid}"
		qdel ${jobid}
		}
	```
	Note, you will need to edit the `PANGEO_RUN_SCRIPT_DIR` variable. 
8. Run the `pangeo` function or submit `start_jupyter.sh` to the queue. For the former, instructions for setting up port forwarding to view your JupyterLab session will be printed to your screen. For the latter, you'll have to parse them from the `jupyter_instructions.txt` file that will appear in the current directory. In both cases, the instructions will only appear once your jobs leaves the queue which may take a minute or so.
9. Following the instructions to view your JupyterLab session via a web browser.
10. Do your science. My typical workflow is to use `dask-jobqueue` to request and access resources to do the "heavy-lifting" in my notebooks (e.g. reducing a large dataset down to a 2D field to plot). The key step to getting `dask-jobqueue` running on Gadi is the manipulation of the default jobscripts submitted by dask's `PBSCluster` into a format that Gadi expects. An example of this hack is given in `run_dask-jobqueue_Gadi.ipynb`.  
	
