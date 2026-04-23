# UART
## UART Controller with FIFO
### UART interface for PC communication, including transmit and receive logic with FIFO buffering to handle asynchronous data smoothly.

This project implements a bidirectional communication system between an FPGA board and a personal computer using the UART protocol. The design enables the user to send and receive messages via hardware inputs (switches and buttons) as well as through a PC keyboard interface.


The system includes buffering mechanisms, signal conditioning, and real-time display output using seven-segment displays.

![image alt](https://github.com/Hosty04/UART/blob/579645e6c175d3026c799b1a5805947459b93192/schematic/UART.png)
---

## Inputs
- 15 switches located on the bottom side of the FPGA board  
- 3 push buttons  
- PC keyboard (via terminal interface)  
- Logical analyzator 

---

## Outputs
- Logical analyzator  
- 2× LEDs (status indication)  
- 2× seven-segment displays 

---

## Components
- 2× Debounce modules  
- 2× FIFO buffers  
- Display Driver  
- UART Receiver (`UART_RX`)  
- UART Transmitter (`UART_TX`)  

---

## Functionality

### FPGA → PC Communication
The user selects a message using the board switches. Additional switches are used to configure communication parameters. The transmission is initiated by pressing a dedicated button.

The FPGA sends the message to the PC via UART. Transmission status is indicated using LEDs and/or seven-segment displays. The received message is displayed on logical analyzator.

### PC → FPGA Communication
The system supports communication in the opposite direction:

- The user types a message on the PC keyboard and confirms it by pressing the **ENTER** key, or  
- Characters are transmitted in real time as they are typed  

Incoming characters are received by the FPGA and displayed sequentially on the two seven-segment displays.

### Data Buffering
In both communication directions, transmitted and received data are stored in FIFO buffers. These buffers temporarily hold a predefined number of characters and ensure proper synchronization between components operating at different speeds.

---

## Specifications

### Debounce
Eliminates unwanted signal glitches caused by mechanical button presses and releases.

[Debounce - Source file](https://github.com/Hosty04/UART/tree/d0c816b90145e416d75e810c0764adc2ca21525a/debounce/debounce.srcs)

### TX
Accepts communication parameters and data from the FIFO buffer and FPGA inputs. It transmits serialized data to the PC, synchronized with the system clock (`CLK`). 

[TX - Source file](https://github.com/Hosty04/UART/tree/d0c816b90145e416d75e810c0764adc2ca21525a/tx/tx.srcs)

### FIFO
Implements a circular buffer to compensate for speed differences between data producers and consumers. It temporarily stores incoming or outgoing characters until they can be processed.

[FIFO - Source file](https://github.com/Hosty04/UART/tree/d0c816b90145e416d75e810c0764adc2ca21525a/fifo/fifo.srcs)

### RX
Receives serial data from the PC and, synchronized with the system clock (`CLK`), stores the incoming data into a FIFO buffer.

[RX - Source file](https://github.com/Hosty04/UART/tree/d0c816b90145e416d75e810c0764adc2ca21525a/rx/rx.srcs)

### Display Driver
Handles conversion from binary values to seven-segment display encoding (`bin_to_seg`). It enables control of multiple displays and allows simultaneous visualization of different characters.

[Display Driver - Source file](https://github.com/Hosty04/UART/tree/d0c816b90145e416d75e810c0764adc2ca21525a/display/display.srcs)

---
## Settings

Communication parameters are selected using the dedicated configuration switches on the FPGA board.

The settings area controls the serial link behavior and determines how data is framed before transmission and how incoming data is interpreted by the receiver.

| Setting | Description |
|---|---|
| **Address flag** | Marks whether the transmitted byte is treated as an address or as regular data. |
| **Parity** | Enables **even parity** for basic error checking. |
| **Stop bits** | Selects the number of stop bits used in the UART frame: **1** or **2**. |
| **Baud rate** | Selects the communication speed: **9600** or **115200** baud. |
| **Info bits** | Selects the number od info bits you want to send: **5-9**. |

These parameters must match the settings of the connected PC terminal to ensure successful communication. A mismatch in baud rate, parity, or stop bits may result in corrupted data or no visible transmission at all.
