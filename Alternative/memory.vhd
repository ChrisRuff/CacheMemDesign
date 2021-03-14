--------------------------------------------------------
-- SSimple Computer Architecture
--
-- memory 256*16
-- 8 bit address; 16 bit data
-- memory.vhd
--------------------------------------------------------

library	ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;   
use work.MP_lib.all;

entity memory is
port ( 	clock	: 	in std_logic;
		rst		: 	in std_logic;
		Mre		:	in std_logic;
		Mwe		:	in std_logic;
		data_in	:	in std_logic_vector(72 downto 0);
		miss		:	in std_logic;
		tag		:	in std_logic_vector(8 downto 0);
		memReady :  out std_logic;
		data_out :	out std_logic_vector(63 downto 0);
		memDelay :  out std_logic
);
end;

architecture behv of memory	 is			

type ram_type is array (0 to 2047) of std_logic_vector(15 downto 0);
signal tmp_ram: ram_type;
signal counter: integer;
signal memReady_t : std_logic;
signal memDelay_t : std_logic;
signal blah : std_logic;
begin
	write: process(clock, rst, Mre, data_in, miss, tag)
	begin				-- program to generate 10 gamma numbers
		if rst='1' then
				tmp_ram <= ( 
									0 => x"3000",         -- R0 <- #0 Holds 0
									1 => x"3101",         -- R1 <- #1 Holds 1
									2 => x"3202",         -- R2 <- #1 Counter starting at 50
									3 => x"3344",         -- R3 <-  Holds seed of 4.25 in format XXX.X
									4 => x"3564",         -- R5 <- #100
									5 => x"1363",         -- M[99] <- R3
									6 => x"A330",       	-- R3 <- R3 * R3
									7 => x"2530",         -- M[R5] <- R3
									8 => x"4510",         -- R5 <- R5 add R1
									9 => x"5210",         -- R2 <- R2 sub R1
									10 => x"620C",        -- branch if R2==0 to 12
									11 => x"6006",        -- always branch to 6

									12  => x"7063",			-- output<- M[50]   mov obuf_out,M[50]
									13  => x"7064",			-- output<- M[51]   mov obuf_out,M[51]
									14  => x"7065",			-- output<- M[52]   mov obuf_out,M[52]
									15  => x"F000",			-- halt
									others => x"0000");
				data_out <= "0000000000000000000000000000000000000000000000000000000000000000";
		else
			if (clock'event and clock = '1') then
				if (Mwe ='1' and Mre = '0' and miss ='1' and memDelay_t ='0' and memReady_t = '0' and blah = '0') then
					blah <= '1';
					counter <= 7;
					memReady_t <= '0';
					tmp_ram(conv_integer(data_in(72 downto 64) & "00")) <= data_in(15 downto 0);
					tmp_ram(conv_integer(data_in(72 downto 64) & "01")) <= data_in(31 downto 16);
					tmp_ram(conv_integer(data_in(72 downto 64) & "10")) <= data_in(47 downto 32);
					tmp_ram(conv_integer(data_in(72 downto 64) & "11")) <= data_in(63 downto 48);
					memDelay_t <= '1';
				elsif (Mre ='1' and Mwe ='0' and miss ='1' and memDelay_t ='0' and memReady_t = '0' and blah = '1') then
					blah <= '0';
					counter <= 7;
					memReady_t <= '0';
					data_out(15 downto 0) <= tmp_ram(conv_integer(tag & "00"));
					data_out(31 downto 16) <= tmp_ram(conv_integer(tag & "01"));
					data_out(47 downto 32) <= tmp_ram(conv_integer(tag & "10"));
					data_out(63 downto 48) <= tmp_ram(conv_integer(tag & "11"));
					memDelay_t <= '1';
				elsif (miss ='1' and memDelay_t ='1' and counter > 0) then
					counter <= counter - 1;
				elsif (miss ='1' and counter = 0) then
					memDelay_t <= '0';
					memReady_t <= '1';
					counter <= 7;
				else
					memReady_t <= '0';
					memDelay_t <= '0';
				end if;
			end if;
		end if;
	end process;
	
	memDelay <= memDelay_t;
	memReady <= memReady_t;
end behv;