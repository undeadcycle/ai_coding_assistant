import tkinter as tk
from tkinter import simpledialog, messagebox, scrolledtext
import logging
from auth import authenticate_user
from chatbot import Chatbot

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class ChatbotGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("AI Coding Assistant")
        self.is_authenticated = False
        self.show_login_dialog()

    def show_login_dialog(self):
        username = simpledialog.askstring("Login", "Enter your username:")
        password = simpledialog.askstring("Login", "Enter your password:", show='*')
        success, message = authenticate_user(username, password)
        if success:
            self.is_authenticated = True
            self.username = username
            self.setup_gui()
        else:
            messagebox.showerror("Authentication Failed", message)
            self.show_login_dialog()

    def setup_gui(self):
        self.chat_display = scrolledtext.ScrolledText(self.root, wrap=tk.WORD)
        self.chat_display.pack(padx=10, pady=10, fill=tk.BOTH, expand=True)

        self.input_frame = tk.Frame(self.root)
        self.input_frame.pack(fill=tk.X, padx=10, pady=10)

        self.input_entry = tk.Entry(self.input_frame)
        self.input_entry.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 10))
        self.input_entry.bind("<Return>", self.send_message)

        self.send_button = tk.Button(self.input_frame, text="Send", command=self.send_message)
        self.send_button.pack(side=tk.RIGHT)

        self.chatbot = Chatbot()

    def send_message(self, event=None):
        if not self.is_authenticated:
            return
        user_input = self.input_entry.get()
        if user_input:
            self.chat_display.insert(tk.END, f"You: {user_input}\n")
            self.input_entry.delete(0, tk.END)
            bot_response = self.get_bot_response(user_input)
            self.chat_display.insert(tk.END, f"Bot: {bot_response}\n")

    def get_bot_response(self, user_input):
        # Placeholder for the AI model integration
        try:
            response = self.chatbot.get_response(user_input)
            return response
        except Exception as e:
            logger.error(f"Error in chatbot response: {e}")
            return "Error in response"

if __name__ == "__main__":
    root = tk.Tk()
    gui = ChatbotGUI(root)
    root.mainloop()
