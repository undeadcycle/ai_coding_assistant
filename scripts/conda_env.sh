#!/bin/bash

# Name of the conda environment
ENV_NAME="codeLlama7bInstruct"

# Create and activate conda environment
conda create --name $ENV_NAME python=3.8 -y
conda activate $ENV_NAME

# Install PyTorch and related libraries
conda install pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia -y

# Install additional Python packages
pip install diffusers transformers accelerate python-dotenv

# Install Jupyter and create a kernel
conda install -c conda-forge jupyter ipykernel -y
python -m ipykernel install --user --name=$ENV_NAME --display-name "Python ($ENV_NAME)"

# Clone the GitHub repository (if not already cloned)
# TODO: mk dir models to place place repo in. how do i want handle tokenizer etc?
if [ ! -d "~/ai_models/codellama" ]; then
  git clone https://github.com/meta-llama/codellama.git ~/ai_models/codellama
fi

# Install the repository in editable mode
pip install -e ~/ai_models/codellama

# Check if .gitignore exists in the parent directory
if [ ! -f ../.gitignore ]; then
  touch ../.gitignore
fi

# Ensure that the auth.env and path.env files are ignored
if ! grep -qxF "auth.env" ../.gitignore && ! grep -qxF "path.env" ../.gitignore; then
  echo "auth.env
path.env" >> ../.gitignore
fi
