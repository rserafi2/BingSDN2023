#include <stdint.h>
#include <SPI.h>

#define ROUTING_TABLE_SIZE 32
#define MAX_ROUTERS 8

struct RoutingTableEntry{
  long MACDes;
  long MACSrc;
  long IPDest;
  long IPSrc;
  uint8_t PortNum;
  _Bool SecBit;
  _Bool Valid;
};

struct router
{
  uint8_t id;
  struct routingTableEntry routingTable[ROUTING_TABLE_SIZE]; 
};

enum Program_State {STARTUP,WAIT,PING_SPI,READ_SPI,CHECK_SPI_COMMAND,READ_SERIAL,SET_ACCESS,DISPLAY_TABLE_ENTRY,WRITE_SERIAL,NEW_IP,NEW_ROUTER,WRITE_TABLE};
char charCommand[128]; 
String command;
char *token;
const char *delimiter = " ";
struct router routerList[MAX_ROUTERS];

void setup() {
  pinMode(10, OUTPUT); 
  Serial.begin(9600); // opens serial port, sets data rate to 9600 bps

void loop() {
  static enum Program_State state = WAIT;
  //digitalWrite(10, portUsed);
  switch(state){
    default:
      
  case STARTUP:
    for (int i = 0; i < MAX_ROUTERS; i++){
      for int j = 0; j < ROUTING_TABLE_SIZE; j++){
        routerList[i].routingTable[j].MACDest = 0;
        routerList[i].routingTable[j].MACSrc = 0;
        routerList[i].routingTable[j].IPDest = 0;
        routerList[i].routingTable[j].IPSrc = 0;
        routerList[i].routingTable[j].PortNum = 0;
        routerList[i].routingTable[j].SecBit = 0;
        routerList[i].routingTable[j].Valid = 0;
      }
    }
    state = WAIT;
    break;
      
    case WAIT:
    if (Serial.available() > 0){
      state = READ_SERIAL;
    }
    else if (Serial.available() = 0 && Wait_Counter != ){
      state = WAIT;
    }
    else if (Wait_Counter = ){
      state = PING_SPI;
    }
    else {
      state = WAIT;
    }
    break;
      
    case PING_SPI:
      //send a blank message over to check if ARTY has sent a message
      //if there is a message move to read SPI and finish reading message
      //if no message return to wait
    break;
      
    case READ_SPI:
      //save SPI bytes in buffer until end of message
      //go to check SPI command
    break;
      
    case CHECK_SPI_COMMAND:
    if (OpCode = 0){
      state = NEW_IP;
    }
    else if (OpCode = 1){
      state = NEW_ROUTER;
    }
    else{
      state = WAIT;
    }
    break;
        
    case READ_SERIAL:
      command = Serial.readString();
      command.toCharArray(charCommand,128);
      token = strtok(charCommand,delimiter);
      Serial.println(token);
      if(String(token).equals("a")){
        token = strtok(NULL,delimiter);
        Serial.println(token);
        while(token != NULL){
          portUsed = String(token).toInt();
          token = strtok(NULL,delimiter);
        }
        state = SET_ACCESS;
      }
      else if(String(token).equals("b")){
        token = strtok(NULL,delimiter);
        Serial.println(token);
        while(token != NULL){
          portUsed = String(token).toInt();
          token = strtok(NULL,delimiter);
        }
        state = DISPLAY_TABLE_ENTRY;
      }
      else{
        Serial.println("Unknown Command");
        //Serial.println("WAIT STATE");
        state = WAIT;
      }
    break;
      
    case SET_ACCESS:
    for (RID = ){
      for (int j = 0; j < ROUTING_TABLE_SIZE; j++){
        for (routerList[RID].routingTable[j].MACSrc = MACSrc && routerList[RID].routingTable[j].MACDest = MACDest){
          for (routerList[RID].routingTable[j].IPSrc = IPSrc && routerList[RID].routingTable[j].IPDest = IPDest){
            routerList[RID].routingTable[j].SecBit = SecBit;
          }
        }
      }
      state = WRITE_TABLE;
    }
    break;
                       
    case DISPLAY_TABLE_ENTRY:
      Serial.print("Display Table Entry At Specified Index");
      Serial.print(routerList[j].routingTable[i].MacDest);
      Serial.print(" , ");
      Serial.print(routerList[j].routingTable[i].MacSrc);
      Serial.print(" , ");
      Serial.print(routerList[j].routingTable[i].IPDest);
      Serial.print(" , ");
      Serial.print(routerList[j].routingTable[i].IPSrc);
      Serial.print(" , ");
      Serial.print(routerList[j].routingTable[i].PortNum);
      Serial.print(" , ");
      Serial.print(routerList[j].routingTable[i].SecBit);
      Serial.print(" , ");
      Serial.println(routerList[j].routingTable[i].Valid);
      state = WRITE_SERIAL;
    break;
                    
    case WRITE_SERIAL:
    Serial.println("Printing Routing Table to Serial Terminal");
    for (int j = 0; j < MAX_ROUTERS; j++){
      for ( int i = 0; i < ROUTING_TABLE_SIZE; i++){
        Serial.print(routerList[j].routingTable[i].MacDest);
        Serial.print(" , ");
        Serial.print(routerList[j].routingTable[i].MacSrc);
        Serial.print(" , ");
        Serial.print(routerList[j].routingTable[i].IPDest);
        Serial.print(" , ");
        Serial.print(routerList[j].routingTable[i].IPSrc);
        Serial.print(" , ");
        Serial.print(routerList[j].routingTable[i].PortNum);
        Serial.print(" , ");
        Serial.print(routerList[j].routingTable[i].SecBit);
        Serial.print(" , ");
        Serial.println(routerList[j].routingTable[i].Valid);
      }
    }
    state = WAIT;
    break;
                       
    case NEW_IP:
      state = WRITE_TABLE;
    break;
                       
    case NEW_ROUTER:
      //TODO: reads in router ID of 0, assignes new router ID to router, sends back a blank routing table
    break;
                       
    case WRITE_TABLE:
      //TODO: writes over table in controller and then sends out table info to router
    break;
  }

  
//  if (Serial.available() > 0) {
//    // read the incoming byte:
//    command = Serial.readString();
//    command.toCharArray(charCommand,128);
//    token = strtok(charCommand,delimiter);
//    if(String(token).equals("hello")){
//      while(token != NULL){
//        Serial.println(token);
//        token = strtok(NULL,delimiter);
//      }
//    }
//    else{
//      Serial.println("cmon be polite");
//    }
//  }
}
