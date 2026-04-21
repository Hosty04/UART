library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_fifo is
end tb_fifo;

architecture tb of tb_fifo is

    constant DATA_WIDTH : positive := 9;
    constant ADDR_WIDTH : positive := 4;

    component fifo
        generic (
            DATA_WIDTH : positive := 9;
            ADDR_WIDTH : positive := 4
        );
        port (
            clk      : in std_logic;
            rst      : in std_logic;
            wr_en    : in std_logic;
            data_in  : in std_logic_vector (DATA_WIDTH-1 downto 0);
            rd_en    : in std_logic;
            data_out : out std_logic_vector (DATA_WIDTH-1 downto 0);
            full     : out std_logic;
            empty    : out std_logic
        );
    end component;

    signal clk      : std_logic;
    signal rst      : std_logic;
    signal wr_en    : std_logic;
    signal data_in  : std_logic_vector (DATA_WIDTH-1 downto 0);
    signal rd_en    : std_logic;
    signal data_out : std_logic_vector (DATA_WIDTH-1 downto 0);
    signal full     : std_logic;
    signal empty    : std_logic;

    constant TbPeriod : time := 10 ns;
    signal TbClock    : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : fifo
        generic map (
            DATA_WIDTH => DATA_WIDTH,
            ADDR_WIDTH => ADDR_WIDTH
        )
        port map (
            clk      => clk,
            rst      => rst,
            wr_en    => wr_en,
            data_in  => data_in,
            rd_en    => rd_en,
            data_out => data_out,
            full     => full,
            empty    => empty
        );

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    clk <= TbClock;

    stimuli : process
    begin
        wr_en <= '0';
        data_in <= (others => '0');
        rd_en <= '0';
        
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait for 20 ns;
        
        -- WRITE PHASE
        for i in 0 to 20 loop
            wr_en <= '1';
            data_in <= std_logic_vector(to_unsigned(i, DATA_WIDTH));
            wait for 10 ns;
        end loop;
        
        wr_en <= '0';
        
        wait for 40 ns;
        
        -- READ PHASE
        for i in 0 to 20 loop
            rd_en <= '1';
            wait for 10 ns;
        end loop;
        
        rd_en <= '0';
        
        TbSimEnded <= '1';
        wait;
    end process;

end tb;