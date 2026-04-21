library ieee;
use ieee.std_logic_1164.all;

entity tb_uart_tx is
end tb_uart_tx;

architecture tb of tb_uart_tx is

    component uart_tx
        port (clk         : in std_logic;
              rst         : in std_logic;
              data        : in std_logic_vector (8 downto 0);
              settings    : in std_logic_vector (5 downto 0);
              tx_start    : in std_logic;
              tx          : out std_logic;
              tx_complete : out std_logic);
    end component;

    signal clk         : std_logic;
    signal rst         : std_logic;
    signal data        : std_logic_vector (8 downto 0);
    signal settings    : std_logic_vector (5 downto 0);
    signal tx_start    : std_logic;
    signal tx          : std_logic;
    signal tx_complete : std_logic;

    constant TbPeriod : time := 10 ns;
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : uart_tx
    port map (clk         => clk,
              rst         => rst,
              data        => data,
              settings    => settings,
              tx_start    => tx_start,
              tx          => tx,
              tx_complete => tx_complete);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    clk <= TbClock;

    stimuli : process
    begin
        data <= (others => '0');
        settings <= (others => '0');
        tx_start <= '0';

        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait for 20 ns;

        settings <= "000000";
        
        -- SEND BYTE 0xA5
        data <= "010100101";
        wait for 10 ns;
        
        -- START TRANSMISSION
        tx_start <= '1';
        
        -- WAIT FOR COMPLETION
        wait until tx_complete = '1';
        
        settings <= "100111";
        
        -- SEND ANOTHER BYTE 0x3C
        data <= "000111100";
        wait for 10 ns;
        
        tx_start <= '1';
        
        wait until tx_complete = '1';
        wait for TbPeriod;
        tx_start <= '0';
        
        TbSimEnded <= '1';
        wait;
    end process;

end tb;