library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx is
    Port (
        clk         : in  STD_LOGIC;
        rst         : in  STD_LOGIC;
        rx          : in  STD_LOGIC;
        data        : out STD_LOGIC_VECTOR (7 downto 0);
        data_valid  : out STD_LOGIC
    );
end uart_rx;

architecture Behavioral of uart_rx is

    constant CLK_FREQ  : integer := 100_000_000;
    constant BAUDRATE  : integer := 9600;
    constant MAX_COUNT : integer := CLK_FREQ / BAUDRATE;

    type state_type is (IDLE, TRANSMIT_START_BIT, TRANSMIT_DATA_BITS, TRANSMIT_STOP_BIT);
    signal state : state_type := IDLE;

    signal baud_cnt  : integer := 0;
    signal bit_index : integer range 0 to 7 := 0;

    signal shift_reg : std_logic_vector(7 downto 0);

begin

    process(clk)
    begin
        if rising_edge(clk) then

            if rst = '1' then
                state       <= IDLE;
                data_valid  <= '0';
                baud_cnt    <= 0;
                bit_index   <= 0;
                shift_reg   <= (others => '0');
                data        <= (others => '0');

            else
                case state is

                    when IDLE =>
                        data_valid <= '0';

                        if rx = '0' then
                            state     <= TRANSMIT_START_BIT;
                            baud_cnt  <= 0;
                        end if;

                    when TRANSMIT_START_BIT =>
                        if baud_cnt = MAX_COUNT/2 then
                            if rx = '0' then
                                baud_cnt  <= 0;
                                bit_index <= 0;
                                state     <= TRANSMIT_DATA_BITS;
                            else
                                state <= IDLE;
                            end if;
                        else
                            baud_cnt <= baud_cnt + 1;
                        end if;

                    when TRANSMIT_DATA_BITS =>
                        if baud_cnt = MAX_COUNT - 1 then
                            baud_cnt <= 0;

                            shift_reg <= rx & shift_reg(7 downto 1);

                            if bit_index = 7 then
                                state <= TRANSMIT_STOP_BIT;
                            else
                                bit_index <= bit_index + 1;
                            end if;
                        else
                            baud_cnt <= baud_cnt + 1;
                        end if;

                    when TRANSMIT_STOP_BIT =>
                        if baud_cnt = MAX_COUNT - 1 then
                            baud_cnt <= 0;
                            state    <= IDLE;
                            if rx = '1' then
                                data       <= shift_reg;
                                data_valid <= '1';
                            else
                                data_valid <= '0';
                            end if;
                        else
                            baud_cnt <= baud_cnt + 1;
                        end if;

                end case;
            end if;
        end if;
    end process;

end Behavioral;