#include <FirebaseESP8266.h>
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClientSecure.h>
#include <ArduinoJson.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <stdlib.h>

#define WIFI_SSID "Ashen_One"
#define WIFI_PASSWORD "thetrueheir"

#define FIREBASE_HOST "https://ecgtest.firebaseio.com"


#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 32
#define OLED_RESET -1

#define BPM_UPDATE_TIME 2000
#define FIREBASE_UPDATE_TIME 500
#define LOCATION_UPDATE_TIME 300000

unsigned long lastBPMUpdateTime = 0;
unsigned long lastFirebaseUpdateTime = 0;
unsigned long lastLocationUpdateTime = 0;
int currentBPM = 75;

float latitude = 0.0;
float longitude = 0.0;
int locationAccuracy = 0;
bool locationValid = false;

FirebaseData firebaseData;
FirebaseAuth auth;
FirebaseConfig config;

Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

String team_name = "Rescue Squad Alpha";
String member_name = "John Doe";

void getLocationFromWiFi() {
  Serial.println("Updating location from WiFi networks...");
  
  int networksFound = WiFi.scanNetworks();
  Serial.printf("%d networks found\n", networksFound);

  if (networksFound == 0) {
    Serial.println("No networks found, can't determine location");
    locationValid = false;
    return;
  }

  // Build the JSON request
  DynamicJsonDocument jsonBuffer(4096);
  JsonObject root = jsonBuffer.to<JsonObject>();
  root["considerIp"] = "false";  // Force WiFi-only location
  JsonArray wifiAccessPoints = root.createNestedArray("wifiAccessPoints");

  // Use strongest networks (up to 7)
  for (int i = 0; i < min(networksFound, 7); i++) {
    JsonObject wifiInfo = wifiAccessPoints.createNestedObject();
    wifiInfo["macAddress"] = WiFi.BSSIDstr(i);
    wifiInfo["signalStrength"] = WiFi.RSSI(i);
    // Signal-to-noise ratio helps accuracy
    wifiInfo["signalToNoiseRatio"] = WiFi.RSSI(i) + 100; // Approximation
  }

  WiFiClientSecure client;
  client.setInsecure(); // Bypass SSL verification (not recommended for production)
  client.setTimeout(15000); // 10 second timeout

  HTTPClient http;
  String url = "https://www.googleapis.com/geolocation/v1/geolocate?key=" + String(GOOGLE_API_KEY);
  
  // Retry up to 3 times
  for (int attempt = 0; attempt < 3; attempt++) {
    http.begin(client, url);
    http.addHeader("Content-Type", "application/json");

    String requestBody;
    serializeJson(root, requestBody);

    Serial.println("Attempting location request...");
    int httpCode = http.POST(requestBody);

    if (httpCode == 200) {
      String payload = http.getString();
      Serial.println("Received: " + payload);
      
      DynamicJsonDocument responseDoc(1024);
      DeserializationError error = deserializeJson(responseDoc, payload);

      if (!error) {
        latitude = responseDoc["location"]["lat"];
        longitude = responseDoc["location"]["lng"];
        locationAccuracy = responseDoc["accuracy"];
        locationValid = true;

        Serial.printf("Location obtained: %.6f, %.6f (accuracy: %dm)\n", 
                     latitude, longitude, locationAccuracy);
        break; // Success - exit retry loop
      } else {
        Serial.println("JSON parsing failed");
      }
    } else {
      Serial.printf("HTTP error %d: %s\n", httpCode, http.errorToString(httpCode).c_str());
    }

    http.end();
    if (attempt < 2) delay(2000); // Wait before retry
  }

  WiFi.scanDelete();
}

// Add these global variables near the top of your file
int teamMemberBPM[7] = {75, 75, 70, 68, 74, 69, 72}; // Initial BPM values for all members

