private package AES.AES_Cipher is
    function Cipher(St: State; Schedule: Key_Schedule) return State;
private
    function Sub_Bytes(St: State) return State;
    function Shift_Rows(St: State) return State;
    function Mix_Columns(St: State) return State;
end AES.AES_Cipher;