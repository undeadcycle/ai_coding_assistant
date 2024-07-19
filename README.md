# AI Coding Assistant

## Overview
This project sets up a local AI coding assistant bot with functionalities for code generation, code completion, code review and optimization, debugging assistance, documentation generation, and answering coding-related questions. 

## Setup Instructions
Download model weights from meta (or mistral if i change the model used for this project)
Run conda_env.sh to create the environment and handle dependencies

### Prerequisites
- [Conda](https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html)
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

### 1. Clone the Repository
```bash
git clone https://github.com/your-repo/ai_coding_assistant.git # This url is not correct and is being used as a placeholder
cd ai_coding_assistant
```

### 2. Set Up Environment
Run the setup script to create the Conda environment, install dependencies, and set up the project.

```bash
bash scripts/conda_env.sh
```

### 3. Authentication
If this is the first time running the application, you will be prompted to create a new user and password.

### 4. Running the Application
To start the GUI application, run:

```bash
python src/gui.py
```

### 5. Uninstallation
To remove the environment, kernel, and cloned repository, run:

```bash
bash scripts/uninstall.sh
```

TODO: where do i want to store the model weights?
## Project Structure
```scss
ai_coding_assistant/ 
├── auth.env
├── code_bot_plan.md
├── data
│   └── users.json (if required)
├── models
│   └── codellama (cloned repository)
├── scripts
│   └── conda_env.sh
│   └── uninstall.sh
└── src
    ├── auth.py
    ├── chatbot.py
    ├── gui.py
    ├── main.py
```
## Contributing
Feel free to open issues or create pull requests.

## License
MIT License