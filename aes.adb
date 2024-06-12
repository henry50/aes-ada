with AES.Cipher;
with AES.Inv_Cipher;
with AES.Internal_Util; use AES.Internal_Util;
with AES.Common; use AES.Common;
with AES.Test;

package body AES is

procedure Run_Tests is
begin
    AES.Test.Run_Tests;
end Run_Tests;

function "xor"(Left, Right: State) return State is
    Result: State;
begin
    for I in State_Row loop
        for J in State_Col loop
            Result(I, J) := Left(I, J) xor Right(I, J);
        end loop;
    end loop;
    return Result;
end "xor";

function AES_Block(Block: Block_Bytes; K: Key; Op: Operation) return Block_Bytes is
    St: State := Block_To_State(Block);
    Result: State := (case Op is
        when Encrypt => AES.Cipher.Cipher(St, K),
        when Decrypt => AES.Inv_Cipher.Inv_Cipher(St, K)
    );
begin
    return State_To_Block(Result);
end AES_Block;

function AES_Block_128(Input: Block_Bytes; K: AES_128_Key; Op: Operation) return Block_Bytes is
begin
    return AES_Block(Input, K, Op);
end AES_Block_128;

function AES_Block_192(Input: Block_Bytes; K: AES_192_Key; Op: Operation) return Block_Bytes is
begin
    return AES_Block(Input, K, Op);
end AES_Block_192;

function AES_Block_256(Input: Block_Bytes; K: AES_256_Key; Op: Operation) return Block_Bytes is
begin
    return AES_Block(Input, K, Op);
end AES_Block_256;

function AES_CBC(Input: Input_Buffer; K: Key; IV: Init_Vector; Op: Operation) return Output_Buffer is
    St: States := Input_To_States(Input, Op);
    Output: States(0..St'Length-1);
    Prev: State := Block_To_State(Input_Buffer(IV));
    begin
    for I in St'Range loop
        Output(I) := (case Op is
            when Encrypt => AES.Cipher.Cipher(St(I) xor Prev, K),
            when Decrypt => AES.Inv_Cipher.Inv_Cipher(St(I), K) xor Prev
        );
        Prev := (case Op is
            when Encrypt => Output(I),
            when Decrypt => St(I)
        );
    end loop;
    return States_To_Output(Output, Op);
end AES_CBC;

function AES_CBC_128(Input: Input_Buffer; K: AES_128_Key; IV: Init_Vector; Op: Operation) return Output_Buffer is
begin
    return AES_CBC(Input, K, IV, Op);
end AES_CBC_128;

function AES_CBC_192(Input: Input_Buffer; K: AES_192_Key; IV: Init_Vector; Op: Operation) return Output_Buffer is
begin
    return AES_CBC(Input, K, IV, Op);
end AES_CBC_192;

function AES_CBC_256(Input: Input_Buffer; K: AES_256_Key; IV: Init_Vector; Op: Operation) return Output_Buffer is
begin
    return AES_CBC(Input, K, IV, Op);
end AES_CBC_256;

end AES;