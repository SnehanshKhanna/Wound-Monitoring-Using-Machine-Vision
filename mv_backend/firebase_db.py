import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase
if not firebase_admin._apps:
    cred = credentials.Certificate("firebase_key.json")
    firebase_admin.initialize_app(cred)

db = firestore.client()


# -------------------------------
# GET PREVIOUS DATA
# -------------------------------
def get_previous_features(user_id):

    docs = db.collection("users") \
             .document(user_id) \
             .collection("history") \
             .limit(2) \
             .stream()

    data = [doc.to_dict() for doc in docs]

    if len(data) >= 1:
        return data[-1]   # latest available

    return None


# -------------------------------
# SAVE CURRENT DATA
# -------------------------------
def save_features(user_id, features):

    db.collection("users") \
      .document(user_id) \
      .collection("history") \
      .add({
          "area": features["area"],
          "healing_score": features.get("healing_score", 0),
          "timestamp": firestore.SERVER_TIMESTAMP
      })