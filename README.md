# 🖥️ Smart Desk Automation System — FPGA & VHDL

A smart desk automation system implemented using **VHDL on an FPGA**, designed to automate common desk interactions based on user presence and ambient lighting conditions.

The system integrates motion and light sensing, automated drawer control, ambient lighting, and session timing to create a responsive and energy-efficient desk environment.

> 🎓 Developed as a team project at the German University in Cairo (GUC).

---

## ✨ Features

- 👤 Detects user presence using a **PIR motion sensor**
- 💡 Automatically controls desk lighting based on presence and ambient light
- 🗄️ Opens and closes a drawer using an **SG90 servo motor**
- ⏱️ Tracks the user's desk session using a **two-digit 7-segment display**
- 🔘 Supports manual drawer opening and closing through push buttons
- 🔄 Automatically closes the drawer after 10 seconds
- ⚙️ Implements the system logic entirely using **VHDL**

---

## 🛠️ Technologies & Hardware

### Software
- VHDL
- FPGA Programming
- Digital Logic Design

### Hardware
- FPGA Board
- PIR Motion Sensor
- Digital LDR Light Sensor
- SG90 Servo Motor
- LEDs
- Two 7-Segment Displays
- Push Buttons

---

## ⚙️ How It Works

The system receives input from the PIR motion sensor, LDR light sensor, and manual control buttons.

These inputs are processed by the FPGA to control the desk's different components.

```text
                         ┌───────────────────────┐
PIR Motion Sensor ──────►│                       │────► Servo Motor
                         │                       │      (Drawer)
LDR Light Sensor ───────►│      FPGA / VHDL     │
                         │                       │────► LEDs
Open Button ────────────►│                       │      (Lighting)
                         │                       │
Close Button ───────────►│                       │────► 7-Segment
                         └───────────────────────┘      Displays
                                                       (Timer)
```

### System Behavior

| Condition | Action |
|---|---|
| User presence detected | Drawer opens |
| Open button pressed | Drawer opens |
| 10 seconds pass | Drawer automatically closes |
| Close button pressed | Drawer closes |
| User detected in darkness | LEDs turn on |
| No user / sufficient lighting | LEDs remain off |
| User remains present | Session timer increments every second |

The servo rotates between **0° and 180°** to represent the closed and open drawer positions.

---

## 🧩 VHDL Architecture

The system was divided into several functional modules:

### PIR Synchronizer
Synchronizes the raw PIR sensor signal with the FPGA system clock.

### Tick Generator
Divides the **50 MHz system clock** to generate a 1-second timing signal used by the system.

### Button Pulse Generator
Detects rising edges from the manual drawer open and close buttons.

### Drawer Logic
Controls the state of the drawer based on:
- User presence
- Manual controls
- Automatic closing timer

### LED Logic
Controls the desk lighting according to user presence and ambient lighting conditions.

### Session Timer
Counts the duration of user presence up to **99 seconds**.

### 7-Segment Decoder
Converts the session timer values into the appropriate output for the two 7-segment displays.

### Servo Driver
Generates the **PWM signal** required to control the SG90 servo motor and change the drawer position.

---

## 📥 Inputs

| Input | Description |
|---|---|
| `clk` | 50 MHz system clock |
| `rst_n` | Active-low reset |
| `presence_raw` | PIR motion sensor input |
| `btn_open` | Manual drawer-open button |
| `btn_close` | Manual drawer-close button |
| `light_dark` | Digital LDR light input |

---

## 📤 Outputs

| Output | Description |
|---|---|
| `led_on[9:0]` | Controls 10 LEDs |
| `pwm_servo` | PWM output controlling the SG90 servo |
| `seg_units` | Units digit of the session timer |
| `seg_tens` | Tens digit of the session timer |

---

## 📊 Results

The completed system successfully demonstrated:

- Automatic drawer opening when motion was detected
- Automatic drawer closing after 10 seconds
- Manual drawer control using push buttons
- Lighting control based on both presence and ambient light
- Real-time session tracking while a user was present
- Servo-based drawer movement between open and closed positions

---

## 👥 Team Project

This project was developed collaboratively as part of our coursework at the **German University in Cairo**.

---

## 🚀 What I Learned

This project provided hands-on experience with:

- FPGA-based system design
- VHDL programming
- Digital logic and hardware control
- PWM-based servo motor control
- Sensor integration
- Clock division and timing
- Modular hardware design
- Hardware/software debugging and testing
