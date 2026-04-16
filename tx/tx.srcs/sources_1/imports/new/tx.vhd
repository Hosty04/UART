library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

----------------------------------------------------------

entity uart_tx is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           data : in STD_LOGIC_VECTOR (7 downto 0);
           settings : in STD_LOGIC_VECTOR (5 downto 0);
           tx_start : in STD_LOGIC;
           tx : out STD_LOGIC;
           tx_complete : out STD_LOGIC);
end uart_tx;

----------------------------------------------------------

architecture Behavioral of uart_tx is

    -- Constants for baud rate and clock frequency
    constant CLK_FREQ : integer := 100_000_000;  -- System clock frequency (100 MHz)
    constant BAUDRATE : integer := to_integer(unsigned(settings(0 downto 0)));        -- Baud rate (9600 Bd)

    -- Number of clock cycles per bit period for baud rate timing
    constant MAX : integer := CLK_FREQ / BAUDRATE;  -- 2 for simulation
                                  -- CLK_FREQ / BAUDRATE for implementation
    constant INFO_BITS : integer := to_integer(unsigned(settings(5 downto 3)));
    constant STOP_BITS : integer := to_integer(unsigned(settings(2 downto 2)));
    constant PARITY : integer := to_integer(unsigned(settings(1 downto 1)));
    
    -- FSM state definitions
    type state_type is (IDLE, TRANSMIT_START_BIT, TRANSMIT_DATA, TRANSMIT_STOP_BIT, TRANSMIT_PARITY_BIT);
    signal current_state : state_type;

    -- Internal signals
    signal current_bit_index : integer range 0 to 7;          -- Index for current bit being transmitted
    signal shift_reg         : std_logic_vector(INFO_BITS downto 0);  -- Data shift register
    signal baud_count        : integer range 0 to MAX-1;      -- Clock cycles for one bit period

begin

    -- UART Transmitter FSM process driven by the main clock (clk)
    p_transmitter : process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- Reset state, outputs, and all internal signals
                current_state     <= IDLE;             -- Start in IDLE state
                tx                <= '1';              -- UART line idle (high)
                tx_complete       <= '0';              -- Transmission not completed
                current_bit_index <= 0;                -- Reset bit index
                shift_reg         <= (others => '0');  -- Clear shift register
                baud_count        <= 0;                -- Reset the baud rate counter

            else
                case current_state is

                    -- IDLE: Wait for the start signal to begin transmission
                    when IDLE =>
                        tx <= '1';
                        tx_complete <= '0';
                        
                        if tx_start = '1' then
                            current_state <= TRANSMIT_START_BIT;
                            shift_reg <= data;       -- Load data into shift register
                            current_bit_index <= 0;  -- Start transmitting the least significant bit
                            baud_count <= 0;         -- Reset baud count for the new transmission
                        end if;

                    -- TRANSMIT_START_BIT: Transmit the start bit (low)
                    when TRANSMIT_START_BIT =>
                        tx <= '0';
                        
                        -- Wait for the baud period to complete
                        if baud_count = MAX - 1 then
                            current_state <= TRANSMIT_DATA;
                            baud_count <= 0;
                        else
                            baud_count <= baud_count + 1;
                        end if;

                    -- TRANSMIT_DATA: Transmit the 8 data bits, LSB first
                    when TRANSMIT_DATA =>
                        tx <= shift_reg(0);
                        
                        if baud_count = MAX - 1 then
                            shift_reg <= '0' & shift_reg(INFO_BITS downto 1);  -- Shift the data right by one bit

                            -- Check if all info bits data bits have been transmitted
                            if current_bit_index = INFO_BITS then
                                current_state <= TRANSMIT_STOP_BIT;
                            else
                                current_bit_index <= current_bit_index + 1;  -- Move to next bit
                            end if;

                            baud_count <= 0;  -- Reset baud counter for the next bit
                        else
                            baud_count <= baud_count + 1;  -- Increment the baud counter
                        end if;

                    -- TRANSMIT_STOP_BIT: Transmit the stop bit (high)
                    when TRANSMIT_STOP_BIT =>
                        tx <= '1';
                        current_bit_index <= 0;
                        
                        -- Wait for the baud period to complete
                        if baud_count = MAX - 1 then
                            
                            -- Check if all stop bits data bits have been transmitted
                            if current_bit_index = STOP_BITS then
                                current_state <= IDLE;
                            else
                                current_bit_index <= current_bit_index + 1;  -- Move to next bit
                            end if;

                            baud_count <= 0;  -- Reset baud counter for the next bit
                        else
                            baud_count <= baud_count + 1;  -- Increment the baud counter
                        end if;
                    
                    -- TRANSMIT_PARITY_BIT: Transmit the parity bit  (odd parity)
                    when TRANSMIT_PARITY_BIT =>
                        tx <= data(7) xor data(6) xor data(5) xor data(4) xor data(3) xor data(2) xor data(1) xor data(0);
                        tx_complete <= '1';
                        
                        -- Wait for the baud period to complete
                        if baud_count = MAX - 1 then
                            current_state <= IDLE;
                        else
                            baud_count <= baud_count + 1;  -- Increment the baud counter
                        end if;

                    -- Default: In case of an unexpected state, return to IDLE
                    when others =>
                        current_state <= IDLE;

                end case;
            end if;
        end if;
    end process p_transmitter;

end Behavioral;