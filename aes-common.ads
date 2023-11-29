private package AES.Common is

function Sub_Bytes(St: State;  Op: Operation) return State;
function Shift_Rows(St: State; Op: Operation) return State;

end AES.Common;