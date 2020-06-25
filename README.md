# Scripts and advice for running Pangeo with `dask-jobqueue` on NCI Gadi
Users will need to be able to log in to Gadi and request resources under a project. New users can sign up here https://my.nci.org.au/mancini/signup/0, but they will need to either join an existing project or propose a new project to be able to access NCI resources.
Users will also need to have a github account.

1. Log in to Gadi;
2. If you don't have conda installed or access to conda (`which conda`), please install it:
```
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod +x Miniconda3-latest-Linux-x86_64.sh
./Miniconda3-latest-Linux-x86_64.sh
```
You'll get prompted for where to install conda. The default is home, which is quite limited for space. I recommend using a persistent location, e.g. `/g/data/v14/<username>/apps/` (you'll have to create the `apps` directory first).
3. Once logged in, clone this repo to a location of your choice: go to the desired location (e.g. `/g/data/v14/<username>`) and enter `git clone git@github.com:csiro-dcfp/pangeo_Gadi.git`;
4. If you don't already have a pangeo conda environment, create one: `conda env create -f pangeo.yml`. This will create a new conda environment called `pangeo`. If you wish to use a different name:

