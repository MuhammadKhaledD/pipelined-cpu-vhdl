library ieee;
use ieee.std_logic_1164.all;


entity ForwardUnit is
    port (
        rs1         : in  std_logic_vector(2 downto 0);
        rs2         : in  std_logic_vector(2 downto 0);
        rd_MEM      : in  std_logic_vector(2 downto 0);
        rd_WB       : in  std_logic_vector(2 downto 0);
        is_swap      : in  std_logic;
        regWrite_MEM: in  std_logic;
        regWrite_WB : in  std_logic;
        forwardA    : out std_logic_vector(1 downto 0);
        forwardB    : out std_logic_vector(1 downto 0)
    );
end entity ForwardUnit;

architecture ForwardUnit_arch of ForwardUnit is
begin
    process(rs1, rs2, rd_MEM, rd_WB, regWrite_MEM, regWrite_WB)
    begin
        -- Default values
        forwardA <= "00";
        forwardB <= "00";

        if(is_swap = '1') then
            -- If swap is active, do not forward
            forwardA <= "00";
            forwardB <= "00";
            return;
        else
        -- Check for forwarding to operand A
            if (regWrite_MEM = '1') and (rd_MEM /= "000") and (rd_MEM = rs1) then
                forwardA <= "10";  -- Forward from MEM stage
            elsif (regWrite_WB = '1') and (rd_WB /= "000") and (rd_WB = rs1) then
                forwardA <= "01";  -- Forward from WB stage
            end if;

        -- Check for forwarding to operand B
            if (regWrite_MEM = '1') and (rd_MEM /= "000") and (rd_MEM = rs2) then
                forwardB <= "10";  -- Forward from MEM stage
            elsif (regWrite_WB = '1') and (rd_WB /= "000") and (rd_WB = rs2) then
                forwardB <= "01";  -- Forward from WB stage
        end if;
    end process;
end architecture ForwardUnit_arch;