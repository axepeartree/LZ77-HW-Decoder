library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decompressor is
    port(
        clock:      in std_logic;
        offset:     in std_logic_vector(11 downto 0);
        length:     in std_logic_vector(3 downto 0);
        byte:       in std_logic_vector(7 downto 0)
    );
end entity decompressor;

architecture behaviour of decompressor is
    signal s_counter:   unsigned(3 downto 0) := b"0000";
begin
    process(clock) is
    begin
        if rising_edge(clock) then
            if s_counter < unsigned(length) then
                s_counter <= s_counter + 1;
            else
                s_counter <= b"0000";
            end if;
        end if;
    end process;
end architecture behaviour;
