# 🌍 GSC - Government-Side Disaster Management App  

## 📌 Overview  
**GSC** is a government-focused disaster management platform that enables officials to monitor, predict, and respond to natural disasters efficiently. It integrates real-time disaster alerts, SOS management, resource tracking, and AI-powered assistance to streamline emergency operations.  

> **Note:** For the civilian-facing SOS app (**D_M_**), refer to: [D_M_ GitHub Repository](https://github.com/pratzzz2432/D_M_.git)  

---

## 🚀 Key Features  

### 🔥 Disaster Prediction & Alerts  
- Real-time earthquake & cyclone predictions via external APIs  
- Automated push notifications for high-risk zones  
- Geospatial visualization of disaster-prone areas  

### 🆘 SOS Alert Management  
- Receives emergency SOS signals from civilian app ([D_M_](https://github.com/pratzzz2432/D_M_.git))  
- Auto-assigns rescue teams based on proximity/availability  
- Firebase-powered real-time alerts with location tracking  

### 🏗️ Refugee Camp Coordination  
- Geo-tagged camp management interface  
- Capacity planning tools (Food/Medical/Shelter)  
- Evacuation route mapping
  
### 📊 Resource Inventory System  
- Centralized stock monitoring  
- Supplier request pipeline  
- AI-powered distribution optimizer 

### 💬 Public Communication Hub  
- Official disaster bulletins  
- Citizen Q&A platform  
- Multilingual content (12 Indian languages)
  
### 🏕️ Community & Camp Coordination  
- Interactive map of refugee camps/shelters  
- Live headcount & resource monitoring  
- Evacuation route planning for disaster zones  

### 🤖 AI-Powered Chatbot (Gemini AI)  
- Instant procedural guidance for officials  
- Disaster response best practices  
- FAQs & decision-making support  

### 🛠️ Hardware Integration  
- **Rescue Team Wearables**:  
  - Real-time GPS tracking modules  
  - Biometric sensors (heart rate/SpO2)  
  - Emergency distress button with LoRa transmission  
  - OLED display for mission briefings  

- **Field Deployment Kits**:  
  - Portable IoT base stations  
  - Solar-powered charging units  
  - Ruggedized tablets with offline maps  

- **Civilian Alert System**:  
  - Community warning sirens  
  - Mesh network nodes for offline communication  

---

## 🛠️ Tech Stack  

**Frontend:**  
- Flutter (Dart)  

**Backend:**  
- Firebase  
- Google Cloud Functions  

**APIs:**  
- Earthquake Prediction API  
- Cyclone Prediction API  

**AI:**  
- Google Gemini AI  

**Hardware Stack:**  
| Component | Specification | Purpose |
|-----------|---------------|---------|
| ESP32 | Dual-core 240MHz | Wearable controller |
| LoRa Module | 915MHz | Long-range comms |
| GPS Module | U-blox NEO-6M | Location tracking |
| Biometric Sensor | MAX30102 | Health monitoring |
| OLED Display | 1.3" SH1106 | Field data display |

---

## 📥 Installation & Setup  

### Prerequisites  
- Flutter SDK (v3.x)  
- Firebase project with:  
  - google-services.json (Android)  
  - GoogleService-Info.plist (iOS)  
- Enabled Firebase Cloud Messaging (FCM)  
- Hardware provisioning:  
  - ESP32 dev kits (for wearables)  
  - LoRa gateways  

### Steps to Run:  
1. Clone the repository:  
   `git clone https://github.com/your-repo/gsc.git`  
   `cd gsc`  

2. Install dependencies:  
   `flutter pub get`  

3. Configure hardware:  
   `cd hardware/firmware`  
   `platformio run --target upload`  

4. Run the app:  
   `flutter run`  

---

## 🔗 API References  

**Earthquake API**  

**Cyclone API**  

**Gemini AI, Maps SDK for Android**  
**Service Usage API**  
**Analytics Hub API**  
**Cloud Storage API**  
**Cloud Trace API**  
**Cloud Translation API**  
**Dataform API**  
**Geocoding API**  
**Google Cloud APIs**  
**Google Cloud Storage JSON API**  
**Maps JavaScript API**  
**Maps SDK for iOS**  
**Places API (New)**  
**Routes API**  
**Service Management API**  

**Hardware APIs**:  
- LoRaWAN Network Server  
- ESP32 AT Commands  
- Biometric Sensor SDK  

---

## 📌 Future Roadmap  
- **Hardware Enhancements**:  
  - AI-accelerated edge processing  
  - Drone integration for aerial recon  
  - AR goggles for rescue teams  

- Software:  
  - Offline Mesh Networking for SOS  
  - Enhanced ML prediction models  
  - Web dashboard for centralized management  

---

### ✅ Deployment Guide  
1. **Field Setup**:  
   - Deploy LoRa gateways in operational zone  
   - Distribute wearables to rescue teams  
   - Calibrate biometric sensors  

2. **Software Deployment**:  
   `flutter build apk --release`  
   `adb install build/app/outputs/flutter-apk/app-release.apk`  

3. **Verification**:  
   - Test SOS signal reception  
   - Validate wearable telemetry  
   - Conduct disaster drill  

---
