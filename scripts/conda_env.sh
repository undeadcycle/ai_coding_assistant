#!/bin/bash

# Troublshooting variables
DISPLAY_LOG=True
CHECK_FILES=True

# Name of the conda environment
ENV_NAME="codeLlama7bInstruct"
KERNEL_NAME="Python ($ENV_NAME)"

# Get the absolute path minus the current directory
ROOT_PATH=$(pwd | sed 's#/[^/]*$##')
check_error "Failed to get absolute path"

# Set log file
LOG_FILE="$ROOT_PATH/setup.log"

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
if [ ! -f $ROOT_PATH/.env ]; then
  touch $ROOT_PATH/.env
fi

# Write ROOT_PATH to .env file
echo "ROOT_PATH=$ROOT_PATH" >> $ROOT_PATH/.env
check_error "Failed to write ROOT_PATH to .env file"

# Promt for location of model files 
read -p "Enter the location (absolute path) of the model files: " MODEL_PATH

# Write MODEL_PATH variable to the .env file
echo "MODEL_PATH=$MODEL_PATH" >> $ROOT_PATH/.env
check_error "Failed to write MODEL_PATH to .env file"

# Write ENV_NAME variable to the .env file
echo "ENV_NAME=$ENV_NAME" >> $ROOT_PATH/.env
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
echo "KERNEL_NAME=$KERNEL_NAME" >> $ROOT_PATH/.env
check_error "Failed to write KERNEL_NAME to .env file"

# TODO: how do i want handle tokenizer etc (this is not in the cloned repo)? I dont think I need this repo anymore
if [ ! -d "$ROOT_PATH/models" ]; then
  mkdir $ROOT_PATH/models
fi
check_error "Failed to find/create models directory"



# Write CLONE_PATH to the .env file
echo "CLONE_PATH=$ROOT_PATH/models" >> $ROOT_PATH/.env
check_error "Failed to write ROOT_PATH to .env file"

# Clone the GitHub repository (if not already cloned)
if [ ! -d "$ROOT_PATH/models/codellama" ]; then
  git clone https://github.com/meta-llama/codellama.git $ROOT_PATH/models
  echo "Codellama repository cloned successfully!"
fi
check_error "Failed to clone GitHub repo"

# Install the repository in editable mode
pip install -e $CLONE_PATH
check_error "Failed to make GitHub repo editable"

# Check if .gitignore exists in the parent directory
if [ ! -f $ROOT_PATH/.gitignore ]; then
  touch $ROOT_PATH/.gitignore
fi
check_error "Failed to create .gitignore file"

# Ensure that the auth.env and path.env files are ignored
if ! grep -qxF ".env" $ROOT_PATH/.gitignore; then
  echo "*.env" >> $ROOT_PATH/.gitignore
fi
check_error "Failed to write *.env to .gitignore file"

# Final log message
log_message "Script completed successfully!"

# Display log if DISPLAY_LOG=True
if [ "$DISPLAY_LOG" = True ]; then
  cat $LOG_FILE
fi

# Check if all files exist in correct location
if [ "$CHECK_FILES" = True ]; then
  FILES_TO_CHECK=(
    # "${ROOT_PATH}/ai_coding_assistant.code-workspace"
    # "${ROOT_PATH}/auth.env"
    # "${ROOT_PATH}/code_bot_plan.md"
    # "${ROOT_PATH}/data/users.json"
    # "${ROOT_PATH}/models/codellama/codellama.egg-info/dependency_links.txt"
    # "${ROOT_PATH}/models/codellama/CODE_OF_CONDUCT.md"
    # "${ROOT_PATH}/models/codellama/CONTRIBUTING.md"
    # "${ROOT_PATH}/models/codellama/dev-requirements.txt"
    # "${ROOT_PATH}/models/codellama/download.sh"
    # "${ROOT_PATH}/models/codellama/example_completion.py"
    # "${ROOT_PATH}/models/codellama/example_infilling.py"
    # "${ROOT_PATH}/models/codellama/example_instructions.py"
    # "${ROOT_PATH}/models/codellama/LICENSE"
    # "${ROOT_PATH}/models/codellama/llama/generation.py"
    # "${ROOT_PATH}/models/codellama/llama/__(link unavailable)"
    # "${ROOT_PATH}/models/codellama/llama/model.py"
    # "${ROOT_PATH}/models/codellama/llama/tokenizer.py"
    # "${ROOT_PATH}/models/codellama/MODEL_CARD.md"
    # "${ROOT_PATH}/models/codellama/README.md"
    # "${ROOT_PATH}/models/codellama/requirements.txt"
    # "${ROOT_PATH}/models/codellama/setup.py"
    # "${ROOT_PATH}/models/codellama/USE_POLICY.md"
    # "${ROOT_PATH}/path.env"
    "${ROOT_PATH}/README.md"
    "${ROOT_PATH}/scripts/conda_env.sh"
    "${ROOT_PATH}/scripts/uninstall.sh"
    "${ROOT_PATH}/src/auth.py"
    "${ROOT_PATH}/src/chatbot.py"
    "${ROOT_PATH}/src/gui.py"
    "${ROOT_PATH}/src/main.py"
    "${ROOT_PATH}/.env"
    # "${ROOT_PATH}/        path to model weights
  )

  for file in ${FILES_TO_CHECK[@]}; do
    if [ ! -f "$file" ]; then
      log_message "Error: File $file not found!"
    fi
  done
fi