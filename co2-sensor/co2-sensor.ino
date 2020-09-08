#include <SoftwareSerial.h>

#define SERIAL_RATE 19200

SoftwareSerial co2_serial(6, 7);

// CO2 sensor data structures:
byte cmd[9] = {0xFF,0x01,0x86,0x00,0x00,0x00,0x00,0x00,0x79}; 
unsigned char co2_resp[9];
byte crc = 0;
unsigned int ppm = 0;

bool led_state = false;
byte led_pins[4] = {14, 15, 16, 17};

void setup() {
  Serial.begin(SERIAL_RATE);
  while(!Serial);
  co2_serial.begin(9600);

  for (byte i = 0; i < sizeof(led_pins); i ++) pinMode(led_pins[i], OUTPUT);
  digitalWrite(led_pins[0], HIGH);
}

void loop() {
  co2_serial.write(cmd, 9);
  memset(co2_resp, 0, 9);
  co2_serial.readBytes(co2_resp, 9);

  bool valid = validate_co2_resp();

  if (valid) {
    ppm = (256 * (unsigned int) co2_resp[2]) + (unsigned int) co2_resp[3];

    if (ppm > 300 && ppm < 4900) {
      Serial.println("CO2: " + String(ppm) + message(ppm));
      set_pin_state(ppm);
    } else {
      Serial.println("CO2: " + String(ppm) + " Error");
      led_state = !led_state;
      digitalWrite(led_pins[2], led_state);
    }
  } else {
    led_state = !led_state;
    digitalWrite(led_pins[3], led_state);
    Serial.println("CRC error: " + String(crc) + "/"+ String(co2_resp[8]));
  }

  delay(1000);
}

bool validate_co2_resp() {
  crc = 0;
  for (int i = 1; i < 8; i++) {
    crc += co2_resp[i];
  }

  crc = 256 - crc;
  return co2_resp[0] == 0xFF && co2_resp[1] == 0x86 && co2_resp[8] == crc;
}

String message(unsigned int ppm) {
  if (ppm < 450) return " Very good";
  if (ppm < 600) return " Good";
  if (ppm < 1000) return " Acceptable";
  if (ppm < 2500) return " Bad";
  return " Health risk";
}

void set_pin_state(unsigned int ppm) {
  for (byte i = 0; i < sizeof(led_pins); i ++) {
    digitalWrite(led_pins[i], LOW);
  }

  byte offset = 0;

  if (ppm > 450) offset = 1;
  if (ppm > 600) offset = 2;
  if (ppm > 1000) offset = 3;
  if (ppm > 2500) led_state = !led_state;
  else led_state = HIGH;

  digitalWrite(led_pins[offset], led_state);
}
