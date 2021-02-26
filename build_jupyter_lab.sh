#!/bin/bash -l

# ====================================
# run a set of commands to build all the jupyterlab extensions
#
#    USAGE: ./build_jupyter_lab.sh
#
#    Thomas Moore
#    26/02/2021
# ====================================
env_name=${1?Error: no name given}

echo -e "----> Starting all the builds"
conda activate ${env_name} && \
# For using the dask extension within JupyterLab (https://github.com/dask/dask-labextension)
jupyter labextension install --no-build --clean dask-labextension && \
jupyter serverextension enable --sys-prefix --py dask_labextension && \
echo -e "----> Done with dask builds" && \
# For using widgets within JupyterLab (https://ipywidgets.readthedocs.io/en/latest/user_install.html)
jupyter labextension install --no-build --clean @jupyter-widgets/jupyterlab-manager && \
jupyter nbextension enable --sys-prefix --py widgetsnbextension && \
echo -e "----> Done with widget builds" && \
# For simplifying setting up the dask dashboard (https://github.com/jupyterhub/jupyter-server-proxy)
jupyter labextension install --no-build --clean @jupyterlab/server-proxy && \
echo -e "----> Done with dask dashboard builds" && \
# For managing versions of your Jupyter notebooks in other languages (https://github.com/mwouts/jupytext)
jupyter labextension install --no-build --clean jupyterlab-jupytext && \
jupyter nbextension enable --sys-prefix --py jupytext && \
echo -e "----> Done with other language builds" && \
jupyter labextension install @pyviz/jupyterlab_pyviz && \
echo -e "----> Done with pyviz build" && \
# Build JupyterLab
jupyter lab build && \
echo -e "----> Done with main build" && \
echo -e "----> Start cleaning" && \
# Clean up unnecessary cache files to reduce inode footprint
jupyter lab clean && \
jlpm cache clean && \
echo -e "----> Done cleaning" && \
echo -e "Done with builds <----"
