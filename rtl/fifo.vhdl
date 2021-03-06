--------------------------------------------------------------------------------
-- Copyright (C) 2018 Dominik Salvet
-- SPDX-License-Identifier: MIT
--------------------------------------------------------------------------------
-- Compliant: IEEE Std 1076-1993
-- Target:    independent
--------------------------------------------------------------------------------
-- Description:
--     This file represents a generic FIFO structure (also known as queue). It
--     is possible to setup it's capacity and stored data's bit width. It is
--     possible to write and read at the same time, see "Notes".
--------------------------------------------------------------------------------
-- Notes:
--     1. The final internal FIFO capacity is equal to 2^g_INDEX_WIDTH only. It
--        is not possible to choose another capacity.
--     2. The FIFO module is implemented as memory with separated indexes for
--        write and read operations.
--     3. If the FIFO is empty, read operation without write can't be performed
--        at all as it leads to an undefined behavior for the FIFO.
--     4. If the FIFO is empty, read and write at the same time will cause the
--        o_data to be undefined, however it is still possible to use the FIFO
--        next time like it should have been used before. The simulation will
--        report an error in this situation, though.
--     5. If the FIFO is full, write and read operations can be performed at the
--        same time.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo is
    generic (
        g_INDEX_WIDTH : positive := 2; -- internal index bit width affecting the FIFO capacity
        g_DATA_WIDTH  : positive := 8 -- bit width of stored data
    );
    port (
        i_clk : in std_ulogic; -- clock signal
        i_rst : in std_ulogic; -- reset signal
        
        i_we   : in  std_ulogic; -- write enable (enqueue)
        i_data : in  std_ulogic_vector(g_DATA_WIDTH - 1 downto 0); -- written data
        o_full : out std_ulogic; -- full FIFO indicator
        
        i_re    : in  std_ulogic; -- read enable (dequeue)
        o_data  : out std_ulogic_vector(g_DATA_WIDTH - 1 downto 0); -- read data
        o_empty : out std_ulogic -- empty FIFO indicator
    );
end entity fifo;


architecture rtl of fifo is
    
    -- output buffers
    signal b_full  : std_ulogic;
    signal b_empty : std_ulogic;
    
    -- definition of internal memory type
    type t_MEM is array(0 to integer((2 ** g_INDEX_WIDTH) - 1)) of
        std_ulogic_vector(g_DATA_WIDTH - 1 downto 0);
    signal r_mem : t_MEM; -- accessible internal memory signal
    
begin
    
    o_full <= b_full;
    
    o_empty <= b_empty;
    
    -- Description:
    --     Internal memory read and write mechanism description.
    mem_access : process (i_clk) is
        variable r_wr_index : unsigned(g_INDEX_WIDTH - 1 downto 0); -- current write index
        variable r_rd_index : unsigned(g_INDEX_WIDTH - 1 downto 0); -- current read index
    begin
        if (rising_edge(i_clk)) then
            if (i_rst = '1') then -- synchronous reset
                b_full     <= '0';
                b_empty    <= '1';
                r_wr_index := to_unsigned(0, r_wr_index'length);
                r_rd_index := to_unsigned(0, r_rd_index'length);
            else
                
                if (i_we = '1') then -- write enable
                    r_mem(to_integer(r_wr_index)) <= i_data;
                    
                    if (i_re = '0') then
                        b_empty <= '0'; -- the FIFO is never empty after write and no read
                        if (r_wr_index + 1 = r_rd_index) then -- full FIFO check
                            b_full <= '1';
                        end if;
                    end if;
                    
                    r_wr_index := r_wr_index + 1;
                end if;
                
                if (i_re = '1') then -- read enable
                    o_data <= r_mem(to_integer(r_rd_index));
                    
                    if (i_we = '0') then
                        b_full <= '0'; -- the FIFO is never full after read and no write
                        if (r_rd_index + 1 = r_wr_index) then -- empty FIFO check
                            b_empty <= '1';
                        end if;
                    end if;
                    
                    r_rd_index := r_rd_index + 1;
                end if;
                
            end if;
        end if;
    end process mem_access;
    
    -- rtl_synthesis off
    input_prevention : process (i_clk) is
    begin
        if (rising_edge(i_clk)) then
            assert (not (b_full = '1' and i_we = '1' and i_re = '0'))
                report "Writing without reading when full has caused overflow and get the module " &
                "into undefined state!"
                severity failure;
            
            assert (not (b_empty = '1' and i_re = '1' and i_we = '0'))
                report "Reading without writing when empty has caused underflow and get the " &
                "module into undefined state!"
                severity failure;
            
            assert (not (b_empty = '1' and i_re = '1' and i_we = '1'))
                report "Reading and writing when empty have caused the o_data to be undefined!"
                severity error;
        end if;
    end process input_prevention;
    -- rtl_synthesis on
    
end architecture rtl;
