# Internet of Things (IoT) Project: ESP32-Based Smart System

## Project Overview

This project involves creating an IoT-based smart system using the ESP32 microcontroller. The system integrates various sensors and components to provide real-time data monitoring and control capabilities. The main components include the DHT22 sensor for temperature and humidity measurement, an LDR for light sensing, and integration with ESP RainMaker for remote control and automation.

## Components Used

- **ESP32 DevKit V1**: A powerful Wi-Fi development board for IoT applications.
- **DHT22 Sensor**: Measures temperature and humidity.
- **LDR (Light Dependent Resistor)**: Measures light intensity.
- **ESP RainMaker**: Platform for cloud-based device management and voice assistant integration.

## Hardware Setup

1. **ESP32 DevKit V1**:
   - [Pinout Diagram & Arduino Reference](https://www.circuitstate.com/pinouts/doit-esp32-devkit-v1-wifi-development-board-pinout-diagram-and-reference/)

2. **DHT22 Sensor**:
   - [Pinout and Specifications](https://components101.com/sensors/dht22-pinout-specs-datasheet)

3. **LDR**:
   - [Datasheet](https://components101.com/resistors/ldr-datasheet)

## Software Setup

1. **Arduino IDE 2**:
   - [Documentation](https://docs.arduino.cc/software/ide-v2)

2. **Arduino Library List**:
   - [Libraries](https://www.arduinolibraries.info/)

3. **ESP RainMaker**:
   - [Introduction](https://rainmaker.espressif.com/docs/intro)
   - [Voice Assistant Integration Tutorial](https://circuitdigest.com/microcontroller-projects/esp-rainmaker-tutorial-esp32-alexa-google-voice-assistant)
   - [Getting Started Tutorial](https://microcontrollerslab.com/esp-rainmaker-tutorial-esp32-arduino-ide/)

## Installation

1. **Install Arduino IDE 2**:
   - Download and install the Arduino IDE from the [official website](https://docs.arduino.cc/software/ide-v2).

2. **Set Up ESP32 in Arduino IDE**:
   - Follow the instructions [here](https://docs.arduino.cc/software/ide-v2/getting-started) to add the ESP32 board to your Arduino IDE.

3. **Install Required Libraries**:
   - Use the Arduino Library Manager to install the necessary libraries for DHT22 and LDR sensors.

4. **Configure ESP RainMaker**:
   - Follow the [ESP RainMaker Introduction](https://rainmaker.espressif.com/docs/intro) and [ESP RainMaker Getting Started Tutorial](https://microcontrollerslab.com/esp-rainmaker-tutorial-esp32-arduino-ide/) to set up your device for cloud integration.

## Usage

1. **Upload Code**:
   - Connect the ESP32 to your computer and upload the provided Arduino sketch to configure sensor readings and ESP RainMaker integration.

2. **Monitor Data**:
   - Open the Serial Monitor in Arduino IDE to view real-time data from the DHT22 sensor and LDR.

3. **Control and Automation**:
   - Use the ESP RainMaker app to control the ESP32 remotely and set up automation rules.


## References

- [Arduino IDE 2 | Arduino Documentation](https://docs.arduino.cc/software/ide-v2)
- [Arduino Library List - Arduino Libraries](https://www.arduinolibraries.info/)
- [DHT22 – Temperature and Humidity Sensor - Components101](https://components101.com/sensors/dht22-pinout-specs-datasheet)
- [ESP RainMaker with ESP32 – Voice Assistant Integration - Circuit Digest](https://circuitdigest.com/microcontroller-projects/esp-rainmaker-tutorial-esp32-alexa-google-voice-assistant)
- [Introduction | ESP RainMaker](https://rainmaker.espressif.com/docs/intro)
- [ESP RainMaker Getting Started Tutorial with ESP32 and Arduino IDE - Microcontrollers Lab](https://microcontrollerslab.com/esp-rainmaker-tutorial-esp32-arduino-ide/)
- [LDR (Light Dependent Resistor) or Photoresistor - Components101](https://components101.com/resistors/ldr-datasheet)
- [DOIT ESP32 DevKit V1 Wi-Fi Development Board - Pinout Diagram & Arduino Reference - CIRCUITSTATE Electronics](https://www.circuitstate.com/pinouts/doit-esp32-devkit-v1-wifi-development-board-pinout-diagram-and-reference/)


