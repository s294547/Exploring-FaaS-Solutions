# ARDUINO PROJECTS: STORE DATACENTERID IN THE EEPROM

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

In this folder we have the code of an arduino project to store in the eeprom the data center id. 

This is an Arduino sketch written for the ESP8266 WiFi module that demonstrates the use of the EEPROM library to read and write data to the non-volatile memory (NVM) of the ESP8266 module.

The code starts by including the necessary libraries for the ESP8266WiFi and ESP_EEPROM modules. It also declares a variable called dataCenterID, which is a 32-bit unsigned integer, and sets its value to 1. This variable is used to store a unique identifier for the data center.

In the setup function, the Serial communication is initialized with a baud rate of 115200. The Serial.println() function is called to output a newline character to the serial console.

Next, the code checks whether the dataCenterID has already been written to the EEPROM. This is done by calling the EEPROM.begin() function with the size of the dataCenterID variable. Then, the EEPROM.put() function is used to write the value of the dataCenterID variable to the EEPROM address 0. The EEPROM.commit() function is then called to ensure that the data is written to the NVM.

Finally, the EEPROM.get() function is used to read the value of the dataCenterID variable from the EEPROM address 0. The value is then printed to the serial console using the Serial.print() and Serial.println() functions.

The loop function is empty in this code, as there is no need for any further action once the EEPROM has been written and read.





## Parameters to be set

Each data center admin should set the right value the following variable:

```
uint32_t dataCenterID = 1; // replace this with a unique identifier for the data center
```