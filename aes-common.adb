with AES.Internal_Util; use AES.Internal_Util;

package body AES.Common is

-- Nk = number of 32-bit words in key
function Nk(K: Key) return Natural is
begin
    return Natural(K'Length / 4);
end Nk;

-- Nr = number of rounds
function Nr(K: Key) return Natural is
begin
    return Nk(K) + 6;
end Nr;

-- Multiplication of two bytes in GF(2^8)
-- Adapted from https://en.wikipedia.org/wiki/Finite_field_arithmetic#Rijndael
function Galois_Multiply(X, Y: Byte) return Byte is
    A: Byte := X;
    B: Byte := Y;
    P: Byte := 0;
    C: Byte;
begin
    loop
        -- If rightmost bit is set
        if (B and 1) = 1 then
            P := P xor A;
        end if;
        B := B / 2; -- B >>= 1
        C := A and 128; -- Leftmost bit of A is set?
        A := A * 2; -- A <<= 1
        if C = 128 then -- If leftmost bit of A was set
            A := A xor 16#1b#; -- 0x1b corresponds to irreducible polynomial
        end if;
        exit when A = 0 or B = 0;
    end loop;
    return P;
end;

function Sub_Bytes(St: State;  Op: Operation) return State is
    S: S_Box := (case Op is when Encrypt => Sbox, when Decrypt => I_Sbox);
    Result: State;
begin
    for I in State_Row loop
        for J in State_Col loop
            Result(I, J) := S(Natural(St(I, J)));
        end loop;
    end loop;
    return Result;
end Sub_Bytes;

function Shift_Rows(St: State; Op: Operation) return State is
    Result: State;
begin
    for I in State_Row loop
        for J in State_Col loop
            case Op is
                when Encrypt => Result(I, J) := St(I, J + State_Col(I));
                when Decrypt => Result(I, J) := St(I, J - State_Col(I));
            end case;
        end loop;
    end loop;
    return Result;
end Shift_Rows;

function Add_Round_Key(St: State; Rk: Round_Key) return State is
    RkSt: State := Block_To_State(Rk);
begin
    return St xor RkSt;
end Add_Round_Key;

end AES.Common;