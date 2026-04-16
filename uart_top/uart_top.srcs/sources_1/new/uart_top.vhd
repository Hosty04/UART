library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity uart_top is
    Port ( clk      : in STD_LOGIC;
           btnd     : in STD_LOGIC;
           btnu     : in STD_LOGIC;
           btnc     : in STD_LOGIC;
           sw       : in STD_LOGIC_VECTOR (15 downto 0);
           ja2      : in STD_LOGIC;
           ja1      : out STD_LOGIC;
           led16_g  : out STD_LOGIC;
           led16_b  : out STD_LOGIC;
           led16_r  : out STD_LOGIC;
           an       : out STD_LOGIC_VECTOR (7 downto 0);
           dp       : out STD_LOGIC;
           seg      : out STD_LOGIC_VECTOR (6 downto 0);
           led17_g  : out STD_LOGIC;
           led17_b  : out STD_LOGIC;
           led17_r  : out STD_LOGIC);
end uart_top;

architecture Behavioral of uart_top is

component debounce is
    Port ( clk       : in STD_LOGIC;
           rst       : in STD_LOGIC;
           btn_in    : in STD_LOGIC;
           btn_state : out STD_LOGIC;
           btn_press : out STD_LOGIC);
end component debounce;

component display_top is
    Port ( clk  : in STD_LOGIC;
           btnu : in STD_LOGIC;
           sw   : in STD_LOGIC_VECTOR (7 downto 0);
           seg  : out STD_LOGIC_VECTOR (6 downto 0);
           an   : out STD_LOGIC_VECTOR (7 downto 0);
           dp   : out STD_LOGIC);
end component display_top;

component fifo is
  Generic (
    DATA_WIDTH : positive := 8;
    ADDR_WIDTH : positive := 4
  );
  Port (
    clk           : in  std_logic;
    rst           : in  std_logic;
    wr_en         : in  std_logic;
    data_in       : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    rd_en         : in  std_logic;
    data_out      : out std_logic_vector(DATA_WIDTH-1 downto 0);
    data_valid    : out std_logic;
    full          : out std_logic;
    empty         : out std_logic;
  );
end component fifo;

component uart_rx is
    Port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        rx         : in  std_logic;
        settings   : in  std_logic_vector(5 downto 0);
        data       : out std_logic_vector(7 downto 0);
        data_valid : out std_logic
    );
end component uart_rx;

component uart_tx is
    Port ( clk           : in STD_LOGIC;
           rst           : in STD_LOGIC;
           data          : in STD_LOGIC_VECTOR (7 downto 0);
           settings      : in STD_LOGIC_VECTOR (5 downto 0);
           tx_start      : in STD_LOGIC;
           tx            : out STD_LOGIC;
           tx_complete   : out STD_LOGIC);
end component uart_tx;

signal sig_wr_en_tx: std_logic;
signal sig_data_rx: std_logic;
signal sig_start_rx: std_logic_vector(7 downto 0);

begin

uart_rx0 : uart_rx
port map (
    clk          => clk, 
    rst          => btnd,
    rx           => ja2,
    settings     => sw,
    data         => sig_data_rx ,
    data_valid   => sig_start_rx

);


debounce0 : debounce
port map (
    clk       => clk,
    rst       => btnd,
    btn_in    => btnu,
    btn_state => sig_wr_en_tx,
    btn_press => open
);

fifo0 : fifo
generic map (
    DATA_WIDTH : positive := 8
    ADDR_WIDTH : positive := 4
)
port map (
     clk         =>   clk,
     rst         =>   rst,  
     wr_en       =>   sig_wr_en_tx,  
     data_in     =>   sw,
     rd_en       =>   sig_rd_en_tx, 
     data_out    =>   sig_data_tx,   
     data_valid  =>   sig_start,
     full        =>   led16_r,
     empty       =>   led16_b
);
end Behavioral;