void updateFirebaseData() {
  // First ensure we have a connection
  if (!Firebase.ready()) {
    Serial.println("Firebase not connected!");
    return;
  }

  // Update BPM values for all members with small random changes
  for (int i = 0; i < 7; i++) {
    int delta = random(-3, 4);
    teamMemberBPM[i] += delta;
    if (teamMemberBPM[i] < 60) teamMemberBPM[i] = 60;
    if (teamMemberBPM[i] > 100) teamMemberBPM[i] = 100;
  }

  // Instead of building one large JSON object, update the teams one by one
  // Team 1: Rescue Squad Alpha
  
  Serial.println("Updating Rescue Squad Alpha...");
  
  // Update John Doe
  if (locationValid) {
    Firebase.setFloat(firebaseData, "/teams/0/members/0/location/lat", latitude);
    Firebase.setFloat(firebaseData, "/teams/0/members/0/location/long", longitude);
  }
  Firebase.setString(firebaseData, "/teams/0/members/0/name", "MEMBER-1");
  Firebase.setString(firebaseData, "/teams/0/members/0/ECG", String(teamMemberBPM[0]) + " BPM");
  Firebase.setString(firebaseData, "/teams/0/members/0/status", "Active");
  
  // Update Jane Smith
  if (locationValid) {
    Firebase.setFloat(firebaseData, "/teams/0/members/1/location/lat", latitude);
    Firebase.setFloat(firebaseData, "/teams/0/members/1/location/long", longitude);
  }
  Firebase.setString(firebaseData, "/teams/0/members/1/name", "MEMBER-2");
  Firebase.setString(firebaseData, "/teams/0/members/1/ECG", String(teamMemberBPM[1]) + " BPM");
  Firebase.setString(firebaseData, "/teams/0/members/1/status", "Active");
  
  Firebase.setString(firebaseData, "/teams/0/name", "Rescue Squad Alpha");
  Firebase.setString(firebaseData, "/teams/0/location", "Downtown Sector 5");
  
  // Team 2: Rapid Response Beta
  Serial.println("Updating Rapid Response Beta...");
  
  // Update Alice Brown
  if (locationValid) {
    Firebase.setFloat(firebaseData, "/teams/1/members/0/location/lat", latitude);
    Firebase.setFloat(firebaseData, "/teams/1/members/0/location/long", longitude);
  }
  Firebase.setString(firebaseData, "/teams/1/members/0/name", "MEMBER-1");
  Firebase.setString(firebaseData, "/teams/1/members/0/ECG", String(teamMemberBPM[2]) + " BPM");
  Firebase.setString(firebaseData, "/teams/1/members/0/status", "Standby");
  
  // Update Bob Johnson
  if (locationValid) {
    Firebase.setFloat(firebaseData, "/teams/1/members/1/location/lat", latitude);
    Firebase.setFloat(firebaseData, "/teams/1/members/1/location/long", longitude);
  }
  Firebase.setString(firebaseData, "/teams/1/members/1/name", "MEMBER-2");
  Firebase.setString(firebaseData, "/teams/1/members/1/ECG", String(teamMemberBPM[3]) + " BPM");
  Firebase.setString(firebaseData, "/teams/1/members/1/status", "Active");
  
  Firebase.setString(firebaseData, "/teams/1/name", "Rapid Response Beta");
  Firebase.setString(firebaseData, "/teams/1/location", "Uptown Zone 3");
  
  // Team 3: Emergency Task Force Gamma
  Serial.println("Updating Emergency Task Force Gamma...");
  
  // Update Charlie Wilson
  if (locationValid) {
    Firebase.setFloat(firebaseData, "/teams/2/members/0/location/lat", latitude);
    Firebase.setFloat(firebaseData, "/teams/2/members/0/location/long", longitude);
  }
  Firebase.setString(firebaseData, "/teams/2/members/0/name", "MEMBER-1");
  Firebase.setString(firebaseData, "/teams/2/members/0/ECG", String(teamMemberBPM[4]) + " BPM");
  Firebase.setString(firebaseData, "/teams/2/members/0/status", "Active");
  
  // Update David Lee
  if (locationValid) {
    Firebase.setFloat(firebaseData, "/teams/2/members/1/location/lat", latitude);
    Firebase.setFloat(firebaseData, "/teams/2/members/1/location/long", longitude);
  }
  Firebase.setString(firebaseData, "/teams/2/members/1/name", "MEMBER-2");
  Firebase.setString(firebaseData, "/teams/2/members/1/ECG", String(teamMemberBPM[5]) + " BPM");
  Firebase.setString(firebaseData, "/teams/2/members/1/status", "Inactive");
  
  Firebase.setString(firebaseData, "/teams/2/name", "Emergency Task Force Gamma");
  Firebase.setString(firebaseData, "/teams/2/location", "Central District 2");
  
  Serial.println("Firebase update completed");
}

void setup() {
  Serial.begin(115200);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("Connected to WiFi");

  config.host = FIREBASE_HOST;
  config.signer.tokens.legacy_token = FIREBASE_AUTH;
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
  
  if (!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) {
    Serial.println(F("SSD1306 allocation failed"));
    for(;;);
  }
  display.display();
  delay(1000);
  display.clearDisplay();
  
  randomSeed(analogRead(0));
  lastBPMUpdateTime = millis();
  lastFirebaseUpdateTime = millis();
  lastLocationUpdateTime = 0;
  
  getLocationFromWiFi();
}

void loop() {
  unsigned long currentTime = millis();

  if (currentTime - lastBPMUpdateTime >= BPM_UPDATE_TIME) {
    int delta = random(-3, 4);
    currentBPM += delta;
    if (currentBPM < 60) currentBPM = 60;
    if (currentBPM > 100) currentBPM = 100;
    Serial.print("Updated BPM: ");
    Serial.println(currentBPM);
    lastBPMUpdateTime = currentTime;
  }

  if (currentTime - lastLocationUpdateTime >= LOCATION_UPDATE_TIME) {
    getLocationFromWiFi();
    lastLocationUpdateTime = currentTime;
  }

  if (currentTime - lastFirebaseUpdateTime >= FIREBASE_UPDATE_TIME) {
    updateFirebaseData();
    lastFirebaseUpdateTime = currentTime;
  }
  
  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);
  
  // First line: Health Monitor and BPM
  display.setCursor(0, 0);
  display.print("Health: ");
  display.print(currentBPM);
  display.print(" BPM");
  
  // Second line: Location data in one line
  display.setCursor(0, 10);
  if (locationValid) {
    // Format: "LAT:xx.xxxx LON:yy.yyyy"
    display.print("LAT:");
    display.print(latitude, 4);
    display.print(" LON:");
    display.print(longitude, 4);
  } else {
    display.print("Location: Scanning...");
  }
  
  display.display();
  delay(10);
}
