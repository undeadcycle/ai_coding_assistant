#!/bin/bash
source ../path.env

# Name of the conda environment
ENV_NAME="codeLlama7bInstruct"

# Remove the conda environment
conda remove --name $ENV_NAME --all -y

# Remove the Jupyter kernel
jupyter kernelspec remove $ENV_NAME -y

# Remove the cloned repository
rm -rf ${CLONE_PATH}

# Inform the user
echo "Environment, kernel, and cloned repository have been removed."