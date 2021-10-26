#include <SPI.h> //Call SPI library so you can communicate with the nRF24L01+
#include <nRF24L01.h> //nRF2401 libarary found at https://github.com/tmrh20/RF24/
#include <RF24.h> //nRF2401 libarary found at https://github.com/tmrh20/RF24/
#include "printf.h" //This is used to print the details of the nRF24 board. if you don't want to use it just comment out "printf_begin()"

const int pinCE = 9; //This pin is used to set the nRF24 to standby (0) or active mode (1)
const int pinCSN = 10; //This pin is used to tell the nRF24 whether the SPI communication is a command or message to send out
int gotByte = 0; //used to store payload from transmit module
byte gotBytes[3];
RF24 wirelessSPI(pinCE, pinCSN); // Declare object from nRF24 library (Create your wireless SPI)
const uint64_t pAddress[2] = {0xE6E6E6E6E6E6, 0xE8E8F0F0E1LL}; //Create a pipe addresses for the 2 nodes to communicate over, the "LL" is for LongLong type
int pipe_def = 0;
bool sent_first = false;
bool sent = false;
unsigned int first_send_time;
unsigned int comp_send_time;
float transmit;
void setup()
{
  Serial.begin(230400);  //start serial to communicate process
  printf_begin();  //This is only used to print details of nRF24 module, needs Printf.h file. It is optional and can be deleted
  wirelessSPI.begin();  //Start the nRF24 module
  //wirelessSPI.setAutoAck(1);                    // Ensure autoACK is enabled, this means rec send acknowledge packet to tell xmit that it got the packet with no problems
  wirelessSPI.enableAckPayload();               // Allow optional payload or message on ack packet
  wirelessSPI.setRetries(5, 5);                // Defines packet retry behavior: first arg is delay between retries at 250us x 5 and max no. of retries
  wirelessSPI.openReadingPipe(1, pAddress[0]);     //open pipe o for recieving meassages with pipe address
  wirelessSPI.startListening();                 // Start listening for messages
  //wirelessSPI.printDetails();                   //print details of nRF24 module to serial, must have printf for it to print to serial



}

void loop()
{
  int done_twice = 0;
  bool left;
  float IMU[7];
  IMU[0] = 100;
  IMU[1] = 0;
  IMU[2] = 0;
  IMU[3] = 0;
  IMU[4] = 0;
  IMU[5] = 0;
  IMU[6] = 0;
  //loop until all of the payload data is recieved
  while (wirelessSPI.available()) {
    wirelessSPI.read( &IMU, (sizeof(IMU) + 1) ); //read one byte of data and store it in gotByte variable
    //Serial.print("Recieved packet number: "); //payload counts packet number
    //Serial.println(gotByte);
    //Serial.print("Packet received is: ");
    delay(1);
    if (pipe_def == 0) {
      pipe_def = 1;
      wirelessSPI.openReadingPipe(0, pAddress[0]);
      left = true;
    }
    if (pipe_def == 1) {
      pipe_def = 0;
      wirelessSPI.openReadingPipe(1, pAddress[1]);
      left = false;
    }
    for (int i = 0; i < sizeof(IMU) / 4; i++) { //Divided by 4 part is because float variables are 4x bigger than bytes
      Serial.print(IMU[i]);
      if (i < (sizeof(IMU) - 1) / 4 ) {
        Serial.print(",");
      }
    }
    Serial.println();
    gotByte = gotByte + 1;
    char incomingByte = 0;
    int number;
    if (Serial.available() >0)// || sent_first == true)// || done_twice == 1
    {
      if (done_twice == 0){            // This section pulls 1 byte (number) from the serial buffer at at time and converts 3 pulled numbers into one 3-digit number
        incomingByte = Serial.read();
        number = incomingByte - '0';
        if (number > 0){
          incomingByte = Serial.read();
          number = number*100;
          int numberTwo = incomingByte -'0';
          delay(0.1);
          incomingByte = Serial.read();
          int numberThree = incomingByte -'0';
          number = number + numberTwo*10 + numberThree;
          sent = false;
          sent_first = false; // So it is reset to be able to send next ones
          if (number == 199){ //199 is the stop number. so if 199 is passed through its passed to both devices twice as a backup
            transmit = number;
           wirelessSPI.writeAckPayload(0,&transmit, sizeof(transmit));
            delay(5);
            wirelessSPI.writeAckPayload(1,&transmit, sizeof(transmit));
           wirelessSPI.writeAckPayload(0,&transmit, sizeof(transmit));
            delay(5);
            wirelessSPI.writeAckPayload(1,&transmit, sizeof(transmit));
            sent = true;
            //break;
        }
          if (number > 145 ){
            number = 0;
          }
          }
        }
       }
      //Serial.println(number);
      if (number > 0 && sent == false) {
        transmit = number;
  //      if (sent == false){
          wirelessSPI.writeAckPayload(0,&transmit, sizeof(transmit));
          sent = true;
          delay(0.5);
          wirelessSPI.writeAckPayload(1,&transmit, sizeof(transmit));
          done_twice = done_twice + 2; //Usually +1 if the if's worked properly
          
       // }
//        comp_send_time = millis();
//        if (comp_send_time - first_send_time >= (delayTime) && sent_first == true){
//          wirelessSPI.writeAckPayload(0,&transmit, sizeof(transmit));
//          done_twice = done_twice + 1;
//          sent = true;
//        }
        
        if (done_twice == 2){ //Says both arduinos have been sent the target number and now were open to receving the next input from matlab
          done_twice = 0;
        }
      }
   

  }

}
