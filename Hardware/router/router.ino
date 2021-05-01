//#include "ESP8266WiFi.h"

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

String path = "/Router/";

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

String prevRouter="Departed";
int inde =0;
String path1 = "/QR Codes/5963358/Location/";
String fin="";
void loop()
{
  if(Firebase.RTDB.get(&fbdo, path.c_str()))
  {
    Serial.println(fbdo.stringData());
    if (fbdo.stringData()!=prevRouter)
    {
      inde=inde+1;
      fin=path1+inde;
      Firebase.RTDB.setString(&fbdo, fin.c_str(), fbdo.stringData());
      prevRouter=fbdo.stringData();
    }
    if(fbdo.stringData()=="Arrived")
    {
      for(int i=0;;){}
    }
  }
}
