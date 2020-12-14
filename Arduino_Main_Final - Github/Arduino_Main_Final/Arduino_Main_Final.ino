#include <Servo.h>
#include "DHT.h"
#include "IRremote.h"

#define DEBUG(a) Serial.println(a);
#define co2Zero 55 //calibracion CO2 0 nivel

//Control
int ServoMove=0;
int myArray[3];   //create array with however many spots you need
int X = 0;         //place holder for the array index spot
int arduinoRiego=0;
int ArduinoTemperatura=0;
int ArduinoLuz=0;
int ArduinoPesti=0;


//Control Remoto

int ServoRemo=0;
int RiegoRemo=0;
int LuzRemo=0;
int TempRemo=0;
int PestiRemo=0;


//Inputs
int ServomotorReceiver=13;
float HumedadSueloReceiver=0.2;
float HumedadAireReceiver=70;
float TemperaturaReceiver=20.2;
float LuminosidadReceiver=105;

//Outputs
int IluminacionRemota=2; //FPGA - Iluminacion
int TemperaturaSender=4; //FPGA - Calefaccion
int RiegoSender=7;// FPGA - Riego
int PesticidaSender=8; //FPGA - pesticida
int ventilacion=12; // Arduino - Servomotor

//Sensores
#define anInput A0 // pin analogo del MQ135
int SensorPin = A2; //Sensor de Humedad Suelo
int sense01 = 1;//Pin analógico UV
#define  pinDHT11  10 //Sensor Humedad y temperatura
#define  tipoDHT    DHT11 //  Configura el pinSensor y tipoDHT pra el DHT11. 

//Valores
int val01 = 0;//Valor del sensor de luz - Solo Enteros
float  humedadAire = 0;//Valor DTH11 - Humedad Aire
float  temperatura =0;//Valor DTH11 - Temperatura
int humedad=0;//Valor raw - Humedad Suelo
float hupedad_p=0;//Valor Porcentual - Humedad Suelo
//El valor de CO2 en PPM esta en el Void Loop



//Declaraciones
int receiver = 11;
DHT  dht11(pinDHT11, tipoDHT); 
IRrecv irrecv(receiver);     
decode_results results;   
Servo servoMotor;
 
