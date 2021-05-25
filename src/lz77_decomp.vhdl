library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lz77_decomp is
    port(
        offset:         in std_logic_vector(12 downto 0);
        length:         in std_logic_vector(2 downto 0);
        byte:           in std_logic_vector(7 downto 0);

        data_out:       out std_logic_vector(63 downto 0);
        write_data:     out std_logic;

        clock:          in std_logic;
        enable:         in std_logic
    );
end entity lz77_decomp;

architecture behaviour of lz77_decomp is
    type buf_mem_type is array (2**13 - 1 downto 0) of std_logic_vector(7 downto 0);
    type match_word_type is array(6 downto 0) of std_logic_vector(7 downto 0);
    type carry_bytes_type is array(15 downto 0) of std_logic_vector(7 downto 0);

    signal s_buffer:            buf_mem_type := (others => x"00");
    signal s_next_buffer_head:  std_logic_vector(12 downto 0) := "0000000000000"; -- next head of the circular buffer
    signal s_carry_bytes_count: integer := 0;
    signal s_carry_bytes:       carry_bytes_type := (others => x"00");
begin
    process(clock, enable) is
        variable v_length:              unsigned (2 downto 0);
        variable v_curr_buffer_head:    unsigned(12 downto 0);
        variable v_match_position:      integer := 0;
        variable v_match_word:          match_word_type;
        variable v_data_out:            std_logic_vector(63 downto 0) := x"0000000000000000";
        variable v_write_data:          std_logic := '0';
        variable v_carry_bytes:         carry_bytes_type;
        variable v_carry_bytes_count:   integer := 0;
    begin
        if rising_edge(clock) and enable = '1' then
            v_curr_buffer_head := unsigned(s_next_buffer_head);
            v_length := unsigned(length);
            v_carry_bytes_count := s_carry_bytes_count + to_integer(v_length) + 1;
            v_carry_bytes := s_carry_bytes;

            -- set match word position
            v_match_position := to_integer(v_curr_buffer_head) - to_integer(unsigned(offset));
            if v_match_position < 0 then
                v_match_position := 8192 + v_match_position;
            else
                v_match_position := v_match_position;
            end if;

            -- copy from buffer to match word
            for i in 0 to 6 loop
                if i + v_match_position > 8191 and i <= v_length then
                    v_match_word(i) := s_buffer(v_match_position + i - 8192);
                elsif i <= to_integer(v_length) then
                    v_match_word(i) := s_buffer(v_match_position + i);
                else
                end if;
            end loop;

            -- copy match word + byte to buffer
            for i in 0 to 6 loop
                if i + 1 <= v_length then
                    if to_integer(v_curr_buffer_head) + i < 8192 then
                        s_buffer(to_integer(v_curr_buffer_head) + i) <= v_match_word(i);
                    else
                        s_buffer(to_integer(v_curr_buffer_head) + i - 8192) <= v_match_word(i);
                    end if;
                end if;
            end loop;
            if to_integer(v_curr_buffer_head) + to_integer(v_length) < 8192 then
                s_buffer(to_integer(v_curr_buffer_head) + to_integer(v_length)) <= byte;
            else
                s_buffer(to_integer(v_curr_buffer_head) + to_integer(v_length) - 8192) <= byte;
            end if;

            -- copy match word to carry bytes
            for i in 0 to 6 loop
                if i + 1 <= v_length then
                    v_carry_bytes(s_carry_bytes_count + i) := v_match_word(i);
                end if;
                v_carry_bytes(s_carry_bytes_count + to_integer(v_length)) := byte;
            end loop;

            -- move carry bytes to output if length is greater than 8
            if v_carry_bytes_count > 8 then
                v_write_data := '1';
                v_data_out := v_carry_bytes(0)
                    & v_carry_bytes(1)
                    & v_carry_bytes(2)
                    & v_carry_bytes(3)
                    & v_carry_bytes(4)
                    & v_carry_bytes(5)
                    & v_carry_bytes(6)
                    & v_carry_bytes(7);

                for i in 0 to 7 loop
                    v_carry_bytes(i) := v_carry_bytes(i + 8);
                end loop;
                for i in 8 to 15 loop
                    v_carry_bytes(i) := x"00";
                end loop;

                v_carry_bytes_count := v_carry_bytes_count - 8;
            else
                v_write_data := '0';
            end if;

            -- set buffer's next position using circular buffer logic
            if v_curr_buffer_head + v_length + 1 > 8191 then
                s_next_buffer_head
                    <= std_logic_vector((v_curr_buffer_head + v_length) - 8191);
            else
                s_next_buffer_head
                    <= std_logic_vector((v_curr_buffer_head + v_length) + 1);
            end if;

            data_out <= v_data_out;
            write_data <= v_write_data;
            s_carry_bytes <= v_carry_bytes;
            s_carry_bytes_count <= v_carry_bytes_count;
        end if;
        end process;
end architecture behaviour;