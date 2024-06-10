with AES.Common; use AES.Common;

package body AES.Key_Expansion is

function "xor"(Left, Right: Word) return Word is
    Result: Word;
begin
    for I in Word_Index loop
        Result(I) := Left(I) xor Right(I);
    end loop;
    return Result;
end "xor";

function Key_Expansion(K: Key) return Key_Schedule is 
    -- Key expansion generates Nr + 1 round keys
    Ks: Key_Schedule(0..Nr(K));
    -- There are Nb words in a round key
    Ks_Len: Natural := Nb * (Nr(K) + 1) - 1;
    Ks_Words: array (0..Ks_Len) of Word;
    Temp: Word;
begin
    -- Copy key to start of key schedule
    for I in 0..Nk(K)-1 loop
        Ks_Words(I) := Word(K(4*I..4*I+3));
    end loop;
    -- Expand key
    for I in Nk(K)..Ks_Len loop
        Temp := Ks_Words(I-1);
        if I rem Nk(K) = 0 then
            Temp := Sub_Word(Rot_Word(Temp)) xor Rcon(I/Nk(K));
        elsif Nk(K) > 6 and I rem Nk(K) = 4 then
            Temp := Sub_Word(Temp);
        end if;
        Ks_Words(I) := Ks_Words(I - Nk(K)) xor Temp;
    end loop;
    -- Group words into round keys
    for I in Ks'Range loop
        Ks(I) := Words_To_Round_Key(Round_Key_Words(Ks_Words(4*I..4*I+3)));
    end loop;
    return Ks;
end Key_Expansion;

function Sub_Word(W: Word) return Word is
    Result: Word;
begin
    for I in Word_Index loop
        Result(I) := Sbox(Natural(W(I)));
    end loop;
    return Result;
end Sub_Word;

function Rot_Word(W: Word) return Word is
    Result: Word;
begin
    for I in Word_Index loop
        Result(I) := W(I + 1);
    end loop;
    return Result;
end Rot_Word;

function Words_To_Round_Key(Ws: Round_Key_Words) return Round_Key is
    Result: Round_Key;
begin
    for I in Result'Range loop
        Result(I) := Ws(I / 4)(Word_Index(I rem 4));
    end loop;
    return Result;
end Words_To_Round_Key;

end AES.Key_Expansion;