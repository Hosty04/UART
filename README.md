# UART
## UART Controller with FIFO
### UART interface for PC communication, including transmit and receive logic with FIFO buffering to handle asynchronous data smoothly.

This project implements a bidirectional communication system between an FPGA board and a personal computer using the UART protocol. The design enables the user to send and receive messages via hardware inputs (switches and buttons) as well as through a PC keyboard interface.


The system includes buffering mechanisms, signal conditioning, and real-time display output using seven-segment displays.

![image alt](https://github.com/Hosty04/UART/blob/8da96e71e9938c1ad4686c9d81b785081e4742ce/UART_schema.png)
---

## Inputs
- 14 switches located on the bottom side of the FPGA board  
- 5 push buttons  
- PC keyboard (via terminal interface)  
- UART input port (`UART_TXD_IN`) via micro USB → USB-A  

---

## Outputs
- UART output port (`UART_TXD_OUT`) via micro USB → USB-A  
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

The FPGA sends the message to the PC via UART. Transmission status is indicated using LEDs and/or seven-segment displays. The received message is displayed on the PC using a serial terminal application (e.g., PuTTY).

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

### UART Receiver (`UART_RX`)
Receives serial data from the PC and, synchronized with the system clock (`CLK`), stores the incoming data into a FIFO buffer.

### FIFO Buffer
Implements a circular buffer to compensate for speed differences between data producers and consumers. It temporarily stores incoming or outgoing characters until they can be processed.

### Display Driver
Handles conversion from binary values to seven-segment display encoding (`bin_to_seg`). It enables control of multiple displays and allows simultaneous visualization of different characters.

### UART Transmitter (`UART_TX`)
Accepts communication parameters and data from the FIFO buffer and FPGA inputs. It transmits serialized data to the PC, synchronized with the system clock (`CLK`).
