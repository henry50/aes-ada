with Ada.Text_IO; use Ada.Text_IO;
with AES.Util; use AES.Util;

package body AES.Internal_Util is

function Block_To_State(Block: Block_Bytes) return State is
    St: State;
    Bl: Block_Bytes := Block;
begin
    for I in State_Row loop
        for J in State_Col loop
            St(State_Row(J), State_Col(I)) := Bl((4*Natural(I))+Natural(J));
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

function Input_To_States(Input: Input_Buffer; Op: Operation) return States is
    Padded: Input_Buffer := (case Op is
        when Encrypt => Pad_Input(Input),
        when Decrypt => Input
    );
    Num_States: Natural := Padded'Length / 16;
    Result: States(0..Num_States-1);
begin
    for I in Result'Range loop
        Result(I) := Block_To_State(
            Padded((16 * I)..(16*I+15))
        );
    end loop;
    return Result;
end Input_To_States;

function State_To_Block(St: State) return Block_Bytes is
    Result: Block_Bytes;
begin
    for I in State_Row loop
        for J in State_Col loop
            Result((4*Natural(J))+Natural(I)) := St(I, J);
        end loop;
    end loop;
    return Result;
end State_To_Block;

function States_To_Output(Output: States; Op: Operation) return Output_Buffer is
    Padding_Error: exception;
    Result_Len: Natural := 16 * Output'Length - 1;
    Result: Output_Buffer(0..Result_Len);
begin
    -- Convert states to byte arrays and concatenate
    for I in Output'Range loop
        Result((16*I)..(16*I+15)) := State_To_Block(Output(I));
    end loop;
    if Op = Decrypt then
    declare
        Last_Block: Bytes := State_To_Block(Output(Output'Last));
        -- The last byte of the last block should be the padding and its length
        Padding: Byte := Last_Block(Last_Block'Last);
    begin
        -- If the padding isn't between 1 and 16 it isn't valid
        if Padding < 1 or Padding > 16 then
            raise Padding_Error;
        end if;
    declare
        -- The expected padding is the padding repeated by itself
        Expected_Padding: Bytes(0..Natural(Padding)-1) := (others => Padding);
        -- The expected padding starts Padding bytes from the end
        Expected_Padding_Start: Natural := 16 - Natural(Padding);
        -- Copy the result up to the start of padding
        Unpadded_Result: Output_Buffer := Result(0..Result_Len-Natural(Padding));
    begin
        if Last_Block(Expected_Padding_Start..Last_Block'Last) /= Expected_Padding then
            raise Padding_Error;
        end if;
        return Unpadded_Result;
    end;
    end;
    else
        return Result;
    end if;
end States_To_Output;

procedure Print_State(St: State) is
begin
    for I in State_Row loop
        for J in State_Col loop
            Put(Byte_To_Hex(St(I, J)));
            Put(" ");
        end loop;
        New_Line;
    end loop;
    New_Line;
end Print_State;

end AES.Internal_Util;