void setup()
{  
  Serial.begin(9600);//Uart Serial
  pinMode(anInput,INPUT); //MQ135 
  irrecv.enableIRIn(); //Control Remoto
  servoMotor.attach(ventilacion);//Servomotor
  dht11.begin();//  Inicializa DHT11
  pinMode(ServomotorReceiver,INPUT); 
  pinMode(IluminacionRemota,OUTPUT); 
  pinMode(TemperaturaSender,OUTPUT);
  pinMode(ventilacion,OUTPUT);
  pinMode(RiegoSender,OUTPUT);
  pinMode(PesticidaSender,OUTPUT);  
}
 
 
void loop()  
{

//código del MQ finaliza
    int co2now[10]; //int array for co2 readings
    int co2raw = 0; //int for raw value of co2
    int co2comp = 0; //int for compensated co2
    int co2ppm = 0; //int for calculated ppm
    int zzz = 0; //int for averaging
    int grafX = 0; //int for x value of graph
    //display.clearDisplay(); //clear display @beginning of each loop
    for (int x = 0;x<10;x++){ //samplpe co2 10x over 2 seconds
    co2now[x]=analogRead(A0);
    delay(50);
    }
    for (int x = 0;x<10;x++){ //add samples together
    zzz=zzz + co2now[x];
    }
    co2raw = zzz/10; //divide samples by 10
    co2comp = co2raw - co2Zero; //get compensated value
    co2ppm = map(co2comp,0,1023,400,5000); //map value for atmospheric levels    
// finaliza el  código MQ


//Comandos Control Remoto
if(irrecv.decode(&results)){

  if(results.value==0xE0E020DF){
    if(LuzRemo==1)LuzRemo=0;
    else LuzRemo=1;
  }
  if(results.value==0xE0E0A05F){
    if(TempRemo==1)TempRemo=0;
    else TempRemo=1;
  }
  if(results.value==0xE0E0609F){
    if(ServoRemo==1)ServoRemo=0;
    else ServoRemo=1;
  }
  if(results.value==0xE0E010EF){
    if(RiegoRemo==1)RiegoRemo=0;
    else RiegoRemo=1;
  }
  if(results.value==0xE0E0906F){
    if(PestiRemo==1)PestiRemo=0;
    else PestiRemo=1;
  }
  if(results.value==0xE0E040BF){
    LuzRemo=0;
    TempRemo=0;
    ServoRemo=0;
    RiegoRemo=0;
    PestiRemo=0;
  }
  Serial.println(results.value,HEX);
  irrecv.resume();
}


//Datos Entrada Uart FPGA->Arduino
if ( Serial.available () > 0 ) {
    
    myArray[X] = Serial.read();
    Serial.println(myArray[X],DEC);
    X = X + 1; 
    if (X == 3){
      X = 0;
      if(myArray[0]==1){
        HumedadSueloReceiver=myArray[1]+myArray[2]/10;
        HumedadSueloReceiver=HumedadSueloReceiver/100;
        Serial.println(HumedadSueloReceiver,DEC);
        myArray[0]=0;
      }
      if(myArray[0]==2){
        HumedadAireReceiver=myArray[1]+myArray[2]/10;
        Serial.println(HumedadAireReceiver,DEC);
        myArray[0]=0;
      }
      if(myArray[0]==3){
        TemperaturaReceiver=myArray[1]+myArray[2]/10;
        Serial.println(TemperaturaReceiver,DEC);
        myArray[0]=0;
      }
      if(myArray[0]==4){
        LuminosidadReceiver=myArray[1]*10+myArray[2];
        Serial.println(LuminosidadReceiver,DEC);
        myArray[0]=0;
      }
    }
  }



//valores del sensor de luz - Dato - Control de prender luz
  val01 = analogRead(sense01);
  Serial.print(val01);


//valores de humedad y temperatura - Dato y Control
  humedadAire  =  dht11.readHumidity();      //  Lectura de Humedad.
  temperatura  =  dht11.readTemperature();   //  Lectura de Temperatura.
  Serial.print("Humedad: ");
  Serial.print(humedadAire);    //  Muestra en Pantalla Humedad.
  Serial.print(" %RH");
  Serial.print(", Temperatura: ");
  Serial.print(temperatura);  //  Muestra en pantalla Temperatura.
  Serial.print(" °C, co2: ");


//valores de CO2 - Dato
 Serial.print(co2ppm, DEC);
 Serial.print(" ppm, ");

// valores humedad de suelo - Dato y Control
   Serial.print(" Humedad de suelo ");
   humedad = analogRead(SensorPin);
   hupedad_p=((0.5*512)/humedad);
   Serial.println(hupedad_p);
  
  
//Automatizacion
  if((hupedad_p<HumedadSueloReceiver) || (RiegoRemo==1)){
    arduinoRiego=1;
  }else {
    arduinoRiego=0;
  }

  if(arduinoRiego==1){
    digitalWrite(RiegoSender, HIGH); 
  }else{
    digitalWrite(RiegoSender, LOW);
  }


  if((humedadAire>HumedadAireReceiver) || (digitalRead(ServomotorReceiver)==1) || (ServoRemo==1) ){
    ServoMove=1;
  }else {
    ServoMove=0;
  }

  if(ServoMove==1){
    servoMotor.write(0);
  }else{
    servoMotor.write(90);
  }



 if((temperatura<TemperaturaReceiver) || (TempRemo==1)){
    ArduinoTemperatura=1;
  }else {
    ArduinoTemperatura=0;
  }

  if(ArduinoTemperatura==1){
    digitalWrite(TemperaturaSender, HIGH); 
  }else{
    digitalWrite(TemperaturaSender, LOW); 
  }



   if((val01<LuminosidadReceiver) || (LuzRemo==1)){
    ArduinoLuz=1;
  }else {
    ArduinoLuz=0;
  }

  if(ArduinoLuz==1){
    digitalWrite(IluminacionRemota, HIGH); 
  }else{
    digitalWrite(IluminacionRemota, LOW); 
  }


  if(PestiRemo==1){
    ArduinoPesti=1;
  }else {
    ArduinoPesti=0;
  }

  if(ArduinoPesti==1){
    digitalWrite(PesticidaSender, HIGH); 
  }else{
    digitalWrite(PesticidaSender, LOW); 
  }

  delay(100);
}
