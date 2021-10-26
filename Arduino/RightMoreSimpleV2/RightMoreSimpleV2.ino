//Include needed Libraries at beginning
//This file is specifically for the LEFT worn device as the data will come in
//with an indicator that identifies it as the left. it will be in the form of a 1 or 0
//The 1 or 0 is to keep the conistency of sending floating point numbers
//0 indicates left

#include "nRF24L01.h" 
#include "RF24.h"
#include "SPI.h"
#include "printf.h"
#include "I2Cdev.h"
#include "MPU6050.h"

#define MPU6050_GYRO_FS_500 0x01

#if I2CDEV_IMPLEMENTATION == I2CDEV_ARDUINO_WIRE
    #include "Wire.h"
#endif

#define MPU6050_GYRO_FS_2000 0x03

const int pinCE = 9;
const int pinCSN = 10;
byte counter = 1; // Count packets sent
MPU6050 accelgyro(0x68); // <-- use for AD0 high

int16_t ax, ay, az;
int16_t gx, gy, gz;

//float ax, ay, az;
//float gx, gy, gz;

bool done = false; //Used to know when to stop sending packets
RF24 wirelessSPI(pinCE, pinCSN); // Creating nRF24 object or wireless SPI connection
const uint64_t pAddress = 0xE6E6E6E6E6E6; // Radio pipe address

unsigned long previousTime = 0;
unsigned long timeNow;
float vibrationDelay;
bool vibrationState = false;
int cadence;
bool firstVibrationDone = false;

unsigned long vibrationStopTime;
unsigned long comparison;
#define OUTPUT_READABLE_ACCELGYRO

void setup()
{
  #if I2CDEV_IMPLEMENTATION == I2CDEV_ARDUINO_WIRE
        Wire.begin();
    #endif
  Serial.begin(38400);
  pinMode( 3 , OUTPUT);  // Must be a PWM pin This is the pin controlling the voltage output for the vibration motor
  pinMode(4, OUTPUT); //In built LED control instead of motor for now
  printf_begin();
  wirelessSPI.begin();
  wirelessSPI.setAutoAck(1);
  wirelessSPI.enableAckPayload(); // This is where i can send data in the acknowledgement

  // DONT FORGET TO MAYBE TURN THIS BACK ON
  //wirelessSPI.setRetries(1,3); //5 is the delay between retries, 5 is the number of retries. We arent too worried about re sending failed data

  
  wirelessSPI.openWritingPipe(pAddress);
  wirelessSPI.stopListening();
  wirelessSPI.printDetails();
   Serial.println("Begin Right device");
  //MPU 6050 initialising
  // initialize device
    //Serial.println("Initializing I2C devices...");
    //accelgyro.initialize();
    //accelgyro.setFullScaleGyroRange(MPU6050_GYRO_FS_500);
    // verify connection
    //Serial.println("Testing device connections...");
    //Serial.println(accelgyro.testConnection() ? "MPU6050 connection successful" : "MPU6050 connection failed");
    analogWrite(3,0);
   
    
}


void loop()  
{
  
  //accelgyro.getMotion6(&ax, &ay, &az, &gx, &gy, &gz);
  float f_ax , f_ay, f_az;
  float f_gx, f_gy, f_gz;
  f_ax = ax;
  f_ay = ay;
  f_az = az;
  f_gx = gx;
  f_gy = gy;
  f_gz = gz;
  int byteLength =3;
  
  float IMU[7];
  IMU[0] = 1;
  IMU[1] = f_ax;
  IMU[2] = f_ay;
  IMU[3] = f_az;
  IMU[4] = f_gx;
  IMU[5] = f_gy;
  IMU[6] = f_gz;

  float ack[1];
  float comp[1];

//  #ifdef OUTPUT_READABLE_ACCELGYRO
//          // display tab-separated accel/gyro x/y/z values
//          Serial.print("a/g:\t");
//          Serial.print(IMU[1]); Serial.print("\t");
//          Serial.print(IMU[2]); Serial.print("\t");
//          Serial.print(IMU[3]); Serial.print("\t");
//          Serial.print(IMU[4]); Serial.print("\t");
//          Serial.print(IMU[5]); Serial.print("\t");
//          Serial.println(IMU[6]);
//      #endif  

  
 if(!done) { //if we are not done yet
    Serial.print("Now send packet: "); 
   Serial.println(counter); //serial print the packet number that is being sent
    unsigned long time1 = micros();  //start timer to measure round trip
    //send or write the packet to the rec nRF24 module. Arguments are the payload / variable address and size
   if (!wirelessSPI.write( IMU, sizeof(IMU) )){  //if the send fails let the user know over serial monitor
       //Serial.println("packet delivery failed");      
   }
   else { //if the send was successful 
      unsigned long time2 = micros(); //get time new time
      time2 = time2 - time1; //calculate round trip time to send and get ack packet from rec module
      Serial.print("Time from message sent to recieve Ack packet: ");
      Serial.print(time2); //print the time to the serial monitor
      Serial.println(" microseconds");
       counter++; //up the packet count
   }
   
   //if the reciever sends payload in ack packet this while loop will get the payload data
//   while(wirelessSPI.available() ){ 
  if(wirelessSPI.available() ){ 
       //int sizeNumber = 3;
       //char gotChars[sizeNumber]; //create array to hold payload
       
       wirelessSPI.read( &ack, sizeof(ack)+1); //read payload from ack packet
       if (ack[0] >= 100 && ack[0] < 200){
        if (ack[0] > 180 && ack[0] < 190){
          ack[0] = 0;
        }
        else {
          Serial.print("received: ");
          Serial.println(ack[0]);
          //New stuff that might work
         
          vibrationStop();
          vibrationState = false;
          
          vibrationDelay = (ack[0]/60);
          vibrationDelay = (1000*2)/(vibrationDelay); // Setting required vibration delays
          delay(vibrationDelay/2);
          previousTime = millis();
        }
       }
       if (ack[0] == 199){
        vibrationStop(); //Stops it straight away here so i dont need it as a contingency in next if statement
        vibrationState = false;
       }
       
    }
    //After receiving data from MATLAB vibrations may or may not be triggered
    
    if (ack[0] >= 100 && ack[0] < 140){
      vibrationDelay = (ack[0]/60);
      vibrationDelay = (1000*2)/(vibrationDelay); // Setting required vibration delays
      vibrationStopTime = vibrationDelay/8;
      timeNow = millis();
      comparison = timeNow - previousTime;
      if (comparison >= vibrationDelay && vibrationState == false){
        vibrationOn(ack[0]);
        previousTime = millis();
        vibrationState = true;
      }
      comparison = timeNow - previousTime;
      if (comparison > vibrationStopTime && vibrationState == true){
        vibrationStop();
        vibrationState = false;
      }
    }

    delay(3);
  }
}


void vibrationStop(){
  analogWrite(3,0);
//  Serial.println("Vibration has stopped");
}

void vibrationOn(int cadence){
  analogWrite(3,255);
//  Serial.print("Vibration has started");
//  Serial.print("\t Cadence value passed through = ");
//  Serial.println(cadence);
  
}
