#include <ESP8266WiFi.h> //permette la connessione della scheda  alla rete WiFi 
#include <ESP_EEPROM.h>
#include <ArduinoJson.h>
#include <PubSubClient.h>
#include <ArduinoJson.h> 
#include <DHT.h>      //libreria necessaria per utilizzare il sensore DHT11

// pin di ESP8266 NodeMCU collegato all'uscita (pin OUT) del sensore DHT11
#define tipoDHT DHT11
/* definisce il tipo di sensore della famiglia DHT:  in questo caso viene selezionato   
   DHT11, ma esistono sono altri sensori quali DHT21 e DHT22 
*/
DHT dht(D1,tipoDHT);  //Istanzia l'oggetto dht della classe DHT    
float h;          //umidità   
float t;         //temperatur
float g; //gas

//***Configurazione WiFI: impostazione delle credenziali di rete 
const char* ssid = "yami";        //Inserire qui l'SSID
const char* password = "giugi99ciao"; //Inserire qui la password WiFi
//WiFiClient  client;
 
unsigned long time_last = 0;        // time ultima rilevazione
unsigned long time_current;         // time corrente
const long interval = 10000;           
// fisso l'intervallo tra una rilevazione e l'altra ad esempio a 15 minuti
// 900000ms = 9000s=15 minuti 


// MQTT Broker : TO BE CONFIGURED WITH YOUR BROKER VARIABLES
const char *mqtt_broker = "38.242.158.232";
const char *topic = "test";
const char *mqtt_username = "test";
const char *mqtt_password = "test";
const int mqtt_port = 32694;

WiFiClient espClient;
PubSubClient client(espClient);

// Device fingerprint and strin with the ID of the datacenter
uint32_t ucid = ESP.getChipId();
uint32_t dataCenterID;
 
void setup() 
{
  delay(1000);

  pinMode(D3,OUTPUT);
  pinMode(D4,OUTPUT);
  pinMode(A0, INPUT);
  dht.begin();
 
  // apre una connessione seriale. A scopo di debug inviamo messaggi al monitor seriale
  Serial.begin(115200); 

   // get device fingerprint

  Serial.print("UCID: ");
  Serial.println(ucid, HEX);

  // Initialize the EEPROM library
  EEPROM.begin(sizeof(dataCenterID));
  EEPROM.get(0, dataCenterID);
  Serial.print("DC ID from EPROM: ");
  Serial.println(dataCenterID, DEC);

  WiFi.begin(ssid, password);   //Si connette al router WiFi
  Serial.println("Connessione al WiFi in corso..");
  while (WiFi.status() != WL_CONNECTED) 
  {
      delay(500);
      Serial.print(".");
  }
  Serial.println("");
  Serial.print("ESP8266 NodeMCU connessa alla rete WiFI: ");
  Serial.print(ssid);
  Serial.print("  con il numero IP : ");
  Serial.println(WiFi.localIP());//l'IP di ESP8266 viene assegnato dal DHCP
  Serial.println();
  digitalWrite(D3, 1); // si accende il led 1 che indica che il Wifi è attivo 
  delay(500);
  rileva_invia();
  // chiamata alla funzione che rileva umidità H e temperatura T  e invia i dati allo script 
  // PHP  del server remoto con una richiesta HTTP GET
 
} //----chiude setup()------------------------------------------------------------------
 
void loop()
{
  time_current = millis();
  if (time_current - time_last >= interval) // se è trascorso il tempo impostato in interval  
  {
    time_last = time_current; // aggiorno il time ultima rilevazione   
    rileva_invia(); 
    // chiamata alla funzione che rileva umidità H e temperatura T  e invia i dati allo script 
    // PHP  del server remoto con una richiesta HTTP GET
 
    // il led 2 si accende per 2 secondi  segnalando che è stata fatta una lettura
      digitalWrite(D4, 1);  
      delay(2000);
      digitalWrite(D4, 0);
  }
}
 
void rileva_invia()
{
   // faccio 3 letture in modo che i valori letti dal sensore DHT11 , che non è velocissimo,      
   // si stabilizzino 
   for(int i=0;i<3;i++)
    { 
        h = dht.readHumidity();     // Lettura dell'umidità  
        t = dht.readTemperature();  // Lettura della temperatura in gradi Celsius 
        g= (analogRead(A0)*100)/1024;
        delay(300);
    } 
    if (isnan(h) || isnan(t))  //Verifica se  si presenta un errore di lettura   
    {  
          Serial.println("Errore di lettura...");  
          return;
          h=0.0;
          t=0.0;
          g=0.0;
    }    
    String s="Umidità= "+String(h)+"     Temperatura="+String(t);
    Serial.println(s);
    String s2=String(h)+"#"+String(t)+"#";
    client.setServer(mqtt_broker, mqtt_port);
    client.setKeepAlive(6000);
while (!client.connected()) {
    String client_id = "esp8266-client-";
    client_id += String(WiFi.macAddress());
    Serial.printf("The client %s connects to the public mqtt broker\n", client_id.c_str());
    if (client.connect(client_id.c_str(), mqtt_username, mqtt_password)) {
    } else {
        Serial.print("failed with state ");
        Serial.print(client.state());
        delay(2000);
    }
}

    // Convert sensor data to JSON format
  StaticJsonDocument<200> doc;
  doc["humidity"] = h;
  doc["temperature"] = t;
  doc["gas_perc"] = g;
  doc["device_fingerprint"] = ucid;
  doc["datacenter_id"] = dataCenterID;
  String json_data;
  serializeJson(doc, json_data);

  // Publish sensor data to MQTT topic
    client.publish(topic, json_data.c_str());

  // Print sensor data to serial monitor
  Serial.println(json_data);
    
}