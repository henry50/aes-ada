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

-- untested
function Pad_Input(Input: Input_Buffer) return Input_Buffer is
    Nearest_16: Natural := ((Input'Length / 16) + 1) * 16;
    Result: Input_Buffer(0..Nearest_16-1);
    Padding: Byte := Byte(Nearest_16 - Input'Length);
begin
    Result(0..Input'Length-1) := Input;
    Result(Input'Length..Nearest_16-1) := (others => Padding);
    return Result;
end Pad_Input;

-- untested
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

-- untested
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