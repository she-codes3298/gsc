# 🌍 Disaster Management App

![Project Banner](https://via.placeholder.com/1200x400.png?text=Disaster+Management+App) <!-- Replace with your project banner -->

Welcome to the **Disaster Management App**, a comprehensive solution designed to help governments and civilians effectively manage and respond to disasters. This app provides real-time alerts, resource allocation, SOS features, and much more to ensure safety and coordination during emergencies.

---

## 🚀 Features

### **Government Side**
- **Real-Time Alerts**: Send instant disaster alerts to civilians.
- **Resource Management**: Track and allocate resources like food, water, and medical supplies.
- **Rescue Team Coordination**: Monitor and coordinate rescue operations.
- **Data Analytics**: Analyze disaster data for better decision-making.

### **Civilian Side**
- **Disaster Alerts**: Receive real-time alerts and updates.
- **SOS Feature**: Send distress signals with your location using **mesh networking**.
- **Refugee Camp Navigation**: Find the nearest safe zones and refugee camps.
- **Community Updates**: Stay informed with government announcements via **WebSocket-based real-time communication**.

---

## 🛠️ Technologies Used

### **Frontend**
- **Flutter**: For building cross-platform mobile apps for both government and civilian users.

### **Backend**
- **FastAPI**: For building a high-performance backend to handle API requests and data processing.
- **Firebase**: For real-time database (Firestore), authentication, and cloud messaging.
- **WebSocket**: For real-time communication in the community feature.

### **Machine Learning**
- **ML Models**: For disaster prediction and severity assessment using pre-trained models and data from sources like IMD, NDMA, and NCS.

### **Hardware**
- **ESP32**: The microcontroller used in the wearable device.
- **LoRa Module**: For long-range communication in areas with poor network connectivity.
- **GSM Module**: For sending SOS signals and location data.
- **GPS Module**: For real-time location tracking of rescue teams and civilians.
- **OLED Screen**: For displaying critical information on the wearable device.

### **Networking**
- **Mesh Networking**: For SOS signals to work in areas with no cellular network coverage.

---

## 🏗️ Currently in Production

We are actively working on this project to bring you the best disaster management solution. Here's what we're focusing on right now:

### **Government App**
- **Real-Time Alerts**: Implementing a robust system for sending alerts to civilians.
- **Resource Allocation**: Developing a feature to track and allocate resources efficiently.
- **Rescue Team Coordination**: Building tools to monitor and coordinate rescue operations.

### **Civilian App**
- **SOS Feature**: Enhancing the SOS functionality with **mesh networking** and real-time location tracking.
- **Refugee Camp Navigation**: Adding navigation features to help civilians find safe zones.
- **Community Updates**: Creating a platform for government announcements and updates using **WebSocket**.

### **Hardware**
- **Wearable Device**: Developing a wearable device for rescue teams with **ESP32**, **LoRa**, **GSM**, **GPS**, and an **OLED screen**.

Stay tuned for updates as we continue to improve and expand the app!

---

## 🧩 How It Works

### **Government App**
1. **Login**: Government officials log in with their credentials.
2. **Dashboard**: View real-time disaster data and manage resources.
3. **Send Alerts**: Create and send disaster alerts to civilians.
4. **Track Resources**: Monitor resource allocation and usage.

### **Civilian App**
1. **Login**: Civilians log in or register using their email.
2. **Home Screen**: View real-time alerts and updates.
3. **SOS Feature**: Send distress signals with your location using **mesh networking**.
4. **Refugee Camps**: Find the nearest safe zones and refugee camps.

### **Hardware**
- **Wearable Device**: Rescue teams use the wearable device to:
  - Track their location using **GPS**.
  - Send SOS signals using **GSM** or **LoRa**.
  - View team members' locations on the **OLED screen**.

---

## 🛠️ Installation

### **Prerequisites**
- Flutter SDK
- Python (for FastAPI backend)
- Firebase account
- Android Studio or VS Code
- ESP32 development environment (e.g., Arduino IDE or PlatformIO)

### **Steps**
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/disaster-management-app.git
