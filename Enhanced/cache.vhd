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
		CPUe		:  in std_logic;
		address	:	in std_logic_vector(10 downto 0);
		word_in	:  in std_logic_vector(15 downto 0);
		block_in	:	in std_logic_vector(63 downto 0);
		word_out :	out std_logic_vector(15 downto 0);
		block_out:  out std_logic_vector(63 downto 0);
		outAddress: out std_logic_vector(10 downto 0);
		hit      :  out std_logic
);
end;

architecture behv of cache	 is			

type tag_list is array(3 downto 0) of std_logic_vector(8 downto 0);
type state_type is (Write, Read);
signal cache_state: state_type;


-- The cache memory
type cache_type is array(3 downto 0, 3 downto 0) of std_logic_vector(15 downto 0);
signal cache_mem : cache_type := (others => (others => "ZZZZZZZZZZZZZZZZ"));

-- Idenifiers of tags in the array
signal tags : tag_list;

signal counter : integer := 0;

-- Identifiers of the address for this cache memory architecture
signal tag : std_logic_vector(10 downto 2);
signal word : std_logic_vector(1 downto 0);

signal hBuf : std_logic;
signal writeCounter : unsigned(4 downto 0) := "00000";
signal writeBuffer : std_logic_vector(63 downto 0);
signal flag 		 : std_logic;
signal outWordBuf : std_logic_vector(15 downto 0);
signal outBlockBuf: std_logic_vector(63 downto 0);
begin

	tag <= address(10 downto 2);
	word <= address(1 downto 0);
	
	
	cache: process(clock, Mwe, Mre, address, word_in, block_in)
	begin
		if(clock'event and clock = '1') then
			if(rst = '1') then
				cache_mem <= (others => (others => "ZZZZZZZZZZZZZZZZ"));
				hBuf <= '1';
				outWordBuf <= "ZZZZZZZZZZZZZZZZ";
			end if;
			
			-- Compare all tags with incoming address
			if(tags(0) = tag) then
				if(Mre = '1') then
					outWordBuf <= cache_mem(0, to_integer(unsigned(word)));
					outBlockBuf(15 downto 0)  <= cache_mem(0,0);
					outBlockBuf(31 downto 16) <= cache_mem(0,1);
					outBlockBuf(47 downto 32) <= cache_mem(0,2);
					outBlockBuf(63 downto 48) <= cache_mem(0,3);
				elsif(Mwe = '1') then
					if(CPUe = '1') then
						cache_mem(0, to_integer(unsigned(word))) <= word_in;
					else 
						cache_mem(0, 0) <= block_in(15 downto 0);
						cache_mem(0, 1) <= block_in(31 downto 16);
						cache_mem(0, 2) <= block_in(47 downto 32);
						cache_mem(0, 3) <= block_in(63 downto 48);
					end if;
				end if;
				hBuf <= '1';
			elsif(tags(1) = tag) then
				if(Mre = '1') then
					outWordBuf <= cache_mem(1, to_integer(unsigned(word)));
					outBlockBuf(15 downto 0)  <= cache_mem(1,0);
					outBlockBuf(31 downto 16) <= cache_mem(1,1);
					outBlockBuf(47 downto 32) <= cache_mem(1,2);
					outBlockBuf(63 downto 48) <= cache_mem(1,3);
				elsif(Mwe = '1') then
					if(CPUe = '1') then
						cache_mem(1, to_integer(unsigned(word))) <= word_in;
					else 
						cache_mem(1, 0) <= block_in(15 downto 0);
						cache_mem(1, 1) <= block_in(31 downto 16);
						cache_mem(1, 2) <= block_in(47 downto 32);
						cache_mem(1, 3) <= block_in(63 downto 48);
					end if;
				end if;
				hBuf <= '1';
			elsif(tags(2) = tag) then
				if(Mre = '1') then
					outWordBuf <= cache_mem(2, to_integer(unsigned(word)));
					outBlockBuf(15 downto 0)  <= cache_mem(2,0);
					outBlockBuf(31 downto 16) <= cache_mem(2,1);
					outBlockBuf(47 downto 32) <= cache_mem(2,2);
					outBlockBuf(63 downto 48) <= cache_mem(2,3);
				elsif(Mwe = '1') then
					if(CPUe = '1') then
						cache_mem(2, to_integer(unsigned(word))) <= word_in;
					else 
						cache_mem(2, 0) <= block_in(15 downto 0);
						cache_mem(2, 1) <= block_in(31 downto 16);
						cache_mem(2, 2) <= block_in(47 downto 32);
						cache_mem(2, 3) <= block_in(63 downto 48);
					end if;
				end if;
				hBuf <= '1';
			elsif(tags(3) = tag) then
				if(Mre = '1') then
					outWordBuf <= cache_mem(3, to_integer(unsigned(word)));
					outBlockBuf(15 downto 0)  <= cache_mem(3,0);
					outBlockBuf(31 downto 16) <= cache_mem(3,1);
					outBlockBuf(47 downto 32) <= cache_mem(3,2);
					outBlockBuf(63 downto 48) <= cache_mem(3,3);
				elsif(Mwe = '1') then
					if(CPUe = '1') then
						cache_mem(3, to_integer(unsigned(word))) <= word_in;
					else 
						cache_mem(3, 0) <= block_in(15 downto 0);
						cache_mem(3, 1) <= block_in(31 downto 16);
						cache_mem(3, 2) <= block_in(47 downto 32);
						cache_mem(3, 3) <= block_in(63 downto 48);
					end if;
				end if;
				hBuf <= '1';
			else
				outWordBuf <= "ZZZZZZZZZZZZZZZZ";
				hBuf <= '0';
				if(flag = '0') then
					flag <= '1';
					writeBuffer(15 downto 0) <= cache_mem(counter, 0);
					writeBuffer(31 downto 16) <= cache_mem(counter, 1);
					writeBuffer(47 downto 32) <= cache_mem(counter, 2);
					writeBuffer(63 downto 48) <= cache_mem(counter, 3);
					
				end if;
				outBlockBuf(15 downto 0)  <= writeBuffer(15 downto 0);
				outBlockBuf(31 downto 16) <= writeBuffer(31 downto 16);
				outBlockBuf(47 downto 32) <= writeBuffer(47 downto 32);
				outBlockBuf(63 downto 48) <= writeBuffer(63 downto 48);
				outAddress(10 downto 2) <= tags(counter);
				
				cache_mem(counter, 0) <= block_in(15 downto 0);
				cache_mem(counter, 1) <= block_in(31 downto 16);
				cache_mem(counter, 2) <= block_in(47 downto 32);
				cache_mem(counter, 3) <= block_in(63 downto 48);
				
				writeCounter <= writeCounter + 1;
				if(writeCounter = 19) then
					writeCounter <= "00000";
					tags(counter) <= tag;
					counter <= (counter + 1) mod 4;
					flag <= '0';
				end if;
			end if;
		end if;
	end process;
	hit <= hBuf;
	word_out <= outWordBuf;
	block_out <= outBlockBuf;
end behv;



