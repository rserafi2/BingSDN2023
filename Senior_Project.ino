#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <SPI.h>
#define ROUTING_TABLE_SIZE 32
#define MAX_ROUTERS 1
#define WAIT_TIME 100
struct routingTableEntry{
  //uint32_t MACDestTop;
  //uint16_t MACDestBottom;//TODO: MY EYEYEYSS
  uint64_t MACDest;
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

enum Program_State {STARTUP,WAIT,PING_SPI,
DEBUG,
READ_SPI,CHECK_SPI_COMMAND,
READ_SERIAL,SET_ACCESS,SET_PORT,SET_VALID,DISPLAY_TABLE_ENTRY,WRITE_SERIAL,NEW_IP,NEW_ROUTER,WRITE_TABLE};

char charCommand[128]; 
String command;
char *token;
const char *delimiter = " ";
struct router routerList[MAX_ROUTERS];
uint8_t spiByte =0;
uint8_t waitCount = 0;
uint8_t tableIndex = 0;
uint8_t securityBit = 0;
uint8_t portNum = 0;
uint8_t valid = 0;
struct routingTableEntry tempTableEntry;

uint8_t SPIbyte(uint8_t message){
    digitalWrite(SS, LOW); // enable Slave Select
    uint8_t received = (SPI.transfer(message));
    digitalWrite(SS, HIGH); // disable Slave Select
    delay(10);
    return received;
}

uint8_t hex_char_to_uint8(char hex_char){
    uint8_t val = 0;

    if (hex_char >= '0'
        && hex_char <= '9') {
        val = hex_char - 48;
    }
    else if (hex_char >= 'a'
             && hex_char <= 'f') {
        val = hex_char - 97 + 10;
    }
    else if (hex_char >= 'A'
             && hex_char <= 'F') {
        val = hex_char - 65 + 10;
    }
   
    return val;
}

uint64_t mac_str_to_uint64(char* mac_str){ // xx:xx:xx:xx:xx:xx
    uint64_t val = 0;
    int hexval_cnt = 12;
    int str_idx = 0;
   
    while(str_idx < 17){
        if (mac_str[str_idx] == ':'){
            str_idx++;
            continue;
        }
        else{
            hexval_cnt--;
        }
       
        val += (uint64_t)hex_char_to_uint8(mac_str[str_idx]) << (uint64_t)(hexval_cnt)*4;
        str_idx++;
    }
    return val;
}
/*
uint32_t ip_str_to_uint32(char* ip_str){
    char buf[20];
    strcpy(buf, ip_str);
    const char s[2] = ".";
    char *token;
    token = strtok(buf, s);
    uint32_t val =   atoi(token) << 24;
    val += atoi(strtok(NULL, s)) << 16;
    val += atoi(strtok(NULL, s)) << 8;
    val += atoi(strtok(NULL, s)) << 0;
    return val;
}
*/
char* ip_uint32_to_str(uint32_t ip_address, char* ip_addr_final){ // ip_addr_final is char[16]
    const int NBYTES = 4;
    uint8_t octet[NBYTES];
    for(int i = 0 ; i < NBYTES ; i++)
    {
        octet[i] = ip_address >> (i * 8);
    }
    sprintf(ip_addr_final, "%d.%d.%d.%d", octet[3], octet[2], octet[1], octet[0]);
    return ip_addr_final;
}


char* mac_uint64_to_str(uint64_t mac_address, char* mac_addr_final){ // ip_addr_final is char[16]
    const int NBYTES = 6;
    uint8_t byte[NBYTES];
    for(int i = 0 ; i < NBYTES ; i++)
    {
        byte[i] = mac_address >> (i * 8);
    }
    sprintf(mac_addr_final, "%x:%x:%x:%x:%x:%x", byte[5], byte[4], byte[3], byte[2], byte[1], byte[0]);
    return mac_addr_final;
}

void setup() {
  pinMode(10, OUTPUT); 
  Serial.begin(9600); // opens serial port, sets data rate to 9600 bps
  delay(1000);
  Serial.begin(115200); // set baud rate to 115200 for usart
  SPI.begin();
  SPI.beginTransaction(SPISettings(4000000, MSBFIRST, SPI_MODE3));
  SPI.setClockDivider(SPI_CLOCK_DIV4);
  Serial.println("SDN Controller Started");
  delay(1000);
};

static enum Program_State state = STARTUP;
void loop() {
  
  switch(state){
  
      
  case STARTUP:
    Serial.println("STATE = STARTUP");
    for (int i = 0; i < MAX_ROUTERS; i++){
      for( int j = 0; j < ROUTING_TABLE_SIZE; j++){
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
    default:  
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
      else if(String(token).equals("SetPortNum")){
        state = SET_PORT;
      }
      else if(String(token).equals("SetValid")){
        state = SET_VALID;
      }
      else if(String(token).equals("DEBUG")){
        state = DEBUG;
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
//        for (routerList[id].routingTable[j].MACSrc = MACSrc && routerList[id].routingTable[j].MACDestt = MACDestt){
//          for (routerList[id].routingTable[j].IPSrc = IPSrc && routerList[id].routingTable[j].IPDest = IPDest){
//            routerList[id].routingTable[j].SecBit = SecBit;
//          }
//        }
//      }
//      state = WRITE_TABLE;
//    }
    break;
    
    case SET_PORT:
    Serial.println("STATE = SET_PORT");
    tableIndex = (uint8_t)atoi(strtok(NULL,delimiter));
    portNum = (uint8_t)atoi(strtok(NULL,delimiter));
    routerList[0].routingTable[tableIndex].PortNum = portNum;
    state = WRITE_TABLE;
    break;

    case SET_VALID:
    Serial.println("STATE = SET_VALID");
    tableIndex = (uint8_t)atoi(strtok(NULL,delimiter));
    valid = (uint8_t)atoi(strtok(NULL,delimiter));
    routerList[0].routingTable[tableIndex].Valid = valid;
    state = WRITE_TABLE;
    break;

    case DEBUG:
      Serial.println("STATE = DEBUG");
      for(int i=0; i<6; i++){
        Serial.println();
        Serial.print("Table Entry At Index ");
        Serial.println(i);
        Serial.println("MACDest\t\t\tMACSrc\t\t\tIPDest\t\t\tIPSrc\t\t\tPortNum\tSecBit\tValid");
        //Serial.print("MACDest ");
        char mac_addr_str[20];
        Serial.print(mac_uint64_to_str(routerList[0].routingTable[i].MACDest,mac_addr_str));
        Serial.print("\t");
        //Serial.print(" ,MACSrc ");
        Serial.print(mac_uint64_to_str(routerList[0].routingTable[i].MACSrc,mac_addr_str));
        Serial.print("\t");
        //Serial.print(" ,IPDest ");
        char ip_addr_str[16];
        Serial.print(ip_uint32_to_str(routerList[0].routingTable[i].IPDest,ip_addr_str));
        Serial.print("\t\t");
        //Serial.print(" ,IPSrc ");
        Serial.print(ip_uint32_to_str(routerList[0].routingTable[i].IPSrc,ip_addr_str));
        Serial.print("\t\t");
        //Serial.print(" ,PortNum ");
        Serial.print(routerList[0].routingTable[i].PortNum);
        Serial.print("\t");
        //Serial.print(" ,SecBit ");
        Serial.print(routerList[0].routingTable[i].SecBit);
        Serial.print("\t");
        //Serial.print(" ,Valid ");
        Serial.println(routerList[0].routingTable[i].Valid);
      }
    state = WAIT;
    break;
        
    case DISPLAY_TABLE_ENTRY:
      Serial.println("STATE = DISPLAY_TABLE_ENTRY");
      tableIndex = (uint8_t)atoi(strtok(NULL,delimiter));
      SPIbyte(0x01);
      SPIbyte(tableIndex);
      spiByte = SPIbyte(0);
      tempTableEntry.Valid = spiByte & 0x01;
      tempTableEntry.SecBit = (spiByte & 0x02)>1;
      tempTableEntry.PortNum = (spiByte & 0x0c)>>2;
      for(int i=0; i<4; i++){
        spiByte = SPIbyte(0);
        tempTableEntry.IPSrc = ((uint32_t)tempTableEntry.IPSrc & ~((uint32_t)0xFF<<(i*8))) | ((uint32_t)spiByte<<(i*8));
      }
      for(int i=0; i<4; i++){
        spiByte = SPIbyte(0);
        tempTableEntry.IPDest = ((uint32_t)tempTableEntry.IPDest & ~((uint32_t)0xFF<<(i*8))) | ((uint32_t)spiByte<<(i*8));
      }
      for(int i=0; i<6; i++){
        spiByte = SPIbyte(0);
        tempTableEntry.MACSrc = ((uint64_t)tempTableEntry.MACSrc & ~((uint64_t)0xFF<<(i*8))) | ((uint64_t)spiByte<<(i*8));
      }
      for(int i=0; i<6; i++){
        spiByte = SPIbyte(0);
        tempTableEntry.MACDest = ((uint64_t)tempTableEntry.MACDest & ~((uint64_t)0xFF<<(i*8))) | ((uint64_t)spiByte<<(i*8));
      }
      routerList[0].routingTable[tableIndex] = tempTableEntry;
      Serial.println();
      Serial.print("Table Entry At Index ");
      Serial.println(tableIndex);
      Serial.println("MACDest\t\t\tMACSrc\t\t\tIPDest\t\t\tIPSrc\t\t\tPortNum\tSecBit\tValid");
      //Serial.print("MACDest ");
      char mac_addr_str[20];
      Serial.print(mac_uint64_to_str(routerList[0].routingTable[tableIndex].MACDest,mac_addr_str));
      Serial.print("\t");
      //Serial.print(" ,MACSrc ");
      Serial.print(mac_uint64_to_str(routerList[0].routingTable[tableIndex].MACSrc,mac_addr_str));
      Serial.print("\t");
      //Serial.print(" ,IPDest ");
      char ip_addr_str[16];
      Serial.print(ip_uint32_to_str(routerList[0].routingTable[tableIndex].IPDest,ip_addr_str));
      Serial.print("\t\t");
      //Serial.print(" ,IPSrc ");
      Serial.print(ip_uint32_to_str(routerList[0].routingTable[tableIndex].IPSrc,ip_addr_str));
      Serial.print("\t\t");
      //Serial.print(" ,PortNum ");
      Serial.print(routerList[0].routingTable[tableIndex].PortNum);
      Serial.print("\t");
      //Serial.print(" ,SecBit ");
      Serial.print(routerList[0].routingTable[tableIndex].SecBit);
      Serial.print("\t");
      //Serial.print(" ,Valid ");
      Serial.println(routerList[0].routingTable[tableIndex].Valid);
      state = WRITE_SERIAL;
    break;
                    
    case WRITE_SERIAL:
    //Serial.println("STATE = WRITE_SERIAL");
    /*Serial.println("Printing Routing Table to Serial Terminal");
    for (int j = 0; j < MAX_ROUTERS; j++){
      for ( int i = 0; i < ROUTING_TABLE_SIZE; i++){
        Serial.print(routerList[j].routingTable[i].MACDest);
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
      SPIbyte(0x02);
      SPIbyte(tableIndex);
      SPIbyte(0x0f&((routerList[0].routingTable[tableIndex].PortNum&0x03)<<2)|
                    ((routerList[0].routingTable[tableIndex].SecBit&0x01)<<1)|
                    (routerList[0].routingTable[tableIndex].Valid&0x01));
      for(int i=0; i<4; i++){
      SPIbyte(0xff&((routerList[0].routingTable[tableIndex].IPSrc)>>(i*8)));
      //Serial.println((uint8_t)(0xff&((routerList[0].routingTable[tableIndex].IPSrc)>>((4-i-1)*8))));
      }
      for(int i=0; i<4; i++){
      SPIbyte(0xff&((routerList[0].routingTable[tableIndex].IPDest)>>(i*8)));
      //Serial.println((uint8_t)(0xff&((routerList[0].routingTable[tableIndex].IPDest)>>((4-i-1)*8))));
      }
      for(int i=0; i<6; i++){
      SPIbyte(0xff&((routerList[0].routingTable[tableIndex].MACSrc)>>(i*8)));
      //Serial.println((uint8_t)(0xff&((routerList[0].routingTable[tableIndex].MACSrc)>>((6-i-1)*8))));
      }
      for(int i=0; i<6; i++){
      SPIbyte(0xff&((routerList[0].routingTable[tableIndex].MACDest)>>(i*8)));
      //Serial.println((uint8_t)(0xff&((routerList[0].routingTable[tableIndex].MACDest)>>((6-i-1)*8))));
      }
      Serial.println("Write Complete");
      
      
      
      
      /*Serial.println((uint8_t)(0x0f&((routerList[0].routingTable[tableIndex].PortNum&0x03)<<2)|
                    ((routerList[0].routingTable[tableIndex].SecBit&0x01)<<1)|
                    (routerList[0].routingTable[tableIndex].Valid&0x01)));*/
      state = WAIT;
      break;
  }
}
/*
int main()
{
    //printf("c = %d\n", hex_char_to_uint8('c'));
    printf("ab:cd:ef:ab:cd:ef = %lx\n", mac_str_to_uint64("ab:cd:ef:ab:cd:ef"));
   
    printf("100.100.100.100 = %x\n", ip_str_to_uint32("100.100.100.100"));
    char ip_addr_str[16];
    char mac_addr_str[20];
    printf("0x64646464 = %s\n", ip_uint32_to_str(0x64646464, ip_addr_str));
    printf("0xabcdefabcdef = %s\n", mac_uint64_to_str(0xabcdefabcdef, mac_addr_str));
    return 0;
}
*/
