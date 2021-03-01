--------------------------------------------------------
-- SSimple Computer Architecture
--
-- memory 256*16
-- 11 bit address; 16 bit data
-- memory.vhd
--------------------------------------------------------

library	ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
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

type tag_list is array(1 downto 0) of std_logic_vector(8 downto 0);

-- The cache memory
type cache_type is array(1 downto 0, 1 downto 0) of std_logic_vector(15 downto 0);
signal cache_mem : cache_type := (others => (others => "ZZZZ"));

-- Idenifiers of tags in the array
signal tags : tag_list;

signal counter : integer := 0;

-- Identifiers of the address for this cache memory architecture
signal tag : std_logic_vector(10 downto 2);
signal word : std_logic_vector(1 downto 0);

signal hBuf : std_logic;
signal outBuf : std_logic_vector(15 downto 0);
begin

	tag <= address(10 downto 2);
	word <= address(1 downto 0);
	write: process(clock, Mwe, address, data_in, tag, word)
	begin
		if(clock'event and clock = '1' and rst = '1') then
			cache_mem <= (others => (others => "ZZZZ"));
		elsif(clock'event and clock = '1' and Mwe = '1') then
			tags(counter) <= tag;
			
			-- Write out to main mem if there is a value
			if(not(cache_mem(counter, to_integer(unsigned(word))) = "ZZZZ")) then
				outBuf <= cache_mem(counter, to_integer(unsigned(word)));
			end if;
			
			-- Replace value in cache memory
			cache_mem(counter, to_integer(unsigned(word))) <= data_in;
			
			-- Increment to keep track of next replacement tag
			counter <= (counter + 1) mod 4;
		end if;
	end process;
	read: process(clock, address, tag, word, hBuf, outBuf)
	begin
		if(clock'event and clock = '1' and rst = '1') then
			hBuf <= '1';
			outBuf <= "ZZZZ";
		elsif(clock'event and clock = '1' and Mre = '1') then
			-- Compare all tags with incoming read address
			if(tags(0) = tag) then
				outBuf <= cache_mem(0, to_integer(unsigned(word)));
				hBuf <= '1';
			elsif(tags(1) = tag) then
				outBuf <= cache_mem(1, to_integer(unsigned(word)));
				hBuf <= '1';
			elsif(tags(2) = tag) then
				outBuf <= cache_mem(2, to_integer(unsigned(word)));
				hBuf <= '1';
			elsif(tags(3) = tag) then
				outBuf <= cache_mem(3, to_integer(unsigned(word)));
				hBuf <= '1';
			else
				outBuf <= "ZZZZ";
				hBuf <= '0';
			end if;
		end if;
	end process;
	hit <= hBuf;
	data_out <= outBuf;
end behv;