------------------------------------------------------------------
-- Simple Computer Architecture
--
-- System composed of
-- 	CPU, Memory and output buffer
--    Sinals with the prefix "D_" are set for Debugging purpose only
-- SimpleCompArch.vhd
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;  
use ieee.numeric_std.all;			   
use work.MP_lib.all;

entity SimpleCompArch is
port( sys_clk								:	in std_logic;
		  sys_rst							:	in std_logic;
		  sys_output						:	out std_logic_vector(15 downto 0);
		
		-- Debug signals from CPU: output for simulation purpose only	
		D_rfout_bus											: out std_logic_vector(15 downto 0);  
		D_RFwa, D_RFr1a, D_RFr2a				: out std_logic_vector(3 downto 0);
		D_RFwe, D_RFr1e, D_RFr2e				: out std_logic;
		D_RFs 										: out std_logic_vector(1 downto 0);
		D_ALUs										: out std_logic_vector(2 downto 0);
		D_PCld, D_jpz										: out std_logic;
		-- end debug variables	

		-- Debug signals from Memory: output for simulation purpose only	
		D_mdout_bus,D_mdin_bus					: out std_logic_vector(15 downto 0); 
		D_mem_addr											: out std_logic_vector(10 downto 0); 
		D_Mre,D_Mwe										: out std_logic;
		D_data_out_cache: out std_logic_vector(15 downto 0);
		D_cache2mem, D_mem2cache: out std_logic_vector(63 downto 0);
		D_miss: out std_logic;
		D_tag: out std_logic_vector(8 downto 0);
		D_memRead : out std_logic;
		D_memWrite : out std_logic;
		D_memBusy : out std_logic;
		D_line0								: out std_logic_vector(72 downto 0);
		D_line1								: out std_logic_vector(72 downto 0);
		D_line2								: out std_logic_vector(72 downto 0);
		D_line3								: out std_logic_vector(72 downto 0);
		D_data_ready						: out std_logic;
		D_memReady							: out std_logic
		-- end debug variables	
);
end;

architecture rtl of SimpleCompArch is
--Memory local variables												  							        							(ORIGIN	-> DEST)
	signal mdout_bus					: std_logic_vector(15 downto 0);  -- Mem data output 		(MEM  	-> CTLU)
	signal mdin_bus					: std_logic_vector(15 downto 0);  -- Mem data bus input 	(CTRLER	-> Mem)
	signal mem_addr					: std_logic_vector(10 downto 0);   -- Const. operand addr.(CTRLER	-> MEM)
	signal Mre							: std_logic;							 -- Mem. read enable  	(CTRLER	-> Mem) 
	signal Mwe							: std_logic;							 -- Mem. write enable 	(CTRLER	-> Mem)
	
	signal data_ready 				: std_logic;
	signal memReady					: std_logic;
	--System local variables
	signal oe							: std_logic;	
begin

Unit1: CPU port map (sys_clk,sys_rst,mdout_bus,mdin_bus,mem_addr,Mre,Mwe,oe, data_ready,
										D_rfout_bus,D_RFwa, D_RFr1a, D_RFr2a,D_RFwe, 			 				--Degug signals
										D_RFr1e, D_RFr2e,D_RFs, D_ALUs,D_PCld, D_jpz);	 						--Degug signals
																					
--Unit2: cache_controller port map(sys_clk,sys_rst,Mre,Mwe,mem_addr,mdin_bus,mdout_bus);
Unit2: cache_controller port map(sys_clk,sys_rst,Mre,Mwe,mem_addr,mdin_bus,mdout_bus,data_ready, D_data_out_cache,
										D_cache2mem, D_mem2cache,D_miss,D_tag,D_memRead,D_memWrite, D_memBusy,
										D_line0, D_line1, D_line2, D_line3, memReady);
Unit3: obuf port map(oe, mdout_bus, sys_output);

-- Debug signals: output to upper level for simulation purpose only
	D_mdout_bus <= mdout_bus;	
	D_mdin_bus <= mdin_bus;
	D_mem_addr <= mem_addr; 
	D_Mre <= Mre;
	D_Mwe <= Mwe;
	D_data_ready <= data_ready;
	D_memReady <= memReady;
-- end debug variables		
	
	
	
end rtl;