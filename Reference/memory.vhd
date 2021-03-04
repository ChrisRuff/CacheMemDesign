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
port (clock_in	: 	in std_logic;
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
signal clock : std_logic := '0';
signal counter : unsigned(5 downto 0) := "000000";
begin
	delay: process(clock_in)
	begin
		if(clock_in'event and clock_in = '1') then
			counter <= counter + 1;
			if(counter = 19) then
				counter <= "000000";
				clock <= not(clock);
			end if;
		end if;
	end process;
	write: process(rst, Mre, address, data_in)
	begin				-- program to generate 10 gamma numbers
		if rst='1' then		
				tmp_ram <= ( 
									0 => x"3000",         -- R0 <- #0 Holds 0
									1 => x"3101",         -- R1 <- #1 Holds 1
									2 => x"3204",         -- R2 <- #1 Counter starting at 50
									3 => x"3303",         -- R3 <- #3 Holds seed
									4 => x"3564",         -- R5 <- 100
									5 => x"3704",         -- R7 <  Holds 4
									6 => x"3808",         -- R8 < Holds 8
									7 => x"1363",         -- M[99] <- R3
									8 => x"A330",       -- R3 <- R3 * R3
									9 => x"8370",        -- R3 <- R3 sll R7
									10 => x"9380",        -- R3 <- R3 srl R8
									11 => x"8370",        -- R3 <- R3 sll R7
									12 => x"2530",        -- M[R5] <- R3
									13 => x"4510",        -- R5 <- R5 add R1
									14 => x"5210",        -- R2 <- R2 sub R1
									15 => x"6211",        -- branch if R2==0 to 17
									16 => x"6008",        -- always branch to 8

									17  => x"7064",			-- output<- M[50]   mov obuf_out,M[50]
									18  => x"7065",			-- output<- M[51]   mov obuf_out,M[51]
									19  => x"7066",			-- output<- M[52]   mov obuf_out,M[52]
									20  => x"7067",			-- output<- M[53]   mov obuf_out,M[53]
									21  => x"7068",			-- output<- M[54]   mov obuf_out,M[54]
									22  => x"7069",			-- output<- M[55]   mov obuf_out,M[55]
									23  => x"706A",			-- output<- M[56]   mov obuf_out,M[56]
									24  => x"706B",			-- output<- M[57]   mov obuf_out,M[57]
									25  => x"706C",			-- output<- M[58]   mov obuf_out,M[58]
									26  => x"706D",			-- output<- M[59]   mov obuf_out,M[59]
									27  => x"706E",			-- output<- M[59]   mov obuf_out,M[59]
									28  => x"706F",			-- output<- M[59]   mov obuf_out,M[59]
									29  => x"7070",			-- output<- M[59]   mov obuf_out,M[59]
									30  => x"7071",			-- output<- M[59]   mov obuf_out,M[59]
									31  => x"7072",			-- output<- M[59]   mov obuf_out,M[59]
									32  => x"7073",			-- output<- M[59]   mov obuf_out,M[59]
									33  => x"7074",			-- output<- M[59]   mov obuf_out,M[59]
									34  => x"7075",			-- output<- M[59]   mov obuf_out,M[59]
									35  => x"F000",			-- halt




									others => x"0000");
		else
			if (clock'event and clock = '1') then
				if (Mwe ='1' and Mre = '0') then
					tmp_ram(conv_integer(address)) <= data_in;
				end if;
			end if;
		end if;
	end process;

    read: process(rst, Mwe, address)
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