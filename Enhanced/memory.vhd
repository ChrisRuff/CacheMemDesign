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
		data_in	:	in std_logic_vector(15 downto 0);
		data_out:	out std_logic_vector(15 downto 0)
);
end;

architecture behv of memory	 is			

type ram_type is array (0 to 2047) of std_logic_vector(15 downto 0);
signal tmp_ram: ram_type;
begin
	write: process(clock, rst, Mre, address, data_in)
	begin				-- program to generate 10 gamma numbers
		if rst='1' then		
			tmp_ram <= (0 => x"3000",      -- R0 <- #0
						1 => x"3101",         -- R1 <- #1
						2 => x"3201",         -- R2 <- #1
						3 => x"3308",         -- R3 <- #10
						4 => x"3400",         -- R4 <- #0
						5 => x"3501",         -- R5 <- #1 
						6 => x"3634",         -- R6 <- #52

						7 => x"1132",         -- M[50] <- R1
						8 => x"1133",         -- M[51] <- R1
						9 => x"103c",         -- M[60] <- R0

							-- Loop 1
							10 => x"043c",         -- R4 <- M[60]
							11 => x"4410",         -- R4 <- R4 + R1
							12 => x"143c",         -- M[60] <- R4
	
								-- Loop 2
								13  => x"5410",        -- R4 <- R4 - R1 
								14  => x"4250",        -- R2 <- R2 + R5 
								15  => x"6411",        -- R4=0: PC <- 17
								16  => x"600D",        -- R0=0: PC <- 13
								-- Loop 2 End

							17  => x"2620",        -- M[R6] <- R2
							18  => x"5550",        -- R5 <- R5 - R5
							19  => x"4520",        -- R5 <- R5 + R2
							20  => x"4610",        -- R6 <- R6 + R1
							21  => x"5310",        -- R3 <- R3 - R1

							22  => x"6318",        -- R3=0: PC <- 24
							23  => x"600A",        -- R0=0: PC <- 10
							-- Loop 1 End

						24  => x"7032",			-- output<- M[50]   mov obuf_out,M[50]
						25  => x"7033",			-- output<- M[51]   mov obuf_out,M[51]
						26  => x"7034",			-- output<- M[52]   mov obuf_out,M[52]
						27  => x"7035",			-- output<- M[53]   mov obuf_out,M[53]
						28  => x"7036",			-- output<- M[54]   mov obuf_out,M[54]
						29  => x"7037",			-- output<- M[55]   mov obuf_out,M[55]
						30  => x"7038",			-- output<- M[56]   mov obuf_out,M[56]
						31  => x"7039",			-- output<- M[57]   mov obuf_out,M[57]
						32  => x"703A",			-- output<- M[58]   mov obuf_out,M[58]
						33  => x"703B",			-- output<- M[59]   mov obuf_out,M[59]
						34  => x"F000",			-- halt



						others => x"0000");
		else
			if (clock'event and clock = '1') then
				if (Mwe ='1' and Mre = '0') then
					tmp_ram(conv_integer(address)) <= data_in;
				end if;
			end if;
		end if;
	end process;

    read: process(clock, rst, Mwe, address)
	begin
		if rst='1' then
			data_out <= ZERO;
		else
			if (clock'event and clock = '1') then
				if (Mre ='1' and Mwe ='0') then								 
					data_out <= tmp_ram(conv_integer(address));
				end if;
			end if;
		end if;
	end process;
end behv;