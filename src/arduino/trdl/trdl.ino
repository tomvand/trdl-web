#include "trdl_add.hpp"


void setup() {
  Serial.begin(115200);
}

void loop() {
  Serial.println(trdl_add(1, 1));
  delay(2000);
}
