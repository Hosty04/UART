library ieee;
use ieee.std_logic_1164.all;

entity tb_uart_rx is
end tb_uart_rx;

architecture tb of tb_uart_rx is

    component uart_rx
        port (clk        : in std_logic;
              rst        : in std_logic;
              rx         : in std_logic;
              data       : out std_logic_vector (7 downto 0);
              data_valid : out std_logic);
    end component;

    signal clk        : std_logic;
    signal rst        : std_logic;
    signal rx         : std_logic;
    signal data       : std_logic_vector (7 downto 0);
    signal data_valid : std_logic;

    constant TbPeriod : time := 10 ns;
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : uart_rx
    port map (clk        => clk,
              rst        => rst,
              rx         => rx,
              data       => data,
              data_valid => data_valid);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    clk <= TbClock;

    stimuli : process

    procedure uart_send_byte(signal line : out std_logic; constant byte : std_logic_vector(7 downto 0)) is
    begin
        -- IDLE
        line <= '1';
        wait for 80 ns;
        
        -- START BIT
        line <= '0';
        wait for 80 ns;
        
        -- DATA BITS
        for i in 0 to 7 loop
            line <= byte(i);
            wait for 80 ns;
        end loop;
        
        -- STOP BIT
        line <= '1';
        wait for 80 ns;
        
        -- GAP
        wait for 160 ns;
    end procedure;
    
    begin
        rx <= '1';
        
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait for 20 ns;
        
        uart_send_byte(rx, "10101100");
        
        TbSimEnded <= '1';
        wait;
    end process;

end tb;