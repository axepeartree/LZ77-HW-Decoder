library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lz77_decomp is
    port(
        offset:         in std_logic_vector(12 downto 0);
        length:         in std_logic_vector(2 downto 0);
        byte:           in std_logic_vector(7 downto 0);

        data_out:       out std_logic_vector(63 downto 0);

        clock:          in std_logic;
        enable:         in std_logic
    );
end entity lz77_decomp;

architecture behaviour of lz77_decomp is
    -- array of 8191 bytes
    type buf_mem_type is array (2**13 - 1 downto 0) of std_logic_vector(7 downto 0);
    type carry_bytes_type is array (6 downto 0) of std_logic_vector(7 downto 0);

    signal s_buffer:            buf_mem_type;
    signal s_next_buffer_head:  std_logic_vector(12 downto 0) := "1111111111111"; -- next head of the circular buffer
    signal s_curr_buffer_head:  std_logic_vector(12 downto 0) := "1111111111111"; -- current head of the circular buffer
    signal s_match_position:    integer := 0; -- only for debugging reasons
    signal s_carry_byte_count:  unsigned (3 downto 0) := b"0000";
    signal s_write:             std_logic := '0';
begin
    process(clock) is
        variable v_curr_buffer_head:    std_logic_vector(12 downto 0) := "1111111111111";
        variable v_match_position:      integer := 0;
        variable v_carry_byte_count:    unsigned (3 downto 0) := b"0000";
        variable v_write:               std_logic := '0';
    begin
        if rising_edge(clock) and enable = '1' then
            v_carry_byte_count := s_carry_byte_count + unsigned(length);
            v_curr_buffer_head := s_next_buffer_head;
            v_match_position := to_integer(unsigned(v_curr_buffer_head)) - to_integer(unsigned(offset));

            if v_carry_byte_count >= 8 then
                v_carry_byte_count := v_carry_byte_count - 8;
                v_write := '1';
            else
                v_write := '0';
            end if;

            -- get buffer's next position
            if unsigned(v_curr_buffer_head) + unsigned(length) + 1 > 8191 then
                s_next_buffer_head
                    <= std_logic_vector((unsigned(v_curr_buffer_head) + unsigned(length)) - 8191);
            else
                s_next_buffer_head
                    <= std_logic_vector((unsigned(v_curr_buffer_head) + unsigned(length)) + 1);
            end if;

            if v_match_position < 0 then
                s_match_position <= 8192 + v_match_position;
            else
                s_match_position <= v_match_position;
            end if;

            s_curr_buffer_head <= v_curr_buffer_head;
            s_carry_byte_count <= v_carry_byte_count;
            s_write <= v_write;
        end if;
        end process;
end architecture behaviour;