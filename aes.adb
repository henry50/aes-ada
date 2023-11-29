with AES.AES_Cipher; use AES.AES_Cipher;
with AES.AES_Inv_Cipher; use AES.AES_Inv_Cipher;

package body AES is

function "xor"(Left, Right: State) return State is
    Result: State;
begin
    for I in 0..3 loop
        for J in 0..3 loop
            Result(i, j) := Left(i, j) xor Right(i, j);
        end loop;
    end loop;
    return Result;
end "xor";

function Block_To_State(Block: Input_Buffer) return State is
    St: State;
    Bl: Input_Buffer(0..15) := Block;
begin
    for I in 0..3 loop
        for J in 0..3 loop
            St(j, i) := Bl((4*I)+J);
        end loop;
    end loop;
    return St;
end Block_To_State;

function Pad_Input(Input: Input_Buffer) return Input_Buffer is
    Nearest_16: Natural := ((Input'Length / 16) + 1) * 16;
    Result: Input_Buffer(0..Nearest_16-1);
    Padding: Byte := Byte(Nearest_16 - Input'Length);
begin
    Result(0..Input'Length-1) := Input;
    Result(Input'Length..Nearest_16-1) := (others => Padding);
    return Result;
end Pad_Input;

function Input_To_States(Input: Input_Buffer) return States is
    Num_States: Natural := Input'Length / 16;
    Return_States: States(0..Num_States);
    Padded: Input_Buffer := Pad_Input(Input);
begin
    for I in Return_States'Range loop
        Return_States(I) := Block_To_State(
            Padded((16 * I)..((16*I)+15))
        );
    end loop;
    return Return_States;
end Input_To_States;

function State_To_Block(St: State) return Output_Buffer is
    Result: Output_Buffer(0..15);
begin
    for I in 0..3 loop
        for J in 0..3 loop
            Result((4*I)+J) := St(i, j);
        end loop;
    end loop;
    return Result;
end State_To_Block;

function States_To_Output(Output: States; Remove_Padding: Boolean) return Output_Buffer is
    Padding_Error: exception;
    Result_Buffer: Output_Buffer(0..(16 * Output'Length)-1);
begin
    for I in Output'Range loop
        Result_Buffer((16*I)..((16*I) + 15)) := State_To_Block(Output(I));
    end loop;
    if Remove_Padding then
    declare
        Padding: Natural := Natural(Result_Buffer'Last);
        Expected_Padding: Output_Buffer(0..Padding-1) := (others => Byte(Padding));
        Padding_Start: Natural := (16 * Output'Length) - 1 - Padding;
    begin
        if Result_Buffer(Padding_Start..Result_Buffer'Length-1)
              /= Expected_Padding or Padding /= Expected_Padding'Length then
            raise Padding_Error;
        else
            declare
                Unpadded_Result: Output_Buffer(0..Result_Buffer'Length-1-Padding)
                    := Result_Buffer(0..Padding_Start-1);
            begin
                return Unpadded_Result;
            end;
        end if;
    end;
    else
        return Result_Buffer;
    end if;
end States_To_Output;

function Key_Expansion(K: Key) return Key_Schedule is 
    Ks: Key_Schedule(0..(K'Length / 32) + 6 - 1);
begin
    return Ks;
end Key_Expansion;

function AES_Block(St: State; K: Key; Op: Operation) return State is
    Schedule: Key_Schedule := Key_Expansion(K);
begin
    return (case Op is
        when Encrypt => Cipher(St, Schedule),
        when Decrypt => Inv_Cipher(St, Schedule)
    );
end AES_Block;

function Generic_CBC(Input: Input_Buffer; K: Key; IV: Init_Vector; Op: Operation) return Output_Buffer is
    St: States := Input_To_States(Input);
    Output: States(0..St'Length-1);
    Prev: State := Block_To_State(Input_Buffer(IV));
    Remove_Padding: Boolean := (case Op is when Encrypt => false, when Decrypt => true);
begin
    for I in St'Range loop
        Output(I) := AES_Block(St(I) xor Prev, K, Op);
        Prev := Output(I);
    end loop;
    return States_To_Output(Output, Remove_Padding);
end Generic_CBC;

function AES_CBC_128(Input: Input_Buffer; K: AES_128_Key; IV: Init_Vector; Op: Operation) return Output_Buffer is
begin
    return Generic_CBC(Input, K, IV, Op);
end AES_CBC_128;

function AES_CBC_192(Input: Input_Buffer; K: AES_192_Key; IV: Init_Vector; Op: Operation) return Output_Buffer is
begin
    return Generic_CBC(Input, K, IV, Op);
end AES_CBC_192;

function AES_CBC_256(Input: Input_Buffer; K: AES_256_Key; IV: Init_Vector; Op: Operation) return Output_Buffer is
begin
    return Generic_CBC(Input, K, IV, Op);
end AES_CBC_256;

end AES;