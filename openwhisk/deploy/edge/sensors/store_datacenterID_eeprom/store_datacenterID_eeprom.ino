#include <ESP8266WiFi.h>
#include <ESP_EEPROM.h>


// data center unique ID
uint32_t dataCenterID = 1; // replace this with a unique identifier for the data center

void setup() {
  Serial.begin(115200);
  Serial.println();

  EEPROM.begin(sizeof(dataCenterID));

  EEPROM.put(0, dataCenterID);
  EEPROM.commit();

  EEPROM.get(0, dataCenterID);
  Serial.print("DC ID from EPROM: ");
  Serial.println(dataCenterID, DEC);
 
}

void loop() {
  // empty
}