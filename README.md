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

### 📦 Inventory & Resource Management  
- Track relief supplies (food, medicine, shelters)  
- AI-driven allocation suggestions for optimal distribution  
- Low-stock alerts for critical resources  

### 🏕️ Community & Camp Coordination  
- Interactive map of refugee camps/shelters  
- Live headcount & resource monitoring  
- Evacuation route planning for disaster zones  

### 🤖 AI-Powered Chatbot (Gemini AI)  
- Instant procedural guidance for officials  
- Disaster response best practices  
- FAQs & decision-making support  

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

**Hardware Integration:**  
- LoRa  
- GPS  
- ESP-based wearables  

---

## 📥 Installation & Setup  

### Prerequisites  
- Flutter SDK (v3.x)  
- Firebase project with:  
  - google-services.json (Android)  
  - GoogleService-Info.plist (iOS)  
- Enabled Firebase Cloud Messaging (FCM)  

### Steps to Run:  
1. Clone the repository:  
   git clone https://github.com/your-repo/gsc.git  
   cd gsc  

2. Install dependencies:  
   flutter pub get  

3. Run the app:  
   flutter run  

---

## 🔗 API References  

**Earthquake API**  

**Cyclone API**  

**Gemini AI ,Maps SDK for Android 
, Service Usage API 
, Analytics Hub API 
, Cloud Storage API 
, Cloud Trace API 
, Cloud Translation API 
, Dataform API 
, Geocoding API 
, Google Cloud APIs 
, Google Cloud Storage JSON API 
, Maps JavaScript API 
, Maps SDK for iOS 
, Places API (New) 
, Routes API 
, Service Management API**  


---

## 📌 Future Roadmap  
- Offline Mesh Networking for SOS  
- Enhanced ML prediction models  
- Web dashboard for centralized management  

---

### ✅ Ready for Deployment  
Follow the installation steps to set up GSC for disaster response operations.
