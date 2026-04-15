# Wound Monitoring System using Machine Learning

## Overview

This project is an AI-powered wound monitoring system that integrates a machine learning pipeline, a Flask-based backend API, and a Flutter mobile application.

The system analyzes wound images and provides quantitative clinical insights while tracking healing progression over time.

It enables objective wound assessment by extracting features such as wound area, redness, tissue condition, and edge irregularity. These features are used to compute a healing score and risk level.

---

## Key Features

- Image-based wound analysis  
- Automatic wound segmentation  
- Wound area estimation  
- Redness and tissue analysis  
- Healing score computation (0–100 scale)  
- Risk classification (Low / Moderate / High)  
- Healing trend analysis (Improving / Stable / Worsening)  
- Historical tracking using cloud database  
- Mobile interface for real-time usage  

---

## System Architecture

The system consists of four main components:

### 1. Mobile Application (Flutter)
- Capture or upload wound images  
- Display analysis results  
- View healing progress over time  
- Access session history  

### 2. Backend API (Flask)
- Receives images from frontend  
- Performs preprocessing and model inference  
- Returns structured JSON response  

### 3. Machine Learning Pipeline
- Segments wound region from the image  
- Extracts features:
  - Area  
  - Redness  
  - Texture  
  - Tissue composition  
  - Edge irregularity  
- Computes:
  - Risk level  
  - Healing score  
  - Healing trend  

### 4. Database (Firebase Firestore)
- Stores scan history per user  
- Maintains timestamps and feature data  
- Enables temporal analysis  

---

## Workflow

1. Image is captured or uploaded via the mobile application  
2. Image is sent to the Flask API  
3. Preprocessing is applied (resize, normalization)  
4. Model performs segmentation and feature extraction  
5. Backend computes:
   - Wound area  
   - Redness  
   - Healing score  
   - Risk level  
6. Previous data is fetched from Firestore  
7. Healing trend is calculated  
8. Results are returned to the app as JSON  
9. Current data is stored in Firestore  

---

## Example API Response

```json
{
  "risk_level": "High Risk",
  "area": 3501.0,
  "redness": 179.9,
  "healing_score": 0.0,
  "healing_trend": "Worsening"
}
```
## Database Structure

```text
users/
  └── user_id/
        └── history/
              ├── document_1
              │    ├── area
              │    ├── healing_score
              │    ├── timestamp
              ├── document_2
```

## Healing Trend Logic

- Computed dynamically using current and previous data
- Not stored directly in the database
- Based on:
  - Change in wound area
  - Change in healing score
- Output categories:
  - Improving
  - Stable
  - Worsening

## Project Structure

```text
project-root/
│
├── mobile_app/        # Flutter frontend
├── backend/           # Flask API
│   ├── app.py
│   ├── pipeline.py
│   ├── features.py
│   ├── decision.py
│   ├── healing.py
│   ├── firebase_db.py
│
├── model/             # ML model files
├── assets/            # Images and resources
├── README.md
```
## Setup Instructions

### Backend (Flask)
```bash
cd backend
pip install -r requirements.txt
python app.py
```
### Frontend (Flutter)
```bash
cd mobile_app
flutter pub get
flutter run
```
## Application Screens
- **Home Dashboard**: Displays current wound status and quick statistics.
- **Scan & Analyze**: Upload or capture image. Displays Risk level, Area, Redness, Healing score, and Healing trend.
- **Healing Progress**: Graph showing wound area over time.
- **Session History**: List of previous scans with timestamps and risk levels.

## Results
- Accurate wound segmentation and feature extraction
- Consistent risk classification
- Real-time analysis through API
- Effective healing progression tracking
- Cloud-based historical data management

## Limitations
- Dependent on image quality and lighting conditions
- Model performance may vary for unseen wound types
- Deployment constraints for heavy ML models on free cloud platforms

## Future Work
- Optimized cloud deployment
- Integration with hospital systems
- IoT-based real-time monitoring
- Multi-patient management system
- Improved deep learning architectures

## Conclusion
This project demonstrates the integration of machine learning, backend APIs, and mobile applications to solve a real-world healthcare problem. It provides a scalable and practical solution for wound monitoring, with potential applications in telemedicine and remote patient care.
