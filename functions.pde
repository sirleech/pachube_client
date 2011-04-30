void updateLocalSensor(){ 
  
  //define the local sensors here
  analog1 = analogRead(analogPin1);
  analog2 = analogRead(analogPin2);
  analog3 = analogRead(analogPin3);  
 
}

void useEthernet(){
  // we have to maually reset the shield before using it
  digitalWrite(resetPin,LOW); // put reset pin to low ==> reset the ethernet shield
  delay(200);
  digitalWrite(resetPin,HIGH); // set it back to high
  delay(2000);                 


  wdt_reset();
  Serial.println("wdt reset");
  Serial.println("getting ip...");
  int result = EthernetDHCP.begin(mac); 
  wdt_reset();
  Serial.println("wdt reset");
  Serial.println("got result...");
  Serial.println(result);


  if(result == 1){
    ipAcquired = true;
    Serial.println("ip acquired...");
  }

  if (client.connect()) {

    Serial.println("connected");
    int content_length = length(analog1) + length(analog2) + length(analog3) + 2 ; 
    //this line is to count the lenght of the content = lenght of each local sensor data + ","
    //in this case we have 3 data so we will need 2 commas 

    client.print("GET /api/feeds/");
    client.print(REMOTEFEED);
    client.println(".csv HTTP/1.1");
    client.println("Host: www.pachube.com");
    client.print("X-PachubeApiKey: ");
    client.println(APIKEY);
    client.println("User-Agent: Arduino (Natural Fuse v`1.1)");
    client.println();

    client.print("PUT /api/feeds/");
    client.print(LOCALFEED);
    client.println(".csv HTTP/1.1");
    client.println("Host: www.pachube.com");
    client.print("X-PachubeApiKey: ");
    client.println(APIKEY);

    client.println("User-Agent: Arduino (Natural Fuse v1.1)");
    client.print("Content-Type: text/csv\nContent-Length: ");
    client.println(content_length);
    client.println("Connection: close");
    client.println();

    client.print(analog1); //modify local sensors here
    client.print(",");
    client.print(analog2);
    client.print(",");
    client.print(successes);
    Serial.println("data send");    
    client.println();

    connectedd = true;
    reading = true;

    successes++;
  } 
  if(ipAcquired){
    if (!client.connected()) {
      Serial.println("but client not connected");

      Serial.println();
      Serial.println("disconnecting.");

      client.stop();
      connectedd = false;
      ipAcquired = false;
      reading = false;
      counter ++;

    }
  }
}




int length(int in){ // this function is to calculate the lenght of each data
  int r;
  if (in > 9999) r = 5;
  else if (in > 999) r = 4;
  else if (in > 99) r = 3;
  else if (in > 9) r = 2;
  else r = 1;
  return r;
}

void checkForResponse(){  

  char c = client.read();

  Serial.print(c);

  buff[pointer] = c;
  if (pointer < 64) pointer++;
  if (c == '\n') {
    found = strstr(buff, "200 OK");
    if (found != 0){
      found_status_200 = true; 
      Serial.print("Found 200");
    }
    buff[pointer]=0;
    found_content = true;
    clean_buffer();    
  }

  if ((found_session_id) && (!found_CSV)){
    found = strstr(buff, "HTTP/1.1");
    if (found != 0){
      char csvLine[strlen(buff)-9];
      strncpy (csvLine,buff,strlen(buff)-9);


      Serial.println("\n--- updated: ");
      Serial.println(pachube_data);
      Serial.println("\n--- retrieved: ");
      char delims[] = ",";
      char *result = NULL;
      char * ptr;
      result = strtok_r( buff, delims, &ptr );
      int counter = 0;
      while( result != NULL ) {
        remoteSensor[counter++] = atof(result); 
        result = strtok_r( NULL, delims, &ptr );
      }  
      for (int i = 0; i < REMOTE_FEED_DATASTREAMS; i++){
        Serial.print("\t");
        
        remote1 = remoteSensor[0]; // define which ID from the remote feed that you want to use
        remote2 = remoteSensor[1]; 
        remote3 = remoteSensor[2];
        
        Serial.println();
        Serial.print("remote1 =");
        Serial.println(remote1);
        Serial.print("remote2 =");
        Serial.println(remote2);
        Serial.print("remote3 =");
        Serial.println(remote3);

      }

      found_CSV = true;

      Serial.print("\nsuccessful updates=");
      Serial.println(successes);

      found_status_200 = false;
      found_session_id = false;
      found_CSV = false;
      found_content = false;
      client.stop();
      stopEthernet();

    }
  }

  if (found_status_200){
    found = strstr(buff, "Vary:");
    if (found != 0){
      clean_buffer();
      found_session_id = true; 
      Serial.println("found Vary:");
    }
  }
}
void clean_buffer() {
  pointer = 0;
  memset(buff,0,sizeof(buff)); 
}


void stopEthernet(){

  Serial.println("disconnecting.");

  client.stop();
  connectedd = false;
  ipAcquired = false;
  reading = false;
  counter ++;
  
  ipAcquired = false;
  connectedd = false;
  reading = false;
  pointer = 0;
  content_length;
  counter = 1;

}



