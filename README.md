# UART
## UART Controller with FIFO
### UART interface for PC communication, including transmit and receive logic with FIFO buffering to handle asynchronous data smoothly.

This project implements a bidirectional communication system between an FPGA board and a personal computer using the UART protocol. The design enables the user to send and receive messages via hardware inputs (switches and buttons) as well as through a PC keyboard interface.


The system includes buffering mechanisms, signal conditioning, and real-time display output using seven-segment displays.

![image alt](https://github.com/Hosty04/UART/blob/24104deb39480394566320f9d1b89f2f38fabeca/schematic/UART.svg)
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
- Eliminates unwanted signal glitches caused by mechanical button presses and releases.

[Debounce - Source file](https://github.com/Hosty04/UART/tree/d0c816b90145e416d75e810c0764adc2ca21525a/debounce/debounce.srcs)

### TX
- Accepts communication parameters and data from the FIFO buffer and FPGA inputs. It transmits serialized data to the PC, synchronized with the system clock (`CLK`). 

[TX - Source file](https://github.com/Hosty04/UART/tree/d0c816b90145e416d75e810c0764adc2ca21525a/tx/tx.srcs)

### FIFO
- Implements a circular buffer to compensate for speed differences between data producers and consumers. It temporarily stores incoming or outgoing characters until they can be processed.

[FIFO - Source file](https://github.com/Hosty04/UART/tree/d0c816b90145e416d75e810c0764adc2ca21525a/fifo/fifo.srcs)

### RX
- Receives serial data from the PC and, synchronized with the system clock (`CLK`), stores the incoming data into a FIFO buffer.

[RX - Source file](https://github.com/Hosty04/UART/tree/d0c816b90145e416d75e810c0764adc2ca21525a/rx/rx.srcs)

### Display Driver
- Handles conversion from binary values to seven-segment display encoding (`bin_to_seg`). It enables control of multiple displays and allows simultaneous visualization of different characters.

[Display Driver - Source file](https://github.com/Hosty04/UART/tree/d0c816b90145e416d75e810c0764adc2ca21525a/display/display.srcs)

---

## Settings

Communication parameters are selected using the dedicated configuration switches on the FPGA board.

The settings area controls the serial link behavior and determines how data is framed before transmission and how incoming data is interpreted by the receiver. 

| Setting     | Switch up        | Switch down     |
|-------------|-----------------|-----------------|
| **Parity**     | Enabled         | Disabled        |
| **Stop bits**   | 2               | 1               |
| **Baud rate**   | 115200          | 9600            |
| **Info bits**   | 9               | 5               |


- **Parity:** Parity is a simple error detection mechanism. When enabled, an additional bit is appended to each transmitted frame to ensure that the total number of logic '1's is either even or odd (depending on implementation). The receiver checks this bit to detect possible transmission errors.

- **Stop bit:** Stop bits indicate the end of a data frame. After transmitting the data (and optional parity bit), the line is held in a logical high state for 1 or 2 bit periods. More stop bits increase reliability but reduce effective data throughput.

- **Baud rate:** The baud rate defines the speed of data transmission in bits per second (bps). Both transmitter and receiver must be configured to the same baud rate (e.g., 9600 or 115200) to ensure correct communication.

- **Info bits:** Info bits (data bits) represent the actual payload of the transmitted frame. Common configurations range from 5 to 9 bits. Increasing the number of data bits allows transmission of a wider range of values per frame.

---

## Simulations 

### TX_max

- Simulation settings: 

| Setting | Set to |
|---|---|
| **Parity** | **1** |
| **Stop bits** | **2** |
| **Baud rate** |  **115200** |
| **Info bits** | **9** |

![image alt](https://github.com/Hosty04/UART/blob/c1735c9b8225c509bf77552a050ddf6beb17206b/simulations/tx_max.png)

### TX_min

- Simulation settings: 

| Setting | Set to |
|---|---|
| **Parity** | **0** |
| **Stop bits** | **1** |
| **Baud rate** | **9600** |
| **Info bits** | **5** |

![image alt](https://github.com/Hosty04/UART/blob/c1735c9b8225c509bf77552a050ddf6beb17206b/simulations/tx_min.png)

### RX

- The simulation shows data being input into the RX component, which acknowledges receipt of the data and sends it in an 8-bit structure to the **FIFO** component.

![image alt](https://github.com/Hosty04/UART/blob/c1735c9b8225c509bf77552a050ddf6beb17206b/simulations/rx.png)

### FIFO_wr

- The simulation demonstrates the reception of 8-bit data from the component **RX** and stores the data until the memory is full.

![image alt](https://github.com/Hosty04/UART/blob/c1735c9b8225c509bf77552a050ddf6beb17206b/simulations/fifo_wr.png)

### FIFO_rd

- The simulation shows how the **FIFO** sends signals indicating when it is full or empty and sequentially transmits data to the **Display Driver** component.

![image alt](https://github.com/Hosty04/UART/blob/c1735c9b8225c509bf77552a050ddf6beb17206b/simulations/fifo_rd.png)
