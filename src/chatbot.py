import os
import logging
from transformers import AutoModelForCausalLM, AutoTokenizer
from dotenv import load_dotenv

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Load environment variables from auth.env
load_dotenv('auth.env')

# Specify the path to your local model
model_path = os.getenv("MODEL_PATH", "~/CodeLlama-7b-Instruct")

try:
    # Load the model and tokenizer
    tokenizer = AutoTokenizer.from_pretrained(model_path)
    model = AutoModelForCausalLM.from_pretrained(model_path)
    logger.info("Model and tokenizer loaded successfully.")
except Exception as e:
    logger.error(f"Failed to load model or tokenizer: {e}")

# Add your chatbot logic here...
