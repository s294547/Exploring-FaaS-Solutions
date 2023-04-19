# ARDUINO PROJECTS: SEND TELEMETRY

<div style="margin-left: auto;
            margin-right: auto;
            width: 50%">

|||
|:--:|:--:|
| **Author** | Giulia Bianchi|
| **Contact** | s294547@studenti.polito.it |
</div>

1. [Introduction](#introduction)
2. [Parameters to be set](#parameters-to-be-set)


## Introduction

In this folder we have the code of an arduino project to send telemetry data.

This code is an Arduino sketch that runs on an ESP8266 NodeMCU board, which is a low-cost microcontroller board with built-in Wi-Fi support. The sketch reads data from a DHT11 temperature and humidity sensor and sends the data to a remote server via HTTP GET requests. Additionally, the sketch reads an analog signal from an A0 pin to detect the gas concentration in the surrounding environment.

The code starts by including several libraries, including the ESP8266WiFi library, which allows the board to connect to a Wi-Fi network, the ESP_EEPROM library for reading and writing to the board's EEPROM memory, the ArduinoJson library for manipulating JSON data, the PubSubClient library for MQTT (Message Queuing Telemetry Transport) communication protocol, and the DHT library for reading data from the DHT11 sensor.

Next, the code defines several variables, including the type of DHT sensor being used (DHT11 in this case), the pin connected to the DHT11 sensor (D1 in this case), and variables for storing humidity, temperature, and gas concentration readings.

The sketch then sets up the Wi-Fi connection by defining the network name (SSID) and password, starting the connection, and waiting until the connection is established before proceeding. Additionally, the sketch initializes the EEPROM library to read and write the datacenter ID and retrieves the datacenter ID from EEPROM memory.

After the Wi-Fi connection is established, the code calls the rileva_invia() function, which reads the humidity, temperature, and gas concentration data from the sensors and sends the data to the remote server via an HTTP GET request. This function is also called every 15 minutes (interval) by the loop() function to ensure regular updates.

The loop() function contains a timer that triggers the rileva_invia() function at a fixed interval. Additionally, the loop() function turns on an LED for two seconds to indicate when a reading has been taken.

The rileva_invia() function reads the humidity and temperature data from the DHT11 sensor and the gas concentration data from the A0 pin. It performs three readings to stabilize the values read from the DHT11 sensor, and if the readings are successful, it sends the data to a remote server via an HTTP GET request. If there is an error in the reading, the function sets the humidity, temperature, and gas concentration variables to 0.

Overall, this sketch is a simple example of using an ESP8266 NodeMCU board with a DHT11 sensor and an A0 pin to read and transmit data to a remote server.

## Parameters to be set

Each data center admin should set the right value the following variables:

```
const char* ssid = "SSID-OF-YOUR-WIFI";       
const char* password = "PASSWORD-OF-YOUR-WIFI"; 
 
const char *mqtt_broker = "YOUR-BROKER-ADDRESS";
const char *topic = "YOUR-TOPIC";
const char *mqtt_username = "YOUR-BROKER-USERNAME";
const char *mqtt_password = "YOUR-BROKER-PASSWORD";
const int mqtt_port = 000// YOUR BROKER PORT;
```