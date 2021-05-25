library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lz77_decoder is
    port(
        offset:         in std_logic_vector(12 downto 0);
        length:         in std_logic_vector(2 downto 0);
        byte:           in std_logic_vector(7 downto 0);
        data_out:       out std_logic_vector(63 downto 0);
        write_data:     out std_logic;
        clock:          in std_logic;
        enable:         in std_logic
    );
end entity lz77_decoder;

architecture behaviour of lz77_decoder is
    type s_buf_t is array (2**13 - 1 downto 0) of std_logic_vector(7 downto 0);
    type out_buf_t is array(15 downto 0) of std_logic_vector(7 downto 0);

    signal s_buf:           s_buf_t := (others => x"00");
    signal s_buf_head:      integer := 8184;
    signal out_next_word:   integer := 8184;
    signal out_next_count:  integer := 0;
begin
    process(clock, enable) is
        variable v_len_int:         integer := 0;
        variable v_ofs_int:         integer := 0;
        variable v_buf_head:        integer := 0;
        variable v_match_pos:       integer := 0;
        variable v_out_buf_size:    integer := 0;
    begin
        if rising_edge(clock) and enable = '1' then
            v_buf_head := s_buf_head;
            v_len_int := to_integer(unsigned(length));
            v_ofs_int := to_integer(unsigned(offset));

            -- find match position
            if v_buf_head - v_ofs_int < 0 then
                v_match_pos := 8192 + v_buf_head - v_ofs_int;
            else
                v_match_pos := v_buf_head - v_ofs_int;
            end if;

            -- copy match to search buffer
            for i in 0 to 6 loop
                if i + 1 <= v_len_int then
                    if v_buf_head + i < 8192 then
                        s_buf(v_buf_head + i) <= s_buf(v_match_pos + i);
                    else
                        s_buf(v_buf_head + i - 8192) <= s_buf(v_match_pos + i);
                    end if;
                end if;
            end loop;

            -- copy byte to buffer
            if v_buf_head + v_len_int < 8192 then
                s_buf(v_buf_head + v_len_int) <= byte;
            else
                s_buf(v_buf_head + v_len_int - 8192) <= byte;
            end if;

            -- set next buf head
            if s_buf_head + v_len_int + 1 > 8191 then
                s_buf_head <= s_buf_head + v_len_int - 8191;
            else
                s_buf_head <= s_buf_head + v_len_int + 1;
            end if;

            -- write words out
            if out_next_count >= 8 then
                out_next_count <= out_next_count + v_len_int + 1 - 8;

                if out_next_word + 8 > 8191 then
                    out_next_word <= 0;
                else
                    out_next_word <= out_next_word + 8;
                end if;

                write_data <= '1';
            else
                out_next_count <= out_next_count + v_len_int + 1;
                write_data <= '0';
            end if;

            data_out <= s_buf(out_next_word)
                & s_buf(out_next_word + 1)
                & s_buf(out_next_word + 2)
                & s_buf(out_next_word + 3)
                & s_buf(out_next_word + 4)
                & s_buf(out_next_word + 5)
                & s_buf(out_next_word + 6)
                & s_buf(out_next_word + 7);
        end if;
    end process;
end architecture behaviour;