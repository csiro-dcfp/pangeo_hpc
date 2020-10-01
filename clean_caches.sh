#!/bin/bash -l

# ====================================
# run a set of clean up commands prior to a conda reset
#
#    USAGE: ./clean_caches.sh
#
#    Thomas Moore
#    24/09/2020
# ====================================

echo -e "----> Starting cleaning"
conda activate pangeo && \
conda clean --all && \
jupyter lab clean && \
jlpm cache clean && \
echo -e "Done with cleanup <----"
