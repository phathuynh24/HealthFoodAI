from flask import Flask
from nutrition import nutrition
from recommendation import recommendation
from dotenv import load_dotenv
from flask_cors import CORS

load_dotenv()
app = Flask(__name__)

# Configuring CORS
CORS(app, resources={r"/*": {"origins": "*"}})

# Analyze food nutrition
app.register_blueprint(nutrition)
# Recommend food recipes
app.register_blueprint(recommendation)

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5001)
