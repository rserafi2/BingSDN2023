#include <stdint.h>
#include <SPI.h>

#define ROUTING_TABLE_SIZE 32
#define MAX_ROUTERS 8

struct routingTableEntry
{
  long IPSrc;
  long IPDest;
  long mask;
  _Bool accessBit;
  uint8_t portNum;
};

struct router
{
  uint8_t id;
  struct routingTableEntry routingTable[ROUTING_TABLE_SIZE]; //Can be a linked list later on
};

enum Program_State {STARTUP,WAIT,PING_SPI,READ_SPI,CHECK_SPI_COMMAND,READ_SERIAL,SET_ACCESS,DISPLAY_TABLE,NEW_IP,NEW_ROUTER,WRITE_TABLE};
char charCommand[128]; // for incoming serial data
String command;
char *token;
const char *delimiter = " ";
struct router routerList[MAX_ROUTERS];

void setup() {
  pinMode(10, OUTPUT); 
  Serial.begin(9600); // opens serial port, sets data rate to 9600 bps
}

void loop() {
  static enum Program_State state = WAIT;
  //digitalWrite(10, portUsed);
  switch(state){
    default:
    case STARTUP:
      //state = WAIT;
    break;
    case WAIT:
      if (Serial.available() > 0){
        state = READ_SERIAL;
      }
      else if
        //waiting counter reaches WAIT_TIME, go to PING_SPI
      else
        //check wait again
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
      //check opcode of SPI message
      if(//opcode is 0, go to ROUTER_STARTUP)
      else if(//opcode is 1, go to NEW_IP)
      else (//there must have been an error and go back to wait. Write to serial saying there was an error)
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
        state = DISPLAY_TABLE;
      }
      else{
        Serial.println("Unknown Command");
        //Serial.println("WAIT STATE");
        state = WAIT;
      }
    break;
    case SET_ACCESS:
      //TODO: write to table entry with ip matching and set access bit
    break;
    case DISPLAY_TABLE:
      //TODO: write the entire routing table to the serial port
    break;
    case NEW_IP:
      //TODO: read in table entry info into registers and save it all in a routingTableEntry and add to routingTable
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
