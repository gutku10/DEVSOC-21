//#include "ESP8266WiFi.h"

#define BLINK_PERIOD 250
long lastBlinkMillis;
boolean ledState;

#define SCAN_PERIOD 5000
long lastScanMillis;

#if defined(ESP32)
#include <WiFi.h>
#elif defined(ESP8266)
#include <ESP8266WiFi.h>
#endif
#include <Firebase_ESP_Client.h>
#define WIFI_SSID "JioFiber-etJbd"
#define WIFI_PASSWORD "g32yK7JpTd2VnugA"
#define FIREBASE_HOST ""
#define API_KEY ""
#define USER_EMAIL ""
#define USER_PASSWORD ""
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

void setup()
{
  Serial.begin(115200);
  Serial.println();

  pinMode(LED_BUILTIN, OUTPUT);

  WiFi.mode(WIFI_STA);
  WiFi.disconnect();
  delay(100);

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();
  config.host = FIREBASE_HOST;
  config.api_key = API_KEY;
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
}
int countTime = 0;
void loop()
{
  if (countTime == 0) {
    int minim = 32766;
    int val = 0;
    long currentMillis = millis();

    if (currentMillis - lastBlinkMillis > BLINK_PERIOD)
    {
      digitalWrite(LED_BUILTIN, ledState);
      ledState = !ledState;
      lastBlinkMillis = currentMillis;
    }
    if (currentMillis - lastScanMillis > SCAN_PERIOD)
    {
      WiFi.scanNetworks(true);
      Serial.print("\nScan start ... ");
      lastScanMillis = currentMillis;
    }
    int n = WiFi.scanComplete();
    if (n >= 0)
    {
      for (int i = 0; i < n; i++)
      {
        Serial.printf("%d: %s, Ch:%d (%ddBm) %s\n", i + 1, WiFi.SSID(i).c_str(), WiFi.channel(i), abs(WiFi.RSSI(i)), WiFi.encryptionType(i) == ENC_TYPE_NONE ? "open" : "");
        if (abs(WiFi.RSSI(i)) <= minim)
        {
          minim = abs(WiFi.RSSI(i));
          val = i;
        }
      }
      WiFi.scanDelete();
      countTime++;
    }
  }
}
