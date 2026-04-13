from flask import Flask, request, jsonify
import os
from pipeline import analyze
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

UPLOAD_FOLDER = "uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@app.route("/")
def home():
    return "API Running"


@app.route("/analyze", methods=["POST"])
def analyze_image():

    if "image" not in request.files:
        return jsonify({"error": "No image uploaded"}), 400

    file = request.files["image"]

    #  GET USER ID (IMPORTANT)
    user_id = request.form.get("user_id", "default_user")

    filepath = os.path.join(UPLOAD_FOLDER, file.filename)
    file.save(filepath)

    # PASS USER ID
    result = analyze(
        filepath,
        user_id=user_id,
        gt_mask_path=None,
        visualize=False
    )

    return jsonify(result)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)