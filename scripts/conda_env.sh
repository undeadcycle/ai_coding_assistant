#!/bin/bash

# Name of the conda environment
ENV_NAME="codeLlama7bInstruct"
KERNEL_NAME="Python ($ENV_NAME)"

# Create a .env file if it doesn't exist
if [ ! -f ../.env ]; then
  touch ../.env
fi

# Write ENV_NAME variable to the .env file
echo "ENV_NAME=$ENV_NAME" >> ../.env

# Create and activate conda environment
conda create --name $ENV_NAME python=3.8 -y
conda activate $ENV_NAME

# Install PyTorch and related libraries
conda install pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia -y

# Install additional Python packages
pip install diffusers transformers accelerate python-dotenv

# Install Jupyter and create a kernel
conda install -c conda-forge jupyter ipykernel -y
python -m ipykernel install --user --name=$ENV_NAME --display-name $KERNEL_NAME

# Write KERNEL_NAME variable to the .env file
echo "KERNEL_NAME=$KERNEL_NAME" >> ../.env

# TODO: how do i want handle tokenizer etc (this is not in the cloned repo)? I dont think I need this repo anymore
if [ ! -d "../models" ]; then
  mkdir ../models
fi

# Get the absolute path minus the current directory
CURRENT_PATH=$(pwd | sed 's#/[^/]*$##')

# Write CLONE_PATH to the .env file
echo "CLONE_PATH=$CURRENT_PATH/models" >> ../.env

# Clone the GitHub repository (if not already cloned)
if [ ! -d "../models/codellama" ]; then
  git clone https://github.com/meta-llama/codellama.git ../models
  echo "Codellama repository cloned successfully!"
fi

# Install the repository in editable mode
pip install -e $CLONE_PATH

# Check if .gitignore exists in the parent directory
if [ ! -f ../.gitignore ]; then
  touch ../.gitignore
fi

# Ensure that the auth.env and path.env files are ignored
if ! grep -qxF ".env" ../.gitignore; then
  echo "*.env" >> ../.gitignore
fi
