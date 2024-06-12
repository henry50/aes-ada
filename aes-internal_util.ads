private package AES.Internal_Util is

function Block_To_State(Block: Block_Bytes) return State;
function Input_To_States(Input: Input_Buffer; Op: Operation) return States;
function State_To_Block(St: State) return Block_Bytes;
function States_To_Output(Output: States; Op: Operation) return Output_Buffer;
procedure Print_State(St: State);

end AES.Internal_Util;