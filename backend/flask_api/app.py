from flask import Flask
from main import main
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
app.register_blueprint(main)

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5001)
