# Flutter ECG App 🫀

A **real-time ECG monitoring application** built with **Flutter** and an **ESP32**.  
Visualize heart signals, calculate BPM, and stream data wirelessly via **BLE** to your mobile device.

![App Demo](assets/images/Intro_RealTime.gif)

---

## Features ✨

- Real-time ECG signal visualization 📊
- Real-time BPM display 💖
- Cloud database (Supabase) stores all the data 📕
- BLE communication with ESP32 ⚡  
- Historical ECG charting from Supabase 📈
- Connection status monitoring  🕵🏼‍♂️

---

## Hardware & Software Requirements 🛠️

### Hardware
| Component           | Description                  |
|--------------------|-----------------------------|
| ESP32 DevKit V1     | Microcontroller board        |
| SparkFun AD8232     | ECG sensor                   |
| Micro USB Cable           | To upload firmware to ESP32    |
| TPS61023 | To maintain a stable voltage (step down) | 
| TP4056 | To power the ECG32 via battery |
| 3000mAh LiPo battery | The power source of the ESP32 | 

### Software
- **Flutter** ≥ 3.0  
- **PlatformIO** for ESP32 firmware  
- Arduino framework for ESP32  

---

## Installation 🚀

### 1. Clone the repository

### 2. Gather dependencies
```bash
cd flutter_ecg_app
flutter pub get
```
### 3. Upload the software to your phone
Connect your phone via USB to VsCode (download  Flutter extension) and run the project / start debugging

OR

Run the app on your computer by running the project / start debugging

### 4. You're in!
