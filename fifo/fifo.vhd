--------------------------------------------------------------------------------
-- Standard: VHDL-1993
-- Platform: independent
--------------------------------------------------------------------------------
-- Description:
--     This file represents a generic FIFO structure (also known as queue). It
--     possible to setup it's capacity and stored data's bit width.
--------------------------------------------------------------------------------
-- Notes:
--     1. The final internal FIFO capacity is equal to 2^INDEX_WIDTH only. It is
--        not possible to choose another capacity.
--     2. The FIFO module is implemented as memory with separated indexes for
--        write and read operations.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity fifo is
    generic (
        INDEX_WIDTH : positive := 8; -- internal index bit width affecting the fifo capacity
        DATA_WIDTH  : positive := 8 -- bit width of stored data
    );
    port (
        clk : in std_logic; -- clock signal
        rst : in std_logic; -- reset signal
        
        we      : in  std_logic; -- wrte enable (enqueue)
        data_in : in  std_logic_vector(DATA_WIDTH - 1 downto 0); -- written data
        full    : out std_logic; -- full FIFO indicator
        
        re       : in  std_logic; -- read enable (dequeue)
        data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0); -- read data
        empty    : out std_logic -- empty FIFO indicator
    );
end entity fifo;


architecture rtl of fifo is
    
    -- definition of internal memeory type
    type mem_t is array((2 ** INDEX_WIDTH) - 1 downto 0) of
        std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal mem : mem_t; -- accessible internal memory signal
    
    signal wr_index : unsigned(INDEX_WIDTH - 1 downto 0); -- current write index
    signal rd_index : unsigned(INDEX_WIDTH - 1 downto 0); -- current read index
    
begin
    
    -- Purpose: Internal memory read and write mechanism description.
    mem_access : process (clk)
    begin
        if (rising_edge(clk)) then
            if (rst = '1') then -- sycnhronous reset
                full     <= '0';
                empty    <= '1';
                wr_index <= (others => '0');
                rd_index <= (others => '0');
            else
                
                if (we = '1') then -- write enable
                    empty                     <= '0'; -- the FIFO is never empty after write
                    mem(to_integer(wr_index)) <= data_in;
                    wr_index                  <= wr_index + 1;
                    
                    if (re = '0' and wr_index + 1 = rd_index) then -- full check
                        full <= '1';
                    end if;
                end if;
                
                if (re = '1') then -- read enable
                    full     <= '0'; -- the FIFO is never full after read
                    data_out <= mem(to_integer(rd_index));
                    rd_index <= rd_index + 1;
                    
                    if (we = '0' and rd_index + 1 = wr_index) then -- empty check
                        empty <= '1';
                    end if;
                end if;
                
            end if;
        end if;
    end process mem_access;
    
end architecture rtl;


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
