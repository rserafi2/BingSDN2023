#include <stdint.h>
#include <SPI.h>

#define ROUTING_TABLE_SIZE 32
#define MAX_ROUTERS 1
#define WAIT_TIME 100

struct routingTableEntry{
  uint64_t MACDes;
  uint64_t MACSrc;
  uint32_t IPDest;
  uint32_t IPSrc;
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
uint8_t spiByte =0;
uint8_t waitCount = 0;
uint8_t tableIndex = 0;
uint8_t securityBit = 0;
struct routingTableEntry tempTableEntry;

uint8_t SPIbyte(uint8_t message){
    digitalWrite(SS, LOW); // enable Slave Select
    uint8_t received = (SPI.transfer(message));
    digitalWrite(SS, HIGH); // disable Slave Select
    delay(10);
    return received;
}

void setup() {
  pinMode(10, OUTPUT); 
  Serial.begin(9600); // opens serial port, sets data rate to 9600 bps
  delay(1000);
  Serial.begin(115200); // set baud rate to 115200 for usart
  SPI.begin();
  SPI.beginTransaction(SPISettings(4000000, MSBFIRST, SPI_MODE3));
  SPI.setClockDivider(SPI_CLOCK_DIV4);
  Serial.println("Hello I'm SPI Mega_Master");
  delay(1000);
};

static enum Program_State state = STARTUP;

void loop() {
  
  switch(state){
  default:
      
  case STARTUP:
  //Serial.println("STATE = STARTUP");
    for (int i = 0; i < MAX_ROUTERS; i++){
      for( int j = 0; j < ROUTING_TABLE_SIZE; j++){
        routerList[i].routingTable[j].MACDes = 0;
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
    //Serial.println("STATE = WAIT");
    if (Serial.available() > 0){
      waitCount = 0;
      state = READ_SERIAL;
    }
    else if (Serial.available() == 0 && waitCount == WAIT_TIME){
      waitCount = 0;
      state = PING_SPI;
    }
    else{
      waitCount++;
      state = WAIT;
    }
    break;
    
    case PING_SPI:
    //Serial.println("STATE = PING_SPI");
      //send a blank message over to check if ARTY has sent a message
      //if there is a message move to read SPI and finish reading message
      //if no message return to wait
      spiByte = SPIbyte(0);
      //Serial.println(spiByte);
      if  (spiByte == 0){
        state = WAIT;
      }
      else{
        state = READ_SPI;
      }
    break;
    /*  
    case READ_SPI:
      //save SPI bytes in buffer until end of message
      //go to check SPI command
    break;
      
    case CHECK_SPI_COMMAND:
    if (OpCode == 0){
      state = NEW_IP;
    }
    else if (OpCode == 1){
      state = NEW_ROUTER;
    }
    else{
      state = WAIT;
    }
    break;
    */    
    case READ_SERIAL:
    Serial.println("STATE = READ_SERIAL");
      command = Serial.readString();
      command.toCharArray(charCommand,128);
      token = strtok(charCommand,delimiter);
      //Serial.println(token);
      if(String(token).equals("ReadTableEntry")){
        state = DISPLAY_TABLE_ENTRY;
      }
      else if(String(token).equals("SetSecurityBit")){
        state = SET_ACCESS;
      }
      else{
        Serial.println("Unknown Command");
        //Serial.println("WAIT STATE");
        state = WAIT;
      }
    break;
      
    case SET_ACCESS:
    Serial.println("STATE = SET_ACCESS");
    tableIndex = (uint8_t)atoi(strtok(NULL,delimiter));
    securityBit = (uint8_t)atoi(strtok(NULL,delimiter));
    routerList[0].routingTable[tableIndex].SecBit = securityBit;
    state = WRITE_TABLE;
      
//    for (id = ){
//      for (int j = 0; j < ROUTING_TABLE_SIZE; j++){
//        for (routerList[id].routingTable[j].MACSrc = MACSrc && routerList[id].routingTable[j].MACDest = MACDest){
//          for (routerList[id].routingTable[j].IPSrc = IPSrc && routerList[id].routingTable[j].IPDest = IPDest){
//            routerList[id].routingTable[j].SecBit = SecBit;
//          }
//        }
//      }
//      state = WRITE_TABLE;
//    }
    break;
                       
    case DISPLAY_TABLE_ENTRY:
      Serial.println("STATE = DISPLAY_TABLE_ENTRY");
      tableIndex = (uint8_t)atoi(strtok(NULL,delimiter));
      //Serial.println(tableIndex);
      Serial.println(SPIbyte(0x01));
      Serial.println(SPIbyte(tableIndex));
      for(int i=0; i<21; i++){
        Serial.println(SPIbyte(0x55),HEX);
      }
      /*
      Serial.println("Display Table Entry At Specified Index");
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
      Serial.println(routerList[j].routingTable[i].Valid);*/
      state = WRITE_SERIAL;
    break;
                    
    case WRITE_SERIAL:
    Serial.println("STATE = WRITE_SERIAL");
    /*Serial.println("Printing Routing Table to Serial Terminal");
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
    }*/
    state = WAIT;
    break;
                       
    case NEW_IP:
      Serial.println("STATE = NEW_IP");
      state = WRITE_TABLE;
    break;
                       
    case NEW_ROUTER:
      Serial.println("STATE = NEW_ROUTER");
      //TODO: reads in router ID of 0, assignes new router ID to router, sends back a blank routing table
      state = WAIT;
    break;
                       
    case WRITE_TABLE:
      Serial.println("STATE = WRITE_TABLE");
      //TODO: writes over table in controller and then sends out table info to router
      Serial.println(SPIbyte(0x02));
      Serial.println(SPIbyte(tableIndex));
      Serial.println(SPIbyte(0x0f&((routerList[0].routingTable[tableIndex].PortNum&0x03)<<2)|
                    ((routerList[0].routingTable[tableIndex].SecBit&0x01)<<1)|
                    (routerList[0].routingTable[tableIndex].Valid&0x01)));
      for(int i=0; i<4; i++){
      Serial.println(SPIbyte(0xff&((routerList[0].routingTable[tableIndex].IPSrc)>>(i*8))));
      //Serial.println((uint8_t)(0xff&((routerList[0].routingTable[tableIndex].IPSrc)>>((4-i-1)*8))));
      }
      for(int i=0; i<4; i++){
      Serial.println(SPIbyte(0xff&((routerList[0].routingTable[tableIndex].IPDest)>>(i*8))));
      //Serial.println((uint8_t)(0xff&((routerList[0].routingTable[tableIndex].IPDest)>>((4-i-1)*8))));
      }
      for(int i=0; i<6; i++){
      Serial.println(SPIbyte(0xff&((routerList[0].routingTable[tableIndex].MACSrc)>>(i*8))));
      //Serial.println((uint8_t)(0xff&((routerList[0].routingTable[tableIndex].MACSrc)>>((6-i-1)*8))));
      }
      for(int i=0; i<6; i++){
      Serial.println(SPIbyte(0xff&((routerList[0].routingTable[tableIndex].MACDes)>>(i*8))));
      //Serial.println((uint8_t)(0xff&((routerList[0].routingTable[tableIndex].MACDes)>>((6-i-1)*8))));
      }
      Serial.println(SPIbyte(0));
      
      
      
      
      /*Serial.println((uint8_t)(0x0f&((routerList[0].routingTable[tableIndex].PortNum&0x03)<<2)|
                    ((routerList[0].routingTable[tableIndex].SecBit&0x01)<<1)|
                    (routerList[0].routingTable[tableIndex].Valid&0x01)));*/
      state = WAIT;
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

/* Setting Table Values Individually Backup
    case READ_SERIAL:
    Serial.println("STATE = READ_SERIAL");
      command = Serial.readString();
      command.toCharArray(charCommand,128);
      token = strtok(charCommand,delimiter);
      //Serial.println(token);
      if(String(token).equals("ReadTableEntry")){
        state = DISPLAY_TABLE_ENTRY;
      }
      else if(String(token).equals("SetMACDestination")){
        state = SET_MAC_DESTINATION;
      }
      else if(String(token).equals("SetMACSource")){
        state = SET_MAC_SOURCE;
      }      
      else if(String(token).equals("SetIPDestination")){
        state = SET_IP_DESTINATION;
      }
      else if(String(token).equals("SetIPSource")){
        state = SET_IP_SOURCE;
      }
      else if(String(token).equals("SetPortNumber")){
        state = SET_PORT_NUMBER;
      }
      else if(String(token).equals("SetSecurityBit")){
        state = SET_ACCESS;
      }
      else if(String(token).equals("SetValid")){
        state = SET_VALID;
      }
      else{
        Serial.println("Unknown Command");
        state = WAIT;
      }
    break;
    
    case SET_MAC_DESTINATION:
    Serial.println("STATE = SET_MAC_DESTINATION");
    tableIndex = (uint8_t)atoi(strtok(NULL,delimiter));
    securityBit = (uint8_t)atoi(strtok(NULL,delimiter));
    routerList[0].routingTable[tableIndex].MACDest = ;
    state = WRITE_TABLE;
    break;
    
    case SET_MAC_SOURCE:
    Serial.println("STATE = SESET_MAC_SOURCE");
    tableIndex = (uint8_t)atoi(strtok(NULL,delimiter));
    securityBit = (uint8_t)atoi(strtok(NULL,delimiter));
    routerList[0].routingTable[tableIndex].MACSrc = ;
    state = WRITE_TABLE;
    break;
    
    case SET_IP_DESTINATION:
    Serial.println("STATE = SET_IP_DESTINATION");
    tableIndex = (uint8_t)atoi(strtok(NULL,delimiter));
    securityBit = (uint8_t)atoi(strtok(NULL,delimiter));
    routerList[0].routingTable[tableIndex].IPDest = ;
    state = WRITE_TABLE;
    break;
    
    case SET_IP_SOURCE:
    Serial.println("STATE = SET_IP_SOURCE");
    tableIndex = (uint8_t)atoi(strtok(NULL,delimiter));
    securityBit = (uint8_t)atoi(strtok(NULL,delimiter));
    routerList[0].routingTable[tableIndex].IPSrc = ;
    state = WRITE_TABLE;
    break;
    
    case SET_PORT_NUMBER:
    Serial.println("STATE = SET_PORT_NUMBER");
    tableIndex = (uint8_t)atoi(strtok(NULL,delimiter));
    securityBit = (uint8_t)atoi(strtok(NULL,delimiter));
    routerList[0].routingTable[tableIndex].PortNum = ;
    state = WRITE_TABLE;
    break;
    
    case SET_ACCESS:
    Serial.println("STATE = SET_ACCESS");
    tableIndex = (uint8_t)atoi(strtok(NULL,delimiter));
    securityBit = (uint8_t)atoi(strtok(NULL,delimiter));
    routerList[0].routingTable[tableIndex].SecBit = securityBit;
    state = WRITE_TABLE;
    break;
    
    case SET_VALID:
    Serial.println("STATE = SET_VALID");
    tableIndex = (uint8_t)atoi(strtok(NULL,delimiter));
    securityBit = (uint8_t)atoi(strtok(NULL,delimiter));
    routerList[0].routingTable[tableIndex].Valid = ;
    state = WRITE_TABLE;
    break;
    */

    
