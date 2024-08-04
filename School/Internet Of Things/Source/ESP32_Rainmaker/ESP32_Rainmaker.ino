// Include necessary libraries
#include "RMaker.h"
#include "WiFi.h"
#include "WiFiProv.h"
#include <DHT.h>
#include <SimpleTimer.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>

// Define constants for WiFi Provisioning
const char *service_name = "PROV_SmartHome";
const char *pop = "1234";

// Define chip ID and node name for ESP-RainMaker
uint32_t espChipId = 5;
char nodeName[] = "ESP32_Smarthome";

// Define names for the switch devices
char deviceName_1[] = "Switch1";
char deviceName_2[] = "Switch2";
char deviceName_3[] = "Switch3";
char deviceName_4[] = "Switch4";

// Define GPIO pins connected to relays and switches
static uint8_t RelayPin1 = 23;  
static uint8_t RelayPin2 = 26;  
static uint8_t RelayPin3 = 25;  
static uint8_t RelayPin4 = 19;  
static uint8_t SwitchPin1 = 13;  
static uint8_t SwitchPin2 = 12;  
static uint8_t SwitchPin3 = 14;  
static uint8_t SwitchPin4 = 27;  
static uint8_t wifiLed      = 2;   // WiFi LED Indicator
static uint8_t gpio_reset   = 0;   // Reset button

// Define pins and variables for sensors
static uint8_t DHTPIN       = 18; // D18  pin connected with DHT
static uint8_t LDR_PIN      = 33; // D33  pin connected with LDR

// Relay State
bool toggleState_1 = LOW; //Define integer to remember the toggle state for relay 1
bool toggleState_2 = LOW; //Define integer to remember the toggle state for relay 2
bool toggleState_3 = LOW; //Define integer to remember the toggle state for relay 3
bool toggleState_4 = LOW; //Define integer to remember the toggle state for relay 4

// Switch State
bool SwitchState_1 = LOW;
bool SwitchState_2 = LOW;
bool SwitchState_3 = LOW;
bool SwitchState_4 = LOW;

// Sensors Readings
float temperature1 = 0;
float humidity1   = 0;
bool highTempAlertSent = false; // Flag to track if the alert has been sent
float ldrVal  = 0;

// Initialize DHT22 sensor
DHT dht(DHTPIN, DHT22);  

// Initialize LCD display
LiquidCrystal_I2C lcd(0x27, 16, 2); // Use the correct address as found by your I2C scanner

// Initialize a timer
SimpleTimer Timer;

// Define switch devices and sensors in ESP-RainMaker
//The framework provides some standard device types like switch, lightbulb, fan, temperature sensor.
static Switch my_switch1(deviceName_1, &RelayPin1);
static Switch my_switch2(deviceName_2, &RelayPin2);
static Switch my_switch3(deviceName_3, &RelayPin3);
static Switch my_switch4(deviceName_4, &RelayPin4);
static TemperatureSensor temperature("Temperature");
static TemperatureSensor humidity("Humidity");
static TemperatureSensor ldr("LDR");

// Function to handle system provisioning events
void sysProvEvent(arduino_event_t *sys_event)
 // Handle different events like provisioning start and WiFi connection
{
  // Callback function for handling changes in device parameters
  switch (sys_event->event_id) {
    case ARDUINO_EVENT_PROV_START:
#if CONFIG_IDF_TARGET_ESP32
      Serial.printf("\nProvisioning Started with name \"%s\" and PoP \"%s\" on BLE\n", service_name, pop);
      printQR(service_name, pop, "ble");
#else
      Serial.printf("\nProvisioning Started with name \"%s\" and PoP \"%s\" on SoftAP\n", service_name, pop);
      printQR(service_name, pop, "softap");
#endif
      break;
    case ARDUINO_EVENT_WIFI_STA_CONNECTED:
      Serial.printf("\nConnected to Wi-Fi!\n");
      digitalWrite(wifiLed, true);
      break;
  }
}

