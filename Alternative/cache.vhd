-- Assignment 2
-- Direct Mapping Cache Controller
-- Reid Hurlburt - 3620186

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity cache is
	port
	(
		clk, rst, Mread, Mwrite			: in std_logic;
		IncomingADDR						: in std_logic_vector(10 downto 0);
		IncomingDATA						: in std_logic_vector(15 downto 0);
		IncomingMemDATA					: in std_logic_vector(63 downto 0);
		memReady								: in std_logic;
		OutgoingMemDATA					: out std_logic_vector(63 downto 0);
		OutgoingDATA						: out std_logic_vector(15 downto 0);
		miss									: out std_logic;
		out_tag								: out std_logic_vector(8 downto 0);
		memRead								: out std_logic;
		memWrite								: out std_logic;
		data_ready							: out std_logic;
		
		--DEBUG SIGNALS
		D_memBusy							: out std_logic;
		D_line0								: out std_logic_vector(72 downto 0);
		D_line1								: out std_logic_vector(72 downto 0);
		D_line2								: out std_logic_vector(72 downto 0);
		D_line3								: out std_logic_vector(72 downto 0)
		--DEBUG SIGNALS
	);
end entity;

architecture behv of cache is			

type cache_type is array (0 to 3) of std_logic_vector(72 downto 0); -- 9bit tag + 4*16bit word
signal tmp_cache: cache_type;
signal ADD_TAG : std_logic_vector(8 downto 0);
signal ADD_WORD : std_logic_vector(1 downto 0);
signal miss_t : std_logic;
signal counter : integer := 1;
signal memBusy : std_logic := '0';
signal memWrite_t : std_logic := '0';
begin
	process(clk, rst, Mread, Mwrite, IncomingADDR, IncomingDATA, IncomingMemDATA)
	begin
		if rst='1' then	-- random cache values preloaded
			tmp_cache <= (0 => "0" & x"C9C956789012345678",	   -- TAG: 9bit, DATA: 3A BF C3 34
							  1 => "0" & x"CACA56789012345678",		-- TAG: 8, DATA: 25 D4 5F 11
							  2 => "0" & x"CBCB56789012345678",		-- TAG: 1, DATA: 79 8C AA 62
							  3 => "0" & x"CCCC56789012345678"		-- TAG: D, DATA: 90 6B 13 FF
							  );
			miss_t <= '0';
			ADD_TAG <= "000000000";
			memBusy <= '0';
			counter <= 1;
			memBusy <= '0';
			memWrite_t <= '0';
		else
			if (clk'event and clk = '1') then 
				if (Mread ='0' and Mwrite ='1') then
					data_ready <= '0';
					if (miss_t ='0' and memBusy ='0') then	-- write incoming data to cache
						ADD_TAG <= IncomingADDR(10 downto 2);
						ADD_WORD <= IncomingADDR(1 downto 0);
						if ADD_TAG=tmp_cache(0)(72 downto 64) then -- compare tags
							case ADD_WORD is
								when "00" => tmp_cache(0)(15 downto 0) <= IncomingDATA; -- change W1
								when "01" => tmp_cache(0)(31 downto 16) <= IncomingDATA; -- change W2
								when "10" => tmp_cache(0)(47 downto 32) <= IncomingDATA;  -- change W3
								when "11" => tmp_cache(0)(63 downto 48) <= IncomingDATA;   -- change W4
							end case;
						elsif ADD_TAG=tmp_cache(1)(72 downto 64) then -- compare tags
							case ADD_WORD is
								when "00" => tmp_cache(1)(15 downto 0) <= IncomingDATA; -- change W1
								when "01" => tmp_cache(1)(31 downto 16) <= IncomingDATA; -- change W2
								when "10" => tmp_cache(1)(47 downto 32) <= IncomingDATA;  -- change W3
								when "11" => tmp_cache(1)(63 downto 48) <= IncomingDATA;   -- change W4
							end case;
						elsif ADD_TAG=tmp_cache(2)(72 downto 64) then -- compare tags
							case ADD_WORD is
								when "00" => tmp_cache(2)(15 downto 0) <= IncomingDATA; -- change W1
								when "01" => tmp_cache(2)(31 downto 16) <= IncomingDATA; -- change W2
								when "10" => tmp_cache(2)(47 downto 32) <= IncomingDATA;  -- change W3
								when "11" => tmp_cache(2)(63 downto 48) <= IncomingDATA;   -- change W4
							end case;
						elsif ADD_TAG=tmp_cache(3)(72 downto 64) then -- compare tags
							case ADD_WORD is
								when "00" => tmp_cache(3)(15 downto 0) <= IncomingDATA; -- change W1
								when "01" => tmp_cache(3)(31 downto 16) <= IncomingDATA; -- change W2
								when "10" => tmp_cache(3)(47 downto 32) <= IncomingDATA;  -- change W3
								when "11" => tmp_cache(3)(63 downto 48) <= IncomingDATA;   -- change W4
							end case;
						else
							-- pull block into cache
							-- have flag saying we need to still write to it
							-- write to cache
							miss_t <= '1';
							memRead <= '1';
							memBusy <= '1';
						end if;
					elsif (miss_t = '1'and memBusy ='0') then
						tmp_cache(counter mod 4)(15 downto 0) <= IncomingMemDATA(15 downto 0); -- change W1
						tmp_cache(counter mod 4)(31 downto 16) <= IncomingMemDATA(31 downto 16); -- change W2
						tmp_cache(counter mod 4)(47 downto 32) <= IncomingMemDATA(47 downto 32); -- change W3
						tmp_cache(counter mod 4)(63 downto 48) <= IncomingMemDATA(63 downto 48); -- change W4
						tmp_cache(counter mod 4)(72 downto 64) <= ADD_TAG; -- change tag
						counter <= counter + 1;
						miss_t <= '0';
						memRead <= '0';
						data_ready <= '1';
					elsif (memBusy = '1') then
						if (memReady = '1') then
							memBusy <= '0';
						else
							memBusy <= '1';
						end if;
					end if;
				elsif (Mread ='1' and Mwrite ='0') then
					data_ready <= '0';
					if (miss_t ='0' and memBusy ='0') then	-- output outgoing data from cache						 
						ADD_TAG <= IncomingADDR(10 downto 2);
						ADD_WORD <= IncomingADDR(1 downto 0);
						if ADD_TAG=tmp_cache(0)(72 downto 64) then -- compare tags
							case ADD_WORD is
								when "00" => OutgoingDATA <= tmp_cache(0)(15 downto 0); -- output W1
								when "01" => OutgoingDATA <= tmp_cache(0)(31 downto 16); -- output W2
								when "10" => OutgoingDATA <= tmp_cache(0)(47 downto 32); -- output W3
								when "11" => OutgoingDATA <= tmp_cache(0)(63 downto 48);	-- output W4
							end case;
						elsif ADD_TAG=tmp_cache(1)(72 downto 64) then -- compare tags
							case ADD_WORD is
								when "00" => OutgoingDATA <= tmp_cache(1)(15 downto 0); -- output W1
								when "01" => OutgoingDATA <= tmp_cache(1)(31 downto 16); -- output W2
								when "10" => OutgoingDATA <= tmp_cache(1)(47 downto 32); -- output W3
								when "11" => OutgoingDATA <= tmp_cache(1)(63 downto 48);	-- output W4
							end case;
						elsif ADD_TAG=tmp_cache(2)(72 downto 64) then -- compare tags
							case ADD_WORD is
								when "00" => OutgoingDATA <= tmp_cache(2)(15 downto 0); -- output W1
								when "01" => OutgoingDATA <= tmp_cache(2)(31 downto 16); -- output W2
								when "10" => OutgoingDATA <= tmp_cache(2)(47 downto 32); -- output W3
								when "11" => OutgoingDATA <= tmp_cache(2)(63 downto 48);	-- output W4
							end case;
						elsif ADD_TAG=tmp_cache(3)(72 downto 64) then -- compare tags
							case ADD_WORD is
								when "00" => OutgoingDATA <= tmp_cache(3)(15 downto 0); -- output W1
								when "01" => OutgoingDATA <= tmp_cache(3)(31 downto 16); -- output W2
								when "10" => OutgoingDATA <= tmp_cache(3)(47 downto 32); -- output W3
								when "11" => OutgoingDATA <= tmp_cache(3)(63 downto 48);	-- output W4
							end case;
						else
							-- REPLACE OLDEST CACHE LINE WITH MEMORY BLOCK REFERENCED IN ADDRESS
							miss_t <= '1';
							memWrite_t <= '1';
							memBusy <= '1';
							ADD_TAG <= tmp_cache(counter mod 4)(72 downto 64);
							OutgoingMemData(15 downto 0) <= tmp_cache(counter mod 4)(15 downto 0);
							OutgoingMemData(31 downto 16) <= tmp_cache(counter mod 4)(31 downto 16);
							OutgoingMemData(47 downto 32) <= tmp_cache(counter mod 4)(47 downto 32);
							OutgoingMemData(63 downto 48) <= tmp_cache(counter mod 4)(63 downto 48);
						end if;
					elsif (miss_t = '1'and memBusy ='0' and memWrite_t = '0') then
						tmp_cache(counter mod 4)(15 downto 0) <= IncomingMemDATA(15 downto 0); -- change W1
						tmp_cache(counter mod 4)(31 downto 16) <= IncomingMemDATA(31 downto 16); -- change W2
						tmp_cache(counter mod 4)(47 downto 32) <= IncomingMemDATA(47 downto 32); -- change W3
						tmp_cache(counter mod 4)(63 downto 48) <= IncomingMemDATA(63 downto 48); -- change W4
						tmp_cache(counter mod 4)(72 downto 64) <= ADD_TAG; -- change tag
						counter <= counter + 1;
						miss_t <= '0';
						memRead <= '0';
						data_ready <= '1';
					elsif (miss_t ='1' and memBusy ='0' and memWrite_t ='1') then
						-- We just wrote oldest cache line to memory, now we need to pull block into cache
						memWrite_t <= '0';
						memRead <= '1';
						memBusy <= '1';
						ADD_TAG <= IncomingADDR(10 downto 2);
					elsif (memBusy='1') then
						if (memReady = '1') then
							memBusy <= '0';
						else
							memBusy <= '1';
						end if;
					end if;
				elsif (Mread ='0' and MWrite ='0') then
					miss_t <= '0';
					memBusy <= '0';
				end if;
			end if;
		end if;
	end process;
	
	out_tag <= ADD_TAG;
	D_memBusy <= memBusy;
	miss <= miss_t;
	memWrite <= memWrite_t;
	D_line0	<= tmp_cache(0);
	D_line1	<= tmp_cache(1);
	D_line2	<= tmp_cache(2);
	D_line3	<= tmp_cache(3);
	
end behv;
