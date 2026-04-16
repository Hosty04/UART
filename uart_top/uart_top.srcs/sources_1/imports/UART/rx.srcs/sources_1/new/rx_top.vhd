library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx is
    port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        rx         : in  std_logic;
        settings   : in  std_logic_vector(5 downto 0);
        data_out   : out std_logic_vector(7 downto 0);
        data_valid : out std_logic;
        fifo_wr_en : out std_logic
    );
end entity;

architecture rtl of uart_rx is

    -- předpoklad: clk = 100 MHz
    constant BAUD_9600   : integer := 100_000_000 / 9600;
    constant BAUD_115200 : integer := 100_000_000 / 115200;

    type state_t is (IDLE, START, DATA, PARITY, STOP);
    signal state      : state_t := IDLE;

    signal baud_cnt   : integer range 0 to BAUD_9600 := 0;
    signal baud_tick  : std_logic := '0';

    signal rx_sync    : std_logic_vector(1 downto 0) := (others => '1');
    signal rx_reg     : std_logic := '1';

    signal bit_cnt    : integer range 0 to 8 := 0;
    signal data_bits  : integer range 5 to 9 := 8;

    signal use_parity : std_logic;
    signal two_stop   : std_logic;
    signal baud_sel   : std_logic;

    signal shift_reg  : std_logic_vector(8 downto 0) := (others => '0');
    signal stop_cnt   : integer range 1 to 2 := 1;

begin

    -- synchronizace RX
    process(clk, rst)
    begin
        if rst = '1' then
            rx_sync <= (others => '1');
            rx_reg  <= '1';
        elsif rising_edge(clk) then
            rx_sync <= rx_sync(0) & rx;
            rx_reg  <= rx_sync(1);
        end if;
    end process;

    -- dekódování settings:
    -- settings(2:0) = data bits (5-9)
    -- settings(3)   = parity enable
    -- settings(4)   = stop bits (0=1, 1=2)
    -- settings(5)   = baud (0=9600, 1=115200)
    
    process(settings)
    begin
        use_parity <= settings(3);
        case settings(2 downto 0) is
            when "000" => data_bits <= 5;
            when "001" => data_bits <= 6;
            when "010" => data_bits <= 7;
            when "011" => data_bits <= 8;
            when "100" => data_bits <= 9;
            when others => data_bits <= 8;
        end case;
        two_stop <= settings(4);
        baud_sel <= settings(5);
    end process;

    -- baud generátor
    process(clk, rst)
        variable limit : integer;
    begin
        if rst = '1' then
            baud_cnt  <= 0;
            baud_tick <= '0';
        elsif rising_edge(clk) then
            if baud_sel = '0' then
                limit := BAUD_9600;
            else
                limit := BAUD_115200;
            end if;

            if baud_cnt = limit-1 then
                baud_cnt  <= 0;
                baud_tick <= '1';
            else
                baud_cnt  <= baud_cnt + 1;
                baud_tick <= '0';
            end if;
        end if;
    end process;

    -- RX stavový automat
    process(clk, rst)
    begin
        if rst = '1' then
            state      <= IDLE;
            bit_cnt    <= 0;
            data_out   <= (others => '0');
            data_valid <= '0';
            fifo_wr_en <= '0';
            stop_cnt   <= 1;
        elsif rising_edge(clk) then
            data_valid <= '0';
            fifo_wr_en <= '0';

            if baud_tick = '1' then
                case state is

                    when IDLE =>
                        if rx_reg = '0' then
                            state <= START;
                        end if;

                    when START =>
                        -- předpoklad: vzorkujeme přesně na hraně
                        if rx_reg = '0' then
                            state   <= DATA;
                            bit_cnt <= 0;
                        else
                            state <= IDLE;
                        end if;

                    when DATA =>
                        shift_reg(bit_cnt) <= rx_reg;
                        if bit_cnt = data_bits-1 then
                            if use_parity = '1' then
                                state <= PARITY;
                            else
                                state    <= STOP;
                                stop_cnt <= 1;
                            end if;
                        else
                            bit_cnt <= bit_cnt + 1;
                        end if;

                    when PARITY =>
                        state    <= STOP;
                        stop_cnt <= 1;

                    when STOP =>
                        if two_stop = '1' then
                            if stop_cnt = 2 then
                                state      <= IDLE;
                                data_out   <= shift_reg(7 downto 0);
                                data_valid <= '1';
                                fifo_wr_en <= '1';
                            else
                                stop_cnt <= stop_cnt + 1;
                            end if;
                        else
                            state      <= IDLE;
                            data_out   <= shift_reg(7 downto 0);
                            data_valid <= '1';
                            fifo_wr_en <= '1';
                        end if;

                end case;
            end if;
        end if;
    end process;

end architecture;
