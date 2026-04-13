from flask import Flask, request, jsonify
import cv2
import os
from pipeline import analyze
from flask_cors import CORS

app = Flask(__name__)
CORS(app)   # 🔥 ADD THIS

UPLOAD_FOLDER = "uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@app.route("/")
def home():
    return "API Running"

@app.route("/analyze", methods=["POST"])
def analyze_image():

    file = request.files["image"]

    filepath = os.path.join(UPLOAD_FOLDER, file.filename)
    file.save(filepath)

    result = analyze(filepath, previous_areas=[12000, 11000], visualize=False)

    return jsonify(result)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)