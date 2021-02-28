--------------------------------------------------------
-- SSimple Computer Architecture
--
-- memory 256*16
-- 11 bit address; 16 bit data
-- memory.vhd
--------------------------------------------------------

library	ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;   
use work.MP_lib.all;

entity cache is
port (clock   	: 	in std_logic;
		rst		: 	in std_logic;
		Mre		:	in std_logic;
		Mwe		:	in std_logic;
		address	:	in std_logic_vector(10 downto 0);
		data_in	:	in std_logic_vector(15 downto 0);
		data_out :	out std_logic_vector(15 downto 0);
		hit      :  out std_logic
);
end;

architecture behv of cache	 is			

-- The cache memory
type cache_type is array (1 downto 0)
						of array(1 downto 0)
							of std_logic_vector(15 downto 0);
signal cache_mem : cache_type;

-- Track order of tags loaded for replacement
signal freq : is array(1 downto 0) of std_logic_vector(1 downto 0);

-- Identifiers of the address for this cache memory architecture
signal tag : std_logic_vector(1 downto 0);
signal word : std_logic_vector(8 downto 0);

signal t : std_logic_vector(15 downto 0);
begin
	tag <= address(10 downto 9);
	word <= address(8 downto 0);
	t <= cache_mem(tag)(word);
	write: process(clock, Mwe, address, data_in, t, data_out)
	begin
		if(clock'event and clock = '1' and Mwe = '1')
			data_out <= t;
			cache_mem(tag)(word) <= data_in;
		end if;
	end process;
	read: process(clock, address, data_out, hit)
	end process;
end behv;