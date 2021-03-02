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

entity cachecontroller is
port ( 	clock	: 	in std_logic;
		rst		: 	in std_logic;
		Mre		:	in std_logic;
		Mwe		:	in std_logic;
		address	:	in std_logic_vector(10 downto 0);
		data_in	:	in std_logic_vector(15 downto 0);
		data_out:	out std_logic_vector(15 downto 0)
);
end;

architecture behv of cachecontroller is			
	type state_type is (not_rest, rest);
	signal cache_state: state_type;
	
	signal outBuf 							: std_logic_vector(15 downto 0);
	signal mem2Cache, cache2Mem		: std_logic_vector(63 downto 0);
	
	signal memRead, memWrite			: std_logic;
	signal CPUe								: std_logic;
	signal hit 								: std_logic;
begin
	cacheController: process(clock, rst)
	begin
		if(clock'event and clock = '1') then
			if(hit = '1') then
				CPUe <= '1';
			elsif(hit = '0' and cache_state = rest) then
				memWrite <= '1';
				memRead <= '0';
				outBuf <= "ZZZZZZZZZZZZZZZZ";
				cache_state <= not_rest;
			else
				memWrite <= '0';
				memRead <= '1';
				CPUe <= '0';
				cache_state <= rest;
				outBuf <= "ZZZZZZZZZZZZZZZZ";
			end if;
		end if;
	end process;
	
	Unit2: cache port map(clock, rst, Mre, Mwe, CPUe, address, data_in, mem2Cache, outBuf, cache2Mem, hit);

	Unit3: memory port map(clock,rst, memRead, memWrite, address, cache2Mem, mem2Cache);
	
	data_out <= outBuf;
end behv;