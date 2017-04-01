int incoming = 0;
int bulb = 12;
int tubelight = 11;
int fan = 10;
int television = 9;
int ac = 8;
int projector = 7;
int laptop = 6;
int cellphone = 5;
 
void setup() {
	Serial.begin(9600);
	pinMode(bulb, OUTPUT);
	pinMode(tubelight, OUTPUT);
	pinMode(fan, OUTPUT);
	pinMode(television, OUTPUT);
	pinMode(ac, OUTPUT);
	pinMode(projector, OUTPUT);
	pinMode(laptop, OUTPUT);
	pinMode(cellphone, OUTPUT);
}
 
void loop() {
	if (Serial.available() > 0) {
		incoming = Serial.read();
                Serial.write("done");
		if(incoming == 49) {
			if(digitalRead(bulb) == LOW)
 				digitalWrite(bulb, HIGH);
 			else
 				digitalWrite(bulb, LOW);
		}
		else if(incoming == 50) { 
 			if(digitalRead(tubelight) == LOW)  
 				digitalWrite(tubelight, HIGH);
 			else
 				digitalWrite(tubelight, LOW);
		}
		else if(incoming == 51) { 
 			if(digitalRead(fan) == LOW)  
 				digitalWrite(fan, HIGH);
 			else
 				digitalWrite(fan, LOW);
		}
		else if(incoming == 52) { 
 			if(digitalRead(television) == LOW)
 				digitalWrite(television, HIGH);
 			else
 				digitalWrite(television, LOW);
		}
		else if(incoming == 53) { 
 			if(digitalRead(ac) == LOW)  
 				digitalWrite(ac, HIGH);
 			else
 				digitalWrite(ac, LOW);
		}
		else if(incoming == 54) { 
 			if(digitalRead(projector) == LOW)  
 				digitalWrite(projector, HIGH);
 			else
 				digitalWrite(projector, LOW);
		}
		else if(incoming == 55) { 
 			if(digitalRead(laptop) == LOW)  
 				digitalWrite(laptop, HIGH);
 			else
 				digitalWrite(laptop, LOW);
		}
		else if(incoming == 56) { 
 			if(digitalRead(cellphone) == LOW)  
 				digitalWrite(cellphone, HIGH);
 			else
 				digitalWrite(cellphone, LOW);
		}
                //Serial.write("done");
	}
}
