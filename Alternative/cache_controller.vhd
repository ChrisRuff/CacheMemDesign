----------------------------------------------------------------
-- Simple Microprocessor Design (ESD Book Chapter 3)
-- Copyright 2001 Weijun Zhang
--
-- DATAPATH composed of Multiplexor, Register File and ALU
-- VHDL structural modeling
-- datapath.vhd
----------------------------------------------------------------

library	ieee;
use ieee.std_logic_1164.all;  
use ieee.std_logic_arith.all;			   
use ieee.std_logic_unsigned.all;
use work.MP_lib.all;

entity cache_controller is				
port(	
	 	clock_cc								: 	in std_logic;
		rst_cc								: 	in std_logic;
		Mre_cc								:	in std_logic;
		Mwe_cc								:	in std_logic;
		address_cc							:	in std_logic_vector(10 downto 0);
		data_in_cc							:	in std_logic_vector(15 downto 0);
		data_out_cc							:	out std_logic_vector(15 downto 0);
		data_ready							:  out std_logic;
		
		-- DEBUG SIGNALS
		D_data_out_cache					: out std_logic_vector(15 downto 0);
		D_cache2mem, D_mem2cache		: out std_logic_vector(63 downto 0);
		D_miss								: out std_logic;
		D_tag									: out std_logic_vector(8 downto 0);
		D_memRead 							: out std_logic;
		D_memWrite 							: out std_logic;
		D_memBusy 							: out std_logic;
		D_line0								: out std_logic_vector(72 downto 0);
		D_line1								: out std_logic_vector(72 downto 0);
		D_line2								: out std_logic_vector(72 downto 0);
		D_line3								: out std_logic_vector(72 downto 0)
		-- DEBUG SIGNALS
);
end;

architecture struct of cache_controller is

signal data_out_cache: std_logic_vector(15 downto 0);
signal cache2mem, mem2cache: std_logic_vector(63 downto 0);
signal miss: std_logic := '0';
signal tag: std_logic_vector(8 downto 0);
signal memRead : std_logic := '0';
signal memWrite : std_logic := '0';

begin		

  --cache ports
  U1: cache port map(clock_cc, rst_cc, Mre_cc, Mwe_cc, address_cc, data_in_cc, mem2cache, cache2mem, data_out_cache,
							miss, tag, memRead, memWrite, data_ready, D_memBusy, D_line0, D_line1, D_line2, D_line3);
  -- memory ports
  U2: memory port map(clock_cc, rst_cc, memRead, memWrite, cache2mem, miss, tag, mem2cache);
			 
  data_out_cc <= data_out_cache;
   
  D_data_out_cache <= data_out_cache;
  D_cache2mem <= cache2mem;
  D_mem2cache <= mem2cache;
  D_miss <= miss;
  D_tag <= tag;
  D_memRead <= memRead;
  D_memWrite <= memWrite;
end struct;