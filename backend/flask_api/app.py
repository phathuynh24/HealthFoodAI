from flask import Flask
from nutrition import nutrition
from recommendation import recommendation
from translate import translate
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
# Translate text
app.register_blueprint(translate)

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5001)
