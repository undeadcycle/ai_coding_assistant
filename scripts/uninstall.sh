#!/bin/bash

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

# Remove the .env file
read -p "Remove .env file? (y/n) " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  rm ${ROOT_PATH}/.env
  echo ".env file removed."
else
  echo ".env file removal cancelled."
fi

# Remove the models directory
read -p "Remove models directory? (y/n) " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  rm -rf ${ROOT_PATH}/models
  echo "Models directory removed."
else
  echo "Models directory removal cancelled."
fi

# Remove the __pycache__ directories
read -p "Remove __pycache__ directories? (y/n) " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  find "${ROOT_PATH}" -name '__pycache__' -type d -exec rm -rf {} +
  echo "__pycache__ directories removed."
else
  echo "__pycache__ directories removal cancelled."
fi