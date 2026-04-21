library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_tx is
    Port (
        clk         : in  STD_LOGIC;
        rst         : in  STD_LOGIC;
        data        : in  STD_LOGIC_VECTOR (8 downto 0);
        settings    : in  STD_LOGIC_VECTOR (5 downto 0);
        tx_start    : in  STD_LOGIC;
        tx          : out STD_LOGIC;
        tx_complete : out STD_LOGIC
    );
end uart_tx;

architecture Behavioral of uart_tx is

    constant CLK_FREQ : integer := 100_000_000;

    signal baudrate  : integer;
    signal max_count : integer;

    signal info_bits : integer range 5 to 9;
    signal stop_bits : integer range 1 to 2;
    signal parity    : std_logic;

    type state_type is (IDLE, TRANSMIT_START_BIT, TRANSMIT_DATA_BITS, TRANSMIT_PARITY_BIT, TRANSMIT_STOP_BITS);
    signal state : state_type := IDLE;

    signal shift_reg   : std_logic_vector(8 downto 0);
    signal bit_index   : integer range 0 to 8 := 0;
    signal baud_cnt    : integer := 0;

    signal parity_reg  : std_logic;

begin

    process(settings)
        variable baud_rate : integer;
        variable tmp       : integer;
    begin
        if settings(0) = '0' then
            baud_rate := 9600;
        else
            baud_rate := 115200;
        end if;

        baudrate  <= baud_rate;
        max_count <= CLK_FREQ / baud_rate;

        tmp := 5 + to_integer(unsigned(settings(5 downto 3)));
        if tmp > 9 then
            info_bits <= 9;
        else
            info_bits <= tmp;
        end if;

        stop_bits <= 1 + to_integer(unsigned(settings(2 downto 2)));
        parity    <= settings(1);
    end process;

    process(clk)
        variable parity_tmp : std_logic;
    begin
        if rising_edge(clk) then

            if rst = '1' then
                state        <= IDLE;
                tx           <= '1';
                tx_complete  <= '0';
                baud_cnt     <= 0;
                bit_index    <= 0;
                parity_reg   <= '0';

            else
                case state is

                    when IDLE =>
                        tx <= '1';
                        tx_complete <= '0';

                        if tx_start = '1' then
                            shift_reg <= data;
                            
                            parity_tmp := '0';
                            for i in 0 to 8 loop
                                if i < info_bits then
                                    parity_tmp := parity_tmp xor data(i);
                                end if;
                            end loop;

                            parity_reg <= parity_tmp;

                            state     <= TRANSMIT_START_BIT;
                            baud_cnt  <= 0;
                        end if;

                    when TRANSMIT_START_BIT =>
                        tx <= '0';

                        if baud_cnt = max_count - 1 then
                            baud_cnt  <= 0;
                            bit_index <= 0;
                            state     <= TRANSMIT_DATA_BITS;
                        else
                            baud_cnt <= baud_cnt + 1;
                        end if;

                    when TRANSMIT_DATA_BITS =>
                        tx <= shift_reg(0);

                        if baud_cnt = max_count - 1 then
                            baud_cnt  <= 0;
                            shift_reg <= '0' & shift_reg(8 downto 1);

                            if bit_index = info_bits - 1 then
                                if parity = '1' then
                                    state <= TRANSMIT_PARITY_BIT;
                                else
                                    state <= TRANSMIT_STOP_BITS;
                                    bit_index <= 0;
                                end if;
                            else
                                bit_index <= bit_index + 1;
                            end if;
                        else
                            baud_cnt <= baud_cnt + 1;
                        end if;

                    when TRANSMIT_PARITY_BIT =>
                        tx <= parity_reg;

                        if baud_cnt = max_count - 1 then
                            baud_cnt  <= 0;
                            state     <= TRANSMIT_STOP_BITS;
                            bit_index <= 0;
                        else
                            baud_cnt <= baud_cnt + 1;
                        end if;

                    when TRANSMIT_STOP_BITS =>
                        tx <= '1';

                        if baud_cnt = max_count - 1 then
                            baud_cnt <= 0;

                            if bit_index = stop_bits - 1 then
                                state       <= IDLE;
                                tx_complete <= '1';
                            else
                                bit_index <= bit_index + 1;
                            end if;
                        else
                            baud_cnt <= baud_cnt + 1;
                        end if;

                end case;
            end if;
        end if;
    end process;

end Behavioral;