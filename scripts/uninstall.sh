#!/bin/bash
source ../path.env

# Remove the conda environment
read -p "Remove environment ${ENV_NAME}? (y/n) " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  conda remove --name ${ENV_NAME} --all -y
  echo "Environment ${ENV_NAME} removed."
else
  echo "Environment removal cancelled."
fi

# Remove the Jupyter kernel
read -p "Remove Jupyter kernel ${KERNEL_NAME}? (y/n) " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  jupyter kernelspec remove ${KERNEL_NAME} -y
  echo "Jupyter kernel ${KERNEL_NAME} removed."
else
  echo "Kernel removal cancelled."
fi

# Remove the cloned repository
read -p "Remove cloned repository at ${CLONE_PATH}? (y/n) " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  rm -rf ${CLONE_PATH}
  echo "Cloned repository at ${CLONE_PATH} removed."
else
  echo "Repository removal cancelled."
fi

# TODO: remove pycache?