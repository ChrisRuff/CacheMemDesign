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
		data_out:	out std_logic_vector(15 downto 0);
		data_ready: out std_logic
);
end;

architecture behv of cachecontroller is		
	
	signal outBuf 							: std_logic_vector(15 downto 0);
	signal mem2Cache, cache2Mem		: std_logic_vector(63 downto 0);
	signal outAddress						: std_logic_vector(10 downto 0);
	signal memAddress						: std_logic_vector(10 downto 0);
	
	signal memRead, memWrite			: std_logic;
	signal CPUe								: std_logic;
	signal hit 								: std_logic;
begin
	cacheController: process(clock, rst)
	begin
		if(clock'event and clock = '1') then
			if(hit = '1') then
				data_ready <= '1';
				CPUe <= '1';
			elsif(hit = '0') then
				data_ready <= '0';
				memWrite <= '1';
				memRead <= '1';
				outBuf <= "ZZZZZZZZZZZZZZZZ";
				CPUe <= '0';
			end if;
		end if;

	end process;
	
	Unit2: cache port map(clock, rst, Mre, Mwe, CPUe, address, data_in, mem2Cache, outBuf, cache2Mem, outAddress, hit);

	Unit3: memory port map(clock ,rst, memRead, memWrite, address, outAddress, cache2Mem, mem2Cache);
	
	data_out <= outBuf;
end behv;