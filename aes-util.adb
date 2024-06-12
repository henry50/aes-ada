package body AES.Util is

function Hex_To_Bytes(Hex: String) return Bytes is
    Len: Natural := Hex'Length / 2;
    Result: Bytes(0..Len-1);
    function To_Digit(C: Character) return Byte is
        Invalid_Hex: exception;
    begin
        return (case C is
            when 'a'..'f' => Character'Pos(C) - Character'Pos('a') + 10,
            when 'A'..'F' => Character'Pos(C) - Character'Pos('A') + 10,
            when '0'..'9' => Character'Pos(C) - Character'Pos('0'),
            when others => raise Invalid_Hex
        );
    end To_Digit;
begin
    for I in Result'Range loop
        Result(I) := Byte(To_Digit(Hex(2*I+1)) * 16 + To_Digit(Hex(2*I+2)));
    end loop;
    return Result;
end Hex_To_Bytes;

function Byte_To_Hex(B: Byte) return String is
    type Nibble is mod 2**4;
    function Nibble_To_Hex(N: Nibble) return Character is
    begin
        return (case N is
            when 10..15 => Character'Val(Natural(N) - 10 + Character'Pos('a')),
            when others => Character'Val(Natural(N) + Character'Pos('0'))
        );
    end Nibble_To_Hex;
    -- (B and 0xf0) << 4
    Nibble_1: Nibble := Nibble((B and 240) / 16);
    -- B and 0x0f
    Nibble_2: Nibble := Nibble(B and 15);
    Result: String := Nibble_To_Hex(Nibble_1) & Nibble_To_Hex(Nibble_2);
begin
    return Result;
end Byte_To_Hex;

function Bytes_To_Hex(Bs: Bytes) return String is
    Result: String(1..2*Bs'Length);
    I: Natural := 1;
begin
    for I in Bs'Range loop
        Result(2*I+1..2*I+2) := Byte_To_Hex(Bs(I));
    end loop;
    return Result;
end Bytes_To_Hex;

end AES.Util;