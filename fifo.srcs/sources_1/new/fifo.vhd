library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo is
  generic (
    DATA_WIDTH : positive := 8;
    ADDR_WIDTH : positive := 4
  );
  port (
    clk        : in  std_logic;
    rst        : in  std_logic;
    wr_en      : in  std_logic;
    data_in    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    rd_en      : in  std_logic;
    data_out   : out std_logic_vector(DATA_WIDTH-1 downto 0);
    data_valid : out std_logic;
    full       : out std_logic;
    empty      : out std_logic
  );
end entity fifo;

architecture Behavioral of fifo is

  constant DEPTH : natural := 2**ADDR_WIDTH;

  type ram_t is array (0 to DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
  signal ram : ram_t;

  signal wr_ptr : unsigned(ADDR_WIDTH downto 0) := (others => '0');
  signal rd_ptr : unsigned(ADDR_WIDTH downto 0) := (others => '0');

  signal wr_addr : unsigned(ADDR_WIDTH-1 downto 0);
  signal rd_addr : unsigned(ADDR_WIDTH-1 downto 0);

  signal full_i  : std_logic;
  signal empty_i : std_logic;

  type state_t is (IDLE, DUMP);
  signal state   : state_t := IDLE;
  signal dumping : std_logic;

begin

  wr_addr <= wr_ptr(ADDR_WIDTH-1 downto 0);
  rd_addr <= rd_ptr(ADDR_WIDTH-1 downto 0);

  empty_i <= '1' when wr_ptr = rd_ptr else '0';
  full_i  <= '1' when (wr_ptr(ADDR_WIDTH) /= rd_ptr(ADDR_WIDTH)) and 
                      (wr_ptr(ADDR_WIDTH-1 downto 0) = rd_ptr(ADDR_WIDTH-1 downto 0)) 
                 else '0';

  dumping <= '1' when state = DUMP else '0';

  full    <= full_i;
  empty   <= empty_i;
  data_out <= ram(to_integer(rd_addr));
  data_valid    <= dumping;

  -- Write process
  write_p : process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        wr_ptr <= (others => '0');
      elsif wr_en = '1' and full_i = '0' and dumping = '0' then
        ram(to_integer(wr_addr)) <= data_in;
        wr_ptr <= wr_ptr + 1;
      end if;
    end if;
  end process write_p;

  -- Read / Dump process
  read_p : process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        rd_ptr <= (others => '0');
        state  <= IDLE;
      else
        case state is
          when IDLE =>
            if rd_en = '1' and empty_i = '0' then
              state  <= DUMP;
              rd_ptr <= rd_ptr + 1;
            end if;

          when DUMP =>
            if empty_i = '0' then
              rd_ptr <= rd_ptr + 1;
            else
              state <= IDLE;
            end if;
        end case;
      end if;
    end if;
  end process read_p;

end architecture Behavioral;