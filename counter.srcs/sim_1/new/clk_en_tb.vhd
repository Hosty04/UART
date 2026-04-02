library ieee;
use ieee.std_logic_1164.all;

---------------------------

entity tb_clk_en is
end tb_clk_en;

---------------------------

architecture tb of tb_clk_en is
    -- Deklarace testované komponenty
    component clk_en
        generic(
            G_MAX : positive
        );
        port (clk : in std_logic;
              rst : in std_logic;
              ce  : out std_logic);
    end component;

    signal clk : std_logic;
    signal rst : std_logic;
    signal ce  : std_logic;

    constant TbPeriod : time := 10 ns; -- ***EDIT*** Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin
    -- Instanciace testované komponenty, DUT
    dut : clk_en
    generic map (
        G_MAX => 10
    )
    port map (clk => clk,
              rst => rst,
              ce  => ce);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    clk <= TbClock;

    stimuli : process
    begin
        -- Reset generation
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;

        -- ***EDIT*** Add stimuli here
        wait for 100 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

---------------------------

configuration cfg_tb_clk_en of tb_clk_en is
    for tb
    end for;
end cfg_tb_clk_en;