void write_callback(Device *device, Param *param, const param_val_t val, void *priv_data, write_ctx_t *ctx)
// Code to handle changes in switch states and update relay states accordingly
{
  const char *device_name = device->getDeviceName();
  const char *param_name = param->getParamName();
  if (strcmp(device_name, deviceName_1) == 0) {
    Serial.printf("Lightbulb = %s\n", val.val.b ? "true" : "false");
    if (strcmp(param_name, "Power") == 0) {
      Serial.printf("Received value = %s for %s - %s\n", val.val.b ? "true" : "false", device_name, param_name);
      toggleState_1 = val.val.b;
      (toggleState_1 == false) ? digitalWrite(RelayPin1, HIGH) : digitalWrite(RelayPin1, LOW);
      param->updateAndReport(val);
    }
  } else if (strcmp(device_name, deviceName_2) == 0) {
    Serial.printf("Switch value = %s\n", val.val.b ? "true" : "false");
    if (strcmp(param_name, "Power") == 0) {
      Serial.printf("Received value = %s for %s - %s\n", val.val.b ? "true" : "false", device_name, param_name);
      toggleState_2 = val.val.b;
      (toggleState_2 == false) ? digitalWrite(RelayPin2, HIGH) : digitalWrite(RelayPin2, LOW);
      param->updateAndReport(val);
    }
  } else if (strcmp(device_name, deviceName_3) == 0) {
    Serial.printf("Switch value = %s\n", val.val.b ? "true" : "false");
    if (strcmp(param_name, "Power") == 0) {

Serial.printf("Received value = %s for %s - %s\n", val.val.b ? "true" : "false", device_name, param_name);
      toggleState_3 = val.val.b;
      (toggleState_3 == false) ? digitalWrite(RelayPin3, HIGH) : digitalWrite(RelayPin3, LOW);
      param->updateAndReport(val);
    }
  } else if (strcmp(device_name, deviceName_4) == 0) {
    Serial.printf("Switch value = %s\n", val.val.b ? "true" : "false");
    if (strcmp(param_name, "Power") == 0) {
      Serial.printf("Received value = %s for %s - %s\n", val.val.b ? "true" : "false", device_name, param_name);
      toggleState_4 = val.val.b;
      (toggleState_4 == false) ? digitalWrite(RelayPin4, HIGH) : digitalWrite(RelayPin4, LOW);
      param->updateAndReport(val);
    }
  }
}
// Function to read sensor data
void readSensor() {
  // Read and process data from DHT22 and LDR sensors
  ldrVal = map(analogRead(LDR_PIN), 400, 4200, 0, 100);
  Serial.print("LDR - "); Serial.println(ldrVal);

  float h = dht.readHumidity();
  float t = dht.readTemperature(); // or dht.readTemperature(true) for Fahrenheit
  if (isnan(h) || isnan(t)) {
    Serial.println("Failed to read from DHT sensor!");
    return;
  }
  else {
    humidity1 = h;
    temperature1 = t;
    Serial.print("Temperature - "); Serial.println(t);
    Serial.print("Humidity - "); Serial.println(h);
  }
}
// Function to send sensor data to ESP-RainMaker
void sendSensor()
{
  // Read sensor data and update ESP-RainMaker parameters
  readSensor();
  temperature.updateAndReportParam("Temperature", temperature1);
  humidity.updateAndReportParam("Temperature", humidity1);
  ldr.updateAndReportParam("Temperature", ldrVal);
}
// Function to handle manual control of switches
void manual_control()
{
  // Check the state of physical switches and update the system state
  if (digitalRead(SwitchPin1) == LOW && SwitchState_1 == LOW) {
    digitalWrite(RelayPin1, LOW);
    toggleState_1 = 1;
    SwitchState_1 = HIGH;
    my_switch1.updateAndReportParam(ESP_RMAKER_DEF_POWER_NAME, toggleState_1);
    Serial.println("Switch-1 on");
  }
  if (digitalRead(SwitchPin1) == HIGH && SwitchState_1 == HIGH) {
    digitalWrite(RelayPin1, HIGH);
    toggleState_1 = 0;
    SwitchState_1 = LOW;
    my_switch1.updateAndReportParam(ESP_RMAKER_DEF_POWER_NAME, toggleState_1);
    Serial.println("Switch-1 off");
  }
  if (digitalRead(SwitchPin2) == LOW && SwitchState_2 == LOW) {
    digitalWrite(RelayPin2, LOW);
    toggleState_2 = 1;
    SwitchState_2 = HIGH;
    my_switch2.updateAndReportParam(ESP_RMAKER_DEF_POWER_NAME, toggleState_2);
    Serial.println("Switch-2 on");
  }
  if (digitalRead(SwitchPin2) == HIGH && SwitchState_2 == HIGH) {
    digitalWrite(RelayPin2, HIGH);
    toggleState_2 = 0;
    SwitchState_2 = LOW;
    my_switch2.updateAndReportParam(ESP_RMAKER_DEF_POWER_NAME, toggleState_2);
    Serial.println("Switch-2 off");
  }
  if (digitalRead(SwitchPin3) == LOW && SwitchState_3 == LOW) {
    digitalWrite(RelayPin3, LOW);
    toggleState_3 = 1;
    SwitchState_3 = HIGH;
    my_switch3.updateAndReportParam(ESP_RMAKER_DEF_POWER_NAME, toggleState_3);
    Serial.println("Switch-3 on");
  }
  if (digitalRead(SwitchPin3) == HIGH && SwitchState_3 == HIGH) {
    digitalWrite(RelayPin3, HIGH);
    toggleState_3 = 0;
    SwitchState_3 = LOW;
    my_switch3.updateAndReportParam(ESP_RMAKER_DEF_POWER_NAME, toggleState_3);
    Serial.println("Switch-3 off");
  }
  if (digitalRead(SwitchPin4) == LOW && SwitchState_4 == LOW) {
    digitalWrite(RelayPin4, LOW);
    toggleState_4 = 1;
    SwitchState_4 = HIGH;
    my_switch4.updateAndReportParam(ESP_RMAKER_DEF_POWER_NAME, toggleState_4);
    Serial.println("Switch-4 on");
  }
  if (digitalRead(SwitchPin4) == HIGH && SwitchState_4 == HIGH) {
    digitalWrite(RelayPin4, HIGH);
    toggleState_4 = 0;
    SwitchState_4 = LOW;
    my_switch4.updateAndReportParam(ESP_RMAKER_DEF_POWER_NAME, toggleState_4);
    Serial.println("Switch-4 off");
  }
}
// Setup function - initializes the system
// Initialize LCD, Serial communication, GPIOs, ESP-RainMaker node, devices, and sensors
// Configure WiFi provisioning
void setup()
{
  // Initialize the LCD and turn on the backlight
  lcd.init();
  lcd.backlight();
  // Start the serial communication
  Serial.begin(115200);
  // Set the Relays GPIOs as output mode
  pinMode(RelayPin1, OUTPUT);
  pinMode(RelayPin2, OUTPUT);
  pinMode(RelayPin3, OUTPUT);
  pinMode(RelayPin4, OUTPUT);
  pinMode(wifiLed, OUTPUT);
  // Configure the input GPIOs
  pinMode(SwitchPin1, INPUT_PULLUP);
  pinMode(SwitchPin2, INPUT_PULLUP);
  pinMode(SwitchPin3, INPUT_PULLUP);
  pinMode(SwitchPin4, INPUT_PULLUP);
  pinMode(gpio_reset, INPUT);
// Write to the GPIOs the default state on booting
  digitalWrite(RelayPin1, !toggleState_1);
  digitalWrite(RelayPin2, !toggleState_2);
  digitalWrite(RelayPin3, !toggleState_3);
  digitalWrite(RelayPin4, !toggleState_4);
  digitalWrite(wifiLed, LOW);
  dht.begin();    // Enabling DHT sensor
  Node my_node;
  my_node = RMaker.initNode(nodeName);
  //Standard switch device
  my_switch1.addCb(write_callback);
  my_switch2.addCb(write_callback);
  my_switch3.addCb(write_callback);
  my_switch4.addCb(write_callback);
  //Add switch device to the node
  my_node.addDevice(my_switch1);
  my_node.addDevice(my_switch2);
  my_node.addDevice(my_switch3);
  my_node.addDevice(my_switch4);
  my_node.addDevice(temperature);
  my_node.addDevice(humidity);
  my_node.addDevice(ldr);
  Timer.setInterval(30000);
  //This is optional
  RMaker.enableOTA(OTA_USING_PARAMS);
  //If you want to enable scheduling, set time zone for your region using setTimeZone().
  //The list of available values are provided here https://rainmaker.espressif.com/docs/time-service.html
  // RMaker.setTimeZone("Asia/Shanghai");
  // Alternatively, enable the Timezone service and let the phone apps set the appropriate timezone
  RMaker.enableTZService();
  RMaker.enableSchedule();
  //Service Name
  for (int i = 0; i < 17; i = i + 8) {
    espChipId |= ((ESP.getEfuseMac() >> (40 - i)) & 0xff) << i;
  }
  Serial.printf("\nChip ID:  %d Service Name: %s\n", espChipId, service_name);
  Serial.printf("\nStarting ESP-RainMaker\n");
  RMaker.start();
  WiFi.onEvent(sysProvEvent);
#if CONFIG_IDF_TARGET_ESP32
  WiFiProv.beginProvision(WIFI_PROV_SCHEME_BLE, WIFI_PROV_SCHEME_HANDLER_FREE_BTDM, WIFI_PROV_SECURITY_1, pop, service_name);
#else
  WiFiProv.beginProvision(WIFI_PROV_SCHEME_SOFTAP, WIFI_PROV_SCHEME_HANDLER_NONE, WIFI_PROV_SECURITY_1, pop, service_name);
#endif
  my_switch1.updateAndReportParam(ESP_RMAKER_DEF_POWER_NAME, false);
  my_switch2.updateAndReportParam(ESP_RMAKER_DEF_POWER_NAME, false);
  my_switch3.updateAndReportParam(ESP_RMAKER_DEF_POWER_NAME, false);
  my_switch4.updateAndReportParam(ESP_RMAKER_DEF_POWER_NAME, false);
}
// Main loop - runs repeatedly
void loop() {
  // Handle reset button, WiFi status, manual control, sensor readings, and display updates
  // Read GPIO0 (external button to reset device)
  if (digitalRead(gpio_reset) == LOW) { // Push button pressed
    Serial.printf("Reset Button Pressed!\n");
    // Key debounce handling
    delay(100);
    int startTime = millis();
    while (digitalRead(gpio_reset) == LOW) delay(50);
    int endTime = millis();
    if ((endTime - startTime) > 10000) {
      // If key pressed for more than 10secs, reset all
      Serial.printf("Reset to factory.\n");
      RMakerFactoryReset(2);
    } else if ((endTime - startTime) > 3000) {
      Serial.printf("Reset Wi-Fi.\n");
      // If key pressed for more than 3secs, but less than 10, reset Wi-Fi
      RMakerWiFiReset(2);
    }
  }
  // Check Wi-Fi connection status and update the LED accordingly
  if (WiFi.status() != WL_CONNECTED) {
    digitalWrite(wifiLed, false);
  } else {
    digitalWrite(wifiLed, true);
    if (Timer.isReady()) {
      sendSensor();
      Timer.reset(); // Reset the timer
    }
  }
  // Perform manual control of the switches
  manual_control();

  // Read humidity and temperature values
  float humidity = dht.readHumidity();
  float temperature = dht.readTemperature();

  // Check if any reads failed and exit early (to try again)
  if (isnan(humidity) || isnan(temperature)) {
    Serial.println("Failed to read from DHT sensor!");
  } else {
    // Logic to turn off the light if temperature exceeds 30 degrees Celsius and alert hasn't been sent
    if (temperature > 30.0 && !highTempAlertSent) {
      Serial.println("High temperature detected. Turning off the light.");
      digitalWrite(RelayPin1, HIGH); // Assuming RelayPin1 controls the light
      toggleState_1 = false; // Update the toggle state
      my_switch1.updateAndReportParam(ESP_RMAKER_DEF_POWER_NAME, toggleState_1); // Update the state in RainMaker
      esp_rmaker_raise_alert("Warning Alert!! High Temperature!! Temperature exceed 30"); // Send an alert
      highTempAlertSent = true; // Set the flag to prevent further alerts
    } else if (temperature <= 30.0) {
      highTempAlertSent = false; // Reset the flag if the temperature goes back below 30
    }
   // Update the display with the new temperature and humidity values
    lcd.setCursor(0, 0); // First line of the LCD
    lcd.print("Temp: ");
    lcd.print(temperature, 1); // One decimal place for temperature
    lcd.write(223); // Degree symbol
    lcd.print("C");

    lcd.setCursor(0, 1); // Second line of the LCD
    lcd.print("Humidity: ");
    lcd.print(humidity, 1); // One decimal place for humidity
    lcd.print("%");
  }
  delay(2000); // Wait for 2 seconds
}
