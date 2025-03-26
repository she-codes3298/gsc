from fastapi import FastAPI
import firebase_admin
from firebase_admin import credentials, messaging, firestore

# Initialize FastAPI
app = FastAPI()

# Load Firebase Admin SDK (only initialize if not already initialized)
if not firebase_admin._apps:
    cred = credentials.Certificate("android/app/google-service.json")  # 🔹 Update with actual path
    firebase_admin.initialize_app(cred)

# Initialize Firestore
db = firestore.client()

# API to send notifications to users in high-risk cities
@app.post("/send-disaster-alert/")
async def send_disaster_alert(city: str, title: str, body: str):
    try:
        users_ref = db.collection("users")
        query = users_ref.where("city", "==", city).stream()

        # Extract FCM tokens safely
        tokens = [user.to_dict().get("fcmToken") for user in query if user.to_dict() and user.to_dict().get("fcmToken")]

        if not tokens:
            return {"status": "No users found in this city"}

        # Send notifications in batches of 500
        batch_size = 500
        success_count = 0
        for i in range(0, len(tokens), batch_size):
            batch_tokens = tokens[i : i + batch_size]
            messages = [
                messaging.Message(
                    notification=messaging.Notification(title=title, body=body),
                    token=token
                ) for token in batch_tokens
            ]
            response = messaging.send_all(messages)
            success_count += response.success_count

        return {"status": "Notifications sent", "success_count": success_count}

    except Exception as e:
        return {"status": "Error", "message": str(e)}
