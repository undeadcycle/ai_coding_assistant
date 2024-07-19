#!/bin/bash

# Troublshooting variables
DISPLAY_LOG=True
CHECK_FILES=True

# Name of the conda environment
ENV_NAME="codeLlama7bInstruct"
KERNEL_NAME="Python ($ENV_NAME)"

# Set log file
LOG_FILE="../setup.log"

# Function to log messages
log_message() {
  echo "$(date) - $1" >> $LOG_FILE
}

# Function to check for errors
check_error() {
  if [ $? -ne 0 ]; then
    log_message "Error: $1"
    exit 1
  fi
}

# Create a .env file if it doesn't exist
if [ ! -f ../.env ]; then
  touch ../.env
fi

# TODO: promt for location of model files and write to .env as MODEL_PATH

# Write ENV_NAME variable to the .env file
echo "ENV_NAME=$ENV_NAME" >> ../.env
check_error "Failed to write ENV_NAME to .env file"

# Create and activate conda environment
conda create --name $ENV_NAME python=3.8 -y
check_error "Failed to create conda environment"
conda activate $ENV_NAME
check_error "Failed to activate conda environment"

# Install PyTorch and related libraries
conda install pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia -y
check_error "Failed to install PyTorch related libraries"

# Install additional Python packages
pip_packages=(
  "diffusers" 
  "transformers" 
  "accelerate" 
  "python-dotenv"
  )
for package in ${pip_packages[@]}; do
  pip install $package
  check_error "Failed to install ${package}"
done

# TODO: do need jupyter since i am now using a GUI? can this be used to troubleshoot the GUI?
# Install Jupyter and create a kernel
conda install -c conda-forge jupyter ipykernel -y
python -m ipykernel install --user --name=$ENV_NAME --display-name $KERNEL_NAME
check_error "Failed to failed to install Jupyer OR create a kernel"

# Write KERNEL_NAME variable to the .env file
echo "KERNEL_NAME=$KERNEL_NAME" >> ../.env
check_error "Failed to write KERNEL_NAME to .env file"

# TODO: how do i want handle tokenizer etc (this is not in the cloned repo)? I dont think I need this repo anymore
if [ ! -d "../models" ]; then
  mkdir ../models
fi
check_error "Failed to find/create models directory"

# Get the absolute path minus the current directory
CURRENT_PATH=$(pwd | sed 's#/[^/]*$##')
check_error "Failed to get absolute path"
echo "ROOT_PATH=$CURRENT_PATH" >> ../.env
check_error "Failed to write ROOT_PATH to .env file"

# Write CLONE_PATH to the .env file
echo "CLONE_PATH=$CURRENT_PATH/models" >> ../.env
check_error "Failed to write CURRENT_PATH to .env file"

# Clone the GitHub repository (if not already cloned)
if [ ! -d "../models/codellama" ]; then
  git clone https://github.com/meta-llama/codellama.git ../models
  echo "Codellama repository cloned successfully!"
fi
check_error "Failed to clone GitHub repo"

# Install the repository in editable mode
pip install -e $CLONE_PATH
check_error "Failed to make GitHub repo editable"

# Check if .gitignore exists in the parent directory
if [ ! -f ../.gitignore ]; then
  touch ../.gitignore
fi
check_error "Failed to create .gitignore file"

# Ensure that the auth.env and path.env files are ignored
if ! grep -qxF ".env" ../.gitignore; then
  echo "*.env" >> ../.gitignore
fi
check_error "Failed to write *.env to .gitignore file"

# Final log message
log_message "Script completed successfully!"

# Display log if DISPLAY_LOG=True
if [ "$DISPLAY_LOG" = True ]; then
  cat $LOG_FILE
fi

# TODO: Check if all files exist in correct location
if [ "$CHECK_FILES" = True ]; then
  FILES_TO_CHECK=(
    # "${CURRENT_PATH}/ai_coding_assistant.code-workspace"
    # "${CURRENT_PATH}/auth.env"
    # "${CURRENT_PATH}/code_bot_plan.md"
    # "${CURRENT_PATH}/data/users.json"
    # "${CURRENT_PATH}/models/codellama/codellama.egg-info/dependency_links.txt"
    # "${CURRENT_PATH}/models/codellama/CODE_OF_CONDUCT.md"
    # "${CURRENT_PATH}/models/codellama/CONTRIBUTING.md"
    # "${CURRENT_PATH}/models/codellama/dev-requirements.txt"
    # "${CURRENT_PATH}/models/codellama/download.sh"
    # "${CURRENT_PATH}/models/codellama/example_completion.py"
    # "${CURRENT_PATH}/models/codellama/example_infilling.py"
    # "${CURRENT_PATH}/models/codellama/example_instructions.py"
    # "${CURRENT_PATH}/models/codellama/LICENSE"
    # "${CURRENT_PATH}/models/codellama/llama/generation.py"
    # "${CURRENT_PATH}/models/codellama/llama/__(link unavailable)"
    # "${CURRENT_PATH}/models/codellama/llama/model.py"
    # "${CURRENT_PATH}/models/codellama/llama/tokenizer.py"
    # "${CURRENT_PATH}/models/codellama/MODEL_CARD.md"
    # "${CURRENT_PATH}/models/codellama/README.md"
    # "${CURRENT_PATH}/models/codellama/requirements.txt"
    # "${CURRENT_PATH}/models/codellama/setup.py"
    # "${CURRENT_PATH}/models/codellama/USE_POLICY.md"
    # "${CURRENT_PATH}/path.env"
    "${CURRENT_PATH}/README.md"
    "${CURRENT_PATH}/scripts/conda_env.sh"
    "${CURRENT_PATH}/scripts/uninstall.sh"
    "${CURRENT_PATH}/src/auth.py"
    "${CURRENT_PATH}/src/chatbot.py"
    "${CURRENT_PATH}/src/gui.py"
    "${CURRENT_PATH}/src/main.py"
    "${CURRENT_PATH}/.env"
    # "${CURRENT_PATH}/        path to model weights
  )

  for file in ${FILES_TO_CHECK[@]}; do
    if [ ! -f "$file" ]; then
      log_message "Error: File $file not found!"
    fi
  done
fi