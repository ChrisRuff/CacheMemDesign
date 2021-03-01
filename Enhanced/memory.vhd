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

entity memory is
port ( 	clock	: 	in std_logic;
		rst		: 	in std_logic;
		Mre		:	in std_logic;
		Mwe		:	in std_logic;
		address	:	in std_logic_vector(10 downto 0);
		data_in	:	in std_logic_vector(63 downto 0);
		data_out:	out std_logic_vector(63 downto 0)
);
end;

architecture behv of memory	 is			

type ram_type is array (0 to 511, 0 to 3) of std_logic_vector(15 downto 0);
signal tmp_ram: ram_type;
begin
	write: process(clock, rst, Mre, address, data_in)
	begin				-- program to generate 10 gamma numbers
		if rst='1' then		
			tmp_ram(0, 0) <= x"3000";      -- R0 <- #0
			tmp_ram(0, 1) <= x"3101";         -- R1 <- #1
			tmp_ram(0, 2) <= x"3201";         -- R2 <- #1
			tmp_ram(0, 3) <= x"3308";         -- R3 <- #10
			tmp_ram(1, 0) <= x"3400";         -- R4 <- #0
						
		else
			if (clock'event and clock = '1') then
				if (Mwe ='1' and Mre = '0') then
					tmp_ram(conv_integer(address), 0) <= data_in(15 downto 0);
					tmp_ram(conv_integer(address), 1) <= data_in(31 downto 16);
					tmp_ram(conv_integer(address), 2) <= data_in(47 downto 32);
					tmp_ram(conv_integer(address), 3) <= data_in(63 downto 48);

				end if;
			end if;
		end if;
	end process;

    read: process(clock, rst, Mwe, address)
	begin
		if rst='1' then
			data_out <= "0000000000000000000000000000000000000000000000000000000000000000";
		else
			if (clock'event and clock = '1') then
				if (Mre ='1' and Mwe ='0') then			
					data_out(15 downto 0)  <= tmp_ram(conv_integer(address), 0);
					data_out(31 downto 16) <= tmp_ram(conv_integer(address), 1);
					data_out(47 downto 32) <= tmp_ram(conv_integer(address), 2);
					data_out(63 downto 48) <= tmp_ram(conv_integer(address), 3);
				end if;
			end if;
		end if;
	end process;
end behv;