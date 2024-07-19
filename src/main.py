import tkinter as tk
from gui import CodingAssistantApp
from chatbot import generate_response
from auth import register_user

class CodingAssistantAppWithAI(CodingAssistantApp):
    def get_bot_response(self, user_input):
        return generate_response(user_input)

if __name__ == "__main__":
    root = tk.Tk()
    app = CodingAssistantAppWithAI(root)
    root.mainloop()
