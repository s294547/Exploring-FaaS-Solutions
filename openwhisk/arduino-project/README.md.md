# ARDUINO PROJECT

<div style="margin-left: auto;
            margin-right: auto;
            width: 50%">

|||
|:--:|:--:|
| **Author** | Giulia Bianchi|
| **Contact** | s294547@studenti.polito.it |
</div>

1. [Introduction](#introduction)



## Introduction

In this folder we have the code of an arduino project.

This code is designed to collect data from a DHT11 humidity and temperature sensor, and a gas sensor connected to pin A0 of the ESP8266 NodeMCU board. The collected data is then sent to a remote server via HTTP GET requests and MQTT protocol. The code is divided into several functions to achieve this.

The code starts by including necessary libraries such as ESP8266WiFi, PubSubClient, and DHT. The DHT library is used to read the data from the DHT11 sensor.

Next, some variables are declared. Variables 'h' and 't' are used to store humidity and temperature values respectively, and 'g' stores the gas sensor readings. Other variables such as WiFi credentials, MQTT broker information, and time intervals are also defined.

In the setup function, the pins of the board are configured, the DHT11 sensor is initialized, and a serial connection is established for debugging purposes. The board connects to the Wi-Fi network using the SSID and password defined in the variables earlier. If the connection is successful, the local IP address of the board is printed. The function then calls the 'rileva_invia' function, which reads data from the sensors and sends it to the remote server using an HTTP GET request.

In the loop function, the time is checked against the last time the sensors were read, and if the time interval is reached, the 'rileva_invia' function is called again. The D4 LED is turned on for 2 seconds to indicate that a reading has been taken.

The 'rileva_invia' function reads the humidity, temperature, and gas sensor values by calling the 'readHumidity', 'readTemperature', and 'analogRead' functions respectively. These values are then sent to the remote server using HTTP GET requests and MQTT protocol. The 'isnan' function checks for any errors in the readings and sets the values to zero if any errors are detected.

Overall, this code collects data from multiple sensors and sends it to a remote server for further processing. It is designed to be used with an ESP8266 NodeMCU board, a DHT11 humidity and temperature sensor, and a gas sensor connected to pin A0 of the board.