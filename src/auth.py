import os
import logging
from dotenv import load_dotenv
from werkzeug.security import generate_password_hash, check_password_hash

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Load environment variables from auth.env
load_dotenv('auth.env') # TODO: does this need to be ../auth.env

# Access environment variables
username = os.getenv('USERNAME')
hashed_password = os.getenv('HASHED_PASSWORD')

if not username or not hashed_password:
    logger.info("No existing credentials found. Creating new user.")
    from getpass import getpass

    new_username = input("Enter new username: ")
    new_password = getpass("Enter new password: ")
    hashed_password = generate_password_hash(new_password)

    with open('auth.env', 'a') as f:
        f.write(f"\nUSERNAME={new_username}\nHASHED_PASSWORD={hashed_password}\n")

    logger.info("New user created. Please restart the application.")
    exit()

def authenticate_user(user, passwd):
    return user == username and check_password_hash(hashed_password, passwd), "Authentication failed" if user != username or not check_password_hash(hashed_password, passwd) else "Authentication succeeded"

# Add your authentication logic here...
