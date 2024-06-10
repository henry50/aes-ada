with AES.Common;
with AES.Key_Expansion;

package body AES.Inv_Cipher is

function Inv_Cipher(St: State; K: Key) return State is
    use AES.Common;
    Schedule: Key_Schedule := AES.Key_Expansion.Key_Expansion(K);
    Result: State;
begin
    Result := Add_Round_Key(St, Schedule(Nr(K)));
    for Round in reverse 1..Nr(K)-1 loop
        Result := Inv_Shift_Rows(Result);
        Result := Inv_Sub_Bytes(Result);
        Result := Add_Round_Key(Result, Schedule(Round));
        Result := Inv_Mix_Columns(Result);
    end loop;
    Result := Inv_Shift_Rows(Result);
    Result := Inv_Sub_Bytes(Result);
    Result := Add_Round_Key(Result, Schedule(0));
    return Result;
end Inv_Cipher;

function Inv_Sub_Bytes(St: State) return State is
begin
    return AES.Common.Sub_Bytes(St, Decrypt);
end Inv_Sub_Bytes;

function Inv_Shift_Rows(St: State) return State is
begin
    return AES.Common.Shift_Rows(St, Decrypt);
end Inv_Shift_Rows;

function Inv_Mix_Columns(St: State) return State is
    Result: State;
    function GM(X, Y: Byte) return Byte renames AES.Common.Galois_Multiply;
begin
    for C in State_Col loop
        Result(0, C) := GM(14, St(0, C)) xor GM(11, St(1, C)) xor GM(13, St(2, C)) xor GM(9, St(3, C));
        Result(1, C) := GM(9, St(0, C)) xor GM(14, St(1, C)) xor GM(11, St(2, C)) xor GM(13, St(3, C));
        Result(2, C) := GM(13, St(0, C)) xor GM(9, St(1, C)) xor GM(14, St(2, C)) xor GM(11, St(3, C));
        Result(3, C) := GM(11, St(0, C)) xor GM(13, St(1, C)) xor GM(9, St(2, C)) xor GM(14, St(3, C));
    end loop;
    return Result;
end Inv_Mix_Columns;

end AES.Inv_Cipher;