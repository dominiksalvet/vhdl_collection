--------------------------------------------------------------------------------
-- Description:
--     The simulated RAM is first initialized with a linear data from a file,
--     then the pattern [address]=address is verified for the initialized data
--     and new data are written to the memory at the same time. Written data
--     have the [address]=16*address format. At the end, the simulation verify
--     this written data by sequential read of the memory addresses.
--------------------------------------------------------------------------------
-- Notes:
--     1. To verify the module by its current implementation, it is required
--        2^(n+1) steps where n=g_ADDR_WIDTH.
--     2. The file path defined by g_MEM_IMG_FILENAME is relative to the file
--        where the ram module is defined in.
--     3. The c_CLK_PERIOD constant is defined in the ram_tb_public package.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vhdl_collection;
use vhdl_collection.util_pkg.all;

use work.ram;


entity ram_tb is
end entity ram_tb;


architecture behavioral of ram_tb is
    
    -- uut generics
    constant g_ADDR_WIDTH : positive := 4;
    constant g_DATA_WIDTH : positive := 8;
    
    constant g_MEM_IMG_FILENAME : string := "../data/mem_img/linear_4_8.txt";
    
    -- uut ports
    signal i_clk : std_ulogic := '0';
    
    signal i_we   : std_ulogic                                   := '0';
    signal i_re   : std_ulogic                                   := '0';
    signal i_addr : std_ulogic_vector(g_ADDR_WIDTH - 1 downto 0) := (others => '0');
    signal i_data : std_ulogic_vector(g_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal o_data : std_ulogic_vector(g_DATA_WIDTH - 1 downto 0);

    -- clock period definition
    constant c_CLK_PERIOD : time := 10 ns;
    
    -- simulation finished flag to stop the clk_gen process
    shared variable v_sim_finished : boolean := false;
    
begin
    
    -- instantiate the unit under test (uut)
    uut : entity work.ram(rtl)
        generic map (
            g_ADDR_WIDTH => g_ADDR_WIDTH,
            g_DATA_WIDTH => g_DATA_WIDTH,
            
            g_MEM_IMG_FILENAME => g_MEM_IMG_FILENAME
        )
        port map (
            i_clk => i_clk,
            
            i_we   => i_we,
            i_re   => i_re,
            i_addr => i_addr,
            i_data => i_data,
            o_data => o_data
        );
    
    clk_gen : process is
    begin
        i_clk <= '0';
        wait for c_CLK_PERIOD / 2;
        i_clk <= '1';
        wait for c_CLK_PERIOD / 2;
        
        if (v_sim_finished) then
            wait;
        end if;
    end process clk_gen;
    
    stimulus : process is
    begin
        
        -- read the initialized data and write to every address it's new value
        i_we <= '1';
        i_re <= '1';
        for i in 0 to integer((2 ** g_ADDR_WIDTH) - 1) loop
            i_addr <= std_ulogic_vector(to_unsigned(i, i_addr'length));
            i_data <= std_ulogic_vector(to_unsigned(16 * i, i_data'length)); -- [address]=16*address
            wait for c_CLK_PERIOD;
            
            -- asserting to verify the initialization function of the module
            assert (o_data = std_ulogic_vector(to_unsigned(i, o_data'length)))
                report "Expected the data from the " &
                integer'image(to_integer(unsigned(i_addr))) & " address to be equal to """ &
                to_string(std_ulogic_vector(to_unsigned(i, o_data'length))) & """, what matches " &
                "the [address]=address pattern!"
                severity error;
        end loop;
        
        i_we <= '0';
        -- read each address and verify it's data correctness
        for i in 0 to integer((2 ** g_ADDR_WIDTH) - 1) loop
            i_addr <= std_ulogic_vector(to_unsigned(i, i_addr'length));
            wait for c_CLK_PERIOD; -- wait for i_clk rising edge to read the desired data
            
            -- asserting to verify the RAM module function
            assert (o_data = std_ulogic_vector(to_unsigned(16 * i, o_data'length)))
                report "Expected the data from the " &
                integer'image(to_integer(unsigned(i_addr))) & " address to be equal to """ &
                to_string(std_ulogic_vector(to_unsigned(16 * i, o_data'length))) & """, what " &
                "matches the [address]=16*address pattern!"
                severity error;
        end loop;
        
        v_sim_finished := true;
        wait;
        
    end process stimulus;
    
end architecture behavioral;


--------------------------------------------------------------------------------
-- MIT License
--
-- Copyright (c) 2018 Dominik Salvet
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--------------------------------------------------------------------------------