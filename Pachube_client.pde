#include <SPI.h>
#include <Ethernet.h>
#include <EthernetDHCP.h>
#include <avr/io.h>
#include <avr/wdt.h>
#include <string.h>
#include <TrueRandom.h>


#define ID             1    //incase you have more than 1 unit on same network, just change the unit ID to other number
#define REMOTEFEED     8281 //remote feed number here, this has to be your own feed
#define LOCALFEED      8281 //local feed number here
#define APIKEY         "YOURKEY" // replace your pachube api key here

byte mac[6];
//byte mac[] = { 0xDA, 0xAD, 0xCA, 0xEF, 0xFE,  byte(ID) };

byte server [] = {  //www.pachube.com
  173, 203, 98, 29
};

boolean ipAcquired = false;
boolean connectedd = false;
boolean reading = false;
#define REMOTE_FEED_DATASTREAMS    27 //define how many of maximun data from remote feed
float remoteSensor[REMOTE_FEED_DATASTREAMS];   
char pachube_data[80];
char buff[64];
char *found;
int pointer = 0;
boolean found_status_200 = false;
boolean found_session_id = false;
boolean found_CSV = false;
boolean found_content = false;
int content_length;
int successes = 0;
int failures = 0;
int counter = 0;
Client client(server, 80);

//timer variables
long previousWdtMillis = 0;
long wdtInterval = 0;
long previousEthernetMillis = 0;
long ethernetInterval = 0;

// variable to store local sensors
int analog0 = 0;
int analog2 = 0;
int analog3 = 0;

//define analog pins for sensors
int analogPin0 = 0;    
int analogPin2 = 2;
int analogPin3 = 5;

//digital out
int resetPin = 9; //reset pin to manually reset the ethernet shield

// variable to store the value coming from the sensor
int remote1 = 0; 
int remote2 = 0;
int remote3 = 0;

void setup(){
  MCUSR=0;
  wdt_enable(WDTO_8S); // setup Watch Dog Timer to 8 sec
  pinMode(resetPin,OUTPUT);
  Serial.begin(9600);
  Serial.println("restarted");
  TrueRandom.mac(mac);
}

void loop(){
  // Watch Dog Timer will reset the arduino if it doesn't get "wdt_reset();" every 8 sec
  if ((millis() - previousWdtMillis) > wdtInterval) {
    previousWdtMillis = millis();
    wdtInterval = 5000;
    wdt_reset();
    Serial.println("wdt reset");
  }

  //main function is here, at the moment it will only connect to pachube every 10 sec
  if ((millis() - previousEthernetMillis) > ethernetInterval) {
    previousEthernetMillis = millis();
    ethernetInterval = 5000; //5 sec
    wdt_reset();
    Serial.println("wdt reset");
    updateLocalSensor();
    useEthernet();    
  }


  while (reading){ 
    while (client.available()) {
      checkForResponse(); 
    } 
  }
}

































