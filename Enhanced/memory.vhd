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
use ieee.math_real.all;  
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
			tmp_ram <= (0 => x"3000",         -- R0 <- #0 Holds 0
						1 => x"3101",         -- R1 <- #1 Holds 1
						2 => x"3203",         -- R2 <- #1 Counter starting at 50
						3 => x"3344",         -- R3 <-  Holds seed of 4.25 in format XXX.X
						4 => x"3564",         -- R5 <- #100
						5 => x"1363",         -- M[99] <- R3

						6 => x"A330",         -- R3 <- R3 * R3
						7 => x"2530",         -- M[R5] <- R3
						8 => x"4510",         -- R5 <- R5 add R1
						9 => x"5210",         -- R2 <- R2 sub R1
						10 => x"620C",        -- branch if R2==0 to 12
						11 => x"6006",        -- always branch to 6

						12  => x"7063",			-- output<- M[99]   mov obuf_out,M[50]
						13  => x"7064",			-- output<- M[51]   mov obuf_out,M[51]
						14  => x"7065",			-- output<- M[52]   mov obuf_out,M[52]
						15  => x"7066",			-- output<- M[53]   mov obuf_out,M[53]
						16  => x"7067",			-- output<- M[54]   mov obuf_out,M[54]
						17  => x"7068",			-- output<- M[55]   mov obuf_out,M[55]
						18  => x"7069",			-- output<- M[56]   mov obuf_out,M[56]
						19  => x"706A",			-- output<- M[57]   mov obuf_out,M[57]
						20  => x"706B",			-- output<- M[58]   mov obuf_out,M[58]
						21  => x"706C",			-- output<- M[59]   mov obuf_out,M[59]
						22  => x"706D",			-- output<- M[59]   mov obuf_out,M[59]
						23  => x"706E",			-- output<- M[59]   mov obuf_out,M[59]
						24  => x"706F",			-- output<- M[59]   mov obuf_out,M[59]
						25  => x"7070",			-- output<- M[59]   mov obuf_out,M[59]
						26  => x"7071",			-- output<- M[59]   mov obuf_out,M[59]
						27  => x"7072",			-- output<- M[59]   mov obuf_out,M[59]
						28  => x"7073",			-- output<- M[59]   mov obuf_out,M[59]
						29  => x"7074",			-- output<- M[59]   mov obuf_out,M[59]
						30  => x"7075",			-- output<- M[59]   mov obuf_out,M[59]
						31  => x"7076",			-- output<- M[59]   mov obuf_out,M[59]
						32  => x"7077",			-- output<- M[59]   mov obuf_out,M[59]
						33   => x"7078",			-- output<- M[59]   mov obuf_out,M[59]
						34  => x"7079",			-- output<- M[59]   mov obuf_out,M[59]
						35  => x"707A",			-- output<- M[59]   mov obuf_out,M[59]
						36  => x"707B",			-- output<- M[59]   mov obuf_out,M[59]
						37  => x"707C",			-- output<- M[50]   mov obuf_out,M[50]
						38  => x"707D",			-- output<- M[51]   mov obuf_out,M[51]
						39  => x"707E",			-- output<- M[52]   mov obuf_out,M[52]
						40  => x"707F",			-- output<- M[53]   mov obuf_out,M[53]
						41  => x"7080",			-- output<- M[54]   mov obuf_out,M[54]
						42  => x"7081",			-- output<- M[55]   mov obuf_out,M[55]
						43  => x"7082",			-- output<- M[56]   mov obuf_out,M[56]
						44  => x"7083",			-- output<- M[57]   mov obuf_out,M[57]
						45  => x"7084",			-- output<- M[58]   mov obuf_out,M[58]
						46  => x"7085",			-- output<- M[59]   mov obuf_out,M[59]
						47  => x"7086",			-- output<- M[59]   mov obuf_out,M[59]
						48  => x"7087",			-- output<- M[59]   mov obuf_out,M[59]
						49  => x"7088",			-- output<- M[59]   mov obuf_out,M[59]
						50  => x"7089",			-- output<- M[59]   mov obuf_out,M[59]
						51  => x"708A",			-- output<- M[59]   mov obuf_out,M[59]
						52  => x"708B",			-- output<- M[59]   mov obuf_out,M[59]
						53  => x"708C",			-- output<- M[59]   mov obuf_out,M[59]
						54  => x"708D",			-- output<- M[59]   mov obuf_out,M[59]
						55  => x"708E",			-- output<- M[59]   mov obuf_out,M[59]
						56  => x"708F",			-- output<- M[59]   mov obuf_out,M[59]
						57  => x"7090",			-- output<- M[59]   mov obuf_out,M[59]
						58  => x"7091",			-- output<- M[59]   mov obuf_out,M[59]
						59  => x"7092",			-- output<- M[59]   mov obuf_out,M[59]
						60  => x"7093",			-- output<- M[59]   mov obuf_out,M[59]
						61  => x"7094",			-- output<- M[59]   mov obuf_out,M[59]
						62  => x"F000",			-- halt
						others => x"0000");		
		else
			if (clock'event and clock = '1') then
				if (Mwe ='1') then
					tmp_ram(conv_integer(unsigned(WBAddress))/4*4)     <= data_in(15 downto 0);
					tmp_ram(conv_integer(unsigned(WBAddress))/4*4 + 1) <= data_in(31 downto 16);
					tmp_ram(conv_integer(unsigned(WBAddress))/4*4 + 2) <= data_in(47 downto 32);
					tmp_ram(conv_integer(unsigned(WBAddress))/4*4 + 3) <= data_in(63 downto 48);

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
					data_out(15 downto 0)  <= tmp_ram(conv_integer(unsigned(address))/4*4);
					data_out(31 downto 16) <= tmp_ram(conv_integer(unsigned(address))/4*4 + 1);
					data_out(47 downto 32) <= tmp_ram(conv_integer(unsigned(address))/4*4 + 2);
					data_out(63 downto 48) <= tmp_ram(conv_integer(unsigned(address))/4*4 + 3);
				end if;
			end if;
		end if;
	end process;
end behv;