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
port ( 	clock_in	: 	in std_logic;
		rst		: 	in std_logic;
		Mre		:	in std_logic;
		Mwe		:	in std_logic;
		address	:	in std_logic_vector(10 downto 0);
		WBAddress: 	in std_logic_vector(10 downto 0);
		data_in	:	in std_logic_vector(63 downto 0);
		data_out:	out std_logic_vector(63 downto 0)
);
end;

architecture behv of memory	 is			

type ram_type is array (0 to 2043) of std_logic_vector(15 downto 0);
signal tmp_ram: ram_type;
signal clock : std_logic := '0';
signal counter : unsigned(5 downto 0) := "000000";
begin
--	delay: process(clock_in)
--	begin
--		if(clock_in'event and clock_in = '1') then
--			counter <= counter + 1;
--			if(counter = 19) then
--				counter <= "000000";
--				clock <= not(clock);
--			end if;
--		end if;
--	end process;
	clock <= clock_in;
	write: process(rst, Mre, WBAddress, data_in)
	begin				
		if rst='1' then		
			tmp_ram <= ( 
								0 => x"3006",         -- R0 <- #0 Holds 0
                        1 => x"1063",         -- R1 <- #1 Holds 1
                        2 => x"7063",         -- R2 <- #1 Counter starting at 5

						others => x"0000");		
		else
			if (clock'event and clock = '1') then
				if (Mwe ='1') then
					tmp_ram(conv_integer(WBAddress)/4) <= data_in(15 downto 0);
					tmp_ram(conv_integer(WBAddress)/4 + 1) <= data_in(31 downto 16);
					tmp_ram(conv_integer(WBAddress)/4 + 2) <= data_in(47 downto 32);
					tmp_ram(conv_integer(WBAddress)/4 + 3) <= data_in(63 downto 48);

				end if;
			end if;
		end if;
	end process;

    read: process(rst, Mwe, address)
	begin
		if rst='1' then
			data_out <= "0000000000000000000000000000000000000000000000000000000000000000";
		else
			if (clock'event and clock = '1') then
				if (Mre ='1') then			
					data_out(15 downto 0)  <= tmp_ram(conv_integer(address)/4);
					data_out(31 downto 16) <= tmp_ram(conv_integer(address)/4 + 1);
					data_out(47 downto 32) <= tmp_ram(conv_integer(address)/4 + 2);
					data_out(63 downto 48) <= tmp_ram(conv_integer(address)/4 + 3);
				end if;
			end if;
		end if;
	end process;
end behv;