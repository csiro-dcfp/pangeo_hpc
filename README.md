# Scripts and advice for running Pangeo with `dask-jobqueue` on NCI Gadi and CSIRO Pearcey
(Note that the NCI-recommended approach for using Pangeo on Gadi is outlined here: https://nci-data-training.readthedocs.io/en/latest/_notebook/prep/pangeo.html. These scripts and instructions describe an alternative approach where users can manage their own conda environment and scale clusters using `dask-jobqueue`)

## Prerequisites
Users will need to be able to log in to their system of interest. To use Gadi, users will need to be able to request resources under a project. New users can sign up here https://my.nci.org.au/mancini/signup/0, but they will need to either join an existing project or propose a new project to be able to access NCI resources. Existing users can check their projects here https://my.nci.org.au/mancini/.
Users will also need to have a github account.

## Getting set up:
1. Log in (Gadi: `ssh -Y <username>@gadi.nci.org.au` or Pearcey: `ssh -Y <username>@pearcey.hpc.csiro.au`)
2. If you don't have conda installed or access to conda (`which conda`), please install it:  
	```
	wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
	chmod +x Miniconda3-latest-Linux-x86_64.sh
	./Miniconda3-latest-Linux-x86_64.sh
	```  
	You'll get prompted for where to install conda. The default is home, which is quite limited for space. I recommend using a persistent location, e.g. `/g/data/v14/<username>/apps/` on Gadi or Bowen storage on Pearcey.
3. Clone this repo to a location of your choice: go to the desired location and run `git clone https://github.com/csiro-dcfp/pangeo_hpc.git`.
4. If you don't already have a pangeo conda environment, create one: `conda env create -f pangeo_environment.yml`. This will create a new conda environment called `pangeo`. If you wish to use a different name: `conda env create --name pangeo_new -f pangeo_environment.yml`.
5. Activate your new `pangeo` environment and install/enable the following useful Jupyter labextensions (you'll only need to do this once):
	```
	conda activate pangeo
	
	jupyter labextension install dask-labextension
	jupyter serverextension enable dask_labextension

	jupyter labextension install @jupyter-widgets/jupyterlab-manager
	jupyter nbextension enable --py widgetsnbextension --sys-prefix

	jupyter serverextension enable --py nbserverproxy

	jupyter labextension install jupyterlab-jupytext
	jupyter nbextension enable --py jupytext
	```
	Note, `jupytext` is a handy little tool for managing versions of your Jupyter notebooks in other languages (https://github.com/mwouts/jupytext).
6. Configure your Jupyter password: 
	```
	jupyter notebook --generate-config
	jupyter notebook password
	```
	and follow the prompts.
7. At this point, you're ready to submit a job to run your JupyterLab and python instances. Once this job is running and you've accessed JupyterLab via your web browser (see below) you'll be able to request additional resources as a dask cluster (using `dask-jobqueue`). We can submit a job to run our JupyterLab instance using the relevant `start_jupyter_<system>.sh` script but it may require a little editing first:
	1. Edit the PBS/SLURM header information (the `#PBS`/`#SLURM` lines) to reflect your project (if relevant), required resources, etc. Remember these are just the resources needed for Python and JupyterLab. For interactive science work, I usually request few resources for a long time, and then do any heavy compute task(s) on dask clusters that are spun up from within JupyterLab.
	2. If you called your conda environment anything other than "pangeo", you'll need to edit the `conda activate pangeo` line accordingly at the beginning of the script.
	
	You could now go ahead and submit your `start_jupyter_<system>.sh` script to the queue. However, for convenience I've also written a simple function for handling the submission of `start_jupyter_<system>.sh` and parsing instructions from the output file. This function receives some of the key job specifications--walltime, memory, number of cpus, project (if relevent) and the notebook directory--as optional inputs so you don't have to edit `start_jupyter_<system>.sh` everytime you want to change any of these. You can append this function to your `.bashrc` by running `./instantiate_pangeo_function.sh` (only run this **once**). The `pangeo` function signature is:
	> Gadi: `pangeo walltime(02:00:00) ncpus(4) mem(16GB) project($PROJECT) notebook_directory(~)`,\
	> Pearcey: `pangeo time(02:00:00) cpus_per_task(4) mem-per-cpu(16GB) notebook_directory(~)`,
	
	where the defaults given in brackets
8. Run the `pangeo` function or submit `start_jupyter_<system>.sh` to the queue. For the former (recommended), instructions for setting up port forwarding to view your JupyterLab session will be printed to your screen. For the latter, you'll have to parse them from the `jupyter_instructions.txt` file that will appear in the current directory. In both cases, the instructions will only appear once your jobs leaves the queue which may take a minute or so.
9. Follow the instructions to access your JupyterLab session via a web browser.
10. Do your science. My typical workflow is to use `dask-jobqueue` to request and access resources for the "heavy-lifting" in my notebooks (e.g. reducing a large dataset down to a 2D field to plot). Examples of setting up a `dask-jobqueue` cluster are given in the [notebooks](https://github.com/csiro-dcfp/pangeo_hpc/tree/master/notebooks) directory of this repo. Note that getting `dask-jobqueue` running on Gadi requires the manipulation of the default jobscripts submitted by dask's `PBSCluster` into a format that Gadi expects. An example of this hack is given in `notebooks/run_dask-jobqueue_Gadi.ipynb`.  
	
