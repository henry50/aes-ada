with AES.Common;
with AES.Key_Expansion;

package body AES.Cipher is

function Cipher(St: State; K: Key) return State is
    use AES.Common;
    Schedule: Key_Schedule := AES.Key_Expansion.Key_Expansion(K);
    Result: State;
begin
    Result := Add_Round_Key(St, Schedule(0));
    for Round in 1..Nr(K)-1 loop
        Result := Sub_Bytes(Result);
        Result := Shift_Rows(Result);
        Result := Mix_Columns(Result);
        Result := Add_Round_Key(Result, Schedule(Round));
    end loop;
    Result := Sub_Bytes(Result);
    Result := Shift_Rows(Result);
    Result := Add_Round_Key(Result, Schedule(Nr(K)));
    return Result;
end Cipher;

function Sub_Bytes(St: State) return State is
begin
    return AES.Common.Sub_Bytes(St, Encrypt);
end Sub_Bytes;

function Shift_Rows(St: State) return State is
begin
    return AES.Common.Shift_Rows(St, Encrypt);
end Shift_Rows;

function Mix_Columns(St: State) return State is
    Result: State;
    function GM(A, B: Byte) return Byte renames AES.Common.Galois_Multiply;
begin
    for C in State_Col loop
        Result(0, C) := GM(2, St(0, C)) xor GM(3, St(1, C)) xor St(2, C) xor St(3, C);
        Result(1, C) := St(0, C) xor GM(2, St(1, C)) xor GM(3, St(2, C)) xor St(3, C);
        Result(2, C) := St(0, C) xor St(1, C) xor GM(2, St(2, C)) xor GM(3, St(3, C));
        Result(3, C) := GM(3, St(0, C)) xor St(1, C) xor St(2, C) xor GM(2, St(3, C));
    end loop;
    return Result;
end Mix_Columns;

end AES.Cipher;