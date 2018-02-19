-------------------------------------------------------------------------------
-- Standard:    VHDL-1993
-- Platform:    independent
-- Dependecies: clk_divider.vhd
-------------------------------------------------------------------------------
-- Description:
--     A test bench of the clk_divider entity with the rtl architecture.
-------------------------------------------------------------------------------
-- Comments:
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity clk_divider_tb is
end entity clk_divider_tb;


architecture behavior of clk_divider_tb is
    
    constant CLK_PERIOD : time := 10 ns; -- clock period definition
    
    -- clk_divider generics
    constant FREQ_DIV_MAX_VALUE : positive := 7; 
    
    -- clk_divider ports
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    
    signal freq_div : positive := 1;
    signal clk_out  : std_logic;
    
begin
    
    -- instantiate the unit under test (uut)
    uut : entity work.clk_divider(rtl)
        generic map (
            FREQ_DIV_MAX_VALUE => FREQ_DIV_MAX_VALUE
        )
        port map (
            clk => clk,
            rst => rst,
            
            freq_div => freq_div,
            clk_out  => clk_out
        );
    
    -- Purpose: Clock process definition.
    clk_proc : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process clk_proc;
    
    -- Purpose: Stimulus process.
    stim_proc : process
    begin 
        
        rst <= '1'; -- initialize the module
        wait for CLK_PERIOD;
        
        rst <= '0';
        wait for 10 * CLK_PERIOD;
        
        freq_div <= 2;
        wait for 10 * CLK_PERIOD;
        
        freq_div <= 3;
        wait for 10 * CLK_PERIOD;
        
        freq_div <= 4;
        wait for 10 * CLK_PERIOD;
        
        freq_div <= 7;
        wait for 10 * CLK_PERIOD;
        
        freq_div <= 1;
        wait for 10 * CLK_PERIOD;
        
        freq_div <= 4;
        wait;
        
    end process stim_proc;
    
end architecture behavior;


-------------------------------------------------------------------------------
-- MIT License
--
-- Copyright (c) 2018 Dominik Salvet
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to
-- deal in the Software without restriction, including without limitation the
-- rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
-- sell copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
-- IN THE SOFTWARE.
-------------------------------------------------------------------------------
